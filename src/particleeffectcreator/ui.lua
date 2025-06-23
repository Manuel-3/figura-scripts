require "globals"
local editor = require "editor"
local uihelper = require "uihelper"
local io = require "io"
local util = require "util"
local cursor = require "cursor"
local GNUI = require "GNUI.main"
local Theme = require "GNUI.theme"
local Button = require "GNUI.element.button"
local Slider = require "GNUI.element.slider"
local TextField = require "GNUI.element.textField"

local state = {}

state.name = io:load("lastSelectedName") or "myparticle"

local rateNumberField
local rate_min = 1
local rate_max = 4000
local rate_hardcap = 100000
local prev_rate_value
local prev_rate_error
state.rate = 20

local modes = {"Loop","Once"}
state.mode = "Loop"

local shapes = {"Point","Sphere","Box","Disc"}
state.shape = "Sphere"

local positionSlider
state.position = {0,16,0}
local prev_position_value
local prev_position_error

local sizeSlider
state.size = {32,32,32}
local prev_size_value
local prev_size_error

local rotationSlider
state.rotation = {0,0,0}
local prev_rotation_value
local prev_rotation_error

local radiusNumberField
local radius_min = 0
local radius_max = 64
state.radius = 16
local prev_radius_value
local prev_radius_error

local spawns = {"Surface","Volume","Outline"}
state.spawn = "Surface"

local origins = {"Player","Modelpart"}
state.origin = "Player"

local modelpartTextField
state.modelpart = "nil"
local prev_modelpart_value
local prev_modelpart_error

local parents = {"World","Origin"}
state.parent = "World"

local velocitySlider
state.velocity = {0,0,0}
local prev_velocity_value
local prev_velocity_error

local relativetos = {"World","Origin"}
state.relativeto = "World"

local types = {"Vanilla","Confetti"}
state.type = "Vanilla"

local particleTextField
state.particle = "flame"
local prev_particle_value
local prev_particle_error

local lifetimeNumberField
local lifetime_min = 1
local lifetime_max = 100
state.lifetime = "default"
local prev_lifetime_value
local prev_lifetime_error

local gravityNumberField
local gravity_min = -4
local gravity_max = 4
state.gravity = "default"
local prev_gravity_value
local prev_gravity_error

local collisions = {"Yes","No"}
state.collision = "No"

local colorSlider
state.color = {255,255,255}
local prev_color_value
local prev_color_error

local scaleNumberField
local scale_min = 0
local scale_max = 2
state.scale = "default"
local prev_scale_value
local prev_scale_error

local scaleOverTimeNumberField
local scaleOverTime_min = 0
local scaleOverTime_max = 2
state.scaleOverTime = 0
local prev_scaleOverTime_value
local prev_scaleOverTime_error

local confettirotationNumberField
local confettirotation_min = 0
local confettirotation_max = 2
state.confettirotation = "default"
local prev_confettirotation_value
local prev_confettirotation_error

local confettirotationOverTimeNumberField
local confettirotationOverTime_min = 0
local confettirotationOverTime_max = 2
state.confettirotationOverTime = 0
local prev_confettirotationOverTime_value
local prev_confettirotationOverTime_error

local accelerationNumberField
local acceleration_min = -4
local acceleration_max = 4
state.acceleration = 0
local prev_acceleration_value
local prev_acceleration_error

local airFrictionNumberField
local airFriction_min = 0
local airFriction_max = 4
state.airFriction = 0
local prev_airFriction_value
local prev_airFriction_error

local groundFrictionNumberField
local groundFriction_min = 0
local groundFriction_max = 4
state.groundFriction = 0
local prev_groundFriction_value
local prev_groundFriction_error

local bouncynessNumberField
local bouncyness_min = 0
local bouncyness_max = 1
state.bouncyness = 0
local prev_bouncyness_value
local prev_bouncyness_error

local hiddenTextures = {
    ".-particle_effect_creator.selection$",
    ".-particle_effect_creator.cursors$",
    ".-gnuiTheme$"
}
local textureNames = {}
for _, value in pairs(textures:getTextures()) do
    local allowed = true
    for _, hidden in ipairs(hiddenTextures) do
        allowed = allowed and not (value:getName():match(hidden))
    end
    if allowed then
        table.insert(textureNames,value:getName())
    end
end
state.texture = textureNames[1]

state.uv = {0,0,8,8}

local meshTextField
state.mesh = "models.confetti.model.Spark"
local prev_mesh_value
local prev_mesh_error

state.frames = "1"
local prev_frames_value
local framesNumberField

local confettitypes = {"Sprite","Mesh"}
state.confettitype = "Sprite"

local directions = {"Vertical","Horizontal"}
state.direction = "Vertical"

local emissives = {"Yes","No"}
state.emissive = "No"

local billboards = {"Yes","No"}
state.billboard = "No"

local speedNumberField
local speed_min = 1
local speed_max = 20
state.speed = 20
local prev_speed_value
local prev_speed_error

io:setDefaultParticle(util.deepCopy(state))

