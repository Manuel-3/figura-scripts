---@diagnostic disable: undefined-doc-name, undefined-field
--[[______   __
	/ ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / Theme File
/ /_/ / /|  / Contains how to theme specific classes
\____/_/ |_/ Source: link]]

--[[ Layout --------
├Class
│├Default
│└AnotherVariant
└Class
 ├Default
 ├Variant
 └MoreVariant
-------------------]]
---GNUI.Button        ->    Button
---GNUI.Button.Slider ->    Slider

local GNUI = require "../../main" ---@module "library.GNUI.main"
local atlas = textures[(...):gsub("/",".") ..".gnuiTheme"]

---@type GNUI.Theme
local theme = {}

-->========================================[ Box ]=========================================<--

theme.Box = {
	Default = function (box)end,
	Background = function (box)
		local spritePressed = GNUI.newNineslice(atlas,23,8,27,12 ,2,2,2,2)
		box:setNineslice(spritePressed)
	end,
	Solid = function (box)
		local spritePressed = GNUI.newNineslice(atlas,2,12,2,12)
		box:setNineslice(spritePressed)
	end
}
-->========================================[ Button ]=========================================<--
theme.Button = {
	----@param box GNUI.Button
	--All = function (box)
	--	local spriteHover = GNUI.newNineslice(atlas,19,1,25,7 ,3,3,3,3, 2,2,2,2)
	--	box.HoverBox:setNineslice(spriteHover):setAnchor(0,0,1,1):setCanCaptureCursor(false):setZMul(1.1)
	--	box.BUTTON_CHANGED:register(function (pressed,hovering)
	--		box.HoverBox:setVisible(hovering):setZMul(10)
	--	end,"GNUI.Hover")
	--	box.HoverBox:setVisible(false)
	--end,
	---@param box GNUI.Button
	Default = function (box)
		box.TextOffset = vec(0,2)
		box.HoverBox:setDimensions(0,-2,0,-2)
		local spriteNormal = GNUI.newNineslice(atlas,7,1,11,7 ,2,2,2,4, 2)
		local spritePressed = GNUI.newNineslice(atlas,13,2,17,6 ,2,2,2,2)
		
		box:setDefaultTextColor("black"):setTextAlign(0.5,0.5)
		local wasPressed = true
		local function update(pressed,hovering,forced)
			if pressed ~= wasPressed or forced then
				wasPressed = pressed
				if pressed then
					box:setNineslice(spritePressed)
					:setChildrenOffset(0,0)
					:setTextOffset(box.TextOffset + vec(0,2))
					:setChildrenOffset(0,2)
					if not forced then
						GNUI.playSound("minecraft:ui.button.click",1) -- click
					end
				else
					box:setNineslice(spriteNormal)
					:setTextOffset(box.TextOffset - vec(0,2))
					:setChildrenOffset(0,0)
				end
			end
		end
		box.BUTTON_CHANGED:register(update)
		update(false,false,true)
	end,
	Secondary = function (box)
		box.TextOffset = vec(0,2)
		box.HoverBox:setDimensions(0,-2,0,-2)
		local spriteNormal = GNUI.newNineslice(atlas,13,15,17,21 ,2,2,2,4, 2)
		local spritePressed = GNUI.newNineslice(atlas,19,17,23,21 ,2,2,2,2)
		
		box:setDefaultTextColor("white"):setTextAlign(0.5,0.5)
		:setTextEffect("SHADOW")
		local wasPressed = true
		local function update(pressed,hovering,forced)
			if pressed ~= wasPressed or forced then
				wasPressed = pressed
				if pressed then
					box:setNineslice(spritePressed)
					:setChildrenOffset(0,0)
					:setTextOffset(box.TextOffset + vec(0,2))
					:setChildrenOffset(0,2)
					if not forced then
						GNUI.playSound("minecraft:ui.button.click",1) -- click
					end
				else
					box:setNineslice(spriteNormal)
					:setTextOffset(box.TextOffset - vec(0,2))
					:setChildrenOffset(0,0)
				end
			end
		end
		box.BUTTON_CHANGED:register(update)
		update(false,false,true)
	end,
	Tertiary = function (box)
		box.TextOffset = vec(0,2)
		box.HoverBox:setDimensions(0,-2,0,-2)
		local spriteNormal = GNUI.newNineslice(atlas,29,11,31,13 ,1,1,1,1)
		local spritePressed = GNUI.newNineslice(atlas,29,15,31,17 ,1,1,1,1)
		
		box:setDefaultTextColor("white"):setTextAlign(0.5,0.5)
		:setTextEffect("SHADOW")
		local wasPressed = true
		local function update(pressed,hovering,forced)
			if pressed ~= wasPressed or forced then
				wasPressed = pressed
				if pressed then
					box:setNineslice(spritePressed)
					if not forced then
						GNUI.playSound("minecraft:ui.button.click",1) -- click
					end
				else
					box:setNineslice(spriteNormal)
				end
			end
		end
		box.BUTTON_CHANGED:register(update)
		update(false,false,true)
	end,
	---@param box GNUI.Button
	Flat = function (box)
		local spriteNormal = GNUI.newNineslice(atlas,9,13,11,15 ,1,1,1,1)
		local spritePressed = GNUI.newNineslice(atlas,5,13,7,15 ,1,1,1,1)
		
		box:setDefaultTextColor("black"):setTextAlign(0.5,0.5)
		local wasPressed = true
		local function update(pressed,hovering)
			if pressed ~= wasPressed then
				wasPressed = pressed
				if pressed then
					box:setNineslice(spritePressed)
					GNUI.playSound("minecraft:ui.button.click",1) -- click
				else
					box:setNineslice(spriteNormal)
				end
			end
		end
		box.BUTTON_CHANGED:register(update)
		update(false,false)
	end
}
-->========================================[ Slider ]=========================================<--
theme.Slider = {
	---@param box GNUI.Slider
	Default = function (box)
		local spriteButton = GNUI.newNineslice(atlas,7,1,11,7 ,2,2,2,4, 2)
		local spriteBG = GNUI.newNineslice(atlas,29,7,31,9, 1,1,1,1)
		
		box.sliderBox:setNineslice(spriteButton)
		box.numberBox:setTextAlign(0.5,0.5)
		
	 
		local wasPressed = true
		local function update(pressed)
			
			if pressed ~= wasPressed then
				wasPressed = pressed
				if pressed then
					GNUI.playSound("minecraft:ui.button.click",1) -- click
				else
				end
			end
		end
		box.numberBox:setDefaultTextColor("white"):setTextEffect("OUTLINE")
		
		box:setNineslice(spriteBG)
		box.BUTTON_CHANGED:register(update)
		update(false)
	end
}
-->========================================[ Text Field ]=========================================<--
theme.TextField = {
	---@param box GNUI.TextField
	Default = function (box)
		local spriteBG = GNUI.newNineslice(atlas,13,9,17,13, 2,2,2,2)
		box:setNineslice(spriteBG)
		box.Label:setDimensions(3,3,-3,-3)
		if box.isMultiLine then box.Label:setTextAlign(0,0)
		else box.Label:setTextAlign(0,0.5)
		end
	end
}
-->========================================[ Separator ]=========================================<--
theme.Separator = {
	---@param box GNUI.TextField
	Default = function (box)
		local spriteBG = GNUI.newNineslice(atlas,1,15,1,15)
		box:setNineslice(spriteBG)
	end
}

return theme