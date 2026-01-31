-- cloth cape by manuel_2867

---------------------Settings----------------------
local flatVariant = false
local useVanillaCapeTexture = false
local gravity = 0.025
local velocityDamping = 0.7
local extraLighting = 0.6
local bodyZ = 2
---------------------------------------------------

vanilla_model.CAPE:setVisible(false)
models.clothcape.cloth:visible(flatVariant)
models.clothcape.cloth2:visible(not flatVariant)
local cape = flatVariant and models.clothcape.cloth.mesh or models.clothcape.cloth2.mesh
if useVanillaCapeTexture then
    models.clothcape:primaryTexture("CAPE")
end

-- merge vertices in same locations
local merged = {}
for _, vertices in pairs(cape:getAllVertices()) do
    for _, vertex in ipairs(vertices) do
        local p = vertex:getPos()
        local s = p.x..p.y
        merged[s] = merged[s] or {}
        table.insert(merged[s],vertex)
    end
end

-- sort vertices
local sorted = {}
for _, list in pairs(merged) do
    -- sort inner vertex lists by z to later split
    table.sort(list,function(a,b)
        return a:getPos().z < b:getPos().z
    end)
    table.insert(sorted,list)
end
-- sort grid by y and x
table.sort(sorted,function(a,b)
    if a[1]:getPos().y == b[1]:getPos().y then
        return a[1]:getPos().x < b[1]:getPos().x
    end
    return a[1]:getPos().y > b[1]:getPos().y
end)

-- debug test if sorting worked (disable other vertex modification first)
-- for i, list in ipairs(sorted) do
--     for _, vert in ipairs(list) do
--         vert:setPos(vert:getPos()+vec(0,0,i/10))
--     end
-- end

-- create grid out of sorted vertices
local gridL1 = {} -- main layer (simulated)
local gridL2 = {} -- second layer (follow)
local width
for i, list in ipairs(sorted) do
    if width then
        if width ~= list[1]:getPos().y then
            width = i-1
            break
        end
    else
        width = list[1]:getPos().y
    end
end
for i, list in ipairs(sorted) do
    local x = ((i-1) % width) + 1
    local y = math.floor((i-1) / width) + 1
    -- split layers by z
    local L1 = {}
    local L2 = {}
    local layer = L1
    table.insert(layer,list[1])
    for n = 2, #list do
        -- z is ordered, split when value changes
        if list[n-1]:getPos().z ~= list[n]:getPos().z then
            layer = L2
        end
        table.insert(layer,list[n])
    end
    gridL1[x] = gridL1[x] or {}
    gridL2[x] = gridL2[x] or {}
    gridL1[x][y] = L1
    gridL2[x][y] = L2
end

-- if no second layer found remove it entirely
-- in order to make the flat variant work
if not gridL2[1][1][1] then
    gridL2 = nil
    -- adjust body distance for flat variant
    -- because it is now simulating the farther layer
    bodyZ = bodyZ + 1
end

-- debug test if grid worked (disable other vertex modification first)
-- for x=1,#gridL1 do
--     for y=1,#(gridL1[1]) do
--         for _, vert in ipairs(gridL1[x][y]) do
--             vert:setPos(vert:getPos()+vec(0,0,(x+y)))
--         end
--     end
-- end

-- helper function to get vertex as world position
local function getWPos(list)
    return cape:partToWorldMatrix():apply((list[1]:getPos()))
end

-- init current and previous vertex positions grid
local _positions = {}
local positions = {}
function events.entity_init()
    for x=1,#gridL1 do
        for y=1,#(gridL1[1]) do
            positions[x] = positions[x] or {}
            _positions[x] = _positions[x] or {}
            positions[x][y] = getWPos(gridL1[x][y])
            _positions[x][y] = getWPos(gridL1[x][y])
        end
    end
end

-- helper functions to get/set vertex positions in position array except for fixed first row
local function getFPos(x,y)
    if y == 1 then
        return getWPos(gridL1[x][y])
    else
        return positions[x][y]
    end
end
local function setFPos(x,y,p)
    positions[x][y] = p
end

-- partToWorldMatrix tick delay workaround estimation by adding velocity
local _vel = vec(0,0,0)
local vel = vec(0,0,0)

local normals = {}

-- main physics calculation
function events.tick()
    -- verlet
    for x=1,#gridL1 do
        for y=2,#(gridL1[1]) do
            local oldPos = positions[x][y]
            local pos = positions[x][y]
            local velocity = pos - _positions[x][y]
            pos = pos + velocity*velocityDamping + vec(0,-gravity,0)
            setFPos(x,y,pos)
            _positions[x][y] = oldPos
        end
    end
    -- constraints and normals
    for x=1,#gridL1 do
        for y=2,#(gridL1[1]) do
            -- constraints
            local delta = getFPos(x,y-1)-getFPos(x,y)
            local distance = delta:length()
            local correction = distance - 0.0625 -- 1/16 = one pixel target length
            setFPos(x,y,getFPos(x,y)+delta:normalized()*correction)
            -- normals
            local neighbor
            normals[x] = normals[x] or {}
            if x == 1 then
                neighbor = getFPos(x+1,y)-getFPos(x,y)
                normals[x][y] = neighbor:crossed(delta):normalized()
            else
                neighbor = getFPos(x-1,y)-getFPos(x,y)
                normals[x][y] = delta:crossed(neighbor):normalized()
            end
        end
    end
    -- ptw workaround
    _vel = vel
    vel = player:getVelocity()
end

-- render smoothing second layer calculation and normals
local lightingNormal = vec(0,extraLighting,0)
function events.render(delta)
    local wtp = cape:partToWorldMatrix():invert()
    local v = math.lerp(_vel, vel, delta)
    for x=1,#gridL1 do
        for y=2,#(gridL1[1]) do
            -- first layer simulated pos
            local pos = wtp:apply(math.lerp(_positions[x][y],positions[x][y],delta)+v)
            pos.z = math.max(bodyZ,pos.z)
            local normal = wtp:applyDir(normals[x][y]):normalized()
            for _, vert in ipairs(gridL1[x][y]) do
                vert:setPos(pos)
                vert:setNormal(normal+lightingNormal)
            end
            if gridL2 then
                -- second layer equals first layer shifted by normal
                local pos2 = pos+normal
                for _, vert in ipairs(gridL2[x][y]) do
                    vert:setPos(pos2)
                    vert:setNormal(normal+lightingNormal)
                end
            end
        end
    end
    -- finish up with the locked first row
    for x=1,#gridL1 do
        local normal = wtp:applyDir(normals[x][2]):normalized()
        for i = 1, #(gridL1[x][1]) do
            gridL1[x][1][i]:setNormal(normal+lightingNormal)
            if gridL2 then
                gridL2[x][1][i]:setNormal(normal+lightingNormal)
                gridL2[x][1][i]:setPos(gridL1[x][1][i]:getPos()+normal)
            end
        end
    end
end
