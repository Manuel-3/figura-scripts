---@diagnostic disable: param-type-mismatch
--[[______  __
  / ____/ | / / by: GNamimates | Discord: "@gn8." | Youtube: @GNamimates
 / / __/  |/ / Sprite Library, specifically made for GNUI.
/ /_/ / /|  /
\____/_/ |_/]]
local default_texture = textures["1x1white"] or textures:newTexture("1x1white",1,1):setPixel(0,0,vec(1,1,1))
local cfg = require(.....".config")
local eventLib,utils = cfg.event, cfg.utils

local update = {}

---@class Nineslice # a representation of a sprite / 9-slice sprite in GNUI
---@field Texture Texture # the texture of the sprite
---@field TEXTURE_CHANGED EventLibAPI
---@field Modelpart ModelPart? # the `ModelPart` used to handle where to display debug features and the sprite.
---@field MODELPART_CHANGED EventLibAPI
---@field UV Vector4 # the UV of the texture in the sprite, in the form (x,y,z,w) with each unit is a pixel
---
---@field Position Vector2 # the position of the sprite.
---@field Size Vector2 # the size of the sprite.
---@field DIMENSIONS_CHANGED EventLibAPI
---
---@field Color Vector3 # The tint applied to the sprite.
---@field Alpha number # The opacity of the sprite.
---@field Scale number # The scale of the borders of a 9-slice.
---
---@field RenderTasks table<any,SpriteTask> # a list of sprite tasks used by the sprite
---@field RenderType ModelPart.renderType # the render type of the sprite.
---
---@field BorderThickness Vector4 # the thickness of the border in the form (left, top, right, bottom)
---@field BORDER_THICKNESS_CHANGED EventLibAPI
---
---@field BorderExpand Vector4 # the expansion of the border in the form (left, top, right, bottom)
---@field BORDER_EXPAND_CHANGED EventLibAPI
---
---@field ExcludeMiddle boolean # if true, the middle of the sprite will not be rendered
---@field DepthOffset number # the depth offset of the sprite
---@field Visible boolean # if true, the sprite will be rendered
---@field id integer # a unique integer for the sprite
---@field package _queue_update boolean
local Nineslice = {}
Nineslice.__index = Nineslice
Nineslice.__type = "Sprite"

local sprite_next_free = 0
---@return Nineslice
function Nineslice.new(obj)
  obj = obj or {}
  local new = {}
  setmetatable(new,Nineslice)
  new.Texture = obj.Texture or default_texture
  new.TEXTURE_CHANGED = eventLib.new()
  new.MODELPART_CHANGED = eventLib.new()
  new.Position = obj.Position or vec(0,0)
  new.DepthOffset = 0
  new.UV = obj.UV or vec(0,0,1,1)
  new.Size = obj.Size or vec(0,0)
  new.Alpha = obj.Alpha or 1
  new.Color = obj.Color or vec(1,1,1)
  new.Scale = obj.Scale or 1
  new.DIMENSIONS_CHANGED = eventLib.new()
  new.RenderTasks = {}
  new.RenderType = obj.RenderType or "CUTOUT"
  new.BorderThickness = obj.BorderThickness or vec(0,0,0,0)
  new.BorderExpand = obj.BorderExpand or vec(0,0,0,0)
  new.BORDER_THICKNESS_CHANGED = eventLib.new()
  new.BORDER_EXPAND_CHANGED = eventLib.new()
  new.ExcludeMiddle = obj.ExcludeMiddle or false
  new.Visible = true
  new.id = sprite_next_free
  sprite_next_free = sprite_next_free + 1
  
  new.TEXTURE_CHANGED:register(function ()
    new:deleteRenderTasks()
    new:buildRenderTasks()
    new:update()
  end,cfg.internal_events_name)

  new.BORDER_THICKNESS_CHANGED:register(function ()
    new:deleteRenderTasks()
    new:buildRenderTasks()
  end,cfg.internal_events_name)
  
  new.DIMENSIONS_CHANGED:register(function ()
    new:update()
  end,cfg.internal_events_name)
  return new
end

