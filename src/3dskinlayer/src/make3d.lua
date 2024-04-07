----   HELP   ----
-- Important first note: Figura currently doesn't have a way to access pixels on the vanilla skin texture,
-- meaning low_complexity_mode can't do optimisations! It is recommended to not turn on use_vanilla_skin
-- and instead replace the existing templatetexture.png with your skin texture!
--
-- It will automatically figure out if you use Steve or Alex style skin.
--
-- In Settings below: It's recommended to either use inflate or scale, and not mix them!
-- Scale simply scales the outer 3d layer, while inflate scales each axis based on cube size to get a more uniform effect.
--
-- With inflate = 0:
---- With offset > 0 and scale = 1 the corners will be missing, can produce a more "round" effect
---- With offset = 0 and scale > 1 corners/edges that have different colors on different sides could show with only one of those colors instead
---- With offset > 0 and scale > 1 might look bad, but with only a tiny offset it can fix the corner/edge colors, but could also cause z-fighting
-- With scale = 1:
---- Basically same as above, except with inflate this time.
---- Note that inflate begins at 0 (no change) to >0 (inflates) instead of scale which is 1 (no change) <1 (smaller) and >1 (bigger)
--
-- Change scale/inflate to fit what you like, also test it with armor on to check if it's clipping through.
-- The default values below should already look good for most cases.

---- SETTINGS ----
local offset = 0.01 -- from 0 to 1, linearly moves pixels along normal axis

local head_inflate = 0.8 -- 0 = no change, >0 inflates
local body_inflate = 0.6
local arm_inflate = 0.6
local leg_inflate = 0.6

local head_scale = 1 -- 1 = no change, <1 makes smaller, >1 makes bigger
local body_scale = 1
local arm_scale = 1
local leg_scale = 1

local use_vanilla_skin = false -- set to true if you want to use your vanilla skin. doesnt work with low complexity mode so it is recommended to replace the included texture with your skin instead
local skin_resolution = 16 -- 16 for normal, 32 for a double resolution skin, etc... up to 256x (will increase complexity significantly)
local low_complexity_mode = true -- set to false if you need to be able to animate or change textures on the fly (will increase complexity significantly)
------------------

---- CODE STARTS HERE DONT CHANGE ANYTHING BELOW THIS LINE ----

vanilla_model.PLAYER:setVisible(use_vanilla_skin)
vanilla_model.HAT:setVisible(false)
vanilla_model.JACKET:setVisible(false)
vanilla_model.RIGHT_SLEEVE:setVisible(false)
vanilla_model.LEFT_SLEEVE:setVisible(false)
vanilla_model.LEFT_PANTS:setVisible(false)
vanilla_model.RIGHT_PANTS:setVisible(false)
models.player_model3d.Head.Head:setVisible(not use_vanilla_skin)
models.player_model3d.Body.Body:setVisible(not use_vanilla_skin)
models.player_model3d.RightArm["Right Arm"]:setVisible(not use_vanilla_skin)
models.player_model3d.LeftArm["Left Arm"]:setVisible(not use_vanilla_skin)
models.player_model3d.RightArmSlim["Right Arm"]:setVisible(not use_vanilla_skin)
models.player_model3d.LeftArmSlim["Left Arm"]:setVisible(not use_vanilla_skin)
models.player_model3d.LeftLeg["Left Leg"]:setVisible(not use_vanilla_skin)
models.player_model3d.RightLeg["Right Leg"]:setVisible(not use_vanilla_skin)
models.player_model3d.pixel:visible(false)

local px = models.player_model3d.pixel["x"..skin_resolution]:visible(true)
local res = skin_resolution / 16

function newPixel(at,north,south,east,west,up,down)
    local pixel = at:newPart("pixel")
    if north then
        pixel:addChild(px.north:copy("north")) 
    end
    if south then
        pixel:addChild(px.south:copy("south")) 
    end
    if east then
        pixel:addChild(px.east:copy("east")) 
    end
    if west then
        pixel:addChild(px.west:copy("west")) 
    end
    if up then
        pixel:addChild(px.up:copy("up")) 
    end
    if down then
        pixel:addChild(px.down:copy("down")) 
    end
    return pixel
end

