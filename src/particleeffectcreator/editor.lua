local cursor = require "cursor"
local io = require "io"

local editmode = false
local rotatemode = false
local dragmode = false
local editposition = nil
local editoffset = vec(0,0,0)
local camerarot = vec(0,-3)
local camerazoom = 4.1
local isInputting = false
local cameraSensitivity = io:load("cameraSensitivity") or 1

function toggleEditMode()
    editmode = not editmode
    editposition = player:getPos()
    if editmode then
        models.particle_effect_creator.WorldSteve:setPos(player:getPos()*16)
        models.particle_effect_creator.WorldAlex:setPos(player:getPos()*16)
        editoffset = vec(0,0,0)
        camerarot = vec(0,-3)
        camerazoom = 4.1
    end
end

function events.entity_init()
    toggleEditMode()
    editposition = player:getPos()
    models.particle_effect_creator.PlayerSteve:setVisible(player:getModelType()=="DEFAULT")
    models.particle_effect_creator.PlayerAlex:setVisible(player:getModelType()=="SLIM")
end

local function inputOverride(value)
    isInputting = value
end

models.particle_effect_creator.WorldSteve:setPrimaryTexture("SKIN")
models.particle_effect_creator.WorldAlex:setPrimaryTexture("SKIN")
models.particle_effect_creator.PlayerSteve:setPrimaryTexture("SKIN")
models.particle_effect_creator.PlayerAlex:setPrimaryTexture("SKIN")
models.particle_effect_creator.WorldSteve:setVisible(false)
models.particle_effect_creator.WorldAlex:setVisible(false)
vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)

keybinds:fromVanilla("key.jump"):onPress(toggleEditMode)

local allowedToRotate = true
function events.mouse_move(x,y)
    if rotatemode and allowedToRotate then
        camerarot = vec(
            camerarot.x-x*cameraSensitivity/60,
            math.clamp(camerarot.y-y*cameraSensitivity/60,-4.7,-1.6)
        )
    elseif dragmode then
        local dir = editposition+editoffset+vec(0,player:getEyeHeight(),0)-renderer:getCameraPivot()
        local u = dir:crossed(vec(0,1,0))
        local v = u:crossed(dir)
        editoffset:sub(u*x*cameraSensitivity/600)
        editoffset:add(v*y*cameraSensitivity/900)
    end
    return editmode
end
function events.mouse_scroll(dir)
    camerazoom = math.max(camerazoom - dir*0.5,0.1)
    return editmode
end
function events.mouse_press(button, action, modifier)
    if editmode then
        if button == 0 then
            allowedToRotate = not isInputting
            rotatemode = action == 1
        elseif button == 1 then
            dragmode = action == 1
        end
    else
        rotatemode = false
        dragmode = false
    end
    return editmode
end

function events.tick()
    local playerDistanceToStart = (player:getPos() - editposition):length()
    local maxPlayerDistance = 2
    if editmode and playerDistanceToStart > maxPlayerDistance then
        editmode = false
    end
    if editmode then
        local opacity = math.map(playerDistanceToStart,0,maxPlayerDistance,0,1)
        models.particle_effect_creator.PlayerSteve:setOpacity(opacity)
        models.particle_effect_creator.PlayerAlex:setOpacity(opacity)
        models.particle_effect_creator.PlayerSteve:setVisible(player:getModelType()=="DEFAULT" and playerDistanceToStart > 0.1)
        models.particle_effect_creator.PlayerAlex:setVisible(player:getModelType()=="SLIM" and playerDistanceToStart > 0.1)
    else
        models.particle_effect_creator.PlayerSteve:setOpacity(1)
        models.particle_effect_creator.PlayerAlex:setOpacity(1)
        models.particle_effect_creator.PlayerSteve:setVisible(player:getModelType()=="DEFAULT")
        models.particle_effect_creator.PlayerAlex:setVisible(player:getModelType()=="SLIM")
    end
    -- host:setUnlockCursor(editmode)
    cursor:setUnlockCursor(editmode)
    models.particle_effect_creator.WorldSteve:setVisible(player:getModelType()=="DEFAULT" and editmode)
    models.particle_effect_creator.WorldAlex:setVisible(player:getModelType()=="SLIM" and editmode)
    if editmode then
        local x = math.cos(camerarot.y) * math.sin(camerarot.x) * camerazoom
        local y = math.sin(camerarot.y) * camerazoom
        local z = math.cos(camerarot.y) * math.cos(camerarot.x) * camerazoom
        renderer:setCameraPivot(
            editposition+editoffset+vec(0,player:getEyeHeight(),0)
            :add(x,y,z)
        )
        local dir = editposition+editoffset+vec(0,player:getEyeHeight(),0)-renderer:getCameraPivot()
        local yaw = math.deg(math.atan2(dir.x, dir.z))
        local pitch = math.deg(math.atan2(dir.y, dir.xz:length()))
        renderer:setCameraRot(-pitch,-yaw,0)
        -- renderer:offsetCameraPivot(dir:crossed(vec(0,-1,0))*0.3)
    else
        renderer:setCameraPivot()
        renderer:setCameraRot()
    end
end

return {
    editMode=function() return editmode end,
    setCameraSensitivity = function(value) cameraSensitivity = value end,
    inputOverride=inputOverride
}