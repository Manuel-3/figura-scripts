-- todo
-- make the x and z rotation locks actually work, currently only setting object.x and object.z to true or false

local objects = {}
local lerp = math.lerp
local atan2 = math.atan2
function events.tick()
    for _, object in ipairs(objects) do
        local mat = object.helper:partToWorldMatrix()
        local start = mat:apply()
        local pos = object.pos
        local drag = object.drag
        local globalgrav = object.parent:partToWorldMatrix():applyDir(object.gravity)
        -- local newpos = pos + (pos - object._pos) + globalgrav
        local newpos = pos + ((pos - object._pos) + globalgrav - (start - object.start) * drag) * (1 - drag)
        

        -- local localpos = object.helper:partToWorldMatrix():invert():apply(newpos)
        -- localpos.y = 0
        -- newpos = object.helper:partToWorldMatrix():apply(localpos)


        object.start = start
        object._pos = pos
        object.pos = start + (newpos - start):normalized() * object.length
    end
end
local _rotz = 0
function events.post_render(delta)
    for _, object in ipairs(objects) do
        local pos = lerp(object._pos,object.pos,delta)
        local dir = object.helper:partToWorldMatrix():invert():apply(pos)
        local rot = vec(-atan2(dir.z, dir.xy:length()),0,atan2(dir.y, dir.x) + 1.57)*57.29577


        -- if object.x then
        --     rot.x = 0
        -- end
        -- if object.z then
        --     rot.z = 0
        -- end
        
        
        -- local rotz = rot.z
        -- if math.abs(_rotz-rotz) > 0.5 then
        --     log(rot)
        -- end
        -- _rotz = rotz
        object.part:setRot(rot)
    end
end
return objects