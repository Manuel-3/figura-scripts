--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / The Button Class.
/ /_/ / /|  / The base class for all clickable buttons.
\____/_/ |_/ Source: link]]

---@diagnostic disable: assign-type-mismatch
local Box = require("./../primitives/box") ---@type GNUI.Box
local cfg = require("./../config") ---@type GNUI.Config
local eventLib = cfg.event ---@type EventLibAPI ---@type EventLibAPI
local Theme = require("./../theme") ---@type GNUI.ThemeAPI

local tree = {}

---@class GNUI.Button : GNUI.Box
---@field isPressed boolean
---@field isToggle boolean
---@field keybind GNUI.keyCode
---
---@field HoverBox GNUI.Box
---
---@field BUTTON_CHANGED EventLibAPI
---@field PRESSED EventLibAPI
---@field BUTTON_DOWN EventLibAPI
---@field BUTTON_UP EventLibAPI
local Button = {}
Button.__index = function (t,i) return rawget(t,i) or Button[i] or Box[i] end
Button.__type = "GNUI.Button"


---@param parent GNUI.Box?
---@param variant string|"None"|"Default"?
---@return GNUI.Button
function Button.new(parent,variant)
  
  ---@type GNUI.Button
  local new = setmetatable(Box.new(parent),Button)
  new.PRESSED = eventLib.new()
  new.BUTTON_DOWN = eventLib.new()
  new.BUTTON_UP = eventLib.new()
  new.keybind = "key.mouse.left"
  new.BUTTON_CHANGED = eventLib.new()
  new.isToggle = false
  new.isPressed = false
  
  local hoverBox = Box.new(new):setAnchor(0,0,1,1):setCanCaptureCursor(false)
  new.HoverBox = hoverBox
  
  new.MOUSE_PRESSENCE_CHANGED:register(function (isHovering)
	 new.BUTTON_CHANGED:invoke(new.isPressed,new.isCursorHovering)
  end)
  
  ---@param event GNUI.InputEvent
  new.INPUT:register(function (event)
	if event.key == new.keybind then
		if event.state == 1 then
			new:press()
		else
			new:release()
		end
		return true
	 end
  end,"GNUI.Input")
  Theme.style(new,variant)
  return new
end


---Sets whether the button is toggleable
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Button:setToggle(toggle)
  ---@cast self GNUI.Button
  self.isToggle = toggle or false
  return self
end

---Presses the button. or if the button is a toggle and is pressed, this releases the button.
---@generic self
---@param self self
---@return self
function Button:press()
  ---@cast self GNUI.Button
  if self.isToggle then
	 self.isPressed = not self.isPressed
  else
	 self.isPressed = true
  end
  
  if self.isPressed then self.BUTTON_DOWN:invoke()
  else self.PRESSED:invoke()
	 self.BUTTON_UP:invoke()
  end
  
  self.BUTTON_CHANGED:invoke(self.isPressed,self.isCursorHovering)
  return self
end

--- Presses and releases the button.
---@generic self
---@param self self
---@return self
function Button:click()
  ---@cast self GNUI.Button
  self:press():release()
  return self
end

---Releases the button, if the button is not a toggle, if it is, call `press()` again to release.
---@generic self
---@param self self
---@return self
function Button:release()
  ---@cast self GNUI.Button
  if not self.isToggle and self.isPressed then
	 self.isPressed = false
	 self.BUTTON_UP:invoke()
	 self.PRESSED:invoke()
	 self.BUTTON_CHANGED:invoke(self.isPressed,self.isCursorHovering)
  end
  return self
end

---Sets whether the button is pressed, only works if the button is a toggle.
---@generic self
---@param self self
---@return self
function Button:setPressed(pressed)
  ---@cast self GNUI.Button
  if self.isToggle and self.isPressed ~= pressed then
	 self:press()
  end
  return self
end


return Button