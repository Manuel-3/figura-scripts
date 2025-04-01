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
local SwingHandler = {}
---@param enabled boolean
function SwingHandler:setEnabled(enabled)end
---@return boolean
function SwingHandler:getEnabled()end
---@param part ModelPart
function SwingHandler:setPart(part)end
---@return ModelPart
function SwingHandler:getPart()end
---@param dir number
function SwingHandler:setDir(dir)end
---@return number
function SwingHandler:getDir()end
---@param limits table
function SwingHandler:setLimits(limits)end
---@return table
function SwingHandler:getLimits()end
---@param root ModelPart
function SwingHandler:setRoot(root)end
---@return ModelPart
function SwingHandler:getRoot()end
---@param depth number
function SwingHandler:setDepth(depth)end
---@return number
function SwingHandler:getDepth()end

--- Adds swinging physics to a part that is attached to the head
---@param part ModelPart The model part that should swing
---@param dir number Angle in degree, where the part is located relative to the center of the head. Imagine a stick pointing out in that direction with the model part hanging from its end. 0 means forward, 45 means diagonally forward and left, 90 means straight left and so on
---@param limits table|nil Limits the rotation of the part to make it appear like its colliding with something. Format: {xLow, xHigh, yLow, yHigh, zLow, zHigh} (optional)
---@param root ModelPart|nil Required if it is part of a chain. Note that the first chain element does not need this root parameter, and does also not need the depth parameter. Only following chain links need it.
---@param depth number|nil An integer that should increase by 1 for each consecutive chain link after the root. The root itself doesnt need this parameter. This increases the friction which makes it look more realistic. Recommended to play around with it a bit to find values you like, also dont make it too high otherwise it will almost look stiff. mostly good values are between 1 and 5
---@param globalLimits boolean If true, will negate the vanilla head rotation to keep the limits in global space instead of local to the head. This could help prevent clipping through other body parts.
---@return SwingHandler
function SwingingPhysics.swingOnHead(part, dir, limits, root, depth, globalLimits)
    assert(part, "Model Part does not exist!")
    local _rot = vec(0,0,0)
    local rot = vec(0,0,0)
    local velocity = vec(0,0,0)
    if depth == nil then depth = 0 end
    local handler = {
        ---@type SwingHandler
    }
    handler.enabled = true
    handler.part = part
    handler.dir = dir
    handler.limits = limits
    handler.root = root
    handler.depth = depth
    function handler:setEnabled(enabled)
        self.enabled = enabled
        if not self.enabled then
            rot = vec(0,0,0)
            _rot = rot
            self.part:setOffsetRot(rot)
        end
    end
    function handler:getEnabled()
        return self.enabled
    end
    function handler:setPart(part)
        self.part = part
    end
    function handler:getPart()
        return self.part
    end
    function handler:setDir(dir)
        self.dir = dir
    end
    function handler:getDir()
        return self.dir
    end
    function handler:setLimits(limits)
        self.limits = limits
    end
    function handler:getLimits()
        return self.limits
    end
    function handler:setRoot(root)
        self.root = root
    end
    function handler:getRoot()
        return self.root
    end
    function events.tick()
        if not handler.enabled then return end

        _rot = rot

        local grav
        if handler.root ~= nil then
            grav = ((downHead - handler.root:getOffsetRot()) - rot) * gravity
        else
            grav = (downHead - rot) * gravity
        end
        
        velocity = velocity + grav + vec(
            sin(handler.dir)*forceHead-cos(moveAngle)*playerSpeed+cos(handler.dir)*math.abs(forceHead)*centrifugalForce,
            0,
            cos(handler.dir)*forceHead+sin(moveAngle)*playerSpeed-sin(handler.dir)*math.abs(forceHead)*centrifugalForce
        )
        velocity = velocity * (1-friction*math.pow(1.5, handler.depth))

        rot = rot + velocity

        if not handler.limits then return end
        local limitoffset = vanilla_model.HEAD:getOriginRot()
        if not globalLimits then limitoffset = vec(0,0,0) end
        if rot.x < handler.limits[1]-limitoffset.x then rot.x = handler.limits[1]-limitoffset.x velocity.x = -velocity.x/2 end
        if rot.x > handler.limits[2]-limitoffset.x then rot.x = handler.limits[2]-limitoffset.x velocity.x = -velocity.x/2 end
        if rot.y < handler.limits[3]-limitoffset.y then rot.y = handler.limits[3]-limitoffset.y velocity.y = -velocity.y/2 end
        if rot.y > handler.limits[4]-limitoffset.y then rot.y = handler.limits[4]-limitoffset.y velocity.y = -velocity.y/2 end
        if rot.z < handler.limits[5]-limitoffset.z then rot.z = handler.limits[5]-limitoffset.z velocity.z = -velocity.z/2 end
        if rot.z > handler.limits[6]-limitoffset.z then rot.z = handler.limits[6]-limitoffset.z velocity.z = -velocity.z/2 end
    end
    function events.render(delta)
        if not handler.enabled then return end
        handler.part:setOffsetRot(lerp(_rot, rot, delta))
    end
    return handler
