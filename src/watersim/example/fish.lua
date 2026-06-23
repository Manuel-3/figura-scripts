-- Fish, I guess

------------
-- CONFIG --
------------

-- Where the waterspace group is
local WATER_SPACE = models.model.Body.waterspace
-- If the fish should move around a bit, or should be static
local FISH_ROTATION = true
local FISH_POSITION = true

---------------------------------
-- DO NOT EDIT BELOW THIS LINE --
---------------------------------

local Task = require("./task")

-- Model Parts
local glass = WATER_SPACE.cube
local headspace = WATER_SPACE:newPart("HeadSpace")
local head = headspace:newPart("InternalHead")
local headoriginrot = vanilla_model.HEAD:getOriginRot()
local _headoriginrot = headoriginrot

-- Glass
glass:primaryTexture("RESOURCE", "minecraft:textures/block/glass.png")

-- Fish
local fish_state_swimming = false
local function setFishSwimming(state)
  fish_state_swimming = state
end
local fish = head:newPart("fish"):pos(-1.5,-8,0)
local fishentity = fish:newEntity("fish"):rot(0,180,0)
local variantId = config:load("variant") or 1

function events.tick()
  -- Smooth look follow rotation
  _headoriginrot = headoriginrot
  headoriginrot = math.lerp(headoriginrot, vanilla_model.HEAD:getOriginRot(), 0.4)

  -- Fish state update from action wheel
  fishentity:rot(0, 180, math.lerp(
    fishentity:getRot().z,
    fish_state_swimming and -90 or 0,
    0.1
  ))
  fish:pos(-1.5, math.lerp(
    fish:getPos().y,
    (fish_state_swimming and 0 or -8) + (variantId > 12 and fish_state_swimming and -3 or 0),
    0.1
  ), 0)
end

-- Apply transforms
function events.render(delta)
  local mt = headspace:partToWorldMatrix():invert()
  local localvel = vec(0,0,0)
  if FISH_POSITION then
    localvel = mt:applyDir(player:getVelocity()) * 0.3
  end
  head:pos(mt:apply(glass:partToWorldMatrix():apply()) - localvel)
  if FISH_ROTATION then
    head:rot(math.lerp(_headoriginrot, headoriginrot, delta))
  else
    head:rot(vanilla_model.HEAD:getOriginRot())
  end
end

-- Fish variant selection
local variants = {
  65536, -- (Orange-White Kob)
  917504, -- (Red-White Kob)
  50660352, -- (LightBlue-Lime Brinely)
  50726144, -- (LightBlue-Pink Spotty)
  50790656, -- (LightBlue-Gray SunStreak)
  67110144, -- (Yellow-LightGray Spotty)
  101253888, -- (Cyan-Pink Dasher)
  117441280, -- (Gray-LightGray Dasher)
  117441536, -- (Gray-LightGray Brinely)
  118161664, -- (Blue-Gray SunStreak)
  134217984, -- (LightGray-Gray SunStreak)
  235340288, -- (Red-Gray Snooper)
  67108865, -- (Yellow-LightGray Flopper)
  918273, -- (Red-White Blockfish)
  918529, -- (Red-White Betty)
  16778497, -- (Orange-LightGray Clayfish)
  67371265, -- (Yellow Stripey)
  117899265, -- (Gray Flopper)
  67764993, -- (Purple-Yellow Blockfish)
  117441025, -- (Gray-LightGray Glitter)
  117506305, -- (Orange-Gray Stripey)
  234882305, -- (Red-LightGray Clayfish)
}

function pings.variantId(i)
  variantId = i
  fishentity:setNbt("minecraft:tropical_fish", "{Variant:" .. variants[variantId] .. "}")
end

local waterscript = require("./water") -- we want to run after water.lua to have priority on the Task stack

waterscript.setFishSwimming = setFishSwimming -- give access to swimming state change