local configuration
configuration = {
    rate = function(env)
        local success, result = pcall(load("return ("..state.rate..")","Rate",env))
        if (not success or not tonumber(result)) and (prev_rate_error ~= result or prev_rate_value ~= state.rate) then
            util.logError("Rate: ",result)
            rateNumberField:setError()
        end
        prev_rate_error = result
        prev_rate_value = state.rate
        local ret = success and tonumber(result) and math.min(tonumber(result),rate_hardcap) or 0
        configuration.notifyRate(ret)
        return ret
    end,
    mode = function() return state.mode end,
    shape = function() return state.shape end,
    position = function(env)
        local success, result = pcall(load("return vec(("..state.position[1]..") or error 'x is nil',("..state.position[2]..") or error 'y is nil',("..state.position[3]..") or error 'z is nil')","Position",env))
        if (not success) and (prev_position_error ~= result or prev_position_value ~= state.position) then
            util.logError("Position: ",result)
            positionSlider:setError()
        end
        prev_position_error = result
        prev_position_value = state.position
        return success and result or vec(0,0,0)
    end,
    size = function(env)
        local success, result = pcall(load("return vec(("..state.size[1]..") or error 'x is nil',("..state.size[2]..") or error 'y is nil',("..state.size[3]..") or error 'z is nil')","Size",env))
        if (not success) and (prev_size_error ~= result or prev_size_value ~= state.size) then
            util.logError("Size: ",result)
            sizeSlider:setError()
        end
        prev_size_error = result
        prev_size_value = state.size
        return success and result or vec(0,0,0)
    end,
    rotation = function(env)
        local success, result = pcall(load("return vec(("..state.rotation[1]..") or error 'x is nil',("..state.rotation[2]..") or error 'y is nil',("..state.rotation[3]..") or error 'z is nil')","Rotation",env))
        if (not success) and (prev_rotation_error ~= result or prev_rotation_value ~= state.rotation) then
            util.logError("Rotation: ",result)
            rotationSlider:setError()
        end
        prev_rotation_error = result
        prev_rotation_value = state.rotation
        return success and result or vec(0,0,0)
    end,
    modelpart = function(env)
        local success, result = pcall(load("return ("..state.modelpart..")","Modelpart",env))
        if (not success or type(result) ~= "ModelPart") and (prev_modelpart_error ~= result or prev_modelpart_value ~= state.modelpart) then
            util.logError("Modelpart: ",result)
            modelpartTextField:setError()
        end
        prev_modelpart_error = result
        prev_modelpart_value = state.modelpart
        return success and result or 0
    end,
    radius = function(env)
        local success, result = pcall(load("return ("..state.radius..")","Radius",env))
        if (not success or not tonumber(result)) and (prev_radius_error ~= result or prev_radius_value ~= state.radius) then
            util.logError("Radius: ",result)
            radiusNumberField:setError()
        end
        prev_radius_error = result
        prev_radius_value = state.radius
        local ret = success and tonumber(result) or 0
        configuration.notifyRadius(ret)
        return ret
    end,
    spawn = function() return state.spawn end,
    origin = function() return state.origin end,
    parent = function() return state.parent end,
    velocity = function(env)
        local success, result = pcall(load("return vec(("..state.velocity[1]..") or error 'x is nil',("..state.velocity[2]..") or error 'y is nil',("..state.velocity[3]..") or error 'z is nil')","Velocity",env))
        if (not success) and (prev_velocity_error ~= result or prev_velocity_value ~= state.velocity) then
            util.logError("Velocity: ",result)
            velocitySlider:setError()
        end
        prev_velocity_error = result
        prev_velocity_value = state.velocity
        return success and result or vec(0,0,0)
    end,
    relativeto = function() return state.relativeto end,
    collision = function() return state.collision=="Yes" end,
    type = function() return state.type end,
    particle = function(env)
        local success, result = pcall(load("if particles[\""..state.particle.."\"] then return \""..state.particle.."\" end","Particle",env))
        if not success and (prev_particle_error ~= result or prev_particle_value ~= state.particle) then
            util.logError("Particle: ",result)
            particleTextField:setError()
        end
        prev_particle_error = result
        prev_particle_value = state.particle
        return success and result or "block_marker minecraft:void_air"
    end,
    lifetime = function(env)
        local success, result = pcall(load("return ("..state.lifetime..")","Lifetime",env))
        if not success and (prev_lifetime_error ~= result or prev_lifetime_value ~= state.lifetime) then
            util.logError("Lifetime: ",result)
            lifetimeNumberField:setError()
        end
        prev_lifetime_error = result
        prev_lifetime_value = state.lifetime
        return success and tonumber(result) or nil
    end,
    gravity = function(env)
        local success, result = pcall(load("return ("..state.gravity..")","Gravity",env))
        if not success and (prev_gravity_error ~= result or prev_gravity_value ~= state.gravity) then
            util.logError("Gravity: ",result)
            gravityNumberField:setError()
        end
        prev_gravity_error = result
        prev_gravity_value = state.gravity
        return success and tonumber(result) or nil
    end,
    color = function(env)
        local success, result = pcall(load("return vec(("..state.color[1]..") or error 'x is nil',("..state.color[2]..") or error 'y is nil',("..state.color[3]..") or error 'z is nil')","Color",env))
        if (not success) and (prev_color_error ~= result or prev_color_value ~= state.color) then
            util.logError("Color: ",result)
            colorSlider:setError()
        end
        prev_color_error = result
        prev_color_value = state.color
        local ret = success and result/255 or vec(0,0,0)
        configuration.notifyColor(ret)
        return ret
    end,
    scale = function(env)
        local success, result = pcall(load("return ("..state.scale..")","Scale",env))
        if not success and (prev_scale_error ~= result or prev_scale_value ~= state.scale) then
            util.logError("Scale: ",result)
            scaleNumberField:setError()
        end
        prev_scale_error = result
        prev_scale_value = state.scale
        return success and tonumber(result) or nil
    end,
    scaleOverTime = function(env)
        local success, result = pcall(load("return ("..state.scaleOverTime..")","ScaleOverTime",env))
        if (not success or not tonumber(result)) and (prev_scaleOverTime_error ~= result or prev_scaleOverTime_value ~= state.scaleOverTime) then
            util.logError("ScaleOverTime: ",result)
            scaleOverTimeNumberField:setError()
        end
        prev_scaleOverTime_error = result
        prev_scaleOverTime_value = state.scaleOverTime
        return success and tonumber(result) or 0
    end,
    confettirotation = function(env)
        local success, result = pcall(load("return ("..state.confettirotation..")","Rotation",env))
        if not success and (prev_confettirotation_error ~= result or prev_confettirotation_value ~= state.confettirotation) then
            util.logError("Rotation: ",result)
            confettirotationNumberField:setError()
        end
        prev_confettirotation_error = result
        prev_confettirotation_value = state.confettirotation
        return success and tonumber(result) or nil
    end,
    confettirotationOverTime = function(env)
        local success, result = pcall(load("return ("..state.confettirotationOverTime..")","RotationOverTime",env))
        if (not success or not tonumber(result)) and (prev_confettirotationOverTime_error ~= result or prev_confettirotationOverTime_value ~= state.confettirotationOverTime) then
            util.logError("RotationOverTime: ",result)
            confettirotationOverTimeNumberField:setError()
        end
        prev_confettirotationOverTime_error = result
        prev_confettirotationOverTime_value = state.confettirotationOverTime
        return success and tonumber(result) or 0
    end,
    acceleration = function(env)
        local success, result = pcall(load("return ("..state.acceleration..")","Acceleration",env))
        if (not success or not tonumber(result)) and (prev_acceleration_error ~= result or prev_acceleration_value ~= state.acceleration) then
            util.logError("Acceleration: ",result)
            accelerationNumberField:setError()
        end
        prev_acceleration_error = result
        prev_acceleration_value = state.acceleration
        return success and tonumber(result) or 0
    end,
    airFriction = function(env)
        local success, result = pcall(load("return ("..state.airFriction..")","Air Friction",env))
        if (not success or not tonumber(result)) and (prev_airFriction_error ~= result or prev_airFriction_value ~= state.airFriction) then
            util.logError("Air Friction: ",result)
            airFrictionNumberField:setError()
        end
        prev_airFriction_error = result
        prev_airFriction_value = state.airFriction
        return success and tonumber(result) or 0
    end,
    groundFriction = function(env)
        local success, result = pcall(load("return ("..state.groundFriction..")","Ground Friction",env))
        if (not success or not tonumber(result)) and (prev_groundFriction_error ~= result or prev_groundFriction_value ~= state.groundFriction) then
            util.logError("Ground Friction: ",result)
            groundFrictionNumberField:setError()
        end
        prev_groundFriction_error = result
        prev_groundFriction_value = state.groundFriction
        return success and tonumber(result) or 0
    end,
    bouncyness = function(env)
        local success, result = pcall(load("return ("..state.bouncyness..")","Bouncyness",env))
        if (not success or not tonumber(result)) and (prev_bouncyness_error ~= result or prev_bouncyness_value ~= state.bouncyness) then
            util.logError("Bouncyness: ",result)
            bouncynessNumberField:setError()
        end
        prev_bouncyness_error = result
        prev_bouncyness_value = state.bouncyness
        return success and tonumber(result) or 0
    end,
    texture = function() return textures[state.texture] end,
    uv = function() return vec(table.unpack(state.uv)) end,
    mesh = function(env)
        local success, result = pcall(load("return ("..state.mesh..")","Mesh",env))
        if (result == models) then
            if prev_mesh_error ~= result or prev_mesh_value ~= state.mesh then
                util.logError("Mesh: Model tree root 'models' is not allowed.\n")
                meshTextField:setError()
            end
            prev_mesh_error = result
            prev_mesh_value = state.mesh
            return nil
        else
            if (not success or type(result) ~= "ModelPart") and (prev_mesh_error ~= result or prev_mesh_value ~= state.mesh) then
                util.logError("Mesh: ",result)
                meshTextField:setError()
            end
            prev_mesh_error = result
            prev_mesh_value = state.mesh
            return success and result or nil
        end
    end,
    frames = function(env)
        if not tonumber(state.frames) and (prev_frames_value ~= state.frames)then
            util.logError("Frames: String \"",state.frames,"\" can not be converted to a number.\n")
            framesNumberField:setError()
        end
        prev_frames_value = state.frames
        return tonumber(state.frames) or 0
    end,
    speed = function(env)
        local success, result = pcall(load("return ("..state.speed..")","Speed",env))
        if (not success or not tonumber(result)) and (prev_speed_error ~= result or prev_speed_value ~= state.speed) then
            util.logError("Speed: ",result)
            speedNumberField:setError()
        end
        prev_speed_error = result
        prev_speed_value = state.speed
        local ret = success and tonumber(result) or 0
        configuration.notifySpeed(ret)
        return ret
    end,

    -- events
    onPlay = function()end,
    onPause = function()end,

    -- actions (replaced later)
    play=nil,
    pause=nil,
    updateTimer=nil,
    notifyEnvStructure=nil,

    -- internal actions (replaced later)
    notifyRate=nil,
    notifyRadius=nil,
    notifyColor=nil,
    notifyMesh=nil,
}

