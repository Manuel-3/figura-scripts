------------
-- CONFIG --
------------

-- Where the waterspace group is
local WATER_SPACE = models.model.Head.waterspace
-- If the fish should move around a bit, or should be static
local FISH_ROTATION = true
local FISH_POSITION = true
-- Variant
local VARIANT = 65536 -- (Orange-White Kob)
-- local VARIANT = 917504 -- (Red-White Kob)
-- local VARIANT = 918273 -- (Red-White Blockfish)
-- local VARIANT = 918529 -- (Red-White Betty)
-- local VARIANT = 16778497 -- (Orange-LightGray Clayfish)
-- local VARIANT = 50660352 -- (LightBlue-Lime Brinely)
-- local VARIANT = 50726144 -- (LightBlue-Pink Spotty)
-- local VARIANT = 50790656 -- (LightBlue-Gray SunStreak)
-- local VARIANT = 67108865 -- (Yellow-LightGray Flopper)
-- local VARIANT = 67110144 -- (Yellow-LightGray Spotty)
-- local VARIANT = 67371265 -- (Yellow Stripey)
-- local VARIANT = 67764993 -- (Purple-Yellow Blockfish)
-- local VARIANT = 101253888 -- (Cyan-Pink Dasher)
-- local VARIANT = 117441025 -- (Gray-LightGray Glitter)
-- local VARIANT = 117441280 -- (Gray-LightGray Dasher)
-- local VARIANT = 117441536 -- (Gray-LightGray Brinely)
-- local VARIANT = 117506305 -- (Orange-Gray Stripey)
-- local VARIANT = 117899265 -- (Gray Flopper)
-- local VARIANT = 118161664 -- (Blue-Gray SunStreak)
-- local VARIANT = 134217984 -- (LightGray-Gray SunStreak)
-- local VARIANT = 234882305 -- (Red-LightGray Clayfish)
-- local VARIANT = 235340288 -- (Red-Gray Snooper)

---------------------------------
-- DO NOT EDIT BELOW THIS LINE --
---------------------------------

-- Model Parts
local glass = WATER_SPACE.cube
local headspace = models.model:newPart("HeadSpace")
local head = headspace:newPart("InternalHead")
local headoriginrot = vanilla_model.HEAD:getOriginRot()
local _headoriginrot = headoriginrot

-- Glass
glass:primaryTexture("RESOURCE", "minecraft:textures/block/glass.png")

-- Fish
local fish = head:newPart("fish"):setPos(-1.5, 0, 0)
fish:newEntity("fish"):setNbt("minecraft:tropical_fish", "{Variant:" .. VARIANT .. "}"):setRot(0, 180, -90)

-- Smooth rotation
function events.tick()
  _headoriginrot = headoriginrot
  headoriginrot = math.lerp(headoriginrot, vanilla_model.HEAD:getOriginRot(), 0.4)
end

-- Apply transforms
function events.render(delta)
  local mt = headspace:partToWorldMatrix():invert()
  local localvel = vec(0,0,0)
  if FISH_POSITION then
    localvel = mt:applyDir(player:getVelocity()) * 0.3
  end
  head:setPos(mt:apply(glass:partToWorldMatrix():apply()) - localvel)
  if FISH_ROTATION then
    head:setRot(math.lerp(_headoriginrot, headoriginrot, delta))
  else
    head:setRot(vanilla_model.HEAD:getOriginRot())
  end
end
