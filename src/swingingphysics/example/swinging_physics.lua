-- Swinging Physics by Manuel_
modName = "manuel_.swinging_physics"

local SwingingPhysics = {}

local gravity = 0.05
local friction = 0.1
local centrifugalForce = 0.2

local sinr = math.sin
local cosr = math.cos
local rad = math.rad
local deg = math.deg
local lerp = math.lerp
local atan = math.atan
local getVelocity
local getPlayerRot
local getBodyYaw
local getLookDir
local playerVelocity
local getPose
local function sin(x)
    return sinr(rad(x))
end
local function cos(x)
    return cosr(rad(x))
end

local moveAngle = 0
local playerSpeed = 0
local _yRotHead = 0
local yRotHead = 0
local forceHead = 0
local downHead = vec(0,0,0)
local _yRotBody = 0
local yRotBody = 0
local forceBody = 0
local downBody = vec(0,0,0)

function events.entity_init()
    getVelocity = player.getVelocity
    getPlayerRot = player.getRot
    getLookDir = player.getLookDir
    getBodyYaw = player.getBodyYaw
    getPose = player.getPose
    _yRotHead = getPlayerRot(player).y
    yRotHead = _yRotHead
    _yRotBody = getBodyYaw(player)
    yRotBody = _yRotBody
    playerVelocity = getVelocity(player)
    playerVelocity.y = 0
end

-- Returns movement angle relative to look direction (2D top down view, ignores Y)
-- Requires velocity vector variable containing player velocity
-- 0   : forward
-- 45  : left forward
-- 90  : left
-- 135 : left backwards
-- 180 : backwards
-- -135: right backwards
-- -90 : right
-- -45 : right forward
local function playerMoveAngle()
    local lookdir = getLookDir(player)
    lookdir.y = 0
    local m = 90+deg(atan(playerVelocity.z/playerVelocity.x))
    if playerVelocity.x < 0 then
        m = m + 180
    end
    local l = 90+deg(atan(lookdir.z/lookdir.x))
    if lookdir.x < 0 then
        l = l + 180
    end
    local ret = l - m
    if ret ~= ret then
        return 0
    else
        return ret
    end 
end

function events.tick()
    moveAngle = playerMoveAngle()
    playerVelocity = getVelocity(player)
    playerVelocity.y = 0
    playerSpeed = playerVelocity:length()*6

    local playerRot = getPlayerRot(player)

    _yRotHead = yRotHead
    yRotHead = playerRot.y
    forceHead = (_yRotHead - yRotHead)/8
    downHead.x = playerRot.x

    _yRotBody = yRotBody
    yRotBody = getBodyYaw(player)
    forceBody = (_yRotBody - yRotBody)/8
    if getPose(player) == "CROUCHING" then
        downBody.x = deg(0.5)
    else
        downBody.x = 0
    end
end

---@class SwingHandler
local SwingHandler = {
    ---@param enabled boolean
    setEnabled = function(self, enabled) end
}

