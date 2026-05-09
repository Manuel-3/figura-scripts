---- Run Later by manuel_2867 ----
local tmrs={}
local t=0
---Schedules a function to run after a certain amount of ticks
---@param ticks number|fun(time: number):boolean Amount of ticks to wait, or a predicate function to check each tick until it returns true. The predicate receives the waited time so far as the only parameter.
---@param next function? Function to run after amount of ticks, or after the predicate function returned true
local function runLater(ticks,next)
    local x=type(ticks)=="number"
    table.insert(tmrs,{t=x and t+ticks or t,p=x and function()return true end or ticks,n=next or function()end})
end
function events.TICK()
    t=t+1
    for key,timer in pairs(tmrs) do
        if timer.p(t-timer.t) and t >= timer.t then
            timer.n()
            tmrs[key]=nil
        end
    end
end
return runLater