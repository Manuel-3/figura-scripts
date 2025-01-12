---- Run Later by manuel_2867 ----
local tmrs={}
local getT = client.getSystemTime
---Schedules a function to run after a certain amount of milliseconds
---WARNING: Uses WORLD_RENDER so whatever you do it will most likely ERROR on the default permission setting as the limit is very low!
---Ideally use the regular tick based runLater instead of this!
---This function also isn't perfectly accurate, as it depends on the framerate, therefore in the callback the amount of overshot milliseconds is passed in.
---@param ms number|function Amount of milliseconds to wait, or a predicate function to check each frame until it returns true
---@param next fun(delta: number) Function to run after amount of milliseconds, or after the predicate function returned true, overshot milliseconds are passed in
local function runLaterMs(ms,next)
    local x=type(ms)=="number"
    table.insert(tmrs,{t=x and getT()+ms,p=x and function()end or ms,n=next})
end
function events.WORLD_RENDER()
    local t = getT()
    for key,timer in pairs(tmrs) do
        if timer.p()or(timer.t and t >= timer.t)then
            timer.n(t-timer.t)
            tmrs[key]=nil
        end
    end
end
return runLaterMs