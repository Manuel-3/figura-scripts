---- Rainbow Nametag by manuel_2867 ----
function rainbow(text, speed, offset)
  local function col(x)
      local hue = world.getTime()*speed+x*offset % 360
      return string.format("#%X", vectors.rgbToInt(vectors.hsvToRGB(hue/360, 1, 1)))
  end
  local json = '['
  for i = 1, #text do
      local char = text:sub(i,i)
      json = json .. '{"text": "'..char..'", "color": "' .. col(i) .. '"},'
  end
  json = json:sub(1, #json - 1)
  json = json .. ']'
  return json
end

-- Example
function events.tick()
  nameplate.ENTITY:setText(rainbow(player:getName(),7,15))
end
