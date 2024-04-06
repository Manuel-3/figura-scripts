TEXTURE_SIZE = 512
TEXTURE_GRID = 8

zelda = false
thin = false

vanilla_model.PLAYER:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

cape_rotation = vec(0,0,0) -- This will contain the cape rotation at all times
hair_sideways_swinging = 0

-- Calculate cape rotation - self contained, you dont have to change anything here
do
    -- Calculate player velocity
    local playervelocity = vec(0,0,0)
    do
        local velocityPos = nil
        local lastVelocityPos = nil
        function events.entity_init()
            velocityPos = player:getPos()
            lastVelocityPos = player:getPos()
        end
        function events.tick()
            velocityPos = player:getPos()
            playervelocity = (velocityPos-lastVelocityPos)/1.8315
            lastVelocityPos = player:getPos()
        end
    end
    -- Helper Functions
    local function look_dir_angle()
        local playerLookDir = player:getLookDir()
        local angle = -math.atan( playerLookDir[3] / playerLookDir[1] )
    
        -- we don't know if we are above or below 0 yet
        angle = angle * 180/math.pi - 90
        if 0 > playerLookDir[1] then
            angle = angle + 180
        end
        --range from -180 to 180
        return angle
    end
    function lerp(a, b, x)
        return a + (b - a) * x
    end
    function lerp_3d(a, b, x)
        return vec(lerp(a.x,b.x,x),lerp(a.y,b.y,x),lerp(a.z,b.z,x))
    end
    function clamp(value,low,high)
        return math.min(math.max(value, low), high)
    end
    local function angle(a,b)
        local aa = math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z)
        local bb = math.sqrt(b.x*b.x+b.y*b.y+b.z*b.z)
        local ab = a.x*b.x+a.y*b.y+a.z*b.z
        return math.acos(ab/(aa*bb))
    end
    local function move_direction()
        local vel = playervelocity
        vel = vec(vel[1],0,vel[3])
        vel = vel:normalized()
    
        local dir = player:getLookDir()
        dir = vec(dir[1],0,dir[3])
        dir = dir:normalized()
    
        local speed = vel[1]+vel[3]
    
        local angle = angle(vel,dir)
    
        if speed == 0 or tostring(speed) == "nan" then
            return "standing"
        elseif math.floor(angle) == 0 then
            return "forward"
        elseif math.floor(angle) == 1 then
            return "sideways"
        else
            return "backward"
        end
    end
    
    local HeadDir = 0
    local lastHeadDir = 0
    local speed = 0
    local lastSpeed = 0
    local capeRot = vec(0,0,0)
    local lastCapeRot = vec(0,0,0)
    local bAdd = 0.2
    local bTime = 1

    local lastHairSidewaysSwinging = 0
    local hairSidewaysSwinging = 0

    -- Cape physics
    local function capePhysics()
        -- ============== Store for next tick ==============
        lastHeadDir = HeadDir
        lastSpeed = speed
        lastCapeRot = capeRot
        lastHairSidewaysSwinging = hairSidewaysSwinging

        -- ============== Sideways rotation swinging ==============
        HeadDir = look_dir_angle() + 180 -- add 180 so its between 0 and 360

        -- rotation difference from last tick
        local diff = lastHeadDir-HeadDir

        -- Fix glitchiness when going over the border from 0 to 360 or other direction
        -- Just check if diff is over 330 or something
        if diff > 330 or diff < -330 then
            diff = (360-lastHeadDir)-HeadDir
        end

        hairSidewaysSwinging = diff

        -- ============== Movement swinging ==============
        speed = math.sqrt(math.pow(playervelocity.x,2) + math.pow(playervelocity.z,2))*(-350)
        
        -- make diff dependent on speed
        diff = diff*(-speed/50)
        diff = clamp(diff, -45, 45)

        speed = clamp(lerp(lastSpeed,speed,0.3), -70, 0)

        -- check which direction the player is moving
        local moveDirection = move_direction()
        if moveDirection == "standing" then
            -- in this case the cape should not be rotated away from the player
            -- dont just set to 0, instead smooth transition
            speed = lastSpeed/2
        elseif moveDirection == "backward" then
            -- in this case do a little swinging animation, like optifine does it
            speed = speed / bTime
            if bTime > 1.7 and bAdd == 0.2 then
                bAdd = -0.2
            elseif bTime < 1.4 and bAdd == -0.2 then
                bAdd = 0.2
            end
            bTime = bTime + bAdd
        end

        if player:getPose() == "SWIMMING" then
            speed = 0
        end

        -- ============== Model rotations to apply in render() ==============
        capeRot = vec(speed, 0, diff)
    end
    function events.tick()
        capePhysics()
    end
    function events.render(delta, context)
        cape_rotation = lerp_3d(lastCapeRot, capeRot, delta)
        hair_sideways_swinging = lerp(lastHairSidewaysSwinging, hairSidewaysSwinging, delta)
    end
