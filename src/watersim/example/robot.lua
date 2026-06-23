-- Model parts
local model = models.model
local body = model.Body
local column = body.column
local top = body.top
local chain = model.chain
local plate = model.plate
local rightArm = body.rightArm
local arm = rightArm.arm
local power = model.power

-- Texturing
chain.wood:primaryTexture("RESOURCE", "minecraft:textures/block/oak_log.png")
chain.wood:primaryTexture("RESOURCE", "minecraft:textures/block/oak_log.png")
column:primaryTexture("RESOURCE", "minecraft:textures/block/oak_log.png")
top:primaryTexture("RESOURCE", "minecraft:textures/block/oak_log_top.png")
plate:primaryTexture("RESOURCE", "minecraft:textures/block/oak_planks.png")
arm:primaryTexture("RESOURCE", "minecraft:textures/block/gray_wool.png")
arm.wood:primaryTexture("RESOURCE", "minecraft:textures/block/oak_planks.png")
power:primaryTexture("RESOURCE", "minecraft:textures/block/redstone_block.png")

for i = 1, 5 do
  chain["gear"..i]:primaryTexture("RESOURCE", "minecraft:textures/block/andesite.png")
  local axle = chain["gear"..i].axle
  if axle then
    axle:primaryTexture("RESOURCE", "minecraft:textures/block/oak_log.png")
  end
end
for i = 1, 8 do
  chain["rubber"..i]:primaryTexture("RESOURCE", "minecraft:textures/block/black_wool.png")
end

-- Held items
arm.RightItemPivot:scale(0.6)
vanilla_model.LEFT_ITEM:visible(false)

-- Duplicate chain to other side
chain:copy("chain2"):moveTo(models.model):scale(-1,1,1)


local tck = 0
local timer = 0
local ptcl, ptclpos
function events.tick()
  -- Gear rotation
  local fwbckw = math.sign(player:getVelocity():dot(player:getLookDir()))
  tck = tck + player:getVelocity().xz:length()*120*fwbckw

  -- Redstone particles
  timer = timer - 1
  if timer <= 0 then
    timer = math.random(20,60)
    ptcl = particles["minecraft:dust 1 0 0 1"]:spawn()
    ptclpos = vec(math.random()*4,math.random()*3,0)
  end
end

function events.render(delta)
  -- Gear rotation
  local t = tck + delta
  for i = 1, 5 do
    local parity = i % 2 == 0
    local gearratio = (i==1 or i==5) and 1 or 2
    local direction = parity and 1 or -1
    local offset = parity and 45 or 0
    chain["gear"..i]:setRot(direction*t*gearratio+offset,0,0)
  end
  for i = 1, 8 do
    chain["rubber"..i]:setUV(0,-0.0025*t)
  end

  -- Crouch fixes
  local c = player:isCrouching()
  model:setPos(0, c and 2 or 0, 0)
  body:setPos(0, c and 3 or 0, 0)

  -- RightArm animation
  rightArm:setRot(vanilla_model.RIGHT_ARM:getOriginRot()*0.5)

  -- Move particle
  if ptcl then
    ptcl:pos(power:partToWorldMatrix():apply(ptclpos))
  end
end
