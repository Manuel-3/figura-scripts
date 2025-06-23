local configuration = require("ui")

local playing = true
local time = 0

function configuration.onPlay()
    playing = true
    time = 0
end

function configuration.onPause()
    playing = false
end

local function range(a,b)
    return a + (b - a) * math.random()
end
local function randomsign()
    return math.random(0, 1) * 2 - 1
end
local function randomInSphere(radius)
    -- Generate random spherical coordinates
    local u = math.random()
    local v = math.random()
    local theta = u * 2 * math.pi
    local phi = math.acos(2 * v - 1)
    local r = radius * (math.random() ^ (1/3))  -- Cube root for uniform distribution in volume

    -- Convert spherical to cartesian coordinates
    local sinPhi = math.sin(phi)
    local x = r * sinPhi * math.cos(theta)
    local y = r * sinPhi * math.sin(theta)
    local z = r * math.cos(phi)

    return vec(x, y, z)
end
local function randomOnSphere(radius, spawn)
    spawn = spawn or "Surface"

    local theta, phi

    if spawn == "Outline" then
        local meridians, parallels
        if math.random(2)==1 then
            meridians = 8  -- number of longitudinal lines
            parallels = 365  -- number of latitudinal lines
        else
            meridians = 365  -- number of longitudinal lines
            parallels = 8  -- number of latitudinal lines
        end

        -- Choose random discrete theta and phi values
        theta = (math.random(0, meridians - 1) / meridians) * 2 * math.pi
        phi = (math.random(0, parallels - 1) / (parallels - 1)) * math.pi
    else
        -- Uniform surface distribution
        local u = math.random()
        local v = math.random()
        theta = u * 2 * math.pi
        phi = math.acos(2 * v - 1)
    end

    local sinPhi = math.sin(phi)
    local x = radius * sinPhi * math.cos(theta)
    local y = radius * sinPhi * math.sin(theta)
    local z = radius * math.cos(phi)

    return vec(x, y, z)
end
local function randomInCircle(radius, pitch, yaw)
    local r = radius * math.sqrt(math.random())
    local theta = math.random() * 2 * math.pi

    -- 2D point on the circle
    local x = r * math.cos(theta)
    local y = r * math.sin(theta)
    local z = 0

    -- Rotate around pitch (x-axis) and yaw (y-axis)
    local cosPitch = math.cos(pitch)
    local sinPitch = math.sin(pitch)
    local cosYaw = math.cos(yaw)
    local sinYaw = math.sin(yaw)

    -- First apply pitch (rotation around x-axis)
    local y1 = y * cosPitch - z * sinPitch
    local z1 = y * sinPitch + z * cosPitch
    local x1 = x

    -- Then apply yaw (rotation around y-axis)
    local x2 = x1 * cosYaw + z1 * sinYaw
    local y2 = y1
    local z2 = -x1 * sinYaw + z1 * cosYaw

    return vec(x2, y2, z2)
end
local function randomOnCircle(radius, pitch, yaw)
    local theta = math.random() * 2 * math.pi

    -- 2D point on the circle
    local x = radius * math.cos(theta)
    local y = radius * math.sin(theta)
    local z = 0

    -- Rotate around pitch (x-axis) and yaw (y-axis)
    local cosPitch = math.cos(pitch)
    local sinPitch = math.sin(pitch)
    local cosYaw = math.cos(yaw)
    local sinYaw = math.sin(yaw)

    -- First apply pitch (rotation around x-axis)
    local y1 = y * cosPitch - z * sinPitch
    local z1 = y * sinPitch + z * cosPitch
    local x1 = x

    -- Then apply yaw (rotation around y-axis)
    local x2 = x1 * cosYaw + z1 * sinYaw
    local y2 = y1
    local z2 = -x1 * sinYaw + z1 * cosYaw

    return vec(x2, y2, z2)
end
local function rotatePoint(point, rot)
    -- Rotate around X-axis
    local cosX = math.cos(rot.x)
    local sinX = math.sin(rot.x)
    local y1 = point.y * cosX - point.z * sinX
    local z1 = point.y * sinX + point.z * cosX

    -- Rotate around Y-axis
    local cosY = math.cos(rot.y)
    local sinY = math.sin(rot.y)
    local x2 = point.x * cosY + z1 * sinY
    local z2 = -point.x * sinY + z1 * cosY

    -- Rotate around Z-axis
    local cosZ = math.cos(rot.z)
    local sinZ = math.sin(rot.z)
    local x3 = x2 * cosZ - y1 * sinZ
    local y3 = x2 * sinZ + y1 * cosZ

    return vec(x3, y3, z2)
end
local function wave(len, magn)
    return math.sin(2 * math.pi * (1/len) * (time/20)) * magn
end
local function cowave(len, magn)
    return math.cos(2 * math.pi * (1/len) * (time/20)) * magn
end
local function hsv(h,s,v)
    return vectors.hsvToRGB(h,s,v)*255
end
local function rnbw(t)
    return hsv(time/(t*20),1,1)
end

local ptcls = {}
function events.render(delta)
    for key, ptcl in pairs(ptcls) do
        if ptcl[2]:isAlive() then
            ptcl[2]:setPos(ptcl[2]:getPos()-ptcl[1]+player:getPos(delta))
            ptcl[1] = player:getPos(delta)
        else
            ptcls[key] = nil
        end
    end
