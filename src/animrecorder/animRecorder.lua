local lib = {}

---@class AnimationRecording
local AnimationRecording = {}

local function deepCopy(part)
    local copy = part:copy(part:getName())
    for _, child in ipairs(part:getChildren()) do
        copy:removeChild(child)
        deepCopy(child):moveTo(copy)
    end
    return copy
end

lib.deepCopy = deepCopy

---@param animation Animation
---@param modelpart ModelPart
---@param callback fun(recording: AnimationRecording)
function lib.record(animation, modelpart, callback)
    local recording = {}
    local function capture(currentPart, frame)
        if currentPart:getType()~="GROUP" then return end
        local idx = currentPart:getName()
        frame[idx] = frame[idx] or {}
        frame[idx].pos = currentPart:getAnimPos()
        frame[idx].rot = currentPart:getAnimRot()
        frame[idx].scale = currentPart:getAnimScale()
        for _, child in ipairs(currentPart:getChildren()) do
            capture(child, frame)
        end
    end
    local t = 0
    local function tick()
        if t == 0 then
            animation:setTime(0):play()
        elseif (t-1)/20 >= animation:getLength() then
            events.tick:remove(tick)
            callback(recording)
            return
        else
            recording[t] = {}
            capture(modelpart, recording[t])
        end
        t = t + 1
    end
    events.tick:register(tick)
end

---@param recording AnimationRecording
---@param modelpart ModelPart
---@param mode Animation.loopMode
function lib.play(recording, modelpart, mode)
    local function apply(currentPart, frame, nextFrame, delta)
        if currentPart:getType()~="GROUP" then return end
        local idx = currentPart:getName()
        currentPart:setPos(math.lerp(frame[idx].pos,nextFrame[idx].pos,delta))
        currentPart:setOffsetRot(math.lerp(frame[idx].rot,nextFrame[idx].rot,delta))
        currentPart:setOffsetScale(math.lerp(frame[idx].scale,nextFrame[idx].scale,delta))
        for _, child in ipairs(currentPart:getChildren()) do
            apply(child, frame, nextFrame, delta)
        end
    end
    local function clear(currentPart)
        if currentPart:getType()~="GROUP" then return end
        currentPart:setPos(0,0,0)
        currentPart:setOffsetRot(0,0,0)
        currentPart:setOffsetScale(1,1,1)
        for _, child in ipairs(currentPart:getChildren()) do
            clear(child)
        end
    end
    local t = 1
    local function render(delta)
        if t == #recording then
            if mode ~= "LOOP" then
                events.render:remove(render)
                delta = 0
                if mode == "ONCE" then
                    clear(modelpart)
                    return
                end
            end
        end
        local nextt = t % #recording + 1
        apply(modelpart, recording[t], recording[nextt], delta)
    end
    local function tick()
        if t == #recording then
            if mode ~= "LOOP" then
                events.tick:remove(tick)
                return
            end
        end
        t = t % #recording + 1
    end
    events.tick:register(tick)
    events.render:register(render)
end

return lib