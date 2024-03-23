---- Confetti - A Custom Particle Library by manuel_2867 ----

---@class Confetti
local Confetti = {}

local Particles = {}
local Instances = {}

if models.confetti then
    error("There is already a confetti.bbmodel. Please remove or rename it.")
end
models:newPart("confetti")
models.confetti:newPart("Instances")
models.confetti:newPart("SpriteTaskTemplate")
models.confetti:setParentType("World")

---@class ConfettoOptions
---@field lifetime number|nil Lifetime in ticks
---@field acceleration Vector3|number|nil Vector in world space or a number which accelerates forwards (positive) or backwards (negative) in the current movement direction
---@field friction number|nil Number of friction to slow down the particle. Value of 1 is no friction, value <1 slows it down, value >1 speeds it up.
---@field scale Vector3|number|nil Initial scale when spawning
---@field scaleOverTime Vector3|number|nil Change of scale every tick
---@field rotation Vector3|number|nil Initial rotation when spawning
---@field rotationOverTime Vector3|number|nil Change of rotation every tick
---@field billboard boolean|nil Whether the Sprite should always face the camera, only affects Sprite particles
local ConfettoOptions = {}

--- Register a Mesh Particle
---@param name string
---@param mesh ModelPart
---@param lifetime number|nil Lifetime in ticks
---@return nil
function Confetti.registerMesh(name, mesh, lifetime)
    Particles[name] = {mesh=mesh,lifetime=lifetime or 20}
    mesh:setVisible(false)
end

--- Register a Sprite Particle
---@param name string
---@param sprite Texture The texture file to use
---@param bounds Vector4 (x,y,z,w) with x,y top left corner (inclusive) and z,w bottom right corner (inclusive), in pixels
---@param lifetime number|nil Lifetime in ticks. Default is 20.
---@param pivot Vector2|nil Offset to change pivot point. 0,0 is top left corner. Default is in center.
---@return nil
function Confetti.registerSprite(name, sprite, bounds, lifetime, pivot)
    Particles[name] = {sprite=sprite,bounds=bounds,lifetime=lifetime or 20,pivot=pivot or vec((bounds.y-bounds.x)/2,(bounds.w-bounds.z)/2)}
end

--- Spawn a registered custom particle
---@param name string
---@param pos Vector3 Position in world coordinates
---@param vel Vector3|nil Velocity vector
---@param options ConfettoOptions|nil
---@return Confetto
function Confetti.newParticle(name, pos, vel, options)
    -- Handle Overloads
    if vel == nil then
        vel = vec(0,0,0)
    end
    if options == nil then
        options = {}
    end
    local scale = options.scale or vec(1,1,1)
    local rotation = options.rotation or vec(0,0,0)
    -- Spawn Particle
    local meshInstance = nil
    if Particles[name].mesh ~= nil then
        meshInstance = Particles[name].mesh:copy("a")
        meshInstance:setVisible(true)
        models.confetti.Instances:addChild(meshInstance)
    else
        meshInstance = models.confetti["SpriteTaskTemplate"]:copy("a")
        local taskholder = models.confetti["SpriteTaskTemplate"]:copy("a")
        if options.billboard then taskholder:setParentType("Camera") end
        meshInstance:addChild(taskholder)
        models.confetti.Instances:addChild(meshInstance)
        local task = taskholder:newSprite("a")
        task:setPos(Particles[name].pivot.xy_)
        task:setTexture(Particles[name].sprite)
        task:setDimensions(Particles[name].sprite:getDimensions())
        task:setUVPixels(Particles[name].bounds.x,Particles[name].bounds.y)
        task:setRegion(Particles[name].bounds.z+1-Particles[name].bounds.x,Particles[name].bounds.w+1-Particles[name].bounds.y)
        task:setSize(Particles[name].bounds.z+1-Particles[name].bounds.x,Particles[name].bounds.w+1-Particles[name].bounds.y)
    end
    if type(options.acceleration) == "number" then
        options.acceleration = vel:normalized() * options.acceleration
    end
    ---@class Confetto
    ---@field mesh ModelPart
    ---@field sprite Texture|nil
    ---@field bounds Vector4
    ---@field lifetime number
    ---@field options ConfettoOptions
    ---@field position Vector3
    ---@field rotation Vector3|number
    ---@field scale Vector3|number
    ---@field private _position any
    ---@field private _rotation any
    ---@field private _scale any
    local particle = {
        mesh=meshInstance,
        sprite=Particles[name].sprite,
        bounds=Particles[name].bounds,
        lifetime=options.lifetime or Particles[name].lifetime,
        options=options,
        position = pos,
        _position = pos,
        velocity = vel,
        scale=scale,
        _scale=scale,
        rotation=rotation,
        _rotation=rotation
    }
    table.insert(Instances,particle)
    return particle
end

function events.TICK()
    local deleted = {}
    for i, value in ipairs(Instances) do
        value._position = value.position
        value._rotation = value.rotation
        value._scale = value.scale

        if value.options.acceleration ~= nil then
            value.velocity = value.velocity + value.options.acceleration
        end

        if value.options.friction ~= nil then
            value.velocity = value.velocity * value.options.friction
        end

        value.position = value.position + value.velocity

        if value.options.scaleOverTime ~= nil then
            if type(value.options.scaleOverTime) == "number" then
                value.scale = value.scale + vec(value.options.scaleOverTime,value.options.scaleOverTime,value.options.scaleOverTime)
            else
                value.scale = value.scale + value.options.scaleOverTime
            end
        end

        if value.options.rotationOverTime ~= nil then
            if type(value.options.rotationOverTime) == "number" then
                value.rotation = value.rotation + vec(value.options.rotationOverTime,value.options.rotationOverTime,value.options.rotationOverTime)
            else
                value.rotation = value.rotation + value.options.rotationOverTime
            end
        end

        value.lifetime = value.lifetime - 1
        if value.lifetime <= 0 then
            table.insert(deleted,i)
            models.confetti.Instances:removeChild(value.mesh)
        end
    end
    for i, key in ipairs(deleted) do
        table.remove(Instances, key-(i-1))
    end
end

function events.RENDER(delta)
    for i, value in ipairs(Instances) do
        if value.mesh ~= nil then
            value.mesh:setPos((math.lerp(value._position,value.position,delta))*16)
            value.mesh:setRot(math.lerp(value._rotation,value.rotation,delta))
            value.mesh:setScale(math.lerp(value._scale,value.scale,delta))
        end
    end
end

return Confetti