local stateCallbacks = {}
-- callbacks must not cause other state changes than itself
-- e.g. registerToState("uv",callback) does not need to but
-- may edit state.uv, but must never edit any other state!
local function registerToState(name,callback)
    stateCallbacks[name] = stateCallbacks[name] or {}
    table.insert(stateCallbacks[name],callback)
end
local function pushStateToGui()
    for name, value in pairs(state) do
        stateCallbacks[name] = stateCallbacks[name] or {}
        for _, callback in ipairs(stateCallbacks[name]) do
            callback(value)
        end
    end
end

local screen = GNUI.getScreenCanvas()
local box_timer = GNUI.newBox(screen)
    :setAnchor(0,0,1,0.07)
    :setDimensions(0,0,0,0)
    :setTextAlign(0.5,0.5)
    :setTextEffect("OUTLINE")
function configuration.updateTimer(t)
    local totalSeconds = t / 20
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    box_timer:setText(string.format("%d:%05.2f", minutes, seconds))
end
local box_sidebar = GNUI.newBox(screen)
    :setAnchor(io:load("sideBarX") or 0.7,0,1,1)
    :setDimensions(0,2,0,0)
local drag_sidebar = false
events.MOUSE_PRESS:register(function (button,status,modifier)
    local pos = box_sidebar:toLocal(screen.MousePosition)
    local new_drag_sidebar = status == 1 and pos.x < 3 and pos.x > -1
    if drag_sidebar and not new_drag_sidebar then
        io:save("sideBarX", box_sidebar.Anchor.x)
    end
    drag_sidebar = new_drag_sidebar
end)
events.MOUSE_MOVE:register(function (x,y)
    local pos = box_sidebar:toLocal(screen.MousePosition)
    if pos.x < 3 and pos.x > -1 or drag_sidebar then
        cursor.setCursor("DragLeftRight")
    end
    if drag_sidebar then
        box_sidebar:setAnchor(math.clamp(screen:XYtoUV(screen:toLocal(screen.MousePosition)).x,0.1,0.9),0,1,1)
    end
end)
-- Theme.style(box_timer,"Background")
local box_file = GNUI.newBox(box_sidebar)
    :setAnchor(0,0.05,1,0.93)
Theme.style(box_file,"Background")
local box_emitter = GNUI.newBox(box_sidebar)
    :setAnchor(0,0.05,1,0.93)
Theme.style(box_emitter,"Background")
uihelper.disableCamera(box_emitter)
local box_motion = GNUI.newBox(box_sidebar)
    :setAnchor(0,0.05,1,0.93)
Theme.style(box_motion,"Background")
uihelper.disableCamera(box_motion)
local box_particle = GNUI.newBox(box_sidebar)
    :setAnchor(0,0.05,1,0.93)
Theme.style(box_particle,"Background")
uihelper.disableCamera(box_particle)
local box_help = GNUI.newBox(box_sidebar)
    :setAnchor(0,0.05,1,0.93)
Theme.style(box_help,"Background")
uihelper.disableCamera(box_help)
local box_confetti = GNUI.newBox(box_sidebar)
    :setAnchor(0,0.05,1,0.93)
Theme.style(box_confetti,"Background")
uihelper.disableCamera(box_confetti)

local tabs = {"File","Emitter","Motion","Particle","Confetti","Help"}
local unsavedtabs = {"File ●"}
for i = 2, #tabs do
    table.insert(unsavedtabs,tabs[i])
end
local tab_default = io:load("selectedTab") or "Emitter"
if tab_default == "File" then
    tab_default = "File ●"
end
local function selectTab(name)
    if name:match("^File.*") then
        box_file:setVisible(true)
        io:save("selectedTab","File")
    else
        box_file:setVisible(false)
        io:save("selectedTab",name)
    end
    box_emitter:setVisible(name == "Emitter")
    box_motion:setVisible(name == "Motion")
    box_particle:setVisible(name == "Particle")
    box_help:setVisible(name == "Help")
    box_confetti:setVisible(name == "Confetti")
end
selectTab(tab_default)

local box_tabs = GNUI.newBox(box_sidebar)
    :setAnchor(0,0,1,0.05)
local tabsPicker = uihelper.Picker(box_tabs,unsavedtabs,tab_default):setAnchor(0,0,1,1)
    :setFontScale(__FONT_TEXT)
tabsPicker.PRESSED:register(function(selected)
    selectTab(selected)
end)
uihelper.disableCamera(tabsPicker)

local box_playbutton = GNUI.newBox(box_sidebar)
    :setAnchor(0,0.93,1,1)
local pauseButton = uihelper.OnOffButton(box_playbutton):setAnchor(0,0,1,1)
    :setText("Play")
    :setOffText("Stop")
pauseButton.PRESSED:register(function(state)
    if state then
        configuration.onPause()
    else
        configuration.onPlay()
    end
end)
pauseButton:setState(false)
uihelper.disableCamera(pauseButton)
function configuration.pause()
    pauseButton:setState(true)
    configuration.onPause()
end
function configuration.play()
    pauseButton:setState(false)
    configuration.onPlay()
end

screen.INPUT:register(function()
    require "runLater" (1,function()
        local unsaved = false
        local savedState = io:lastLoadedParticle()
        if savedState ~= nil then
            for key, value in pairs(state) do
                if type(value)=="table" then
                    for subkey, subvalue in ipairs(value) do
                        if savedState[key][subkey] ~= subvalue then
                            unsaved = true
                        end
                    end
                else
                    if savedState[key] ~= value then
                        unsaved = true
                    end
                end
            end
        else
            unsaved = true
        end
        tabsPicker:setOptions(unsaved and unsavedtabs or tabs)
    end)
end)

do
    local shouldDisplayPointer = false
    local shouldDisplayText = false
    local shouldDisplayDragLeftRight = false
    screen.HOVERING_ELEMENT_CHANGED:register(function (a,b)
        if not a then return end
        shouldDisplayPointer = type(a) == "GNUI.Button"
        shouldDisplayText = type(a) == "GNUI.TextField"
        shouldDisplayDragLeftRight = type(a) == "GNUI.Slider"
    end)
    events.MOUSE_MOVE:register(function (x,y)
        if shouldDisplayPointer then
            cursor.setCursor("Pointer")
        end
        if shouldDisplayText then
            cursor.setCursor("Text")
        end
        if shouldDisplayDragLeftRight then
            cursor.setCursor("DragLeftRight")
        end
    end)
end

