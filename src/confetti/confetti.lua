---- Confetti - A Custom Particle Library by manuel_2867 ----

---@class Confetti
local Confetti = {}

local Particles = {}
local Instances = {}
local modelinstances = models:newPart("confetti"..client.intUUIDToString(client.generateUUID())):setParentType("World"):newPart("Instances")
local DEFAULT_LIFETIME = 20
local math_lerp = math.lerp

-- Metatable change for syncing emissive SpriteTask to the regular one
local SpriteMap = {}
local SpriteTask__index = figuraMetatables.SpriteTask.__index
figuraMetatables.SpriteTask.__index = {}
for key, value in pairs(SpriteTask__index) do
    figuraMetatables.SpriteTask.__index[key] = function(self,...)
        if SpriteMap[self] then
            value(SpriteMap[self],...)
        end
        return value(self,...)
    end
end

---Default ticker
---@param instance Confetto
function Confetti.defaultTicker(instance)
    local opts = instance.options
    instance._position = instance.position
    instance._rotation = instance.rotation
    instance._scale = instance.scale
    instance.velocity = (instance.velocity + opts.acceleration) * opts.friction
    instance.position = instance.position + instance.velocity
    instance.scale = instance.scale + opts.scaleOverTime
    instance.rotation = instance.rotation + opts.rotationOverTime
end

---Default renderer
---@param instance Confetto
function Confetti.defaultRenderer(instance, delta, context, matrix)
    if context == "PAPERDOLL" then return end
    instance.mesh:setPos((math_lerp(instance._position,instance.position,delta))*16)
    instance.mesh:setRot(math_lerp(instance._rotation,instance.rotation,delta))
    instance.mesh:setScale(math_lerp(instance._scale,instance.scale,delta))
end

---@class ConfettoOptions
---@field lifetime number|nil Initial lifetime in ticks
---@field acceleration Vector3|number|nil Vector in world space or a number which accelerates forwards (positive) or backwards (negative) in the current movement direction
---@field friction number|nil Number of friction to slow down the particle. Value of 1 is no friction, value <1 slows it down, value >1 speeds it up.
---@field scale Vector3|number|nil Initial scale when spawning
---@field scaleOverTime Vector3|number|nil Change of scale every tick
---@field rotation Vector3|number|nil Initial rotation when spawning
---@field rotationOverTime Vector3|number|nil Change of rotation every tick
---@field billboard boolean|nil Makes the particle always face the camera
---@field emissive boolean|nil Makes the particle emissive.
---@field ticker fun(particle: Confetto)|nil Function called each tick. Will overwrite the default behavior which calculates position, velocity, rotation and scale. To keep default behavior, call `Confetti.defaultTicker(particle)` before your own code.
---@field renderer fun(particle: Confetto, delta: number, context: Event.Render.context, matrix: Matrix4)|nil Function called each frame. Will overwrite the default behavior which smoothes the pos,rot,scale if it was calculated correctly by the ticker. To keep default behavior, call `Confetti.defaultRenderer(particle, delta, context, matrix)` before your own code.
local ConfettoOptions = {}

local DefaultConfettoOptions = {
    lifetime = DEFAULT_LIFETIME,
    acceleration = vec(0,0,0),
    friction = 1,
    scale = vec(1,1,1),
    scaleOverTime = vec(0,0,0),
    rotation = vec(0,0,0),
    rotationOverTime = vec(0,0,0),
    billboard=false,
    emissive=false,
    ticker=Confetti.defaultTicker,
    renderer=Confetti.defaultRenderer
}

---@class Confetto
---@field mesh ModelPart The model part
---@field task SpriteTask|nil The sprite task if it's a sprite particle. (If emissive, not a real SpriteTask but a fake one because internally it uses two actual SpriteTasks to have a normal layer and an emissive layer above it. This is so you can still just use one line of code to access both of them at the same time internally.)
---@field position Vector3 Current position in world coordinates
---@field _position Vector3 Last tick position
---@field velocity Vector3 The particles velocity
---@field lifetime number Remaining lifetime in ticks
---@field scale Vector3|number Current scale
---@field _scale Vector3|number Last tick scale
---@field rotation Vector3|number Current rotation
---@field _rotation Vector3|number Last tick rotation
---@field options ConfettoOptions
local Confetto = {}
Confetto.__index = Confetto

function Confetto:new(mesh, task, pos, vel, bounds, pivot, options)
    return setmetatable({
        mesh=mesh,
        task=task,
        position=pos,
        _position=pos,
        velocity=vel,
        lifetime=options.lifetime,
        scale=options.scale,
        _scale=options.scale,
        rotation=options.rotation,
        _rotation=options.rotation,
        bounds=bounds,
        pivot=pivot,
        options=options
    }, Confetto)
