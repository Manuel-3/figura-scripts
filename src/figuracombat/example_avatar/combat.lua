-- Figura Combat by manuel_2867

-- Not yet implemented or potential future features:
-- Attacks that can hit multiple targets in quick succession, and only have longer cooldown after that (to make area of effect attacks)
-- Enable attacks on a player by player basis, to allow locking them behind some sort of game progression on a server

local Combat = {}

-- Version check for datapack
local requiredVersion = "1.20.2"
local gameVersion = client.getVersion()
if client.compareVersions(requiredVersion, gameVersion) > 0 then
    error("Figura Combat needs at least minecraft version "..requiredVersion.." or above!")
end

---Ask the server to show attack information
function Combat.showInfo()
    host:sendChatCommand("/trigger figuracombat_info set 1")
end

-- Check if chat messages setting is enabled, and handle server command responses
local commandsEnabledTimer = 20*2
local commandsEnabled = false
local commandsEnabledUUID = tostring(client.generateUUID())
host:sendChatCommand(commandsEnabledUUID)
events.CHAT_RECEIVE_MESSAGE:register(function (message)
    if not message then return message end
    if commandsEnabledTimer > 0 and(message:find("nknown or incomplete command") or message:find(commandsEnabledUUID)) then
        commandsEnabled = true
        return false
    end
    if message:find('figuracombat_') then
        if message:find("nknown scoreboard objective") then
            logJson(toJson({text="This server does not have the Figura Combat datapack installed.",color="red"}))
        end
        return false
    end
    if message:find("trigger this objective yet") then
        return false
    end
end)

local preview = 0

-- commands
events.CHAT_SEND_MESSAGE:register(function (message)
    if message=="/showinfo" then
        Combat.showInfo()
        return
    elseif message:match("^/preview") then
        local n = tonumber(message:sub(10))
        if n then
            preview = n
        else
            preview = 0
        end
        return
    end
    return message
end)

-- limit attacks to once per tick
local hasAttackedThisTick = false
function events.tick()
    hasAttackedThisTick = false
end

---Attack an entity with a given attackId and damage amount.
---**Important!** You can only call this at max once per tick!
---Ideally less, to let the server update properly. Best practice to keep track of your current cooldown, and only call it when its over.
---To determine your cooldown, go check which attack cooldowns are set on this server by calling Config.showInfo() or run the /showinfo command.
---Then whenever you use an attack, remember its cooldown amount of ticks and count them down to 0. Your player is on cooldown for **all attacks** after using an attack! (Not just the attack you used to get the cooldown! Cooldown is applied to your entire player when you use any attack, and you can't use another attack until it has reached 0.)
---It is advised to work with a cooldown of one or two ticks above what the server tells you, to account for a little bit of potential lag.
---If you have server permissions, you can use `/scoreboard objectives setdisplay sidebar figuracombat_cooldown` to display your current cooldown.
---@param attackId number To see which attacks are available call Combat.showInfo() or run the /showinfo command
---@param entity Entity|number[] The entity to attack, or it's uuid as an integer array
---@param damage number Damage amount, will be capped by the attacks max damage if it's above
function Combat.attack(attackId, entity, damage)
    assert(type(attackId)=="number", "Invalid argument 1, for attackId.")
    assert(type(entity)~="nil" and (entity.getUUID or type(entity[1])=="number"), "Invalid argument 2, for entity.")
    assert(type(damage)=="number", "Invalid argument 3, for damage.")
    local uuid = type(entity[1])=="number" and entity or {client.uuidToIntArray(entity:getUUID())}
    if hasAttackedThisTick then return end
    hasAttackedThisTick = true
    log("performing")
    host:sendChatCommand("/trigger figuracombat_uuid_1 set "..tostring(uuid[1]))
    host:sendChatCommand("/trigger figuracombat_uuid_2 set "..tostring(uuid[2]))
    host:sendChatCommand("/trigger figuracombat_uuid_3 set "..tostring(uuid[3]))
    host:sendChatCommand("/trigger figuracombat_uuid_4 set "..tostring(uuid[4]))
    host:sendChatCommand("/trigger figuracombat_damage set "..tostring(damage))
    host:sendChatCommand("/trigger figuracombat_attack set "..tostring(attackId))
end

---Attack all entities in the given list. This takes the given cooldown into account and attacks them over the next several ticks.
---It is advised to put a cooldown of one or two ticks above what the server tells you, to account for a little bit of potential lag.
---@param attackId number To see which attacks are available call Combat.showInfo() or run the /showinfo command
---@param entities Entity[]|number[][] List of entities, or list of uuid integer arrays
---@param damage number Damage amount, will be capped by the attacks max damage if it's above
---@param cooldown number The cooldown of the attack with the give attackId
function Combat.attackAll(attackId, entities, damage, cooldown)
    local i = 1
    local t = cooldown
    local len = #entities
    local tick tick = function()
        if i > len then
            events.tick:remove(tick)
            return
        end
        t = t + 1
        if t >= cooldown then
            t = 0
            Combat.attack(attackId, entities[i], damage)
            i = i + 1
        end
    end
    events.tick:register(tick)
end

local function DefaultPredicate(entity)
    return entity:getUUID()~=player:getUUID() and entity:getType()~="minecraft:item" and entity:getType()~="minecraft:experience_orb"
end

---Get entities in a radius around a position.
---@param position Vector3
---@param radius number
---@param predicate nil|fun(entity: Entity):boolean Predicate to check wheter to include an entity. If not provided, will use a default predicate that excludes dropped items and experience orbs, as well as the own player entity.
---@return Entity[] entities Array of entities
function Combat.getEntities(position, radius, predicate)
    predicate = predicate or DefaultPredicate
    local min = position:copy():sub(radius,radius,radius)
    local max = position:copy():add(radius,radius,radius)
    local e = {}
    raycast:entity(min, max, function (hit)
        if (position-hit:getPos()):length() <= radius and predicate(hit) then
            e[#e+1] = hit
        end
        return false
    end)
    return e
end

---Display attack radius preview in world
---You can also use the /preview command
---@param radius any
function Combat.previewRadius(radius)
    preview = radius
end

---Stop attack radius preview
function Combat.stopPreview()
    preview = 0
end

function events.tick()
    if commandsEnabledTimer > 0 then
        commandsEnabledTimer = commandsEnabledTimer - 1
    elseif not commandsEnabled then
        error('The "Chat Messages" setting is turned off! To use Figura Combat go into the Figura settings and turn it on!')
    end
    if preview > 0 then
        local angleStep = math.pi / (10 * math.min(preview, 7))  -- Step size decreases with larger radius
        for b = 0, math.pi, angleStep do  -- Polar angle (up/down), from 0 to pi
            local sinB = math.sin(b)  -- Sin of the polar angle controls the spacing
            local adjustedStep = angleStep / sinB  -- Adjust azimuthal step based on latitude
        
            if sinB > 0.01 then  -- Avoid division by zero near the poles
                for a = 0, 2 * math.pi, adjustedStep do  -- Azimuthal angle (around), from 0 to 2pi
                    local x = preview * sinB * math.cos(a)  -- X coordinate
                    local y = preview * math.cos(b)  -- Y coordinate
                    local z = preview * sinB * math.sin(a)  -- Z coordinate
                    particles:newParticle("minecraft:bubble", player:getPos():add(x, y, z))
                end
            end
        end
    end
end

return Combat