---@param at ModelPart
---@param dims Vector3
---@param north Vector4
---@param east Vector4
---@param south Vector4
---@param west Vector4
---@param up Vector4
---@param down Vector4
local function Make3d(at, scale, inflate, dims, north, east, south, west, up, down)
    local p = at:getTruePivot()
    local texture = use_vanilla_skin and {getPixel=function(_,x,y)return {a=1} end} or at:getTextures()[1]
    at:setScale(scale*(1+inflate/dims.x)/res, scale*(1+inflate/dims.y)/res, scale*(1+inflate/dims.z)/res)
    local function needsN(x, y, u, v, w, h)
        if use_vanilla_skin then return {true, false, true, true, true, true} end
        return {
            true, --north
            false, --south
            x==u or texture:getPixel(x-1,y).a==0, --east
            x==u+w-1 or texture:getPixel(x+1,y).a==0, --west
            y==v or texture:getPixel(x,y-1).a==0, --up
            y==v+h-1 or texture:getPixel(x,y+1).a==0, --down
        }
    end
    local function needsS(x, y, u, v, w, h)
        if use_vanilla_skin then return {false, true, true, true, true, true} end
        return {
            false, --north
            true, --south
            x==u+w-1 or texture:getPixel(x+1,y).a==0, --east
            x==u or texture:getPixel(x-1,y).a==0, --west
            y==v or texture:getPixel(x,y-1).a==0, --up
            y==v+h-1 or texture:getPixel(x,y+1).a==0, --down
        }
    end
    local function needsE(x, y, u, v, w, h)
        if use_vanilla_skin then return {true, true, true, false, true, true} end
        return {
            x==u+w-1 or texture:getPixel(x+1,y).a==0, --north
            x==u or texture:getPixel(x-1,y).a==0, --south
            true, --east
            false, --west
            y==v or texture:getPixel(x,y-1).a==0, --up
            y==v+h-1 or texture:getPixel(x,y+1).a==0, --down
        }
    end
    local function needsW(x, y, u, v, w, h)
        if use_vanilla_skin then return {true, true, false, true, true, true} end
        return {
            x==u or texture:getPixel(x-1,y).a==0, --north
            x==u+w-1 or texture:getPixel(x+1,y).a==0, --south
            false, --east
            true, --west
            y==v or texture:getPixel(x,y-1).a==0, --up
            y==v+h-1 or texture:getPixel(x,y+1).a==0, --down
        }
    end
    local function needsU(x, y, u, v, w, h)
        if use_vanilla_skin then return {true, true, true, true, true, false} end
        return {
            y==v+h-1 or texture:getPixel(x,y+1).a==0, --north
            y==v or texture:getPixel(x,y-1).a==0, --south
            x==u+w-1 or texture:getPixel(x+1,y).a==0, --east
            x==u or texture:getPixel(x-1,y).a==0, --west
            true, --up
            false, --down
        }
    end
    local function needsD(x, y, u, v, w, h)
        if use_vanilla_skin then return {true, true, true, true, false, true} end
        return {
            y==v+h-1 or texture:getPixel(x,y+1).a==0, --north
            y==v or texture:getPixel(x,y-1).a==0, --south
            x==u+w-1 or texture:getPixel(x+1,y).a==0, --east
            x==u or texture:getPixel(x-1,y).a==0, --west
            false, --up
            true, --down
        }
    end

    local u,v,w,h = north:unpack()
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            if not low_complexity_mode or texture:getPixel(x,y).a ~= 0 then
                newPixel(at,table.unpack(needsN(x,y, u, v, w, h))):setUVPixels(x,y):pos(-x+u-1+p.x+dims.x/2,-y+v-1+p.y+dims.y/2, -offset+p.z-dims.z/2)
            end
        end
    end

    u,v,w,h = south:unpack()
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            if not low_complexity_mode or texture:getPixel(x,y).a ~= 0 then
                newPixel(at,table.unpack(needsS(x,y,u,v,w,h))):setUVPixels(x,y):pos(x-u+p.x-dims.x/2,-y+v-1+p.y+dims.y/2, offset-1+p.z+dims.z/2)
            end
        end
    end

    u,v,w,h = east:unpack()
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            if not low_complexity_mode or texture:getPixel(x,y).a ~= 0 then
                newPixel(at,table.unpack(needsE(x,y,u,v,w,h))):setUVPixels(x,y):pos(offset-1+dims.x/2+p.x,-y+v-1+p.y+dims.y/2, p.z-x+u+dims.z/2-1)
            end
        end
    end

    u,v,w,h = west:unpack()
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            if not low_complexity_mode or texture:getPixel(x,y).a ~= 0 then
                newPixel(at,table.unpack(needsW(x,y,u,v,w,h))):setUVPixels(x,y):pos(-offset-dims.x/2+p.x,-y+v-1+p.y+dims.y/2, p.z+x-u-dims.z/2)
            end
        end
    end

    u,v,w,h = up:unpack()
    u = u + w
    v = v + h
    w = math.abs(w)
    h = math.abs(h)
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            if not low_complexity_mode or texture:getPixel(x,y).a ~= 0 then
                newPixel(at,table.unpack(needsU(x,y,u,v,w,h))):setUVPixels(x,y):pos(p.x-x+u-1+dims.x/2,p.y+dims.y/2+offset-1,p.z-y+v+dims.z/2-1)
            end
        end
    end

    u,v,w,h = down:unpack()
    u = u + w
    w = math.abs(w)
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            if not low_complexity_mode or texture:getPixel(x,y).a ~= 0 then
                newPixel(at,table.unpack(needsD(x,y,u,v,w,h))):setUVPixels(x,y):pos(p.x-x+u-1+dims.x/2,p.y-dims.y/2-offset,p.z-y+v+dims.z/2-1)
            end
        end
    end
