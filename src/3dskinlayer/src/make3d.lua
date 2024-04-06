----   HELP   ----
-- With offset > 0 and scale = 0 the corners will be missing
-- With offset = 0 and scale > 0 z-fighting might occur
-- With offset > 0 and scale > 0 probably doesn't look good
-- Scale when armor can be 0 to hide completely, or adjusted individually to fit inside armor

---- SETTINGS ----
local offset = 0 -- from 0 to 1
local head_scale = 1.15
local body_scale = 1.25
local arm_scale = 1.27
local leg_scale = 1.25
------------------

vanilla_model.PLAYER:setVisible(false)
models.player_model3d:setPrimaryTexture("SKIN")

local px = models.player_model3d.pixel:visible(false)

---@param at ModelPart
---@param dims Vector3
---@param north Vector4
---@param east Vector4
---@param south Vector4
---@param west Vector4
---@param up Vector4
---@param down Vector4
local function Make3d(at, dims, north, east, south, west, up, down)
    local p = at:getTruePivot()

    local u,v,w,h = north:unpack()
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            px:copy("pixel"):visible(true):setUVPixels(x,y):moveTo(at):setPos(-x+u-1+p.x+dims.x/2,-y+v-1+p.y+dims.y/2, -offset+p.z-dims.z/2)
        end
    end

    u,v,w,h = south:unpack()
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            px:copy("pixel"):visible(true):setUVPixels(x,y):moveTo(at):setPos(-x+u-1+p.x+dims.x/2,-y+v-1+p.y+dims.y/2, offset-1+p.z+dims.z/2)
        end
    end

    u,v,w,h = east:unpack()
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            px:copy("pixel"):visible(true):setUVPixels(x,y):moveTo(at):setPos(offset-1+dims.x/2+p.x,-y+v-1+p.y+dims.y/2, p.z-x+u+dims.z/2-1)
        end
    end

    u,v,w,h = west:unpack()
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            px:copy("pixel"):visible(true):setUVPixels(x,y):moveTo(at):setPos(-offset-dims.x/2+p.x,-y+v-1+p.y+dims.y/2, p.z+x-u-dims.z/2)
        end
    end

    u,v,w,h = up:unpack()
    u = u + w
    v = v + h
    w = math.abs(w)
    h = math.abs(h)
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            px:copy("pixel"):visible(true):setUVPixels(x,y):moveTo(at):setPos(p.x+x-u-dims.x/2,p.y+dims.y/2+offset-1,p.z-y+v+dims.z/2-1)
        end
    end

    u,v,w,h = down:unpack()
    u = u + w
    w = math.abs(w)
    for x = u, u+w-1 do
        for y = v, v+h-1 do
            px:copy("pixel"):visible(true):setUVPixels(x,y):moveTo(at):setPos(p.x+x-u-dims.x/2,p.y-dims.y/2-offset,p.z-y+v+dims.z/2-1)
        end
    end
end

models.player_model3d.Head.center2:setScale(head_scale)
models.player_model3d.Body.center3:setScale(body_scale)
models.player_model3d.LeftLeg.center:setScale(leg_scale)
models.player_model3d.RightLeg.center6:setScale(leg_scale)
models.player_model3d.LeftArm.center5:setScale(arm_scale)
models.player_model3d.LeftArmSlim.center8:setScale(arm_scale)
models.player_model3d.RightArm.center4:setScale(arm_scale)
models.player_model3d.RightArmSlim.center7:setScale(arm_scale)

Make3d(models.player_model3d.Head.center2 , vec(8,8,8), vec(40, 8, 8, 8), vec(32, 8, 8, 8), vec(56, 8, 8, 8), vec(48, 8, 8, 8), vec(48, 8, -8, -8), vec(56, 0, -8, 8))
Make3d(models.player_model3d.Body.center3, vec(8,12,4), vec(20,36,8,12), vec(16,36,4,12), vec(32,36,8,12), vec(28,36,4,12), vec(28,36,-8,-4), vec(36,32,-8,4))
Make3d(models.player_model3d.LeftLeg.center, vec(4,12,4), vec(4,52,4,12), vec(0,52,4,12), vec(12,52,4,12), vec(8,52,4,12), vec(8,52,-4,-4), vec(12,48,-4,4))
Make3d(models.player_model3d.RightLeg.center6, vec(4,12,4), vec(4,36,4,12), vec(0,36,4,12), vec(12,36,4,12), vec(8,36,4,12), vec(8,36,-4,-4), vec(12,32,-4,4))

events.ENTITY_INIT:register(function ()
    if player:getModelType() == "SLIM" then
        models.player_model3d.LeftArm:setVisible(false)
        models.player_model3d.RightArm:setVisible(false)
        Make3d(models.player_model3d.LeftArmSlim.center8, vec(3,12,4), vec(52,52,3,12), vec(48,52,4,12), vec(59,52,3,12), vec(55,52,4,12), vec(55,52,-3,-4), vec(58,48,-4,4))
        Make3d(models.player_model3d.RightArmSlim.center7, vec(3,12,4), vec(44,36,3,12), vec(40,36,4,12), vec(51,36,3,12), vec(47,36,4,12), vec(47,36,-3,-4), vec(50,32,-3,4))
    else
        models.player_model3d.LeftArmSlim:setVisible(false)
        models.player_model3d.RightArmSlim:setVisible(false)
        Make3d(models.player_model3d.LeftArm.center5, vec(4,12,4), vec(52,52,4,12), vec(48,52,4,12), vec(60,52,4,12), vec(56,52,4,12), vec(56,52,-4,-4), vec(60,48,-4,4))
        Make3d(models.player_model3d.RightArm.center4, vec(4,12,4), vec(44,36,4,12), vec(40,36,4,12), vec(52,36,4,12), vec(48,36,4,12), vec(48,36,-4,-4), vec(52,32,-4,4))
    end
end)