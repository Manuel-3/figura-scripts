-- Task by manuel_2867

local INSTRUCTION_CUTOFF_PERCENT = 0.7
local DISABLE_PROGRESS_BARS = false
local ENABLE_EVENT_WARNINGS = true

local stack = {}
local render_events = {}
local events_registered = false

-- Event log for warnings, the following lines can be deleted if you wish to do so
local filename = ({...})[2]
local function check_event(event)
    if events_registered and ENABLE_EVENT_WARNINGS then
        event = string.upper(event)
        if event == "TICK" or event == "RENDER" then
            ENABLE_EVENT_WARNINGS = false
            logJson(toJson{{text='Warning! ',color='yellow'},{text=filename..'.lua was not the last script to register a '..event..' event! For task.lua to function properly, it must have the last TICK and RENDER events, otherwise you are risking "overran resource limits" errors. Make sure your TICK and RENDER events are registered before the ENTITY_INIT event has run. You can get rid of this warning by going into task.lua and removing the event log section which is marked with comments.\n',color='white'}})
        end
    end
end
local figuraMetatablesEventsAPI__newindex = figuraMetatables.EventsAPI.__newindex
local figuraMetatablesEventsAPI__index = figuraMetatables.EventsAPI.__index
figuraMetatables.EventsAPI.__newindex = function(self,key,...)
    check_event(key)
    return figuraMetatablesEventsAPI__newindex(self,key,...)
end
figuraMetatables.EventsAPI.__index = function(self,key)
    check_event(key)
    return figuraMetatablesEventsAPI__index(self,key)
end
-- Event log end

--- Create new render event that only runs once per world render.
--- Prevents resource overrun error that can usually happen if render event is called multiple
--- times per frame in different contexts.
---@param f fun(delta: number, ctx: string, matrix: Matrix4)
local function SingleRender(f)
    table.insert(render_events, f)
end

--- Perform as many processes as allowed by max
---@param max number
local function step(max)
    repeat
        local current = stack[#stack]
        if not stack[#stack] then return end
        if current.finish and current.i > current.finish or current.condition and not current.condition() then
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
    function events.render(delta, ctx, matrix)
        if lastframe == frame then return end
        lastframe = frame
        for _, render in ipairs(render_events) do
            render(delta, ctx, matrix)
        end
        step(maxrender)
    end
    events_registered = true
end

---Simple progress bar shown in the ActionBar
---@param name string
---@param target number The progress ranges from 0 to `target`. This should be the total amount of steps youre processing.
---@param length number? How many characters the progress bar is, defaults to 15 characters.
---@return fun(amount: number?) Returns the progress function, call it to increase the progress. When all your processing is done the total progress should equal `target`.
local function ProgressBar(name, target, length)
    if DISABLE_PROGRESS_BARS or not host:isHost() then return function()end end
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
---@param callback? function When the task is done, calls this function.
local function For(_, start,finish,process,callback)
    table.insert(stack,{process=process,callback=callback,i=start,finish=finish})
end

---@param condition fun():boolean The while condition
---@param process fun(i: number) Loop body, gets i variable like a regular for loop.
---@param callback? function When the task is done, calls this function.
local function While(condition,process,callback)
    table.insert(stack,{process=process,callback=callback,i=1,condition=condition})
end

return setmetatable({ProgressBar=ProgressBar,While=While,For=For,SingleRender=SingleRender},{__call=For})
