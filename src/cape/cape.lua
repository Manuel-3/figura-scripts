-- Cape by manuel_2867
cape_rotation = vec(-6,0,0)

local cape_rot = vec(0,0,0)
local _cape_rot = cape_rot
local _yaw = 0
local bobt = 0

function events.entity_init()
    _yaw = player:getBodyYaw()+90
end

function events.tick()
    local velocity = player:getVelocity()
    local y = math.max(velocity.y,-1)
    velocity.y = 0
    local length = velocity:length()
    bobt = bobt + length * 3.5
    local bobbing = math.sin(bobt) * length * 40 * (player:isOnGround() and 1 or 0)
    local yaw = player:getBodyYaw()+90
    local dir = vec(math.cos(math.rad(yaw)), 0, math.sin(math.rad(yaw)))
    local diff = math.clamp((dir:copy():cross(velocity)*300).y+(yaw-_yaw)*length*13, -10, 10)
    local x = bobbing + math.min(0,math.max(-80, -6 - length * math.sign(velocity:dot(dir)) * 160) + y * 31 + math.abs(diff))
    local xz = math.lerp(cape_rot.y,diff, 0.3)
    _cape_rot = cape_rot
    cape_rot = vec(math.lerp(cape_rot.x,x,0.3), xz, xz)
    _yaw = yaw
end

function events.render(delta)
    cape_rotation = math.lerp(_cape_rot, cape_rot, delta)
end