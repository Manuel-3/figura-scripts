--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / Theme Class Handler
/ /_/ / /|  / the script that manages how every class looks.
\____/_/ |_/ Source: link]]

---@alias GNUI.Theme table<string,table<string|"default",fun(box:GNUI.Box)>>

local theme = {}

---@alias GNUI.Theme.Variants string : string
---| "default"
---| "none"

-- load theme from data/theme folder

local function mergeStyle(style)
  for className, classData in pairs(style) do
    theme[className] = theme[className] or {}
    for styleName, styleFun in pairs(classData) do
      theme[className][styleName] = styleFun
    end
  end
end

local requirePath = .....".theme"

-- load theme from theme folder
for _, path in pairs(listFiles(requirePath,true)) do
  if #requirePath ~= #path then
    local style = require(path)
      mergeStyle(style)
    end
end


-- load `data/theme` folder
if host:isHost() and file:isDirectory("GNUI/theme") then
  local styleFuns = {}
  for key, fileName in pairs(file:list("GNUI/theme")) do
    local path = "GNUI/theme/" .. fileName
    local type = fileName:match("[^%.]+$")
    local name = fileName:sub(1,-#type-2)
    if type == "lua" then
      styleFuns[#styleFuns+1] = loadstring(file:readString(path))
    elseif type == "png" then
      local read = file:openReadStream(path)
      local buff = data:createBuffer(read:available())
      buff:readFromStream(read)
      buff:setPosition(0)
      local data = buff:readBase64(buff:available())
      textures:read("GNUI.theme."..name,data)
      buff:close()
      read:close()
    end
  end
  for name,style in pairs(styleFuns) do
    local varag = {...}
      varag[1] = varag[1] .. "/theme"
      varag[2] = name
      mergeStyle(style(table.unpack(varag)))
    end
end

---@class GNUI.ThemeAPI
local Theme = {}

local cache = {}

---Styles a given class using the theme script, the single lua file in the theme folder.
---@param object any
---@param variant string|"none"|"Default"?
function Theme.style(object,variant)
  local class
  if cache[object.__type] then
    class = cache[object.__type]
  else
    class = object.__type:match("[^%.]+$") -- GNUI.Button -> Button
    cache[object.__type] = class
  end
  
  variant = variant or "Default"
  if not theme[class] then
    return object
  end
  if theme[class].All then
    theme[class].All(object)
  end
  if theme[class] and theme[class][variant] then
    theme[class][variant](object)
  end
  return object
end

return Theme