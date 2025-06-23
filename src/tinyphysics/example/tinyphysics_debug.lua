local size = 2
local enabled = true
--------------------
if not enabled then return end
size = math.max(1,math.floor(size))
local objects = require "./tinyphysics"
local white = textures:newTexture("whitepixel",1,1):setPixel(0,0,vec(1,1,1))
local red = textures:newTexture("redpixel",1,1):setPixel(0,0,vec(1,0,0))
local green = textures:newTexture("greenpixel",1,1):setPixel(0,0,vec(0,1,0))
function events.post_render(delta)
    for _, object in ipairs(objects) do
        object.task3_part = object.task3_part or models:newPart("debug","HUD")
        object.task3 = object.task3 or object.task3_part:newSprite("debug"):setTexture(white,size,size)
        object.task1_part = object.task1_part or models:newPart("debug","HUD")
        object.task1 = object.task1 or object.task1_part:newSprite("debug"):setTexture(green,size,size)
        object.task2_part = object.task2_part or models:newPart("debug","HUD")
        object.task2 = object.task2 or object.task2_part:newSprite("debug"):setTexture(red,size,size)
        local start = object.helper:partToWorldMatrix():apply()
        local dir = (math.lerp(object._pos,object.pos,delta)-start):normalized()
        local pos = start+dir*object.length
        ---@diagnostic disable: param-type-mismatch
        object.task1:setPos(((vectors.worldToScreenSpace(start).xy_ * 0.5 + 0.5) * -client:getScaledWindowSize().xy_)+vec(size/2,size/2,size/2))
        object.task2:setPos(((vectors.worldToScreenSpace(pos).xy_ * 0.5 + 0.5) * -client:getScaledWindowSize().xy_)+vec(size/2,size/2,size/2))
        object.task3:setPos(vec(size/2,size/2,size/2))
        local linedir = (object.task1:getPos()-object.task2:getPos())
        object.task3:setScale(1,linedir:length()/size,1)
        object.task3_part:setPos(((vectors.worldToScreenSpace(start).xy_ * 0.5 + 0.5) * -client:getScaledWindowSize().xy_)-linedir:normalized())
        object.task3_part:setRot(0,0,math.deg(math.atan2(linedir.y,linedir.x)-math.pi/2))
    end
end