uihelper.vertical({},{
    function(anchor)
        local remakeLoadPicker
        local box = GNUI.newBox(box_file):setAnchor(anchor:unpack())
            :setDimensions(0,5,0,-5)
        uihelper.vertical({1,1,1,5,1,1},{
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                    :setText("File")
                    :setFontScale(__FONT_HEADING)
                    :setTextAlign(0.5,0.5)
                uihelper.disableCamera(box)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2,1},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Name")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local textfield = TextField.new(box):setAnchor(anchor:unpack())
                            :setTextField(state.name)
                        textfield.Label:setFontScale(__FONT_TEXT)
                        textfield.FIELD_CONFIRMED:register(function(text)
                            state.name = text
                        end)
                        registerToState("name",function(value)
                            textfield:setTextField(value)
                        end)
                        uihelper.disableCamera(textfield)
                    end,
                    function(anchor)
                        local function save()
                            io:saveParticle(state.name,state)
                            io:loadParticle(state.name) -- refresh last loaded
                            io:save("lastSelectedName",state.name)
                            remakeLoadPicker()
                        end
                        local button = Button.new(box):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                            :setText("Save")
                        button.PRESSED:register(function()
                            save()
                        end)
                        uihelper.disableCamera(button)
                        function events.KEY_PRESS(key,status,modifier)
                            if key == 83 and status == 1 and modifier == 2 then
                                -- ctrl s
                                save()
                                return true
                            end
                        end
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                    :setText("Load")
                    :setFontScale(__FONT_TEXT)
                    :setTextAlign(0.5,0.5)
                uihelper.disableCamera(box)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                local picker
                remakeLoadPicker = function()
                    if picker then
                        picker:free()
                    end
                    picker = uihelper.Picker(box,io:listParticles(),state.name,"vertical"):setAnchor(0,0,1,1)
                        :setFontScale(__FONT_TEXT)
                    picker.PRESSED:register(function(selected)
                        state = io:loadParticle(selected)
                        state.name = selected
                        io:save("lastSelectedName",state.name)
                        pushStateToGui()
                    end)
                    uihelper.disableCamera(picker)
                end
                remakeLoadPicker()
            end,
            function(anchor)
                local button = Button.new(box):setAnchor(anchor:unpack())
                    :setFontScale(__FONT_TEXT)
                    :setText("Save to clipboard")
                button.PRESSED:register(function()
                    io:saveParticleToClipboard(state)
                end)
                uihelper.disableCamera(button)
            end,
            function(anchor)
                local button = Button.new(box):setAnchor(anchor:unpack())
                    :setFontScale(__FONT_TEXT)
                    :setText("Load from clipboard")
                button.PRESSED:register(function()
                    state = io:loadParticleFromClipboard()
                    pushStateToGui()
                end)
                uihelper.disableCamera(button)
            end,
        })
    end,
})

uihelper.vertical({},{
    function(anchor)
        local box = GNUI.newBox(box_emitter):setAnchor(anchor:unpack())
            :setDimensions(0,5,0,-5)
        uihelper.vertical({1,3,2,6,2,2,2,3,2},{
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                    :setText("Emitter")
                    :setFontScale(__FONT_HEADING)
                    :setTextAlign(0.5,0.5)
                uihelper.disableCamera(box)
            end,
            function(anchor)
                rateNumberField = uihelper.NumberField(box,"Rate",nil,rate_min,rate_max):setAnchor(anchor:unpack())
                    :setFontScale(__FONT_TEXT)
                rateNumberField.VALUE_CHANGED:register(function(value)
                    state.rate = value
                end)
                registerToState("rate",function(value)
                    rateNumberField:setValue(value)
                end)
                function configuration.notifyRate(r)
                    if r == state.rate then
                        rateNumberField:setName("Rate")
                    else
                        rateNumberField:setName("Rate\n"..string.format("%.2f", r))
                    end
                end
                uihelper.disableCamera(rateNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Mode")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,modes,state.mode):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.mode = selected
                            if state.mode == "Loop" then
                                configuration.play()
                            end
                        end)
                        registerToState("mode",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Shape")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,shapes,state.shape,"vertical"):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.shape = selected
                        end)
                        registerToState("shape",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Position")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local min, max = -64, 64
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                        local sliderX = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0,0,0.33,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        local function updateSlider(slider,value,axis)
                            local newvalue = value
                            if tonumber(value) then
                                newvalue = math.round(math.map(value,slider.min,slider.max,min,max))
                            end
                            state.position[axis] = newvalue
                            slider.numberBox:setText(newvalue)
                        end
                        sliderX.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderX,value,1)
                        end)
                        registerToState("position",function(value)
                            sliderX:setValue(math.map(value[1],min,max,sliderX.min,sliderX.max))
                            sliderX.numberBox:setText(tostring(value[1]))
                        end)
                        sliderX:setValue(math.map(state.position[1],min,max,sliderX.min,sliderX.max))
                        updateSlider(sliderX,math.map(state.position[1],min,max,sliderX.min,sliderX.max),1)
                        uihelper.disableCamera(sliderX)

                        local sliderY = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.33,0,0.66,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        sliderY.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderY,value,2)
                        end)
                        registerToState("position",function(value)
                            sliderY:setValue(math.map(value[2],min,max,sliderY.min,sliderY.max))
                            sliderY.numberBox:setText(tostring(value[2]))
                        end)
                        sliderY:setValue(math.map(state.position[2],min,max,sliderY.min,sliderY.max))
                        updateSlider(sliderY,math.map(state.position[2],min,max,sliderY.min,sliderY.max),2)
                        uihelper.disableCamera(sliderY)

                        local sliderZ = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.66,0,1,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        sliderZ.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderZ,value,3)
                        end)
                        registerToState("position",function(value)
                            sliderZ:setValue(math.map(value[3],min,max,sliderZ.min,sliderZ.max))
                            sliderZ.numberBox:setText(tostring(value[3]))
                        end)
                        sliderZ:setValue(math.map(state.position[3],min,max,sliderZ.min,sliderZ.max))
                        updateSlider(sliderZ,math.map(state.position[3],min,max,sliderZ.min,sliderZ.max),3)
                        uihelper.disableCamera(sliderZ)

                        positionSlider = {
                            setError = function(self)
                                sliderX.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderX.numberBox.Text..'"}]')
                                sliderY.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderY.numberBox.Text..'"}]')
                                sliderZ.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderZ.numberBox.Text..'"}]')
                                return self
                            end
                        }
                    end
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Rotation")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local min, max = -179, 180
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                        local sliderX = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0,0,0.33,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        local function updateSlider(slider,value,axis)
                            local newvalue = value
                            if tonumber(value) then
                                newvalue = math.round(math.map(value,slider.min,slider.max,min,max))
                            end
                            state.rotation[axis] = newvalue
                            slider.numberBox:setText(newvalue)
                        end
                        sliderX.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderX,value,1)
                        end)
                        registerToState("rotation",function(value)
                            sliderX:setValue(math.map(value[1],min,max,sliderX.min,sliderX.max))
                            sliderX.numberBox:setText(tostring(value[1]))
                        end)
                        sliderX:setValue(math.map(state.rotation[1],min,max,sliderX.min,sliderX.max))
                        updateSlider(sliderX,math.map(state.rotation[1],min,max,sliderX.min,sliderX.max),1)
                        uihelper.disableCamera(sliderX)

                        local sliderY = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.33,0,0.66,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        sliderY.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderY,value,2)
                        end)
                        registerToState("rotation",function(value)
                            sliderY:setValue(math.map(value[2],min,max,sliderY.min,sliderY.max))
                            sliderY.numberBox:setText(tostring(value[2]))
                        end)
                        sliderY:setValue(math.map(state.rotation[2],min,max,sliderY.min,sliderY.max))
                        updateSlider(sliderY,math.map(state.rotation[2],min,max,sliderY.min,sliderY.max),2)
                        uihelper.disableCamera(sliderY)

                        local sliderZ = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.66,0,1,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        sliderZ.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderZ,value,3)
                        end)
                        registerToState("rotation",function(value)
                            sliderZ:setValue(math.map(value[3],min,max,sliderZ.min,sliderZ.max))
                            sliderZ.numberBox:setText(tostring(value[3]))
                        end)
                        sliderZ:setValue(math.map(state.rotation[3],min,max,sliderZ.min,sliderZ.max))
                        updateSlider(sliderZ,math.map(state.rotation[3],min,max,sliderZ.min,sliderZ.max),3)
                        uihelper.disableCamera(sliderZ)

                        rotationSlider = {
                            setError = function(self)
                                sliderX.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderX.numberBox.Text..'"}]')
                                sliderY.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderY.numberBox.Text..'"}]')
                                sliderZ.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderZ.numberBox.Text..'"}]')
                                return self
                            end
                        }
                    end
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.shape=="Box" end)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Size")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local min, max = 0, 128
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                        local sliderX = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0,0,0.33,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        local function updateSlider(slider,value,axis)
                            local newvalue = value
                            if tonumber(value) then
                                newvalue = math.round(math.map(value,slider.min,slider.max,min,max))
                            end
                            state.size[axis] = newvalue
                            slider.numberBox:setText(newvalue)
                        end
                        sliderX.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderX,value,1)
                        end)
                        registerToState("size",function(value)
                            sliderX:setValue(math.map(value[1],min,max,sliderX.min,sliderX.max))
                            sliderX.numberBox:setText(tostring(value[1]))
                        end)
                        sliderX:setValue(math.map(state.size[1],min,max,sliderX.min,sliderX.max))
                        updateSlider(sliderX,math.map(state.size[1],min,max,sliderX.min,sliderX.max),1)
                        uihelper.disableCamera(sliderX)

                        local sliderY = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.33,0,0.66,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        sliderY.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderY,value,2)
                        end)
                        registerToState("size",function(value)
                            sliderY:setValue(math.map(value[2],min,max,sliderY.min,sliderY.max))
                            sliderY.numberBox:setText(tostring(value[2]))
                        end)
                        sliderY:setValue(math.map(state.size[2],min,max,sliderY.min,sliderY.max))
                        updateSlider(sliderY,math.map(state.size[2],min,max,sliderY.min,sliderY.max),2)
                        uihelper.disableCamera(sliderY)

                        local sliderZ = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.66,0,1,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        sliderZ.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderZ,value,3)
                        end)
                        registerToState("size",function(value)
                            sliderZ:setValue(math.map(value[3],min,max,sliderZ.min,sliderZ.max))
                            sliderZ.numberBox:setText(tostring(value[3]))
                        end)
                        sliderZ:setValue(math.map(state.size[3],min,max,sliderZ.min,sliderZ.max))
                        updateSlider(sliderZ,math.map(state.size[3],min,max,sliderZ.min,sliderZ.max),3)
                        uihelper.disableCamera(sliderZ)

                        sizeSlider = {
                            setError = function(self)
                                sliderX.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderX.numberBox.Text..'"}]')
                                sliderY.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderY.numberBox.Text..'"}]')
                                sliderZ.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderZ.numberBox.Text..'"}]')
                                return self
                            end
                        }
                    end
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                radiusNumberField = uihelper.NumberField(box,"Radius",nil,radius_min,radius_max,true):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                radiusNumberField.VALUE_CHANGED:register(function(value)
                    state.radius = value
                end)
                registerToState("radius",function(value)
                    radiusNumberField:setValue(value)
                end)
                function configuration.notifyRadius(r)
                    if r == state.radius then
                        radiusNumberField:setName("Radius")
                    else
                        radiusNumberField:setName("Radius\n"..string.format("%.2f", r))
                    end
                end
                uihelper.visibleWhen(box,function()return state.shape=="Sphere" or state.shape=="Disc" end)
                uihelper.disableCamera(radiusNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.shape~="Point" end)
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Spawn")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,spawns,state.spawn):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.spawn = selected
                        end)
                        registerToState("spawn",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
        })
    end,
})