end

mainPage = action_wheel:newPage()

local characterSwitch = mainPage:newAction()
characterSwitch:item('minecraft:player_head{SkullOwner:{Id:[I;-550873673,589579375,-1908560700,1329827380],Properties:{textures:[{Value:"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZTY1ZjMwMGI1N2QwMzYyYzcxNDI3MjM0OTM1M2E5M2YzZTUwMTI0NTNjYjkwM2M5NDdmZTkyNjY5ZTVjYmFjYyJ9fX0="}]}}}')

function pings.characterSwitch(a)
    zelda = a
    if zelda then
        characterSwitch:item('minecraft:player_head{SkullOwner:{Id:[I;-550873673,589579375,-1908560700,1329827380],Properties:{textures:[{Value:"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZTY1ZjMwMGI1N2QwMzYyYzcxNDI3MjM0OTM1M2E5M2YzZTUwMTI0NTNjYjkwM2M5NDdmZTkyNjY5ZTVjYmFjYyJ9fX0="}]}}}')
        characterSwitch:title("Switch to Link")
    else
        characterSwitch:item('minecraft:player_head{SkullOwner:{Id:[I;217038883,327174434,-1965079918,995364097],Properties:{textures:[{Value:"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvODdkNzUxODgyNjk0ZGYzNDg1MjA0MDI3MDczZmQ0NjRiM2IwZjljNjNhODkzMWE3MGEyZTUwYTU4MTNlNDUwOSJ9fX0="}]}}}')
        characterSwitch:title("Switch to Zelda")
    end
end

local armsSwitch = mainPage:newAction()
function pings.armsSwitch(a)
    thin = a
    if thin then
        armsSwitch:item("minecraft:oak_log")
        armsSwitch:title("Thicc arms")
    else
        armsSwitch:item("minecraft:stick")
        armsSwitch:title("Thin arms")
    end
    models.player_model.Player.RightArm.RightArmThin:setVisible(thin)
    models.player_model.Player.RightArm.RightArmLayerThin:setVisible(thin)
    models.player_model.Player.RightArm.RightArm:setVisible(not thin)
    models.player_model.Player.RightArm.RightArmLayer:setVisible(not thin)
    models.player_model.Player.LeftArm.LeftArmThin:setVisible(thin)
    models.player_model.Player.LeftArm.LeftArmLayerThin:setVisible(thin)
    models.player_model.Player.LeftArm.LeftArm:setVisible(not thin)
    models.player_model.Player.LeftArm.LeftArmLayer:setVisible(not thin)
end
pings.characterSwitch(zelda)
pings.armsSwitch(thin)


characterSwitch:onLeftClick(function ()
    pings.characterSwitch(not zelda)
end)
armsSwitch:onLeftClick(function ()
    pings.armsSwitch(not thin)
end)

function host_tick()
    -- Runs every tick on the host
    if world:getTime()%(5*20)==0 then -- every 5 seconds
        pings.characterSwitch(zelda)
        pings.armsSwitch(thin)
    end
