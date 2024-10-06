local Combat = require("combat")

local attackRadius = 11
local attackDamage = 5
local attackId = 1
local canAttack = true

local Confetti = require("confetti")
Confetti.registerMesh("sword", models.model.sword, 2)

local wasSwingingArm = false
function events.tick()
    if canAttack and player:getHeldItem().id == "minecraft:stick" and player:isSwingingArm() and not wasSwingingArm then
        canAttack = false
        summonSwords()
    end
    wasSwingingArm = player:isSwingingArm()
end

---@param particle Confetto
function ticker(particle)
    if particle.options.remove then return end
    if not particle.mesh.rotationhelper then
        particle.mesh.meshholder:moveTo(particle.mesh:newPart("rotationhelper"))
    end
    local target = particle.options.positioning:partToWorldMatrix():apply()
    particle.options.zRot = particle.options.zRot+particle.options.zSpeed
    particle.lifetime = 2
    particle._position = particle.position
    particle.mesh.rotationhelper:setRot(0,0,particle.options.zRot)
    local entity = Combat.getEntities(player:getPos(),attackRadius)[1]
    if entity then
        particle.options.timer = particle.options.timer + 1
        local dir = (entity:getPos():add(0,0.5,0)-particle.position)
        local distance = dir:length()
        dir = dir:normalized()
        if particle.options.timer > 20 then
            particles:newParticle("minecraft:soul_fire_flame", particle.position)
            target = entity:getPos():add(0,0.5,0)
            if distance < 0.8 then
                particle.options.remove = true
                particle.lifetime = 0
                performAttack(entity)
            end
        end
        local pitch = math.atan2(dir.y, math.sqrt(dir.x*dir.x+dir.z*dir.z))
        local yaw = math.atan2(dir.x, dir.z)
        particle.rotation = vec(pitch,yaw):toDeg():add(0,180).xy_
        particle._rotation = particle.rotation
    else
        particle.options.timer = 0
        particle._rotation = particle.rotation
        particle.rotation = player:getRot():mul(-1,-1):add(0,180).xy_
    end
    particle.position = math.lerp(particle.position, target, 0.3)
end

-- limit attacks to once per tick
local hasAttackedThisTick = false
function performAttack(entity)
    if not hasAttackedThisTick then
        hasAttackedThisTick = true
        canAttack = true
        createImpactEffect(entity:getPos())
        Combat.attack(attackId, entity, attackDamage)
    end
end
function events.tick()
    hasAttackedThisTick = false
end

function createImpactEffect(pos)
    local dirs = {}
    local poss = {}
    local n = 8
    particles:newParticle("minecraft:explosion", pos)
    particles:newParticle("minecraft:explosion", pos+vec(0,1,0))
    for _ = 1, 10 do
        table.insert(dirs,vec(math.random()-0.5,2,math.random()-0.5):normalized())
        table.insert(poss, pos:copy())
    end
    local tick tick = function()
        for index, dir in ipairs(dirs) do
            local r = 0.5-math.random()
            poss[index] = poss[index]+dir*0.3+vec(r,r,r)
            particles:newParticle("minecraft:electric_spark", poss[index])
        end
        n = n - 1
        if n <= 0 then
            events.tick:remove(tick)
        end
    end
    events.tick:register(tick)
end

function summonSwords()
    for i = 1, 3 do
        Confetti.newParticle("sword", player:getPos():add(0,1,0),nil,{
            ticker=ticker,
            positioning=models.model["pos"..i],
            zRot=math.random()*180,
            zSpeed=5+math.random()*6,
            timer=0,
            remove=false
        })
    end
end