uihelper.vertical({},{
    function(anchor)
        local box = GNUI.newBox(box_motion):setAnchor(anchor:unpack())
            :setDimensions(0,5,0,-5)
        uihelper.vertical({},{
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                    :setText("Motion")
                    :setFontScale(__FONT_HEADING)
                    :setTextAlign(0.5,0.5)
                uihelper.disableCamera(box)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Origin")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,origins,state.origin):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.origin = selected
                        end)
                        registerToState("origin",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Modelpart")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local textfield = TextField.new(box):setAnchor(anchor:unpack())
                        textfield.Label:setFontScale(__FONT_TEXT)
                        textfield.FIELD_CONFIRMED:register(function(text)
                            state.modelpart = text
                        end)
                        registerToState("modelpart",function(value)
                            textfield:setTextField(value)
                        end)
                        modelpartTextField = {
                            setError = function(self)
                                if textfield.Label.TextPart:getTask()["1"] then
                                    textfield.Label.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..textfield.textField..'"}]')
                                end
                                return self
                            end
                        }
                        uihelper.disableCamera(textfield)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Parent")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,parents,state.parent):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.parent = selected
                        end)
                        registerToState("parent",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Velocity")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local min, max = -64, 64
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                        local sliderX = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0,0,0.33,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        local function updateSlider(slider,value,axis)
                            local newvalue = value
                            if tonumber(value) then
                                newvalue = math.round(math.map(value,slider.min,slider.max,min,max))
                            end
                            state.velocity[axis] = newvalue
                            slider.numberBox:setText(newvalue)
                        end
                        sliderX.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderX,value,1)
                        end)
                        registerToState("velocity",function(value)
                            sliderX:setValue(math.map(value[1],min,max,sliderX.min,sliderX.max))
                            sliderX.numberBox:setText(tostring(value[1]))
                        end)
                        sliderX:setValue(math.map(state.velocity[1],min,max,sliderX.min,sliderX.max))
                        updateSlider(sliderX,math.map(state.velocity[1],min,max,sliderX.min,sliderX.max),1)
                        uihelper.disableCamera(sliderX)

                        local sliderY = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.33,0,0.66,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        sliderY.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderY,value,2)
                        end)
                        registerToState("velocity",function(value)
                            sliderY:setValue(math.map(value[2],min,max,sliderY.min,sliderY.max))
                            sliderY.numberBox:setText(tostring(value[2]))
                        end)
                        sliderY:setValue(math.map(state.velocity[2],min,max,sliderY.min,sliderY.max))
                        updateSlider(sliderY,math.map(state.velocity[2],min,max,sliderY.min,sliderY.max),2)
                        uihelper.disableCamera(sliderY)

                        local sliderZ = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.66,0,1,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(1/max)
                            :setFontScale(__FONT_TEXT)
                        sliderZ.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderZ,value,3)
                        end)
                        registerToState("velocity",function(value)
                            sliderZ:setValue(math.map(value[3],min,max,sliderZ.min,sliderZ.max))
                            sliderZ.numberBox:setText(tostring(value[3]))
                        end)
                        sliderZ:setValue(math.map(state.velocity[3],min,max,sliderZ.min,sliderZ.max))
                        updateSlider(sliderZ,math.map(state.velocity[3],min,max,sliderZ.min,sliderZ.max),3)
                        uihelper.disableCamera(sliderZ)

                        velocitySlider = {
                            setError = function(self)
                                sliderX.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderX.numberBox.Text..'"}]')
                                sliderY.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderY.numberBox.Text..'"}]')
                                sliderZ.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderZ.numberBox.Text..'"}]')
                                return self
                            end
                        }
                    end
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Relative to")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,relativetos,state.relativeto):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.relativeto = selected
                        end)
                        registerToState("relativeto",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                gravityNumberField = uihelper.NumberField(box,"Gravity",nil,gravity_min,gravity_max,true):setAnchor(anchor:unpack())
                    :setFontScale(__FONT_TEXT)
                gravityNumberField.VALUE_CHANGED:register(function(value)
                    state.gravity = value
                end)
                registerToState("gravity",function(value)
                    gravityNumberField:setValue(value)
                end)
                uihelper.disableCamera(gravityNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Collision")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,collisions,state.collision):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.collision = selected
                        end)
                        registerToState("collision",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.type=="Confetti"end)
                confettirotationNumberField = uihelper.NumberField(box,"Rotation",nil,confettirotation_min,confettirotation_max,true):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                confettirotationNumberField.VALUE_CHANGED:register(function(value)
                    state.confettirotation = value
                end)
                registerToState("confettirotation",function(value)
                    confettirotationNumberField:setValue(value)
                end)
                uihelper.disableCamera(confettirotationNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.type=="Confetti"end)
                confettirotationOverTimeNumberField = uihelper.NumberField(box,"RotationOverTime",nil,confettirotationOverTime_min,confettirotationOverTime_max,true):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                confettirotationOverTimeNumberField.VALUE_CHANGED:register(function(value)
                    state.confettirotationOverTime = value
                end)
                registerToState("confettirotationOverTime",function(value)
                    confettirotationOverTimeNumberField:setValue(value)
                end)
                uihelper.disableCamera(confettirotationOverTimeNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.type=="Confetti"end)
                accelerationNumberField = uihelper.NumberField(box,"Acceleration",nil,acceleration_min,acceleration_max,true):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                accelerationNumberField.VALUE_CHANGED:register(function(value)
                    state.acceleration = value
                end)
                registerToState("acceleration",function(value)
                    accelerationNumberField:setValue(value)
                end)
                uihelper.disableCamera(accelerationNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.type=="Confetti"end)
                airFrictionNumberField = uihelper.NumberField(box,"Air Friction",nil,airFriction_min,airFriction_max,true):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                airFrictionNumberField.VALUE_CHANGED:register(function(value)
                    state.airFriction = value
                end)
                registerToState("airFriction",function(value)
                    airFrictionNumberField:setValue(value)
                end)
                uihelper.disableCamera(airFrictionNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.type=="Confetti"end)
                groundFrictionNumberField = uihelper.NumberField(box,"Ground Friction",nil,groundFriction_min,groundFriction_max,true):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                groundFrictionNumberField.VALUE_CHANGED:register(function(value)
                    state.groundFriction = value
                end)
                registerToState("groundFriction",function(value)
                    groundFrictionNumberField:setValue(value)
                end)
                uihelper.disableCamera(groundFrictionNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.type=="Confetti"end)
                bouncynessNumberField = uihelper.NumberField(box,"Bouncyness",nil,bouncyness_min,bouncyness_max,true):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                bouncynessNumberField.VALUE_CHANGED:register(function(value)
                    state.bouncyness = value
                end)
                registerToState("bouncyness",function(value)
                    bouncynessNumberField:setValue(value)
                end)
                uihelper.disableCamera(bouncynessNumberField)
            end,
        })
    end,
})

