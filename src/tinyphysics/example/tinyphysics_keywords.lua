-- local axisAdjustment = 0
local enabled = true
------------------------
if not enabled then return end
local objects = require "./tinyphysics_core"
local function extract(s)
    if s:match("^tinyphys") then
        local values = {
            x=true,
            z=true,
            l=16,
            g=1,
            d=1,
            a=0
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
        helper1:setRot(-180,-values.a,-180)
        bone:setRot(180,values.a,180)
        objects[#objects+1] = {
            part=helper2,
            helper=helper1,
            start=vec(0,0,0),
            pos=vec(0,0,0),
            _pos=vec(0,0,0),
            length=values.l/16*math.playerScale,
            parent=parent,
            gravity=parent:partToWorldMatrix():invert():applyDir(bone:partToWorldMatrix():applyDir(0,-1,0):normalized()*0.08*values.g),
            drag = 0.06*values.d,
            x=values.x,
            z=values.z,
        }
    end
    for _, child in ipairs(bone:getChildren()) do
        walk(child,bone)
    end
end
function events.entity_init()
    walk(models)
end