end
--- Adds swinging physics to a part that is attached to the body
---@param part ModelPart The model part that should swing
---@param dir number Angle in degree, where the part is located relative to the center of the head. Imagine a stick pointing out in that direction with the model part hanging from its end. 0 means forward, 45 means diagonally forward and left, 90 means straight left and so on
---@param limits table|nil Limits the rotation of the part to make it appear like its colliding with something. Format: {xLow, xHigh, yLow, yHigh, zLow, zHigh} (optional)
---@param root ModelPart|nil Required if it is part of a chain. Note that the first chain element does not need this root parameter, and does also not need the depth parameter. Only following chain links need it.
---@param depth number|nil An integer that should increase by 1 for each consecutive chain link after the root. The root itself doesnt need this parameter. This increases the friction which makes it look more realistic. Recommended to play around with it a bit to find values you like, also dont make it too high otherwise it will almost look stiff. mostly good values are between 1 and 5
---@param globalLimits boolean If true, will negate the vanilla body rotation to keep the limits in global space instead of local to the body. This could help prevent clipping through other body parts.
---@return SwingHandler
function SwingingPhysics.swingOnBody(part, dir, limits, root, depth, globalLimits)
    assert(part, "Model Part does not exist!")
    local _rot = vec(0,0,0)
    local rot = vec(0,0,0)
    local velocity = vec(0,0,0)
    if depth == nil then depth = 0 end
    local handler = {
        ---@type SwingHandler
    }
    handler.enabled = true
    handler.part = part
    handler.dir = dir
    handler.limits = limits
    handler.root = root
    handler.depth = depth
    function handler:setEnabled(enabled)
        self.enabled = enabled
        if not self.enabled then
            rot = vec(0,0,0)
            _rot = rot
            self.part:setOffsetRot(rot)
        end
    end
    function handler:getEnabled()
        return self.enabled
    end
    function handler:setPart(part)
        self.part = part
    end
    function handler:getPart()
        return self.part
    end
    function handler:setDir(dir)
        self.dir = dir
    end
    function handler:getDir()
        return self.dir
    end
    function handler:setLimits(limits)
        self.limits = limits
    end
    function handler:getLimits()
        return self.limits
    end
    function handler:setRoot(root)
        self.root = root
    end
    function handler:getRoot()
        return self.root
    end
    function events.tick()
        if not handler.enabled then return end

        _rot = rot

        local grav
        if handler.root ~= nil then
            grav = ((downBody - handler.root:getOffsetRot()) - rot) * gravity
        else
            grav = (downBody - rot) * gravity
        end

        velocity = velocity + grav + vec(
            sin(handler.dir)*forceBody-cos(moveAngle)*playerSpeed+cos(handler.dir)*math.abs(forceBody)*centrifugalForce,
            0,
            cos(handler.dir)*forceBody+sin(moveAngle)*playerSpeed-sin(handler.dir)*math.abs(forceBody)*centrifugalForce
        )
        velocity = velocity * (1-friction*math.pow(1.5, handler.depth))

        rot = rot + velocity

        if not handler.limits then return end
        local limitoffset = vanilla_model.BODY:getOriginRot()
        if not globalLimits then limitoffset = vec(0,0,0) end
        if rot.x < handler.limits[1]-limitoffset.x then rot.x = handler.limits[1]-limitoffset.x velocity.x = -velocity.x/2 end
        if rot.x > handler.limits[2]-limitoffset.x then rot.x = handler.limits[2]-limitoffset.x velocity.x = -velocity.x/2 end
        if rot.y < handler.limits[3]-limitoffset.y then rot.y = handler.limits[3]-limitoffset.y velocity.y = -velocity.y/2 end
        if rot.y > handler.limits[4]-limitoffset.y then rot.y = handler.limits[4]-limitoffset.y velocity.y = -velocity.y/2 end
        if rot.z < handler.limits[5]-limitoffset.z then rot.z = handler.limits[5]-limitoffset.z velocity.z = -velocity.z/2 end
        if rot.z > handler.limits[6]-limitoffset.z then rot.z = handler.limits[6]-limitoffset.z velocity.z = -velocity.z/2 end
    end
    function events.render(delta)
        if not handler.enabled then return end
        handler.part:setOffsetRot(lerp(_rot, rot, delta))
    end
    return handler
end

return SwingingPhysics