end
do
    function generateID()
        local characterSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-={}|[]`~"
        local ret = ""
        for i = 1, 98 do
            local rand = math.random(#characterSet)
            ret = ret .. string.sub(characterSet, rand, rand)
        end
        return ret
    end
    local isHost = false
    local myid = generateID();
    function pings.host(id) if myid == id then isHost = true end end
    pings.host(myid)
    function events.tick() if isHost then host_tick() end end
end

function armorSelection()
    local helmet = player:getItem(6).id
    local chestplate = player:getItem(5).id
    local leggings = player:getItem(4).id
    local boots = player:getItem(3).id

    local uvH = vec(0,0)
    local uvC = vec(0,0)
    local uvL = vec(0,0)

    local uvLeather = vec(1,0)
    local uvGold = vec(2,0)
    local uvChain = vec(3,0)
    local uvIron = vec(4,0)
    local uvDiamond = vec(5,0)
    local uvNether = vec(6,0)

    models.player_model.Player.Head.HairBack:setVisible(not zelda)
    models.player_model.Player.Head.HairLeft:setVisible(not zelda)
    models.player_model.Player.Head.HairRight:setVisible(not zelda)
    models.player_model.Player.Head.LeftEar:setVisible(true)
    models.player_model.Player.Head.RightEar:setVisible(true)

    models.player_model.Player.Body.Cape:setVisible(false)
    models.player_model.Player.Body.CapeTriangle:setVisible(false)
    models.player_model.Player.Body.CapeLeft:setVisible(false)
    models.player_model.Player.Body.CapeRight:setVisible(false)
    models.player_model.Player.Head.SheikahHair:setVisible(false)
    models.player_model.Player.Head.Feather:setVisible(false)
    models.player_model.Player.Head.AncientHelmet:setVisible(false)
    models.player_model.Player.Head.ThunderHelm:setVisible(false)

    models.player_model.Player.Head.GerudoHair:setVisible(false)
    models.player_model.Player.Head.HairZelda:setVisible(zelda)
    models.player_model.Player.Head.HairKnight:setVisible(false)

    models.player_model.Player.Body.Cape:setUV(vec(0,0))

    if helmet == "minecraft:leather_helmet" then
        uvH = uvLeather
        models.player_model.Player.Body.Cape:setVisible(not zelda)
        models.player_model.Player.Body.CapeTriangle:setVisible(zelda)
        models.player_model.Player.Body.CapeLeft:setVisible(zelda)
        models.player_model.Player.Body.CapeRight:setVisible(zelda)
        models.player_model.Player.Head.HairZelda:setVisible(false)
    elseif helmet == "minecraft:golden_helmet" then
        uvH = uvGold
        models.player_model.Player.Head.ThunderHelm:setVisible(not zelda)
        models.player_model.Player.Head.GerudoHair:setVisible(zelda)
        models.player_model.Player.Head.HairZelda:setVisible(false)
    elseif helmet == "minecraft:chainmail_helmet" then
        uvH = uvChain
        models.player_model.Player.Head.HairBack:setVisible(false)
        models.player_model.Player.Head.SheikahHair:setVisible(true)
        models.player_model.Player.Head.HairZelda:setVisible(false)
        if zelda then
            models.player_model.Player.Head.SheikahHair.HairCube:setUV(0, TEXTURE_SIZE/TEXTURE_GRID/TEXTURE_SIZE)
        else
            models.player_model.Player.Head.SheikahHair.HairCube:setUV(vec(0,0))
        end
    elseif helmet == "minecraft:iron_helmet" then
        uvH = uvIron
        models.player_model.Player.Head.Feather:setVisible(not zelda)
        models.player_model.Player.Head.HairBack:setVisible(false)
        models.player_model.Player.Head.HairKnight:setVisible(zelda)
        models.player_model.Player.Head.HairZelda:setVisible(false)
        -- models.player_model.Player.Head.LeftEar:setVisible(false)
        -- models.player_model.Player.Head.RightEar:setVisible(false)
    elseif helmet == "minecraft:diamond_helmet" then
        uvH = uvDiamond
    elseif helmet == "minecraft:netherite_helmet" then
        uvH = uvNether
        models.player_model.Player.Head.AncientHelmet:setVisible(true)
        models.player_model.Player.Head.HairBack:setVisible(false)
        models.player_model.Player.Head.LeftEar:setVisible(false)
        models.player_model.Player.Head.RightEar:setVisible(false)
    end

    if chestplate == "minecraft:elytra" then
        if leggings == "minecraft:leather_leggings" then
            chestplate = "minecraft:leather_chestplate"
        elseif leggings == "minecraft:golden_leggings" then
            chestplate = "minecraft:golden_chestplate"
        elseif leggings == "minecraft:chainmail_leggings" then
            chestplate = "minecraft:chainmail_chestplate"
        elseif leggings == "minecraft:iron_leggings" then
            chestplate = "minecraft:iron_chestplate"
        elseif leggings == "minecraft:diamond_leggings" then
            chestplate = "minecraft:diamond_chestplate"
        elseif leggings == "minecraft:netherite_leggings" then
            chestplate = "minecraft:netherite_chestplate"
        end
    end

    if chestplate == "minecraft:leather_chestplate" then
        uvC = uvLeather
    elseif chestplate == "minecraft:golden_chestplate" then
        uvC = uvGold
    elseif chestplate == "minecraft:chainmail_chestplate" then
        uvC = uvChain
        models.player_model.Player.Body.Cape:setVisible(true)
        if zelda then
            models.player_model.Player.Body.Cape:setUV(42/TEXTURE_SIZE,-9/TEXTURE_SIZE)
        else
            models.player_model.Player.Body.Cape:setUV(29/TEXTURE_SIZE,12/TEXTURE_SIZE)
        end
    elseif chestplate == "minecraft:iron_chestplate" then
        uvC = uvIron
    elseif chestplate == "minecraft:diamond_chestplate" then
        uvC = uvDiamond
    elseif chestplate == "minecraft:netherite_chestplate" then
        uvC = uvNether
    end

    if leggings == "minecraft:leather_leggings" then
        uvL = uvLeather
    elseif leggings == "minecraft:golden_leggings" then
        uvL = uvGold
    elseif leggings == "minecraft:chainmail_leggings" then
        uvL = uvChain
    elseif leggings == "minecraft:iron_leggings" then
        uvL = uvIron
    elseif leggings == "minecraft:diamond_leggings" then
        uvL = uvDiamond
    elseif leggings == "minecraft:netherite_leggings" then
        uvL = uvNether
    end

    if zelda then
        uvH = vec(uvH[1]/TEXTURE_GRID,(1+uvH[2])/TEXTURE_GRID)
        uvC = vec(uvC[1]/TEXTURE_GRID,(1+uvC[2])/TEXTURE_GRID)
        uvL = vec(uvL[1]/TEXTURE_GRID,(1+uvL[2])/TEXTURE_GRID)
    else
        uvH = vec(uvH[1]/TEXTURE_GRID,uvH[2]/TEXTURE_GRID)
        uvC = vec(uvC[1]/TEXTURE_GRID,uvC[2]/TEXTURE_GRID)
        uvL = vec(uvL[1]/TEXTURE_GRID,uvL[2]/TEXTURE_GRID)
    end

    models.player_model.Player.Head.Head:setUV(uvH)
    models.player_model.Player.Head.HatLayer:setUV(uvH)
    models.player_model.Player.Body.Body:setUV(uvC)
    models.player_model.Player.Body.BodyLayer:setUV(uvC)
    models.player_model.Player.RightArm.RightArm:setUV(uvC)
    models.player_model.Player.RightArm.RightArmLayer:setUV(uvC)
    models.player_model.Player.RightArm.RightArmThin:setUV(uvC)
    models.player_model.Player.RightArm.RightArmLayerThin:setUV(uvC)
    models.player_model.Player.LeftArm.LeftArm:setUV(uvC)
    models.player_model.Player.LeftArm.LeftArmLayer:setUV(uvC)
    models.player_model.Player.LeftArm.LeftArmThin:setUV(uvC)
    models.player_model.Player.LeftArm.LeftArmLayerThin:setUV(uvC)
    models.player_model.Player.RightLeg.RightLeg:setUV(uvL)
    models.player_model.Player.RightLeg.RightLegLayer:setUV(uvL)
    models.player_model.Player.LeftLeg.LeftLeg:setUV(uvL)
    models.player_model.Player.LeftLeg.LeftLegLayer:setUV(uvL)

    if not (string.find(helmet, "minecraft") ~= nil and string.find(helmet, "helmet") ~= nil) or string.find(helmet, "turtle") ~= nil then
        vanilla_model.HELMET:setVisible(true)
    else
        vanilla_model.HELMET:setVisible(false)
    end

    if not (string.find(chestplate, "minecraft") ~= nil and (string.find(chestplate, "chestplate") ~= nil or string.find(chestplate, "tunic") ~= nil)) then
        vanilla_model.CHESTPLATE:setVisible(true)
    else
        vanilla_model.CHESTPLATE:setVisible(false)
    end

    if not (string.find(leggings, "minecraft") ~= nil and string.find(leggings, "leggings") ~= nil) then
        vanilla_model.LEGGINGS:setVisible(true)
    else
        vanilla_model.LEGGINGS:setVisible(false)
    end

    if not (string.find(boots, "minecraft") ~= nil and string.find(boots, "boots") ~= nil) then
        vanilla_model.BOOTS:setVisible(true)
    else
        vanilla_model.BOOTS:setVisible(false)
    end
end

playerRot = 0
playerPos = 0
lastPlayerRot = 0
lastPlayerPos = 0

function events.render(delta)
    models.player_model.Player.Body.Cape:setRot(cape_rotation)
    models.player_model.Player.Body.CapeTriangle:setRot(cape_rotation)
    models.player_model.Player.Body.CapeLeft:setRot(cape_rotation.x*0.9, cape_rotation.x*0.3, cape_rotation.z*1.6)
    models.player_model.Player.Body.CapeRight:setRot(cape_rotation.x*0.9, -cape_rotation.x*0.3, cape_rotation.z*1.6)
    models.player_model.Player.Body.SheikahSlate:setRot(cape_rotation*0.5)
    models.player_model.Player.Head.Feather.F2:setRot(cape_rotation*1.2)
    local hair_factor = 0
    if player:getPose() ~= "FALL_FLYING" then hair_factor = -vanilla_model.HEAD:getOriginRot()[1] end
    local hair_crouch = 0
    if player:getPose() == "CROUCHING" then hair_crouch = vec(-25,0,0) end
    local hair_rotation = vec(hair_factor,0,0)
    local hair_rotation_clamped = vec(clamp(hair_factor, -90, 0),0,0)
    models.player_model.Player.Head.HairZelda:setRot(cape_rotation*0.8+hair_rotation+hair_crouch)
    models.player_model.Player.Head.HairBack:setRot(cape_rotation*0.8+hair_rotation_clamped)
    local hair_sideways_swinging_rotation = vec(0,0,hair_sideways_swinging)
    models.player_model.Player.Head.HairLeft:setRot(cape_rotation*0.5+hair_rotation-hair_sideways_swinging_rotation)
    models.player_model.Player.Head.HairRight:setRot(cape_rotation*0.5+hair_rotation-hair_sideways_swinging_rotation)
    models.player_model.Player.Head.GerudoHair.GerudoHair1:setRot(cape_rotation*0.3)
    models.player_model.Player.Head.GerudoHair.GerudoHair1.GerudoHair2:setRot(cape_rotation*0.45+hair_rotation)

    local wind = vec((vanilla_model.LEFT_LEG:getOriginRot()[1]*180/3.14159)/10,0,0)
    models.player_model.Player.Head.HairKnight.bone:setRot(cape_rotation+hair_rotation+hair_crouch)
    models.player_model.Player.Head.HairKnight.bone.bone1:setRot(wind)
    models.player_model.Player.Head.HairKnight.bone.bone1.bone2:setRot(wind)
    models.player_model.Player.Head.HairKnight.bone.bone1.bone2.bone3:setRot(wind)
    models.player_model.Player.Head.HairKnight.bone.bone1.bone2.bone3.bone4:setRot(wind)

    if player:getPose() == "FALL_FLYING" then
        local r = lerp(lastPlayerRot, playerRot, delta)
        local d = lerp(lastPlayerPos, playerPos, delta)
        models.player_model.Player.Paraglider:setVisible(true)
        models.player_model.Player:setRot(90,0,0)
        models.player_model.Player:setPos(0,25,-d)
        models.player_model.Player.Paraglider:setPos(0,24,0)

        models.player_model.Player.Head:setRot(-45,0,0)
        models.player_model.Player.RightArm:setRot(180,0,0)
        models.player_model.Player.LeftArm:setRot(180,0,0)
    else
        models.player_model.Player.Paraglider:setVisible(false)
        models.player_model.Player:setRot(0,0,0)
        models.player_model.Player.Head:setRot(0,0,0)
        models.player_model.Player:setPos(0,0, 0)
        models.player_model.Player.RightArm:setRot(0,0,0)
        models.player_model.Player.LeftArm:setRot(0,0,0)
        models.player_model.Player.Paraglider:setPos(0,0,0)
    end
end

function events.tick()
    lastPlayerRot = playerRot
    lastPlayerPos = playerPos
    if player:getPose() == "FALL_FLYING" then
        if playerRot < 90 then
            playerRot = playerRot + 0
        end
        if playerPos < 30 then
            playerPos = playerPos + 10
        end
    else
        playerRot = 0
        playerPos = 0
    end
    armorSelection()
end

action_wheel:setPage(mainPage)