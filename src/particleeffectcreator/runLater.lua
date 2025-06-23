---- Run Later by manuel_2867 ----
local tmrs={}
local t=0
---Schedules a function to run after a certain amount of ticks
---@param ticks number|function Amount of ticks to wait, or a predicate function to check each tick until it returns true
---@param next function Function to run after amount of ticks, or after the predicate function returned true
local function runLater(ticks,next)
    local x=type(ticks)=="number"
    table.insert(tmrs,{t=x and t+ticks,p=x and function()end or ticks,n=next})
end
function events.TICK()
    t=t+1
    for key,timer in pairs(tmrs) do
        if timer.p()or(timer.t and t >= timer.t)then
            timer.n()
            tmrs[key]=nil
        end
    end
end
return runLater