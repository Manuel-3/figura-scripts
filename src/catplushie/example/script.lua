local catPlushieModel = models.catplushie.SKULL
local textureWidth = textures["texture"]:getDimensions().x
local cats = {}

local time = 0
local shouldUpdate = false

local nextCatId = nil

local offset = vec(0, 1, 0)
local vec2Half = vec(0.5, 0.5)
local sitPos = vec(0, -8, -4)

local maxComplexity = 100
local closeToRenderInstructions = false

-- check if cat
local myUuid = avatar:getUUID()
local function isCat(pos)
   local data = world.getBlockState(pos):getEntityData()
   return data and data.SkullOwner and data.SkullOwner.Id and client:intUUIDToString(table.unpack(data.SkullOwner.Id)) == myUuid
end

-- update function called every frame
local function update()
   maxComplexity = avatar:getMaxComplexity() - 100

   local maxTime = time - 2
   for _, p in pairs(world.getPlayers()) do
      local swingTime = p:getSwingTime()
      if swingTime == 1 then
         local _, pos = p:getTargetedBlock()
         local strPos = tostring(pos:floor())
         local cat = cats[strPos]
         if cat and cat.lastUpdated < maxTime then
            cat.lastUpdated = time
            if p:isSneaking() then
               cat.uv = (cat.uv + 32) % textureWidth
            else
               cat.rot = (cat.rot + 90) % 360
               cat.offset = (cat.rot == 90 or cat.rot == 270) and -2 or 0
            end
         end
      end
   end
end

-- render cats
function events.skull_render(delta, block)
   if closeToRenderInstructions then
      return
   end
   if shouldUpdate then
      shouldUpdate = false
      update()
   end
   if avatar:getComplexity() > maxComplexity then
      closeToRenderInstructions = true
   end
   if not block then
      catPlushieModel:setRot(0, 0, 0)
      catPlushieModel:setPos(0, 0, 0)
      catPlushieModel:setUV(0, 0)
      return
   end
   local pos = block:getPos()
   local strPos = tostring(pos)
   local cat = cats[strPos]
   if not cat then
      cat = {
         pos = pos,
         rot = 0,
         uv = 0,
         offset = 0,
         lastUpdated = time,
      }
      cats[strPos] = cat
      return
   end
   catPlushieModel:setRot(0, 0, cat.rot)
   catPlushieModel:setUVPixels(cat.uv, 0)
   if block.id == "minecraft:player_head" then
      local floor = world.getBlockState(pos - offset)
      if floor.id:match("stairs") and floor.properties and floor.properties.half == "bottom" then
         catPlushieModel:setPos(sitPos.x, sitPos.y + cat.offset, sitPos.z)
      else
         local y = 0
         local shape = floor:getOutlineShape()
         for _, v in ipairs(shape) do
            if v[1].xz <= vec2Half and v[2].xz >= vec2Half then
               y = math.max(y, v[2].y)
            end
         end
         if #shape >= 1 then
            catPlushieModel:setPos(0, y * 16 - 16 + cat.offset, 0)
         else
            catPlushieModel:setPos(0, cat.offset, 0)
         end
     end
   else
      catPlushieModel:setPos(0, cat.offset, 0)
   end
end

function events.world_render()
   shouldUpdate = true
   closeToRenderInstructions = false
end

function events.world_tick()
   time = time + 1
   local limit = math.min((avatar:getMaxWorldTickCount() - 14) / 56, 100)
   for _ = 1, limit do
      if not cats[nextCatId] then
         nextCatId = next(cats)
         return
      end
      if nextCatId and not isCat(cats[nextCatId].pos) then
         cats[nextCatId] = nil
      end
      nextCatId = next(cats, nextCatId)
   end
end