end
local function spawnParticle(origin,pos,offset,color,gravity,collision,scale)
    local ptcl = particles:newParticle(configuration.particle(),origin+pos+offset)
        :setColor(color)
        :setPhysics(collision)
    if configuration.lifetime() ~= nil then
        ptcl:setLifetime(configuration.lifetime())
    end
    if gravity ~= nil then
        ptcl:setGravity(gravity)
    end
    if scale ~= nil then
        ptcl:setScale(scale,scale,scale)
    end
    if configuration.parent() == "Origin" then
        ptcls[client.intUUIDToString(client.generateUUID())]={
            origin,
            ptcl
        }
    end
end

local spawnCount = 0
local knowsEnvStructure = false

local spritetask = models:newSprite("")

function events.tick()
    spritetask:setTexture(configuration.texture(),configuration.texture():getDimensions():unpack())
    spritetask:setUVPixels(configuration.uv()[1],configuration.uv()[2])
    spritetask:setRegion(configuration.uv()[3],configuration.uv()[4])
    local env = setmetatable({
        time=time,
        sin=math.sin,
        cos=math.cos,
        deg=math.deg,
        rad=math.rad,
        wave=wave,
        cowave=cowave,
        hsv=hsv,
        rnbw=rnbw,
        rnd=math.random,
        range=range,
    }, { __index = _ENV })
    if not knowsEnvStructure then
        configuration.notifyEnvStructure(env,{
            time="The amount of ticks this effect has ran for.",
            sin={"sin(value)","Alias for math.sin"},
            cos={"cos(value)","Alias for math.cos"},
            deg={"deg(value)","Alias for math.deg"},
            rad={"rad(value)","Alias for math.rad"},
            wave={"wave(len, magn)","Creates a sine wave with wavelength and magnitude, e.g. wave(2, 5) is a sine wave going from -5 to +5 and takes 2 seconds to complete once."},
            cowave={"cowave(len, magn)","Same as wave but with cosine. Short for \"cos(2 * math.pi * (1/len) * (time/20)) * magn\""},
            hsv={"hsv(h,s,v)","Short for vectors.hsvToRGB(h,s,v)*255"},
            rnbw={"rnbw(t)","Rainbow colors cycling through in t amount of seconds. Short for hsv(time/(t*20),1,1)"},
            rnd={"rnd([a [,b]])","Alias for math.random"},
            range={"range(a, b)","Random float range. Short for math.lerp(a,b,math.random())"},
        })
        knowsEnvStructure = true
    end
    if not playing then return end
    configuration.updateTimer(time)
    local mode = configuration.mode(env)
    local spawn = configuration.spawn(env)
    local shape = configuration.shape(env)
    local rate = configuration.rate(env)
    local pos = configuration.position(env)
    local size = configuration.size(env)
    local rotation = configuration.rotation(env):toRad()
    local radius = configuration.radius(env)/16
    local modelpart
    local origin = configuration.origin(env)
    local color = configuration.color(env)
    local scale = configuration.scale(env)
    local gravity = configuration.gravity(env)
    local collision = configuration.collision(env)
    local mesh = configuration.mesh(env)
    configuration.notifyMesh(mesh)
    if origin == "Modelpart" then
        modelpart = configuration.modelpart(env)
    end
    if mode == "Once" then
        spawnCount = rate
        configuration.pause()
    else
        spawnCount = spawnCount + rate/20
    end
    while spawnCount > 0 do
        spawnCount = spawnCount - 1
        if shape == "Point" then
            spawnParticle(player:getPos(),pos/16,vec(0,0,0),color,gravity,collision,scale)
        elseif shape == "Sphere" then
            local offset
            if spawn == "Volume" then
                offset = randomInSphere(radius)
            else
                offset = randomOnSphere(radius,spawn)
            end
            offset = rotatePoint(offset,rotation)
            spawnParticle(player:getPos(),pos/16,offset,color,gravity,collision,scale)
        elseif shape == "Box" then
            local offset = vec(
                range(-size.x/2,size.x/2)/16,
                range(-size.y/2,size.y/2)/16,
                range(-size.z/2,size.z/2)/16
            )
            if spawn == "Surface" then
                local notPushed = true
                for i=1,3 do
                    if size[i] == 0 then
                        notPushed = false
                        local others = {1,2,3}
                        table.remove(others,i)
                        local chosen2 = others[math.random(2)]
                        offset[chosen2] = randomsign()*(size[chosen2]/2)/16
                    end
                end
                if notPushed then
                    local chosen = math.random(3)
                    offset[chosen] = randomsign()*(size[chosen]/2)/16
                end
            elseif spawn == "Outline" then
                local others = {1,2,3}
                table.remove(others,math.random(3))
                for i=1,2 do
                    offset[others[i]] = randomsign()*(size[others[i]]/2)/16
                end
            end
            offset = rotatePoint(offset,rotation)
            spawnParticle(player:getPos(),pos/16,offset,color,gravity,collision,scale)
        elseif shape == "Disc" then
            local offset
            if spawn == "Surface" then
                offset = randomOnCircle(radius,rotation.x,rotation.y)
            else
                offset = randomInCircle(radius,rotation.x,rotation.y)
            end
            spawnParticle(player:getPos(),pos/16,offset,color,gravity,collision,scale)
        end
    end
    time = time + 1
end