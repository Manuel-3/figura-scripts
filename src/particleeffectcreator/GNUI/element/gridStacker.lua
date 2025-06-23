--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / The GridStacker Class.
/ /_/ / /|  / A type of stacker that aranges its children onto a grid.
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Box = require("./../primitives/box") ---@type GNUI.Box
local cfg = require("./../config") ---@type GNUI.Config
local utils = cfg.utils ---@type GNUI.UtilsAPI
local eventLib = cfg.event ---@type EventLibAPI

---@class GNUI.GridStacker : GNUI.Box
---@field ItemSize Vector2
---@field Spacing Vector2
local GridStacker = {}
GridStacker.__index = function (t,i) return rawget(t,i) or GridStacker[i] or Box[i] end
GridStacker.__type = "GNUI.GridStacker"

---Creates a new GridStacker.
---@param itemSize Vector2
---@return GNUI.GridStacker
function GridStacker.new(itemSize,parent)
   ---@type GNUI.GridStacker
   local box = Box.new(parent)
   box._parent_class = GridStacker
   box.ItemSize = itemSize or vec(16,16)
   box.Spacing = vec(0,0)
   
   setmetatable(box,GridStacker)
   local function update() box:rearangeChildren() end
   box.SIZE_CHANGED:register(update,"GridStacker")
   box.CHILDREN_CHANGED:register(update,"GridStacker")
   return box
end

---Rearanges the children to a grid. automatically called, but in case it dosent update, call this
---@generic self
---@param self self
---@return self
function GridStacker:rearangeChildren()
   ---@cast self GNUI.GridStacker
   local space = self.Spacing
   local size = self.ItemSize
   local x,y = space.x,space.y
   for i,v in pairs(self.Children) do
      v:setPos(x,y)
      x = x + size.x + space.x * 2
      if x > self.Size.x-size.x then
         x = space.x
         y = y + size.y + space.y
      end
   end
   return self
end


---Sets the item size for each children.
---@param x number|Vector2
---@param y number?
---@generic self
---@param self self
---@return self
function GridStacker:setItemSize(x,y)
   ---@cast self GNUI.GridStacker
   local itemSize = utils.vec2(x,y)
   self.ItemSize = itemSize
   self:rearangeChildren()
   return self
end


---Sets the spacing between each children.
---@param x number|Vector2
---@param y number?
---@generic self
---@param self self
---@return self
function GridStacker:setSpacing(x,y)
   ---@cast self GNUI.GridStacker
   local spacing = utils.vec2(x,y)
   self.Spacing = spacing
   self:rearangeChildren()
   return self
end


return GridStacker