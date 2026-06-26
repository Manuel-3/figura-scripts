-- water sim by manuel_2867

------------
-- CONFIG --
------------

-- How strongly container movement affects water
local ACCELERATION_FORCE = 2
-- How strongly water wants to become flat
local RESTORING_FORCE = 0.4
-- How strongly neighboring cells influence each other
local WAVE_SPREAD = 1
-- Energy loss per tick (1 = no damping, 0 = instant stop)
local DAMPING = 0.81
-- Maximum height displacement
local MAX_WAVE_HEIGHT = 4
local MAX_WAVE_DEPTH = -10
-- Base water height
local WATER_LEVEL = 23
-- Bottom of water height
local GROUND_HEIGHT = 11
-- How strongly the water follows gravity slope
local GRAVITY_SLOPE_FORCE = 45
-- How quickly the water settles into the new orientation
local GRAVITY_SLOPE_SPEED = 0.2
-- Scale of the water block
local WATER_SCALE = 0.85
-- Extra opacity to make the fish more visible
local WATER_OPACITY = 0.85
-- Where the waterspace group is
local WATER_SPACE = models.model.Body.waterspace
-- Speed of the water texture animation
local TEXTURE_ANIMATION_SPEED = 0.5

---------------------------------
-- DO NOT EDIT BELOW THIS LINE --
---------------------------------

local Task = require("./task")
local heapsort = require("./sort")

-- Model Parts
local water = WATER_SPACE.water:scale(WATER_SCALE,WATER_SCALE,WATER_SCALE):opacity(WATER_OPACITY):visible(false)

local curVelocity = vec(0, 0, 0)
local prevVelocity = vec(0, 0, 0)
--- Player acceleration function
local function getContainerAcceleration()
  prevVelocity = curVelocity
  curVelocity = WATER_SPACE:partToWorldMatrix():invert():applyDir(player:getVelocity())
  return curVelocity - prevVelocity
end

--- Calculate "down"
local function getDownDirectionInLocalSpace()
  return WATER_SPACE:partToWorldMatrix():invert():applyDir(0,-1,0):normalized()
end

--- Vector to String
---@param pos Vector3
local function serialize(pos)
  return string.format("%.3f", pos.x) .. ";" .. string.format("%.3f", pos.y) .. ";" .. string.format("%.3f", pos.z)
end

--- Grid Coords to Index
---@param x number
---@param y number
---@param width number
---@return number
local function xyToIndex(x, y, width)
  return x + y * width
end

--- Index to Grid Coords
---@param index number
---@param width number
---@return number
---@return number
local function indexToXy(index,width)
  return index%width,math.floor(index/width)
end

--- Group vertices together efficiently
---@param list Vertex[]
---@return {setPos:fun(y:number),getPos:fun():Vector3}
local function newGroup(list)
  local function getPos()
    return list[1]:getPos()
  end
  local function setPos(y)
    local x,_,z = getPos():unpack()
    for _, value in ipairs(list) do
      value:setPos(x,y,z)
    end
  end
  return {
    getPos=getPos,
    setPos = setPos
  }
end

-- Animated water texture
local texture = textures:fromVanilla("water", "minecraft:textures/block/water_still.png")
local w, h = texture:getDimensions():unpack()
local framecount = h / w
local frame = 0
local mat = matrices.mat3()
water:primaryTexture("CUSTOM", texture)
local watercolor
events.ENTITY_INIT:register(function ()
  watercolor = world.getBiome(player:getPos()):getWaterColor()
end)
function events.tick()
  frame = (frame + TEXTURE_ANIMATION_SPEED) % framecount
  mat:reset():scale(WATER_SCALE, (1 / framecount)*WATER_SCALE):translate(0, (math.floor(frame) / framecount)/WATER_SCALE)
  water:setUVMatrix(mat)
  watercolor = math.lerp(watercolor,world.getBiome(player:getPos()):getWaterColor(),0.035)
  water:setColor(watercolor)
end

-- Grid size, how many vertices are there on the square plane in both x and z
local gridsize = 10
-- Fluid simulation data
local simulation_disabled = true
local fluidinfo = {}
local newfluid = {}
-- Organize vertices
local vertices = {}
local unsorted = {}
local ground = {}
local grouped = {}
local _, vs = next(water:getAllVertices())
-- Water drained state
local drained = true

Task(1,#vs,function(i)
  local vertex = vs[i]
  -- Split ground layer and water layer
  if vertex:getPos().y == 0 then
    table.insert(ground,vertex)
  else
    local key = serialize(vertex:getPos())
    if not grouped[key] then
      local t = {}
      grouped[key] = t
      table.insert(unsorted, t)
    end
    table.insert(grouped[key], vertex)
  end
end,
function()
  -- Move ground
  for _, value in ipairs(ground) do
    local pos = value:getPos()
    value:setPos(
      pos.x,
      GROUND_HEIGHT,
      pos.z
    )
  end
  -- Sort into grid shape
  heapsort(unsorted, function(a, b)
    local ap = a[1]:getPos()
    local bp = b[1]:getPos()
    if ap.z == bp.z then
      return ap.x < bp.x
    end
    return ap.z < bp.z
  end,function(result)
    -- Group same position vertices
    vertices = result
    Task(1,#vertices,function(index)
      vertices[index] = newGroup(vertices[index])
      local x, y = indexToXy(index-1, gridsize)
      fluidinfo[x] = fluidinfo[x] or {}
      local neighbors = {
        { x + 1, y },
        { x - 1, y },
        { x, y + 1 },
        { x, y - 1 },
      }
      local px = x/(gridsize-1) - 0.5
      local pz = y/(gridsize-1) - 0.5
      local offsetX = x / gridsize - 0.5
      local offsetZ = y / gridsize - 0.5
      fluidinfo[x][y] = { height = 0, _height=0, velocity = 0, neighbors=neighbors,px=px,pz=pz,offsetX=offsetX,offsetZ=offsetZ }
    end,function()
      -- Preparations complete
      drained = config:load("drained") or false
      simulation_disabled = false
    end)
  end)
end)

