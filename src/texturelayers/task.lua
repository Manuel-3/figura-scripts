-- Task by manuel_2867

local INSTRUCTION_CUTOFF_PERCENT = 0.7

local stack = {}

local function step(max)
    repeat
        local current = stack[#stack]
        if not stack[#stack] then return end
        if current.i > current.finish then
            table.remove(stack,#stack)
            if current.callback then
                current.callback()
            end
        else
            current.process(current.i)
            current.i = current.i + 1
        end
    until avatar:getCurrentInstructions()/max > INSTRUCTION_CUTOFF_PERCENT
end

function events.entity_init() -- register late
    local maxrender = avatar:getMaxRenderCount()
    local maxtick = avatar:getMaxTickCount()
    local frame = 0
    local lastframe = 0
    function events.tick() step(maxtick) end
    function events.world_render() frame = frame + 1 end
    function events.render()
        if lastframe == frame then return end
        lastframe = frame
        step(maxrender)
    end
end

---Simple progress bar shown in the ActionBar
---@param name string
---@param target number The progress ranges from 0 to `target`. This should be the total amount of steps youre processing.
---@param length number? How many characters the progress bar is, defaults to 15 characters.
---@return fun(amount: number?) Returns the progress function, call it to increase the progress. When all your processing is done the total progress should equal `target`.
local function ProgressBar(name, target, length)
    if not host:isHost() then return function()end end
    length = length or 15
    local val = 0
    local function progress(i)
        val = val + (i or 1)
        local perc = val/target
        local visual = {}
        table.insert(visual,{text=name,color="yellow"})
        table.insert(visual,{text=string.format(" %02d%% ",100*perc),color="white"})
        for _ = 1, perc*length do
            table.insert(visual,{text="=",color="green"})
        end
        for _ = 1, math.ceil(length-perc*length) do
            table.insert(visual,{text="-",color="gray"})
        end
        host:setActionbar(toJson{visual})
    end
    return progress
end

--- Add a new Task to the stack. Tasks are basically async for loops.
--- The process function should handle a small chunk of the overall work you need to do.
--- You can nest Tasks by making new ones inside of the process function.
--- Execution of tasks is done as fast as possible using both tick and render events.
--- System tries to use the remaining available instructions, cutoff before limit is reached can be changed at the top of the `task.lua` file.
--- These events are registered in entity_init to run after all other registered events, because the system uses up all the remaining instructions (up to the cutoff).
--- Example
--- ```
--- Task(1,5,function(i)
---     --code
--- end,
--- function()
---     --done
--- end)
--- ```
--- basically equivalent to
--- ```
--- for i = 1, 5 do
---     --code
--- end
--- --done
--- ```
---@param start number Lower bound of loop (inclusive).
---@param finish number Upper bound of loop (inclusive).
---@param process fun(i: number) Loop body, gets i variable like a regular for loop.
---@param callback function When the task is done, calls this function.
local function Task(_, start,finish,process,callback)
    table.insert(stack,{process=process,callback=callback,i=start,finish=finish})
end

return setmetatable({ProgressBar=ProgressBar},{__call=Task})