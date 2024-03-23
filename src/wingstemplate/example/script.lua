-- 2D Wings by Manuel_2867

-- Settings
local elytra = false -- set to true if you want the wings to only show up when wearing an elytra
local fold_wings = true -- set to false if you want the wings to always be opened
local open_when_crouching = true -- open wings when crouching
local strength = 12 -- how far the wings flap when flying
local glide_strength = 2 -- how far the wings flap when gliding
local speed = 0.25 -- how fast the wings flap
local rotation_offset = 20 -- default rotation offset of the wings
local curve = 0.3 -- how much the wings should curve when flapping
local idle_curve = 3 -- curves wings when not flying
local fly_rot = 0 -- when flying wings rotation
local fly_pos = 0 -- when flying wings y pos
local ground_rot = 45 -- on ground wings rotation
local ground_pos = 2 -- on ground wings y pos
local transition_speed = 0.15 -- transition speed
local invertRotation = true -- flap the wings the other direction
-- Settings end

vanilla_model.ELYTRA:setVisible(false)

local playervelocity = vec(0,0,0)
local cape_rotation = vec(0,0,0)

-- Calculate cape rotation
do
    local lerp = math.lerp
    local math_floor = math.floor
    local math_acos = math.acos
    local math_max = math.max
    local math_sin = math.sin
    local world_getTime = world.getTime
    local player_getPos = nil
    local player_getRot = nil
    local player_getLookDir = nil
    function events.ENTITY_INIT()
        player_getPos = player.getPos
        player_getRot = player.getRot
        player_getLookDir = player.getLookDir
    end
    do
        local velocityPos = vec(0,0,0)
        local lastVelocityPos = vec(0,0,0)
        function events.ENTITY_INIT()
            velocityPos = player_getPos(player)
            lastVelocityPos = player_getPos(player)
        end
        function events.TICK()
            velocityPos = player_getPos(player)
            playervelocity = (velocityPos-lastVelocityPos)/1.8315
            lastVelocityPos = player_getPos(player)
        end
    end

    local vel = vec(0,0,0)

    local function move_direction()
        local veln = vel:normalized()
        local dir = player_getLookDir(player)
        dir = vec(dir[1],0,dir[3]):normalized()
        return veln:length() == 0 and 0 or math_floor(1+math_acos(veln:dot(dir))*1.4)
    end
    
    local headDir = 0
    local lastHeadDir = 0
    local speed = 0
    local lastSpeed = 0
    local capeRot = vec(0,0,0)
    local lastCapeRot = vec(0,0,0)
    
    local function capePhysics()
        vel = vec(playervelocity[1],0,playervelocity[3])
        
        lastHeadDir = headDir
        lastSpeed = speed
        lastCapeRot = capeRot

        headDir = -player_getRot(player).y
        local diff = lastHeadDir-headDir
        diff = diff*(-speed/50)

        if move_direction() > 3 then
            speed = math_sin(world_getTime()*1)*4-20 -- walk backwards animation
        else
            speed = math_max(lerp(lastSpeed,-vel:length()*350,0.3), -70) -- lerp for slowing down the cape
        end

        capeRot = vec(speed, 0, diff)
    end
    function events.TICK()
        capePhysics()
    end
    function events.RENDER(delta)
        cape_rotation = lerp(lastCapeRot, capeRot, delta)
    end
end

function events.TICK()
    if elytra then
        local x = player:getItem(5).id == "minecraft:elytra"
        models.model.Body.LW:setVisible(x)
        models.model.Body.RW:setVisible(x)
    end
end

local zrot = 0
local _zrot = 0
local zrot_target = ground_rot
local ypos = 0
local _ypos = 0
local ypos_target = ground_pos
local str = 0
local _str = 0
local str_target = strength
local invertMultiplier = invertRotation == true and -1 or 1
local invertStrength = invertRotation == true and 3 or 1
local invertTimeOffset = invertRotation == true and 20 or 0

function events.TICK()
    _zrot = zrot
    zrot = math.lerp(zrot,zrot_target,transition_speed)
    _ypos = ypos
    ypos = math.lerp(ypos,ypos_target,transition_speed)
    _str = str
    str = math.lerp(str,str_target,transition_speed)
    if (player:getPose() == "FALL_FLYING") or (not fold_wings) or (player:getPose() == "CROUCHING" and open_when_crouching) then
        zrot_target = fly_rot
        ypos_target = fly_pos
    else
        zrot_target = ground_rot
        ypos_target = ground_pos
    end
    if playervelocity.y < 0 then
        str_target = glide_strength
    else
        str_target = strength
    end