-- Fluid simulation
local acc = nil
local down = nil
local tickcounter = 1
function events.tick()
  if simulation_disabled then return end
  tickcounter = tickcounter + 1
  local parity = tickcounter % 2 == 0

  if parity then
    acc = getContainerAcceleration()
    down = getDownDirectionInLocalSpace()
  end

  local gravityX = down.x
  local gravityZ = down.z

  local forceX = -acc.x
  local forceZ = -acc.z

  -- Split computation between even and odd ticks
  -- Even first half, odd second half
  local xfrom = parity and 0 or gridsize/2
  local xto = parity and gridsize/2-1 or gridsize-1

  for x = xfrom, xto do
    newfluid[x] = {}
    for y = 0, gridsize - 1 do

      local info = fluidinfo[x][y]

      local height = info.height
      local velocity = info.velocity
      local neighbors = info.neighbors

      -- Gravity
      local targetHeight =
        (gravityX * info.px + gravityZ * info.pz)
        * GRAVITY_SLOPE_FORCE
      velocity = velocity 
        + (targetHeight - height)
        * GRAVITY_SLOPE_SPEED

      -- Container movement force
      velocity = velocity
        + forceX * info.offsetX * ACCELERATION_FORCE
        + forceZ * info.offsetZ * ACCELERATION_FORCE

      -- Neighbor wave propagation
      local average = 0
      local count = 0
      for _, n in ipairs(neighbors) do
        local nx = n[1]
        local ny = n[2]
        if nx >= 0 and nx < gridsize
            and ny >= 0 and ny < gridsize then
          average = average + fluidinfo[nx][ny].height
          count = count + 1
        end
      end
      if count > 0 then
        average = average / count
        velocity = velocity + (average - height) * WAVE_SPREAD
      end

      -- Gravity / surface tension
      velocity = velocity - height * RESTORING_FORCE

      -- Damping
      velocity = velocity * DAMPING

      -- Update height
      height = height + velocity

      -- Clamp waves
      if height > MAX_WAVE_HEIGHT then
        height = MAX_WAVE_HEIGHT
        velocity = 0
        -- Chance to schedule particle spawn whenever instructions are available
        if math.random() < 0.6 then
          Task(1,1,function()
            particles:newParticle("minecraft:splash",WATER_SPACE:partToWorldMatrix():apply(vertices[xyToIndex(x,y,gridsize)+1]:getPos()))
          end)
        end
      elseif height < MAX_WAVE_DEPTH then
        height = MAX_WAVE_DEPTH
        velocity = 0
      end

      -- Update point
      newfluid[x][y] = {
        _height = info.height,
        height = height,
        velocity = velocity,
        neighbors=neighbors,
        px=info.px,
        pz=info.pz,
        offsetX=info.offsetX,
        offsetZ=info.offsetZ,
      }
    end
  end

  -- Update fluid on odd ticks (both halfs have been computed)
  if not parity then
    fluidinfo = newfluid
    newfluid = {}
  end
end

-- Start water at ground level always
local waterlevel = GROUND_HEIGHT

Task.SingleRender(function(delta)
  if simulation_disabled then return end
  -- Adjust tick delta according to parity
  local parity = tickcounter % 2 == 0
  delta = delta / 2
  if parity then
    delta = 0.5 + delta
  end
  -- Apply to mesh
  for x = 0, gridsize-1 do
    for y = 0, gridsize-1 do
      vertices[xyToIndex(x,y,gridsize)+1].setPos(waterlevel + math.lerp(fluidinfo[x][y]._height,fluidinfo[x][y].height,delta))
    end
  end
end)

-- Table for fish script to add its drain interaction function later
local waterscript = {}

-- Action wheel

function pings.drained(state)
  drained = state
end

local mainPage = require("./mainpage")

local action
action = mainPage:newAction()
  :title("Drain water"):item("minecraft:water_bucket")
  :toggleTitle("Fill water"):toggleItem("minecraft:bucket")
  :setToggled(config:load("drained") or false)
  :onToggle(function(state)
    if simulation_disabled then
      action:setToggled(not action:isToggled())
      return
    end
    config:save("drained",state)
    pings.drained(state)
  end)

-- Water draining or filling animation
function events.tick()
  water:visible(not simulation_disabled and waterlevel - GROUND_HEIGHT > 0.3)
  local settled = waterlevel - GROUND_HEIGHT < 0.6 or WATER_LEVEL - waterlevel < 1
  if waterscript.setFishSwimming then waterscript.setFishSwimming(not drained) end
  if drained then
    waterlevel = math.lerp(waterlevel, GROUND_HEIGHT, 0.1)
    if not settled then
      for i = 1, 10 do
        particles:newParticle("minecraft:splash",player:getPos():add(0,1,0),vec(math.random()-0.5,0,math.random()-0.5):normalized()*0.2)
      end
    end
  else
    waterlevel = math.lerp(waterlevel, WATER_LEVEL, 0.05)
    if not settled then
      for i = 1, 10 do
        particles:newParticle("minecraft:splash",player:getPos():add(0,1,0),vec(math.random()-0.5,0.1,math.random()-0.5)*0.2)
      end
    end
  end
end

-- Resyncing
if host:isHost() then
  local t = 0
  function events.tick()
    if t % 60 == 30 then
      pings.drained(drained)
    end
    t = t + 1
  end
end

return waterscript