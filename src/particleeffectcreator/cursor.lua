local GNUI = require "GNUI.main"
local screen = GNUI.getScreenCanvas()

local activeCursor = "Normal"
local cursorUnlocked = false
local mouseposition = client:getWindowSize()/2
local sensitivity = 1

local figuraMetatablesHostAPI__indexisCursorUnlocked = figuraMetatables.HostAPI.__index.isCursorUnlocked
figuraMetatables.HostAPI.__index.isCursorUnlocked = function(self)
    return figuraMetatablesHostAPI__indexisCursorUnlocked(host) or cursorUnlocked
end

local function screenCheck()
    return figuraMetatablesHostAPI__indexisCursorUnlocked(host) and not host:getScreen() or host:isChatOpen()
end

local figuraMetatablesClientAPI__indexgetMousePos = figuraMetatables.ClientAPI.__index.getMousePos
figuraMetatables.ClientAPI.__index.getMousePos = function(self)
    return screenCheck() and figuraMetatablesClientAPI__indexgetMousePos(client) or mouseposition
end

events.MOUSE_MOVE:register(function (x,y)
    mouseposition = mouseposition + vec(x,y) * sensitivity
    local normalized = mouseposition/client:getWindowSize()
    mouseposition.x = math.clamp(normalized.x,0,1)
    mouseposition.y = math.clamp(normalized.y,0,1)
    mouseposition = mouseposition*client:getWindowSize()
end)

local texCursors = textures["particle_effect_creator.cursors"]
local size = vec(10,10)

local dragLeftRightCursor = GNUI.newBox(screen)
    :setNineslice(GNUI.newNineslice(texCursors,
        0,0,15,15
    ))
    :setDimensions(0,0,size.x,size.y)
    :setZMul(999)
    :setVisible(false)
local dragUpDownCursor = GNUI.newBox(screen)
    :setNineslice(GNUI.newNineslice(texCursors,
        32,0,47,15
    ))
    :setDimensions(0,0,size.x,size.y)
    :setZMul(999)
    :setVisible(false)
local dragDiagonalCursor = GNUI.newBox(screen)
    :setNineslice(GNUI.newNineslice(texCursors,
        16,0,31,15
    ))
    :setDimensions(0,0,size.x,size.y)
    :setZMul(999)
    :setVisible(false)
local dragAllCursor = GNUI.newBox(screen)
    :setNineslice(GNUI.newNineslice(texCursors,
        0,16,15,31
    ))
    :setDimensions(0,0,size.x,size.y)
    :setZMul(999)
    :setVisible(false)
local normalCursor = GNUI.newBox(screen)
    :setNineslice(GNUI.newNineslice(texCursors,
        16,16,31,31
    ))
    :setDimensions(0,0,size.x,size.y)
    :setZMul(999)
    :setVisible(false)
local pointerCursor = GNUI.newBox(screen)
    :setNineslice(GNUI.newNineslice(texCursors,
        32,16,47,31
    ))
    :setDimensions(0,0,size.x,size.y)
    :setZMul(999)
    :setVisible(false)
local textCursor = GNUI.newBox(screen)
    :setNineslice(GNUI.newNineslice(texCursors,
        48,0,63,15
    ))
    :setDimensions(0,0,size.x,size.y)
    :setZMul(999)
    :setVisible(false)

events.ENTITY_INIT:register(function ()
    events.MOUSE_MOVE:register(function ()
        dragLeftRightCursor:setVisible(activeCursor == "DragLeftRight")
        dragUpDownCursor:setVisible(activeCursor == "DragUpDown")
        dragDiagonalCursor:setVisible(activeCursor == "DragDiagonal")
        dragAllCursor:setVisible(activeCursor == "DragAll")
        normalCursor:setVisible(activeCursor == "Normal")
        pointerCursor:setVisible(activeCursor == "Pointer")
        textCursor:setVisible(activeCursor == "Text")
        
        local centerpos = screen.MousePosition-size/2
        dragLeftRightCursor:setPos(centerpos)
        dragUpDownCursor:setPos(centerpos)
        dragDiagonalCursor:setPos(centerpos)
        dragAllCursor:setPos(centerpos)
        normalCursor:setPos(screen.MousePosition)
        pointerCursor:setPos(screen.MousePosition-vec(size.x*4/16,0))
        textCursor:setPos(centerpos)
    
        activeCursor = "Normal"
    end)
end)

local lib = {}

---@param name "Normal"|"Pointer"|"Text"|"DragLeftRight"|"DragUpDown"|"DragDiagonal"|"DragAll"
function lib.setCursor(name)
    activeCursor = name
end

function lib.setSensitivity(value)
    sensitivity = value
end

function lib:setUnlockCursor(bool)
    cursorUnlocked = bool
end

return lib