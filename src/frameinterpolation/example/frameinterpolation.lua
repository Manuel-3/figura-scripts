-- Frame Interpolation by manuel_2867

local Atlas = require("./atlas")
local Task = require("./task")

local frameinterpolation = {}

---Takes a vertical texture strip, generates interpolated inbetweens and calls the callback function with the interpolated atlas data
---@param texture Texture A vertical texture animation strip
---@param frameCount number|string How many frames the texture currently has, or "auto" to determine it using the width, or "unknown" if it could be different amounts such as for vanilla resource texture that could have been changed using a resource pack. In the case of putting a number or putting "auto", the UV of your model in blockbench must be set to the first frame of the texture. In the case of "unknown", the UV must be set to the full entire texture.
---@param interpolationCount number How many new frames to add for each of the current frames
---@param callback fun(atlas: Atlas) When finished, calls this function with the resulting Atlas
function frameinterpolation.interpolate(texture, frameCount, interpolationCount, callback)
    local width, height = texture:getDimensions():unpack()
    interpolationCount = interpolationCount + 1
    local frameCountMode = type(frameCount) == "string" and frameCount:lower() or frameCount
    frameCount = (type(frameCountMode) == "string" and (frameCountMode == "auto" or frameCountMode == "unknown")) and height/width or frameCount

    local frameHeight = height/frameCount
    local y = -frameHeight
    Atlas:new(width, frameCountMode == "unknown" and height/frameCount or height, width, frameHeight, frameCount*interpolationCount, function(atlas)
        local progress = Task.ProgressBar(texture:getName(), frameCount*interpolationCount)

        Task(0,frameCount-1,function(frame)
            y = y + frameHeight
            local nextY = (y + frameHeight) % height
            Task(1,interpolationCount,function(i)
                progress()
                atlas:putBlend(frame*interpolationCount+i,texture,0,y,0,nextY,(i-1)/interpolationCount)
            end)
        end,
        function()
            atlas:update()
            callback(atlas)
        end)
    end)
end

local mat3 = matrices.mat3()

---Apply a certain frame to a list of parts
---@param parts ModelPart[] List of model parts to animate
---@param atlas Atlas Atlas to animate
---@param frame number The frame number to apply (starts at 1)
function frameinterpolation.applyFrame(parts, atlas, frame)
    frame = (frame - 1) % atlas.frameCount + 1
    local texture, x, y = atlas:get(frame)
    mat3:reset()
        :translate(x/atlas.width/atlas.horizontalScale,y/atlas.height/atlas.verticalScale)
        :scale(atlas.horizontalScale,atlas.verticalScale)
    for _, part in ipairs(parts) do
        part:setPrimaryTexture("CUSTOM", texture)
        part:setUVMatrix(mat3)
    end
end

---Animation helper for the resulting interpolated frames
---@param parts ModelPart[] List of model parts to animate
---@param atlas Atlas Atlas to animate
---@param ticksPerFrame number? Defaults to 1 if omitted. An integer. The amount of ticks per frame, essentially the speed (1 is new frame each tick, 2 means new frame only every other tick, 3 is new frame every 3 ticks etc...)
---@return function tick Returns the registered tick event for this animation, that way you could unregister it later to stop the animation.
function frameinterpolation.animate(parts, atlas, ticksPerFrame)
    ticksPerFrame = ticksPerFrame or 1
    local f = 1
    local n = 0
    local function tick()
        n = n + 1
        if n % ticksPerFrame ~= 0 then return end
        f = f + 1
        frameinterpolation.applyFrame(parts, atlas, f)
    end
    events.tick:register(tick)
    return tick
end

return frameinterpolation