-------------------------------
-- Host only code starts now --
-------------------------------
if host:isHost() then

  local names = {
    "Orange-White Kob",
    "Red-White Kob",
    "LightBlue-Lime Brinely",
    "LightBlue-Pink Spotty",
    "LightBlue-Gray SunStreak",
    "Yellow-LightGray Spotty",
    "Cyan-Pink Dasher",
    "Gray-LightGray Dasher",
    "Gray-LightGray Brinely",
    "Blue-Gray SunStreak",
    "LightGray-Gray SunStreak",
    "Red-Gray Snooper",
    "Yellow-LightGray Flopper",
    "Red-White Blockfish",
    "Red-White Betty",
    "Orange-LightGray Clayfish",
    "Yellow Stripey",
    "Gray Flopper",
    "Purple-Yellow Blockfish",
    "Gray-LightGray Glitter",
    "Orange-Gray Stripey",
    "Red-LightGray Clayfish",
  }

  -- Color table, 000000 in first slot has special meaning to reduce hsv 'value' of the texture
  local colors = {
    {}, -- first is default
    {'86231d','ffffff'},
    {'609617','36a8cd'},
    {'e0809d','36a8cd'},
    {'36a8cd','41494c'},
    {'e6ebea','fbd53c'},
    {'f089a8','149090'},
    {'e6ebea','464e51'},
    {'e6ebea','464e51'},
    {'000000','373f9d'},
    {'ffffff','ffffff'},
    {'000000','ab2d25'},
    {'ffffff','d9b834'},
    {'ffffff','7c201b'},
    {'ffffff','7c201b'},
    {'ffffff','f67e1d'},
    {'f9d43c','8f7922'},
    {'000000','282c2e'},
    {'fbd53c','722999'},
    {'ffffff','393f42'},
    {'000000','cf6a18'},
    {'ffffff','ae2d26'},
  }

  -- Convert color table to hsv
  for _, list in ipairs(colors) do
    for i, color in ipairs(list) do
      list[i] = vectors.rgbToHSV(vectors.hexToRGB(color))
    end
  end

  -- Lightness to select differently bright areas on the texture
  local function lightness(col)
    return 0.2126 * col.r +
          0.7152 * col.g +
          0.0722 * col.b
  end

  local mainPage = require("./mainpage")

  local fishPage = action_wheel:newPage()
  mainPage:newAction():item("minecraft:tropical_fish_bucket"):title("Change fish"):onLeftClick(function()
    action_wheel:setPage(fishPage)
  end)
  fishPage:newAction():item("minecraft:arrow"):title("Exit"):onLeftClick(function()
    action_wheel:setPage(mainPage)
  end)

  -- Generate all fish variant actions and their textures
  for i, value in ipairs(variants) do
    local texture = textures:fromVanilla("tropical_fish_"..i,"minecraft:textures/item/tropical_fish.png")
    local dims = texture:getDimensions()
    if i ~= 1 then -- first fish is default colors
      Task(0,dims.x-1,function(x)
        Task(0,dims.y-1,function(y)
          local col = texture:getPixel(x,y)
          local hsv = vectors.rgbToHSV(col.rgb--[[@as Vector3 --]])
          if col.a > 0 then
            if lightness(col) > 0.7 then -- 0.7 is a good cutoff for differenciating between the orange and white of the tropical fish texture
              hsv = colors[i][2]--[[@as Vector3 --]]
            else
              local newhsv = colors[i][1]--[[@as Vector3 --]]
              hsv.x = newhsv.x
              hsv.y = newhsv.y
              if newhsv.z == 0 then -- preserve value to have shading, unless special case 0 then darken it
                hsv.z = hsv.z / 4
              end
            end
            texture:setPixel(x,y,vectors.hsvToRGB(hsv))
          end
        end)
      end,
      function()
        texture:update()
      end)
    end
    fishPage:newAction()
      :texture(texture)
      :title("["..i.."] "..names[i])
      :onLeftClick(function()
        config:save("variant",i)
        pings.variantId(i)
      end)
  end

  -- Resyncing
  local t = 0
  function events.tick()
    if t % 60 == 0 then
      pings.variantId(variantId)
    end
    t = t + 1
  end
end