---Sets the modelpart to parent to.
---@param part ModelPart?
---@return Nineslice
function Nineslice:setModelpart(part)
  self:deleteRenderTasks()
  self.Modelpart = part
  
  if self.Modelpart then
    self:buildRenderTasks()
  end
  self.MODELPART_CHANGED:invoke(self.Modelpart)
  return self
end


---Sets the displayed image texture on the sprite.
---@param texture Texture
---@return Nineslice
function Nineslice:setTexture(texture)
  if type(texture) ~= "Texture" then error("Invalid texture, recived "..type(texture)..".",2) end
  self.Texture = texture
  local dim = texture:getDimensions()
  self.UV = vec(0,0,dim.x-1,dim.y-1)
  self.TEXTURE_CHANGED:invoke(self,self.Texture)
  return self
end

---Sets the position of the Sprite, relative to its parent.
---@param xpos number
---@param y number
---@return Nineslice
function Nineslice:setPos(xpos,y)
  self.Position = utils.vec2(xpos,y)
  self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
  return self
end

---Tints the Sprite multiplicatively
---@param r number|Vector3
---@param g number?
---@param b number?
---@return Nineslice
function Nineslice:setColor(r,g,b)
  self.Color = utils.vec3(r,g,b)
  self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
  return self
end


---@param a number
---@return Nineslice
function Nineslice:setOpacity(a)
  self.Alpha = math.clamp(a or 1,0,1)
  self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
  return self
end

---Sets the size of the sprite duh.
---@param xpos number|Vector2
---@param y number?
---@return Nineslice
function Nineslice:setSize(xpos,y)
  self.Size = utils.vec2(xpos,y)
  self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
  return self
end

---@param scale number
---@return Nineslice
function Nineslice:setScale(scale)
  self.Scale = scale
  self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
  return self
end

-->====================[ Border ]====================<--

---Sets the top border thickness.
---@param units number?
---@return Nineslice
function Nineslice:setBorderTop(units)
  self.BorderThickness.y = units or 0
  self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
  return self
end

---Sets the left border thickness.
---@param units number?
---@return Nineslice
function Nineslice:setBorderLeft(units)
  self.BorderThickness.x = units or 0
  self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
  return self
end

---Sets the down border thickness.
---@param units number?
---@return Nineslice
function Nineslice:setBorderBottom(units)
  self.BorderThickness.w = units or 0
  self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
  return self
end

---Sets the right expansion.
---@param units number?
---@return Nineslice
function Nineslice:setBorderRight(units)
  self.BorderThickness.z = units or 0
  self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
  return self
end




---Sets the expansion.
---@param left number?
---@param top number?
---@param right number|Vector2
---@param bottom number|Vector2|Vector3
---@return Nineslice
function Nineslice:setExpand(left,top,right,bottom)
  local expand = utils.vec4(
  left or self.BorderExpand.x,
  top or self.BorderExpand.y,
  right or self.BorderExpand.z,
  bottom or self.BorderExpand.w)
  self.BorderExpand = expand
  self.BORDER_EXPAND_CHANGED:invoke(self,self.BorderExpand)
  return self
end

---Sets the top expansion.
---@param units number?
---@return Nineslice
function Nineslice:setExpandTop(units)
  self.BorderExpand.y = units or 0
  self.BORDER_EXPAND_CHANGED:invoke(self,self.BorderExpand)
  return self
end

---Sets the left expansion.
---@param units number?
---@return Nineslice
function Nineslice:setExpandLeft(units)
  self.BorderExpand.x = units or 0
  self.BORDER_EXPAND_CHANGED:invoke(self,self.BorderExpand)
  return self
end

---Sets the down expansion.
---@param units number?
---@return Nineslice
function Nineslice:setExpandBottom(units)
  self.BorderExpand.w = units or 0
  self.BORDER_EXPAND_CHANGED:invoke(self,self.BorderExpand)
  return self
end

---Sets the right expansion.
---@param units number?
---@return Nineslice
function Nineslice:setExpandRight(units)
  self.BorderExpand.z = units or 0
  self.BORDER_EXPAND_CHANGED:invoke(self,self.BorderExpand)
  return self
end


---Sets the padding for all sides.
---@param left number?
---@param top number?
---@param right number?
---@param bottom number?
---@return Nineslice
function Nineslice:setBorderThickness(left,top,right,bottom)
  self.BorderThickness.x = left  or 0
  self.BorderThickness.y = top   or 0
  self.BorderThickness.z = right  or 0
  self.BorderThickness.w = bottom or 0
  self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
  return self