end

function events.ENTITY_INIT()
    if player:getModelType() == "SLIM" then
        models.player_model3d.LeftArm:setVisible(false)
        models.player_model3d.RightArm:setVisible(false)
        Make3d(models.player_model3d.LeftArmSlim.center8, arm_scale, arm_inflate, vec(3,12,4)*res, vec(52,52,3,12)*res, vec(48,52,4,12)*res, vec(59,52,3,12)*res, vec(55,52,4,12)*res, vec(55,52,-3,-4)*res, vec(58,48,-3,4)*res)
        Make3d(models.player_model3d.RightArmSlim.center7, arm_scale, arm_inflate, vec(3,12,4)*res, vec(44,36,3,12)*res, vec(40,36,4,12)*res, vec(51,36,3,12)*res, vec(47,36,4,12)*res, vec(47,36,-3,-4)*res, vec(50,32,-3,4)*res)
    else
        models.player_model3d.LeftArmSlim:setVisible(false)
        models.player_model3d.RightArmSlim:setVisible(false)
        Make3d(models.player_model3d.LeftArm.center5, arm_scale, arm_inflate, vec(4,12,4)*res, vec(52,52,4,12)*res, vec(48,52,4,12)*res, vec(60,52,4,12)*res, vec(56,52,4,12)*res, vec(56,52,-4,-4)*res, vec(60,48,-4,4)*res)
        Make3d(models.player_model3d.RightArm.center4, arm_scale, arm_inflate, vec(4,12,4)*res, vec(44,36,4,12)*res, vec(40,36,4,12)*res, vec(52,36,4,12)*res, vec(48,36,4,12)*res, vec(48,36,-4,-4)*res, vec(52,32,-4,4)*res)
    end
    Make3d(models.player_model3d.Head.center2, head_scale, head_inflate, vec(8,8,8)*res, vec(40, 8, 8, 8)*res, vec(32, 8, 8, 8)*res, vec(56, 8, 8, 8)*res, vec(48, 8, 8, 8)*res, vec(48, 8, -8, -8)*res, vec(56, 0, -8, 8)*res)
    Make3d(models.player_model3d.Body.center3, body_scale, body_inflate, vec(8,12,4)*res, vec(20,36,8,12)*res, vec(16,36,4,12)*res, vec(32,36,8,12)*res, vec(28,36,4,12)*res, vec(28,36,-8,-4)*res, vec(36,32,-8,4)*res)
    Make3d(models.player_model3d.LeftLeg.center, leg_scale, leg_inflate, vec(4,12,4)*res, vec(4,52,4,12)*res, vec(0,52,4,12)*res, vec(12,52,4,12)*res, vec(8,52,4,12)*res, vec(8,52,-4,-4)*res, vec(12,48,-4,4)*res)
    Make3d(models.player_model3d.RightLeg.center6, leg_scale, leg_inflate, vec(4,12,4)*res, vec(4,36,4,12)*res, vec(0,36,4,12)*res, vec(12,36,4,12)*res, vec(8,36,4,12)*res, vec(8,36,-4,-4)*res, vec(12,32,-4,4)*res)    

    if use_vanilla_skin then
        models.player_model3d:setPrimaryTexture("SKIN")
    end
end