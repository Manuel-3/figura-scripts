-- Settings --
local needsRespirationIIfor30secondSound = true -- respiration I and lower will always be less than 30 seconds remaining
local meterScale = 5 -- 1 block is this many meters (because oceans are not that deep in minecraft)
local debugLogData = false -- enable to see debug data in chat
local playLeviathanWarning = true -- occasionally plays the leviathan warning if in large open water
local leviathanTimer = 20*60 -- time to wait between leviathan attempt in ticks
local leviathanChance = 0.35 -- chance the leviathan sound actually plays
-- End Settings --

if not host:isHost() then return end

local canPlay30seconds = true
local canPlayOxygen = true
local canPlay100meters = true
local canPlay200meters = true
local lt = leviathanTimer

function events.tick()
    local level = 0
    if player:getItem(6) ~= nil and player:getItem(6).tag.Enchantments ~= nil then
        for k,v in pairs(player:getItem(6).tag.Enchantments) do
            if v.id == "minecraft:respiration" then
                level = v.lvl
            end
        end
    end

    if not (player:getGamemode() == "SURVIVAL" or player:getGamemode() == "ADVENTURE") or (level < 2 and needsRespirationIIfor30secondSound) then
        canPlay30seconds = false
    end

    if playLeviathanWarning then
        local pos = player:getPos()
        if
            world.getBlockState(pos+vec(10,0,0)).id == "minecraft:water" and
            world.getBlockState(pos+vec(-10,0,0)).id == "minecraft:water" and
            world.getBlockState(pos+vec(0,0,10)).id == "minecraft:water" and
            world.getBlockState(pos+vec(0,0,-10)).id == "minecraft:water"
        then
            lt = lt - 1
            if (lt <= 0) then
                lt = leviathanTimer
                if math.random() < leviathanChance then
                    sounds:playSound("sounds.leviathan", player:getPos(), 1, 1)
                end
            end
        end
    end

    local secondsleft = math.ceil(host:getAir()*(level+1)/20)

    local depth = 0
    local foundAir = false
    while not foundAir do
        depth = depth + 1
        local pos = player:getPos()+vec(0,depth,0)
        foundAir = world.getBlockState(pos).id == "minecraft:air" or (pos.y > 62 and player:getPos().y < 62)
    end
    depth = depth - 1

    if canPlay30seconds and secondsleft < 30 and player:isUnderwater() then
        sounds:playSound("sounds.30seconds", player:getPos(), 1, 1)
        canPlay30seconds = false
    end
    if secondsleft > 32 or (level<=1 and host:getAir() == 300) then
        canPlay30seconds = true
    end
    if canPlayOxygen and secondsleft < 5 then
        sounds:playSound("sounds.oxygen", player:getPos(), 1, 1)
        canPlayOxygen = false
    end
    if secondsleft > 7 then
        canPlayOxygen = true
    end
    if canPlay100meters and depth*meterScale > 100 then
        sounds:playSound("sounds.depth_100", player:getPos(), 1, 1)
        canPlay100meters = false
    end
    if depth*meterScale < 80 then
        canPlay100meters = true
    end
    if canPlay200meters and depth*meterScale > 200 then
        sounds:playSound("sounds.depth_200", player:getPos(), 1, 1)
        canPlay200meters = false
    end
    if depth*meterScale < 180 then
        canPlay200meters = true
    end
    
    if debugLogData then
        log("Air:")
        log(secondsleft)
        log("Depth:")
        log(depth*meterScale)
    end
end