uihelper.vertical({},{
    function(anchor)
        local box = GNUI.newBox(box_particle):setAnchor(anchor:unpack())
            :setDimensions(0,5,0,-5)
        uihelper.vertical({},{
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                    :setText("Particle")
                    :setFontScale(__FONT_HEADING)
                    :setTextAlign(0.5,0.5)
                uihelper.disableCamera(box)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Type")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,types,state.type):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            if state.type ~= selected then
                                particleTextField:setTextField(selected == "Vanilla" and "flame" or "myparticle")
                            end
                            state.type = selected
                        end)
                        registerToState("type",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Particle")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local textfield = TextField.new(box):setAnchor(anchor:unpack())
                            :setTextField(state.particle)
                        textfield.Label:setFontScale(__FONT_TEXT)
                        textfield.FIELD_CONFIRMED:register(function(text)
                            state.particle = text
                        end)
                        registerToState("particle",function(value)
                            textfield:setTextField(value)
                        end)
                        particleTextField = {
                            setTextField = function(self,text)
                                textfield:setTextField(text)
                                return self
                            end,
                            setError = function(self)
                                if textfield.Label.TextPart:getTask()["1"] then
                                    textfield.Label.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..textfield.textField..'"}]')
                                end
                                return self
                            end
                        }
                        uihelper.disableCamera(textfield)
                    end,
                })
            end,
            function(anchor)
                lifetimeNumberField = uihelper.NumberField(box,"Lifetime",nil,lifetime_min,lifetime_max,false):setAnchor(anchor:unpack())
                    :setFontScale(__FONT_TEXT)
                lifetimeNumberField.VALUE_CHANGED:register(function(value)
                    state.lifetime = value
                end)
                registerToState("lifetime",function(value)
                    lifetimeNumberField:setValue(value)
                end)
                uihelper.disableCamera(lifetimeNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                local colorTextBox
                function configuration.notifyColor(c)
                    colorTextBox:setDefaultTextColor(c)
                end
                uihelper.horizontal({1,2},{
                    function(anchor)
                        colorTextBox = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Color")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local min, max = 0, 255
                        local function updateSlider(slider,value,axis)
                            local newvalue = value
                            if tonumber(value) then
                                newvalue = math.round(math.map(value,slider.min,slider.max,min,max))
                            end
                            state.color[axis] = newvalue
                            -- if tonumber(state.color[1]) and tonumber(state.color[2]) and tonumber(state.color[3]) then
                            --     colorTextBox:setDefaultTextColor(vec(state.color[1]/255,state.color[2]/255,state.color[3]/255))
                            -- end
                            slider.numberBox:setText(newvalue)
                        end
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                        local sliderX = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0,0,0.33,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(2/max)
                            :setFontScale(__FONT_TEXT)
                        sliderX.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderX,value,1)
                            if tonumber(state.color[1]) then
                                sliderX.numberBox:setDefaultTextColor(vec(state.color[1]/255,0,0))
                            end
                        end)
                        registerToState("color",function(value)
                            sliderX:setValue(math.map(value[1],min,max,sliderX.min,sliderX.max))
                            sliderX.numberBox:setText(tostring(value[1]))
                        end)
                        sliderX:setValue(math.map(state.color[1],min,max,sliderX.min,sliderX.max))
                        updateSlider(sliderX,math.map(state.color[1],min,max,sliderX.min,sliderX.max),1)
                        uihelper.disableCamera(sliderX)

                        local sliderY = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.33,0,0.66,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(2/max)
                            :setFontScale(__FONT_TEXT)
                        sliderY.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderY,value,2)
                            if tonumber(state.color[2]) then
                                sliderY.numberBox:setDefaultTextColor(vec(0,state.color[2]/255,0))
                            end
                        end)
                        registerToState("color",function(value)
                            sliderY:setValue(math.map(value[2],min,max,sliderY.min,sliderY.max))
                            sliderY.numberBox:setText(tostring(value[2]))
                        end)
                        sliderY:setValue(math.map(state.color[2],min,max,sliderY.min,sliderY.max))
                        updateSlider(sliderY,math.map(state.color[2],min,max,sliderY.min,sliderY.max),2)
                        uihelper.disableCamera(sliderY)

                        local sliderZ = Slider.new(box,{isVertical=false,showNumber=true,actualMin=min,actualMax=max}):setAnchor(0.66,0,1,1)
                            :setMin(0)
                            :setMax(2)
                            :setStep(2/max)
                            :setFontScale(__FONT_TEXT)
                        sliderZ.VALUE_CHANGED:register(function(value)
                            updateSlider(sliderZ,value,3)
                            if tonumber(state.color[3]) then
                                sliderZ.numberBox:setDefaultTextColor(vec(math.map(state.color[3]/255,0,1,0,0.3),math.map(state.color[3]/255,0,1,0,0.3),state.color[3]/255))
                            end
                        end)
                        registerToState("color",function(value)
                            sliderZ:setValue(math.map(value[3],min,max,sliderZ.min,sliderZ.max))
                            sliderZ.numberBox:setText(tostring(value[3]))
                        end)
                        sliderZ:setValue(math.map(state.color[3],min,max,sliderZ.min,sliderZ.max))
                        updateSlider(sliderZ,math.map(state.color[3],min,max,sliderZ.min,sliderZ.max),3)
                        uihelper.disableCamera(sliderZ)

                        colorSlider = {
                            setError = function(self)
                                sliderX.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderX.numberBox.Text..'"}]')
                                sliderY.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderY.numberBox.Text..'"}]')
                                sliderZ.numberBox.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..sliderZ.numberBox.Text..'"}]')
                                return self
                            end
                        }
                    end
                })
            end,
            function(anchor)
                scaleNumberField = uihelper.NumberField(box,"Scale",nil,scale_min,scale_max,true):setAnchor(anchor:unpack())
                    :setFontScale(__FONT_TEXT)
                scaleNumberField.VALUE_CHANGED:register(function(value)
                    state.scale = value
                end)
                registerToState("scale",function(value)
                    scaleNumberField:setValue(value)
                end)
                uihelper.disableCamera(scaleNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.type=="Confetti"end)
                scaleOverTimeNumberField = uihelper.NumberField(box,"ScaleOverTime",nil,scaleOverTime_min,scaleOverTime_max,true):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                scaleOverTimeNumberField.VALUE_CHANGED:register(function(value)
                    state.scaleOverTime = value
                end)
                registerToState("scaleOverTime",function(value)
                    scaleOverTimeNumberField:setValue(value)
                end)
                uihelper.disableCamera(scaleOverTimeNumberField)
            end,
        })
    end,
})