end

function events.RENDER(delta)
    local zrot_ = math.lerp(_zrot,zrot,delta)
    local str_ = math.lerp(_str,str,delta)
    local crouch_offset = player:getPose() == "CROUCHING" and 2 or 0

    models.model.Body.LW:setPos(0,math.lerp(_ypos,ypos,delta),crouch_offset)
    models.model.Body.RW:setPos(0,math.lerp(_ypos,ypos,delta),crouch_offset)

    local time = world.getTime()+delta
    if player:getPose() == "FALL_FLYING" or (player:getPose() == "CROUCHING" and open_when_crouching) then
        local rl = -(math.sin(time*speed)*str_)*curve
        local rr = (math.sin(time*speed)*str_)*curve

        models.model.Body.LW:setRot(0, rotation_offset-math.sin((invertTimeOffset+time)*speed)*str_*invertMultiplier*(invertStrength/2), zrot_)
        models.model.Body.LW.two:setRot(0, rl*invertStrength, 0)
        models.model.Body.LW.two.three:setRot(0, rl*2*invertStrength, 0)
        models.model.Body.LW.two.three.four:setRot(0, rl*3, 0)
        models.model.Body.LW.two.three.four.five:setRot(0, rl*3, 0)
        models.model.Body.LW.two.three.four.five.six:setRot(0, rl*3, 0)
        models.model.Body.LW.two.three.four.five.six.seven:setRot(0, rl*3, 0)
        models.model.Body.LW.two.three.four.five.six.seven.eight:setRot(0, rl*3, 0)

        models.model.Body.RW:setRot(0, -rotation_offset+math.sin((invertTimeOffset+time)*speed)*str_*invertMultiplier*(invertStrength/2), -zrot_)
        models.model.Body.RW.two2:setRot(0, rr*invertStrength, 0)
        models.model.Body.RW.two2.three2:setRot(0, rr*2*invertStrength, 0)
        models.model.Body.RW.two2.three2.four2:setRot(0, rr*3, 0)
        models.model.Body.RW.two2.three2.four2.five2:setRot(0, rr*3, 0)
        models.model.Body.RW.two2.three2.four2.five2.six2:setRot(0, rr*3, 0)
        models.model.Body.RW.two2.three2.four2.five2.six2.seven2:setRot(0, rr*3, 0)
        models.model.Body.RW.two2.three2.four2.five2.six2.seven2.eight2:setRot(0, rr*3, 0)
    else
        local rl = idle_curve - (cape_rotation.x / 8)
        local rr = (cape_rotation.x / 8) - idle_curve

        models.model.Body.LW:setRot(cape_rotation.x / 8, rotation_offset-(cape_rotation.x / 8), zrot_)
        models.model.Body.LW.two:setRot(0, rl, 0)
        models.model.Body.LW.two.three:setRot(0, rl*1.5, 0)
        models.model.Body.LW.two.three.four:setRot(0, rl*2, 0)
        models.model.Body.LW.two.three.four.five:setRot(0, rl*3.5, 0)
        models.model.Body.LW.two.three.four.five.six:setRot(0, rl*5, 0)
        models.model.Body.LW.two.three.four.five.six.seven:setRot(0, rl*6.5, 0)
        models.model.Body.LW.two.three.four.five.six.seven.eight:setRot(0, rl*8, 0)
    
        models.model.Body.RW:setRot(cape_rotation.x / 8, -rotation_offset+(cape_rotation.x / 8), -zrot_)
        models.model.Body.RW.two2:setRot(0, rr, 0)
        models.model.Body.RW.two2.three2:setRot(0, rr*1.5, 0)
        models.model.Body.RW.two2.three2.four2:setRot(0, rr*2, 0)
        models.model.Body.RW.two2.three2.four2.five2:setRot(0, rr*3.5, 0)
        models.model.Body.RW.two2.three2.four2.five2.six2:setRot(0, rr*5, 0)
        models.model.Body.RW.two2.three2.four2.five2.six2.seven2:setRot(0, rr*6.5, 0)
        models.model.Body.RW.two2.three2.four2.five2.six2.seven2.eight2:setRot(0, rr*8, 0)
    end
end