--- Adds swinging physics to a part that is attached to the head
---@param part ModelPart The model part that should swing
---@param dir number Angle in degree, where the part is located relative to the center of the head. Imagine a stick pointing out in that direction with the model part hanging from its end. 0 means forward, 45 means diagonally forward and left, 90 means straight left and so on
---@param limits table|nil Limits the rotation of the part to make it appear like its colliding with something. Format: {xLow, xHigh, yLow, yHigh, zLow, zHigh} (optional)
---@param root ModelPart|nil Required if it is part of a chain. Note that the first chain element does not need this root parameter, and does also not need the depth parameter. Only following chain links need it.
---@param depth number|nil An integer that should increase by 1 for each consecutive chain link after the root. The root itself doesnt need this parameter. This increases the friction which makes it look more realistic.
---@return SwingHandler
function SwingingPhysics.swingOnHead(part, dir, limits, root, depth)
    assert(part, "Model Part does not exist!")
    local _rot = vec(0,0,0)
    local rot = vec(0,0,0)
    local velocity = vec(0,0,0)
    if depth == nil then depth = 0 end
    local fric = friction*math.pow(1.5, depth)
    local handler = {
        ---@type SwingHandler
    }
    handler.enabled = true
    ---@param enabled boolean
    function handler:setEnabled(enabled)
        self.enabled = enabled
        if not self.enabled then
            rot = vec(0,0,0)
            _rot = rot
            part:setOffsetRot(rot)
        end
    end
    function events.tick()
        if not handler.enabled then return end

        _rot = rot

        local grav
        if root ~= nil then
            grav = ((downHead - root:getOffsetRot()) - rot) * gravity
        else
            grav = (downHead - rot) * gravity
        end
        
        velocity = velocity + grav + vec(
            sin(dir)*forceHead-cos(moveAngle)*playerSpeed+cos(dir)*math.abs(forceHead)*centrifugalForce,
            0,
            cos(dir)*forceHead+sin(moveAngle)*playerSpeed-sin(dir)*math.abs(forceHead)*centrifugalForce
        )
        velocity = velocity * (1-fric)

        rot = rot + velocity
    end
    if limits ~= nil then function events.tick()
        if not handler.enabled then return end
        if rot.x < limits[1] then rot.x = limits[1] velocity.x = 0 end
        if rot.x > limits[2] then rot.x = limits[2] velocity.x = 0 end
        if rot.y < limits[3] then rot.y = limits[3] velocity.y = 0 end
        if rot.y > limits[4] then rot.y = limits[4] velocity.y = 0 end
        if rot.z < limits[5] then rot.z = limits[5] velocity.z = 0 end
        if rot.z > limits[6] then rot.z = limits[6] velocity.z = 0 end
    end end
    function events.render(delta)
        if not handler.enabled then return end

        part:setOffsetRot(lerp(_rot, rot, delta))
    end
    return handler
end
--- Adds swinging physics to a part that is attached to the body
---@param part ModelPart The model part that should swing
---@param dir number Angle in degree, where the part is located relative to the center of the head. Imagine a stick pointing out in that direction with the model part hanging from its end. 0 means forward, 45 means diagonally forward and left, 90 means straight left and so on
---@param limits table|nil Limits the rotation of the part to make it appear like its colliding with something. Format: {xLow, xHigh, yLow, yHigh, zLow, zHigh} (optional)
---@param root ModelPart|nil Required if it is part of a chain. Note that the first chain element does not need this root parameter, and does also not need the depth parameter. Only following chain links need it.
---@param depth number|nil An integer that should increase by 1 for each consecutive chain link after the root. The root itself doesnt need this parameter. This increases the friction which makes it look more realistic.
---@return SwingHandler
function SwingingPhysics.swingOnBody(part, dir, limits, root, depth)
    assert(part, "Model Part does not exist!")
    local _rot = vec(0,0,0)
    local rot = vec(0,0,0)
    local velocity = vec(0,0,0)
    if depth == nil then depth = 0 end
    local fric = friction*math.pow(1.5, depth)
    local handler = {
        ---@type SwingHandler
    }
    handler.enabled = true
    ---@param enabled boolean
    function handler:setEnabled(enabled)
        self.enabled = enabled
        if not self.enabled then
            rot = vec(0,0,0)
            _rot = rot
            part:setOffsetRot(rot)
        end
    end
    function events.tick()
        if not handler.enabled then return end

        _rot = rot

        local grav
        if root ~= nil then
            grav = ((downBody - root:getOffsetRot()) - rot) * gravity
        else
            grav = (downBody - rot) * gravity
        end

        velocity = velocity + grav + vec(
            sin(dir)*forceBody-cos(moveAngle)*playerSpeed+cos(dir)*math.abs(forceBody)*centrifugalForce,
            0,
            cos(dir)*forceBody+sin(moveAngle)*playerSpeed-sin(dir)*math.abs(forceBody)*centrifugalForce
        )
        velocity = velocity * (1-fric)

        rot = rot + velocity
    end
    if limits ~= nil then function events.tick()
        if not handler.enabled then return end

        if rot.x < limits[1] then rot.x = limits[1] velocity.x = 0 end
        if rot.x > limits[2] then rot.x = limits[2] velocity.x = 0 end
        if rot.y < limits[3] then rot.y = limits[3] velocity.y = 0 end
        if rot.y > limits[4] then rot.y = limits[4] velocity.y = 0 end
        if rot.z < limits[5] then rot.z = limits[5] velocity.z = 0 end
        if rot.z > limits[6] then rot.z = limits[6] velocity.z = 0 end
    end end
    function events.render(delta)
        if not handler.enabled then return end

        part:setOffsetRot(lerp(_rot, rot, delta))
    end
    return handler
end

return SwingingPhysics