uihelper.vertical({},{
    function(anchor)
        -- Mesh Display
        local hud = models:newPart("HudParticleDisplay"):moveTo(models):setParentType("GUI")
            :setPos(-100,-100)
            :setRot(-35,-40,23)
            :setScale(8)
        uihelper.visibleWhen(hud,function()return state.confettitype=="Mesh" end)
        if state.mesh == "models" then
            -- prevent stack overflow
            state.mesh = "nil"
        end
        local original = load("return ("..state.mesh..")")()
        local displayed
        local function display(part)
            if not part then return end
            if displayed then displayed:remove() end
            displayed = part:copy():moveTo(hud)
        end
        display(original)
        function configuration.notifyMesh(part)
            if original ~= part then
                original = part
                display(original)
            end
        end

        -- Texture Display
        local upperbox = GNUI.newBox(box_confetti):setAnchor(anchor:unpack())
            :setDimensions(5,5,-5,-5)
        uihelper.disableCamera(upperbox)
        uihelper.visibleWhen(upperbox,function()return state.confettitype=="Sprite" end)
        
        local box = GNUI.newBox(box_confetti):setAnchor(anchor:unpack())
        --     :setColor(1,0,0)
        -- Theme.style(box,"Background")

        local dims = textures[state.texture]:getDimensions()
        local image = GNUI.newBox(upperbox)
            :setNineslice(GNUI.newNineslice(textures[state.texture]))
        uihelper.disableCamera(image)

        local selTex = textures["particle_effect_creator.selection"]
        local selDims = vec(math.min(8,dims.x),math.min(8,dims.y))
        local nineslice = GNUI.newNineslice(selTex
            ,0,0,6,6
            ,3,3,3,3
            ,0,0,0,0
        )
        local selection = GNUI.newBox(image)
            :setNineslice(nineslice)
        uihelper.disableCamera(selection)
    
        local hovering = false
        local dragging = false
        local startdragmouse = vec(0,0)
        local startdragselection = vec(0,0)
        local startdragseldims = vec(0,0)
        local position = vec(0,0)
        local inCorner = false
        local width = 0

        state.uv = {position.x,position.y,selDims.x,selDims.y}

        -- selection.MOUSE_ENTERED:register(function()
        --     log("enter")
        -- end)

        -- selection.MOUSE_EXITED:register(function()
        --     log("exit")
        -- end)

        -- selection.MOUSE_MOVED:register(function()
        --     log("move")
        -- end)

        events.MOUSE_PRESS:register(function (button,status,modifier)
            if hovering and status == 1 then
                dragging = true
                startdragmouse = vec(screen.MousePosition.x,screen.MousePosition.y)
                startdragselection = vec(position.x,position.y)
                startdragseldims = vec(selDims.x,selDims.y)

                width = math.min((upperbox.ContainmentRect.z - upperbox.ContainmentRect.x), (upperbox.ContainmentRect.w - upperbox.ContainmentRect.y) / 2)
                local pixel = width/dims.x
                local relMousePos = (screen.MousePosition-selection:toGlobal(0,0))/(selDims*pixel)
                local relMousePosPx = relMousePos*selDims
                local cornerSize = 2
                inCorner = relMousePosPx.x > selDims.x-cornerSize and relMousePosPx.y > selDims.y-cornerSize
            elseif status == 0 then
                dragging = false
            end
        end)

        selection.MOUSE_MOVED:register(function()
            width = math.min((upperbox.ContainmentRect.z - upperbox.ContainmentRect.x), (upperbox.ContainmentRect.w - upperbox.ContainmentRect.y) / 2)
            local pixel = width/dims.x
            local relMousePos = (screen.MousePosition-selection:toGlobal(0,0))/(selDims*pixel)
            local relMousePosPx = relMousePos*selDims
            local cornerSize = 2
            cursor.setCursor((relMousePosPx.x > selDims.x-cornerSize and relMousePosPx.y > selDims.y-cornerSize) and "DragDiagonal" or "DragAll")
            local distance = vec(screen.MousePosition.x,screen.MousePosition.y)-startdragmouse
            if dragging then
                if inCorner then
                    local newCornerPos = startdragseldims*pixel + distance
                    newCornerPos.x = math.round(newCornerPos.x / pixel)
                    newCornerPos.y = math.round(newCornerPos.y / pixel)
                    newCornerPos.x = math.clamp(newCornerPos.x,1,dims.x-startdragselection.x)
                    newCornerPos.y = math.clamp(newCornerPos.y,1,dims.y-startdragselection.y)
                    selDims = newCornerPos
                else
                    position = startdragselection*pixel + distance
                    position.x = math.round(position.x / pixel)
                    position.y = math.round(position.y / pixel)
                    position.x = math.clamp(position.x,0,dims.x-selDims.x)
                    position.y = math.clamp(position.y,0,dims.y-selDims.y)
                end
                selection:setDimensions(position.x*pixel,position.y*pixel,position.x*pixel+selDims.x*pixel,position.y*pixel+selDims.y*pixel)
                state.uv = {position.x,position.y,selDims.x,selDims.y}
            end
        end)

        upperbox.SIZE_CHANGED:register(function ()
            local parentwidth = (upperbox.Parent.ContainmentRect.z - upperbox.Parent.ContainmentRect.x)
            width = math.min((upperbox.ContainmentRect.z - upperbox.ContainmentRect.x), (upperbox.ContainmentRect.w - upperbox.ContainmentRect.y) / 2)
            local pixel = width/dims.x
            image:setDimensions(parentwidth/2-width/2-upperbox.Dimensions.x,0,parentwidth/2-width/2-upperbox.Dimensions.x+width,dims.y*pixel)
            box:setDimensions((upperbox.Dimensions._y_w+vec(0,dims.y*pixel+5,0,0)):unpack())
            selection:setDimensions(position.x*pixel,position.y*pixel,position.x*pixel+selDims.x*pixel,position.y*pixel+selDims.y*pixel)
                :setScaleFactor(pixel/2)
            hud:setPos(-image:toGlobal(image:UVtoXY(0.5,0.5)).xy_:add(0,10,100))
        end)

        selection.MOUSE_PRESSENCE_CHANGED:register(function(hover,press)
            -- log("presence",hover,press)
            hovering = hover
        end)

        registerToState("uv",function(value)
            position = vec(value[1],value[2])
            selDims = vec(value[3],value[4])
            width = math.min((upperbox.ContainmentRect.z - upperbox.ContainmentRect.x), (upperbox.ContainmentRect.w - upperbox.ContainmentRect.y) / 2)
            local pixel = width/dims.x
            selection:setDimensions(position.x*pixel,position.y*pixel,position.x*pixel+selDims.x*pixel,position.y*pixel+selDims.y*pixel)
                :setScaleFactor(pixel/2)
        end)

        uihelper.vertical({1,#textureNames+1,2,2,2,2,2,2,2},{
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                    :setText("Texture")
                    :setFontScale(__FONT_TEXT)
                    :setTextAlign(0.5,0.5)
                uihelper.visibleWhen(box,function()return state.confettitype=="Sprite" end)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.visibleWhen(box,function()return state.confettitype=="Sprite" end)
                local picker = uihelper.Picker(box,textureNames,textureNames[1],"vertical"):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                picker.PRESSED:register(function(selected)
                    state.texture = selected
                    dims = textures[state.texture]:getDimensions()
                    image:setNineslice(GNUI.newNineslice(textures[state.texture]))
                    selDims = vec(math.min(8,dims.x),math.min(8,dims.y))
                    position = vec(0,0)
                    local parentwidth = (upperbox.Parent.ContainmentRect.z - upperbox.Parent.ContainmentRect.x)
                    width = math.min((upperbox.ContainmentRect.z - upperbox.ContainmentRect.x), (upperbox.ContainmentRect.w - upperbox.ContainmentRect.y) / 2)
                    local pixel = width/dims.x
                    image:setDimensions(parentwidth/2-width/2-upperbox.Dimensions.x,0,parentwidth/2-width/2-upperbox.Dimensions.x+width,dims.y*pixel)
                    selection:setDimensions(position.x*pixel,position.y*pixel,position.x*pixel+selDims.x*pixel,position.y*pixel+selDims.y*pixel)
                        :setScaleFactor(pixel/2)
                    state.uv = {position.x,position.y,selDims.x,selDims.y}
                end)
                registerToState("texture",function(value)
                    dims = textures[value]:getDimensions()
                    image:setNineslice(GNUI.newNineslice(textures[value]))
                    local parentwidth = (upperbox.Parent.ContainmentRect.z - upperbox.Parent.ContainmentRect.x)
                    width = math.min((upperbox.ContainmentRect.z - upperbox.ContainmentRect.x), (upperbox.ContainmentRect.w - upperbox.ContainmentRect.y) / 2)
                    local pixel = width/dims.x
                    image:setDimensions(parentwidth/2-width/2-upperbox.Dimensions.x,0,parentwidth/2-width/2-upperbox.Dimensions.x+width,dims.y*pixel)
                end)
                uihelper.disableCamera(picker)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.visibleWhen(box,function()return state.confettitype=="Mesh" end)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Mesh Modelpart")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local textfield = TextField.new(box):setAnchor(anchor:unpack())
                            :setTextField(state.mesh)
                        textfield.Label:setFontScale(__FONT_TEXT)
                        textfield.FIELD_CONFIRMED:register(function(text)
                            state.mesh = text
                        end)
                        registerToState("mesh",function(value)
                            textfield:setTextField(value)
                            display(load("return ("..value..")")())
                        end)
                        meshTextField = {
                            setError = function(self)
                                if textfield.Label.TextPart:getTask()["1"] then
                                    textfield.Label.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..textfield.textField..'"}]')
                                end
                                return self
                            end
                        }
                        uihelper.disableCamera(textfield)
                    end,
                })
            end,
            function(anchor)
                framesNumberField = uihelper.NumberField(box,"Frames",nil,1,8):setAnchor(anchor:unpack())
                    :setFontScale(__FONT_TEXT)
                framesNumberField.VALUE_CHANGED:register(function(value)
                    state.frames = value
                end)
                registerToState("frames",function(value)
                    framesNumberField:setValue(value)
                end)
                uihelper.disableCamera(framesNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                speedNumberField = uihelper.NumberField(box,"Speed",nil,speed_min,speed_max,false):setAnchor(0,0,1,1)
                    :setFontScale(__FONT_TEXT)
                speedNumberField.VALUE_CHANGED:register(function(value)
                    state.speed = value
                end)
                registerToState("speed",function(value)
                    speedNumberField:setValue(value)
                end)
                function configuration.notifySpeed(r)
                    if r == state.speed then
                        speedNumberField:setName("Speed")
                    else
                        speedNumberField:setName("Speed\n"..string.format("%.2f", r))
                    end
                end
                uihelper.visibleWhen(box,function()return state.shape=="Sphere" or state.shape=="Disc" end)
                uihelper.disableCamera(speedNumberField)
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Direction")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,directions,state.direction):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.direction = selected
                        end)
                        registerToState("direction",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Type")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,confettitypes,state.confettitype):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.confettitype = selected
                        end)
                        registerToState("confettitype",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Emissive")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,emissives,state.emissive):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.emissive = selected
                        end)
                        registerToState("emissive",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
            function(anchor)
                local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                uihelper.disableCamera(box)
                uihelper.horizontal({1,2},{
                    function(anchor)
                        local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                            :setText("Billboard")
                            :setFontScale(__FONT_TEXT)
                            :setTextAlign(0.5,0.5)
                        uihelper.disableCamera(box)
                    end,
                    function(anchor)
                        local picker = uihelper.Picker(box,billboards,state.billboard):setAnchor(anchor:unpack())
                            :setFontScale(__FONT_TEXT)
                        picker.PRESSED:register(function(selected)
                            state.billboard = selected
                        end)
                        registerToState("billboard",function(value)
                            picker:setValue(value)
                        end)
                        uihelper.disableCamera(picker)
                    end,
                })
            end,
        })
    end,
})

