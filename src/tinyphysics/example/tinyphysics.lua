-- todo
-- make the x and z rotation locks actually work, currently only setting object.x and object.z to true or false

local objects = {}

local function extract(s)
    if s:match("^tinyphys") then
        local values = {
            x=true,
            z=true,
            l=16,
            g=1,
            a=1,
        }
        local data = s:match("^tinyphys(.*)")
        if data then
            for match in data:gmatch("([0-9.]-%l)") do
                local value, type = match:match("([0-9.]-)(%l)")
                if type == "x" or type == "z" then
                    values[type] = false
                else
                    values[type] = tonumber(value)
                end
            end
        end
        if values.x and values.z then
            values.x = false
            values.z = false
        end
        return values
    end
end

---@param bone ModelPart
local function walk(bone,parent)
    local name = bone:getName():lower()
    if name:match("^tinyphys") then
        local values = extract(name)
        local helper1 = bone:newPart(bone:getName().."Helper1"):moveTo(parent)
        local helper2 = bone:newPart(bone:getName().."Helper2"):moveTo(helper1)
        bone:moveTo(helper2)
        helper1:setRot(0,-90,0)
        bone:setRot(0,90,0)
        objects[#objects+1] = {
            part=helper2,
            helper=helper1,
            start=vec(0,0,0),
            pos=vec(0,0,0),
            _pos=vec(0,0,0),
            length=values.l/16*math.playerScale,
            gravity=vec(0,-0.08*values.g,0),
            airResistance = 0.06*values.a,
            x=values.x,
            z=values.z,
        }
        -- logTable(objects[#objects])
    end
    for _, child in ipairs(bone:getChildren()) do
        walk(child,bone)
    end
end
walk(models)

function events.tick()
    for _, object in ipairs(objects) do
        local mat = object.helper:partToWorldMatrix()
        local start = mat:apply()
        local pos = object.pos
        local airResistance = object.airResistance
        local newpos = pos + ((pos - object._pos) + object.gravity - (start - object.start) * airResistance) * (1 - airResistance)
        object.start = start
        object._pos = pos
        object.pos = start + (newpos - start):normalized() * object.length
    end
end

local lerp = math.lerp
local atan2 = math.atan2
function events.post_render(delta)
    for _, object in ipairs(objects) do
        local pos = lerp(object._pos,object.pos,delta)
        local dir = object.helper:partToWorldMatrix():invert():apply(pos)
        local rot = vec(-atan2(dir.z, dir.xy:length()), 0, atan2(dir.y, dir.x) + 1.57)*57.29577
        object.part:setRot(rot)
    end
end

return objects