end

---Sets the UV region of the sprite.
--- if x2 and y2 are missing, they will use x and y as a substitute
---@param x number|Vector2|Vector4
---@param y number|Vector2
---@param x2 number?
---@param y2 number?
---@return Nineslice
function Nineslice:setUV(x,y,x2,y2)
  self.UV = utils.vec4(x,y,x2 or x,y2 or y)
  self.DIMENSIONS_CHANGED:invoke(self.BorderThickness)
  return self
end

---Sets the render type of your sprite
---@param renderType ModelPart.renderType
---@return Nineslice
function Nineslice:setRenderType(renderType)
  self.RenderType = renderType
  self:deleteRenderTasks()
  self:buildRenderTasks()
  return self
end

---Set to true if you want a hole in the middle of your ninepatch
---@param toggle boolean
---@return Nineslice
function Nineslice:excludeMiddle(toggle)
  self.ExcludeMiddle = toggle
  return self
end

function Nineslice:copy()
  local copy = {}
  for key, value in pairs(self) do
    if type(value):find("Vector") then
      value = value:copy()
    end
    copy[key] = value
  end
  return Nineslice.new(copy)
end

function Nineslice:setVisible(visibility)
  self.Visible = visibility
  self:update()
  return self
end

function Nineslice:setDepthOffset(offset_units)
  self.DepthOffset = offset_units
  return self
end