end

--- Register a Mesh Particle
---@param name string
---@param mesh ModelPart
---@param lifetime number|nil Lifetime in ticks
---@return nil
function Confetti.registerMesh(name, mesh, lifetime)
    assert(mesh, "Model Part does not exist! Double check the path, spelling, and if you saved your model file.")
    if mesh:getType() ~= "GROUP" then logJson('[{color="yellow",text="[WARNING] "},{color:"white",text:"You are creating a particle by targeting a model part directly, instead of a group. This can cause unexpected behavior. It is recommended to use a group that is positioned at (0,0,0) instead. If you know what you are doing, to get rid of this warning simply delete this line of code."}]') end
    Particles[name] = {mesh=mesh,lifetime=lifetime or DEFAULT_LIFETIME}
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
    if not sprite then
        logTable(textures:getTextures())
        error("Texture does not exist. Use the correct name shown in the list above. It may need a model name before the texture name separated by a dot.")
    end
    Particles[name] = {sprite=sprite,bounds=bounds,lifetime=lifetime or DEFAULT_LIFETIME,pivot=pivot or vec((bounds.z+1-bounds.x)/2,(bounds.w+1-bounds.y)/2)}
end

--- Spawn a registered custom particle without checking arguments. This uses less instructions, but doesn't allow different argument types. In the options, scaleOverTime, rotationOverTime and acceleration must be Vector3 if used.
---@param name string
---@param pos Vector3 Position in world coordinates
---@param vel Vector3 Velocity vector
---@param options ConfettoOptions
---@return Confetto
function Confetti.newParticleUnchecked(name, pos, vel, options)
    local ptcl = Particles[name]
    options.lifetime = options.lifetime or ptcl.lifetime
    setmetatable(options, { __index = DefaultConfettoOptions })
    local meshInstance, task
    if ptcl.mesh ~= nil then
        meshInstance = modelinstances:newPart("_")
        ptcl.mesh:copy("meshholder"):moveTo(meshInstance):setParentType(options.billboard and "CAMERA" or "NONE"):setVisible(true)
    else
        meshInstance = modelinstances:newPart("_")
        local holder = meshInstance:newPart("taskholder")
            :setParentType(options.billboard and "CAMERA" or "NONE")
        local x,y,z,w = ptcl.bounds:unpack()
        task = (holder:newPart("_")):newSprite("_")
            :setPos(ptcl.pivot.xy_)
            :setTexture(ptcl.sprite)
            :setDimensions(ptcl.sprite:getDimensions())
            :setUVPixels(x,y)
            :setRegion(z+1-x,w+1-y)
            :setSize(z+1-x,w+1-y)
        if options.emissive then
            SpriteMap[task] = (holder:newPart("_")):newSprite("_")
                :setPos(ptcl.pivot.xy_)
                :setTexture(ptcl.sprite)
                :setDimensions(ptcl.sprite:getDimensions())
                :setUVPixels(x,y)
                :setRegion(z+1-x,w+1-y)
                :setSize(z+1-x,w+1-y)
                :setRenderType("EMISSIVE")
        end
    end
    if options.emissive then
        meshInstance:setSecondaryTexture("PRIMARY")
    end
    local particle = Confetto:new(meshInstance, task, pos, vel, ptcl.bounds, Particles[name].pivot, options)
    Instances[client.intUUIDToString(client.generateUUID())] = particle
    return particle
end

--- Spawn a registered custom particle
---@param name string
---@param pos Vector3 Position in world coordinates
---@param vel Vector3|nil Velocity vector
---@param options ConfettoOptions|nil
---@return Confetto
function Confetti.newParticle(name, pos, vel, options)
    vel = vel or vec(0,0,0)
    options = options or {}
    if type(options.scaleOverTime) == "number" then
        options.scaleOverTime = vec(options.scaleOverTime,options.scaleOverTime,options.scaleOverTime)
    end
    if type(options.rotationOverTime) == "number" then
        options.rotationOverTime = vec(options.rotationOverTime,options.rotationOverTime,options.rotationOverTime)
    end
    if type(options.acceleration) == "number" then
        options.acceleration = vel:normalized() * options.acceleration
    end
    return Confetti.newParticleUnchecked(name, pos, vel, options)
end

function events.TICK()
    for key, instance in pairs(Instances) do
        instance.options.ticker(instance)
        instance.lifetime = instance.lifetime - 1
        if instance.lifetime <= 0 then
            modelinstances:removeChild(instance.mesh)
            if instance.task then
                SpriteMap[instance.task] = nil
            end
            Instances[key] = nil
        end
    end
end

function events.RENDER(delta, context, matrix)
    for _, instance in pairs(Instances) do
        instance.options.renderer(instance, delta, context, matrix)
    end
end

return Confetti
