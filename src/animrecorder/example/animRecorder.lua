local ENABLE_WARNINGS = true
local SCRIPT_NAME = ({...})[#{...}]..".lua"

local lib = {}

---@class Transform
---@field pos Vector3
---@field rot Vector3
---@field scale Vector3
local Transform = {}

---@alias RecordedFrame table<string, Transform>

---@class AnimationRecording
---@field [number] RecordedFrame
---@field name string
---@field blend number|nil Between 0 and 1 just like regular animation blend
local AnimationRecording = {}

--- Deep copy model parts.
---@param part ModelPart
---@return ModelPart
function lib.deepCopy(part)
    local copy = part:copy(part:getName())
    for _, child in ipairs(part:getChildren()) do
        copy:removeChild(child)
        lib.deepCopy(child):moveTo(copy)
    end
    return copy
end

--- Plays the animation and records it from the model part, when done calls the callback function passing the finished recording.
---@param animation Animation
---@param modelpart ModelPart
---@param callback fun(recording: AnimationRecording)
function lib.record(animation, modelpart, callback)
    local recording = {name=animation:getName()}
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
        if client:isPaused() then return end
        if t == 0 then
            animation:setTime(0):play()
        elseif (t-1)/20 >= animation:getLength() then
            events.tick:remove(tick)
            callback(recording)
            return
        else
            recording[t] = {}
            host:setActionbar('Recording "'..animation:getName()..'" '..t..'/'..math.floor(animation:getLength()*20))
            capture(modelpart, recording[t])
        end
        t = t + 1
    end
    events.tick:register(tick)
end

--- Delete all position, rotation, and scale values of a model part group and all child groups.
---@param part ModelPart
function lib.clear(part)
    if part:getType()~="GROUP" then return end
    part:setPos(0,0,0)
    part:setOffsetRot(0,0,0)
    part:setOffsetScale(1,1,1)
    for _, child in ipairs(part:getChildren()) do
        lib.clear(child)
    end
end

--- Helper function to apply all the animation values of a recorded frame to a model part and its children groups
---@param part ModelPart
---@param frame RecordedFrame
---@param nextFrame RecordedFrame
---@param delta number Render delta
---@param blend number|table<string, number>|nil Blend amount between 0 and 1 or a table mapping group names to individual blend amounts
---@param name string|nil Animation name only used for warning message
function lib.applyFrame(part, frame, nextFrame, delta, blend, name)
    blend = blend or 1
    name = name or "Unnamed"
    if part:getType()~="GROUP" then return end
    local idx = part:getName()
    if frame[idx] then
        local blendAmount = blend
        if type(blend) == "table" then
            blendAmount = blend[idx] or 1
        end
        part:setPos(blendAmount*math.lerp(frame[idx].pos,nextFrame[idx].pos,delta))
        part:setOffsetRot(blendAmount*math.lerp(frame[idx].rot,nextFrame[idx].rot,delta))
        part:setOffsetScale(blendAmount*math.lerp(frame[idx].scale,nextFrame[idx].scale,delta):add(-1,-1,-1)+vec(1,1,1))
    elseif ENABLE_WARNINGS then
        logJson(toJson{color='yellow',text='Warning: The animation recording of "'..name..'" does not have a "'..idx..'" group in it. Did you apply it to the wrong group or did you forget to remap a group name? To disable warnings set ENABLE_WARNINGS to false at the top of '..SCRIPT_NAME..'.\n'})
        ENABLE_WARNINGS = false
    end
    for _, child in ipairs(part:getChildren()) do
        lib.applyFrame(child, frame, nextFrame, delta, blend, name)
    end
end

--- Play a recorded animation on a model part
---@param recording AnimationRecording
---@param modelpart ModelPart
---@param mode Animation.loopMode|nil Default is "LOOP"
function lib.play(recording, modelpart, mode)
    mode = mode or "LOOP"
    local t = 1
    local function render(delta)
        if client:isPaused() then return end
        if t == #recording then
            if mode ~= "LOOP" then
                events.render:remove(render)
                delta = 0
                if mode == "ONCE" then
                    lib.clear(modelpart)
                    return
                end
            end
        end
        local nextt = t % #recording + 1
        lib.applyFrame(modelpart, recording[t], recording[nextt], delta, recording.blend, recording.name)
    end
    local function tick()
        if client:isPaused() then return end
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

--- Bake a recording into lua code, will be copied into the clipboard
---@param recording AnimationRecording
function lib.bake(recording)
    local function serialize(o)
        if type(o) == "table" then
            local str = '{'
            for key, value in pairs(o) do
                str = str .. key .. '=' .. serialize(value)
            end
            str = str .. '},'
            return str
        elseif type(o) == "Vector3" then
            return 'vec(' .. o.x .. ',' .. o.y .. ',' .. o.z .. '),'
        end
    end
    local str = 'local recording = {name="'..recording.name..'",'
    for _, value in ipairs(recording) do
        str = str .. serialize(value)
    end
    str = str .. "}"
    host:setClipboard(str)
    host:setActionbar("Copied recording to clipboard. You can now paste it into your script.")
end

--- Remap group names in the animation recording.
--- Does not mutate the input. Returns remapped recording.
---@param recording AnimationRecording
---@param remappings table<string, string>
---@return AnimationRecording
function lib.remap(recording,remappings)
    local remapped = {name=recording.name}
    for i=1,#recording do
        local oldFrame = recording[i]
        local newFrame = {}
        for oldKey, oldValue in pairs(oldFrame) do
            local key = remappings[oldKey] or oldKey
            newFrame[key] = {
                pos = oldValue.pos:copy(),
                rot = oldValue.rot:copy(),
                scale = oldValue.scale:copy(),
            }
        end
        remapped[i] = newFrame
    end
    return remapped
end

return lib