function Nineslice:update()
  if not self._queue_update then
    self._queue_update = true
    update[#update+1] = self
  end
end

function Nineslice:deleteRenderTasks()
  if self.Modelpart then
    for _, task in pairs(self.RenderTasks) do
      self.Modelpart:removeTask(task:getName())
    end
  end
  return self
end

function Nineslice:free()
  self:deleteRenderTasks()
  return self
end

function Nineslice:buildRenderTasks()
  if not self.Modelpart then return self end
  local b = self.BorderThickness
  local d = self.Texture:getDimensions()
  self.is_nineslice = not (b.x == 0 and b.y == 0 and b.z == 0 and b.w == 0)
  if not self.is_nineslice then -- not 9-Slice
    self.RenderTasks[1] = self.Modelpart:newSprite(self.id.."slice"):setTexture(self.Texture,d.x,d.y)
  else
    self.RenderTasks = {
      self.Modelpart:newSprite(self.id.."slice_tl"),
      self.Modelpart:newSprite(self.id.."slice_t" ),
      self.Modelpart:newSprite(self.id.."slice_tr"),
      self.Modelpart:newSprite(self.id.."slice_ml"),
      self.Modelpart:newSprite(self.id.."slice_m" ),
      self.Modelpart:newSprite(self.id.."slice_mr"),
      self.Modelpart:newSprite(self.id.."slice_bl"),
      self.Modelpart:newSprite(self.id.."slice_b" ),
      self.Modelpart:newSprite(self.id.."slice_br"),
    }
    for i = 1, 9, 1 do
      self.RenderTasks[i]:setTexture(self.Texture,d.x,d.y):setVisible(false)
    end
  end
  self:update()
end

function Nineslice:updateRenderTasks()
  if not self.Modelpart then return self end
  local res = self.Texture:getDimensions()
  local uv = self.UV:copy():add(0,0,1,1)
  local s = self.Scale
  local pos = vec(self.Position.x+self.BorderExpand.x*s,self.Position.y+self.BorderExpand.y*s,self.DepthOffset)
  local size = self.Size+(self.BorderExpand.xy+self.BorderExpand.zw)*s
  if not self.is_nineslice then
    self.RenderTasks[1]
    :setPos(pos)
    :setScale(size.x/res.x,size.y/res.y,0)
    :setColor(self.Color:augmented(self.Alpha))
    :setRenderType(self.RenderType)
    :setUVPixels(
      uv.x,
      uv.y
    ):region(
      uv.z-uv.x,
      uv.w-uv.y
    ):setVisible(self.Visible)
  else
    local sborder = self.BorderThickness*self.Scale --scaled border, used in rendering
    local border = self.BorderThickness         --border, used in UVs
    local uvsize = vec(uv.z-uv.x,uv.w-uv.y)
    for _, task in pairs(self.RenderTasks) do
      task
      :setColor(self.Color:augmented(self.Alpha))
      :setRenderType(self.RenderType)
    end
    self.RenderTasks[1]
    :setPos(
      pos
    ):setScale(
      sborder.x/res.x,
      sborder.y/res.y,0
    ):setUVPixels(
      uv.x,
      uv.y
    ):region(
      border.x,
      border.y
    ):setVisible(self.Visible)
    
    self.RenderTasks[2]
    :setPos(
      pos.x-sborder.x,
      pos.y,
      pos.z
    ):setScale(
      (size.x-sborder.z-sborder.x)/res.x,
      sborder.y/res.y,0
    ):setUVPixels(
      uv.x+border.x,
      uv.y
    ):region(
      uvsize.x-border.x-border.z,
      border.y
    ):setVisible(self.Visible)

    self.RenderTasks[3]
    :setPos(
      pos.x-size.x+sborder.z,
      pos.y,
      pos.z
    ):setScale(
      sborder.z/res.x,sborder.y/res.y,0
    ):setUVPixels(
      uv.z-border.z,
      uv.y
    ):region(
      border.z,
      border.y
    ):setVisible(self.Visible)

    self.RenderTasks[4]
    :setPos(
      pos.x,
      pos.y-sborder.y,
      pos.z
    ):setScale(
      sborder.x/res.x,
      (size.y-sborder.y-sborder.w)/res.y,0
    ):setUVPixels(
      uv.x,
      uv.y+border.y
    ):region(
      border.x,
      uvsize.y-border.y-border.w
    ):setVisible(self.Visible)
    if not self.ExcludeMiddle then
      self.RenderTasks[5]
      :setPos(
        pos.x-sborder.x,
        pos.y-sborder.y,
        pos.z
      )
      :setScale(
        (size.x-sborder.x-sborder.z)/res.x,
        (size.y-sborder.y-sborder.w)/res.y,0
      ):setUVPixels(
        uv.x+border.x,
        uv.y+border.y
      ):region(
        uvsize.x-border.x-border.z,
        uvsize.y-border.y-border.w
      ):setVisible(self.Visible)
    else
      self.RenderTasks[5]:setVisible(false)
    end

    self.RenderTasks[6]
    :setPos(
      pos.x-size.x+sborder.z,
      pos.y-sborder.y,
      pos.z
    )
    :setScale(
      sborder.z/res.x,
      (size.y-sborder.y-sborder.w)/res.y,0
    ):setUVPixels(
      uv.z-border.z,
      uv.y+border.y
    ):region(
      border.z,
      uvsize.y-border.y-border.w
    ):setVisible(self.Visible)
    
    
    self.RenderTasks[7]
    :setPos(
      pos.x,
      pos.y-size.y+sborder.w,
      pos.z
    )
    :setScale(
      sborder.x/res.x,
      sborder.w/res.y,0
    ):setUVPixels(
      uv.x,
      uv.w-border.w
    ):region(
      border.x,
      border.w
    ):setVisible(self.Visible)

    self.RenderTasks[8]
    :setPos(
      pos.x-sborder.x,
      pos.y-size.y+sborder.w,
      pos.z
    ):setScale(
      (size.x-sborder.z-sborder.x)/res.x,
      sborder.w/res.y,0
    ):setUVPixels(
      uv.x+border.x,
      uv.w-border.w
    ):region(
      uvsize.x-border.x-border.z,
      border.w
    ):setVisible(self.Visible)

    self.RenderTasks[9]
    :setPos(
      pos.x-size.x+sborder.z,
      pos.y-size.y+sborder.w,
      pos.z
    ):setScale(
      sborder.z/res.x,
      sborder.w/res.y,0
    ):setUVPixels(
      uv.z-border.z,
      uv.w-border.w
    ):region(
      border.z,
      border.w
    ):setVisible(self.Visible)
  end
end

function Nineslice.updateAll()
	if #update > 0 then
		for i = 1, #update, 1 do
		 update[i]:updateRenderTasks()
		 update[i]._queue_update = nil
		end
		update = {}
 	end
end
return Nineslice