local knowsEnvStructure = false
function configuration.notifyEnvStructure(env,description)
    if knowsEnvStructure then error "This function is only allowed to be called once!" end
    knowsEnvStructure = true
    local text = {}
    table.insert(text,{text="- You can put lua code in place of any number.\n- Double click on sliders to edit via a textbox.\n- Below are some additional variables you have access to.\n\n"})
    local keys = {}
    for key, _ in pairs(env) do
        table.insert(keys,key)
    end
    table.sort(keys,function(a,b)
        local aa = type(description[a])=="table" and description[a][2] or description[a]
        local bb = type(description[b])=="table" and description[b][2] or description[b]
        return aa < bb
    end)
    for _, key in ipairs(keys) do
        local value = env[key]
        local desc = (description[key] or "No description.")
        local signature = ""
        local lpar = type(value)=="function" and "(" or ""
        local rpar = type(value)=="function" and ")" or ""
        if type(desc)=="table" then
            signature = desc[1]:match(".+%((.+)%)")
            desc = desc[2]
        end
        table.insert(text,{color="yellow",text=key..lpar})
        table.insert(text,{color="white",text=signature})
        table.insert(text,{color="yellow",text=rpar.." "})
        table.insert(text,{color="gray",text=desc})
        table.insert(text,{color="gray",text="\n\n"})
    end
    uihelper.vertical({},{
        function(anchor)
            local box = GNUI.newBox(box_help):setAnchor(anchor:unpack())
                :setDimensions(3,5,-3,-5)
            uihelper.vertical({1,12,1,1},{
                function(anchor)
                    local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                        :setText("Help")
                        :setFontScale(__FONT_HEADING)
                        :setTextAlign(0.5,0.5)
                    uihelper.disableCamera(box)
                end,
                function(anchor)
                    local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                        :setText(text)
                        :setFontScale(__FONT_TEXT)
                        :setTextAlign(0.5,0.5)
                    uihelper.disableCamera(box)
                end,
                function(anchor)
                    local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                    uihelper.disableCamera(box)
                    uihelper.horizontal({1,2},{
                        function(anchor)
                            local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                                :setText("Mouse sensitivity")
                                :setFontScale(__FONT_TEXT)
                                :setTextAlign(0.5,0.5)
                            uihelper.disableCamera(box)
                        end,
                        function(anchor)
                            local slider = Slider.new(box,{isVertical=false,showNumber=true,allowInput=false}):setAnchor(anchor:unpack())
                                :setMin(0.1)
                                :setMax(2)
                                :setValue(io:load("mouseSensitivity") or 1)
                                :setFontScale(__FONT_TEXT)
                            slider.VALUE_CHANGED:register(function(value)
                                cursor.setSensitivity(value)
                                io:save("mouseSensitivity",value)
                            end)
                            uihelper.disableCamera(slider)
                        end,
                    })
                end,
                function(anchor)
                    local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                    uihelper.disableCamera(box)
                    uihelper.horizontal({1,2},{
                        function(anchor)
                            local box = GNUI.newBox(box):setAnchor(anchor:unpack())
                                :setText("Camera sensitivity")
                                :setFontScale(__FONT_TEXT)
                                :setTextAlign(0.5,0.5)
                            uihelper.disableCamera(box)
                        end,
                        function(anchor)
                            local slider = Slider.new(box,{isVertical=false,showNumber=true,allowInput=false}):setAnchor(anchor:unpack())
                                :setMin(0.1)
                                :setMax(2)
                                :setValue(io:load("cameraSensitivity") or 1)
                                :setFontScale(__FONT_TEXT)
                            slider.VALUE_CHANGED:register(function(value)
                                editor.setCameraSensitivity(value)
                                io:save("cameraSensitivity",value)
                            end)
                            uihelper.disableCamera(slider)
                        end,
                    })
                end,
            })
        end,
    })
end

state = io:loadParticle(state.name,true)
pushStateToGui()

function events.tick()
    screen:setVisible(editor.editMode())
end

return configuration