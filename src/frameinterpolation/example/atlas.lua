-- Atlas by manuel_2867

local Task = require("./task")

---@class Atlas
---@field frameCount number
---@field frameWidth number
---@field width number
---@field frameHeight number
---@field height number
---@field horizontalScale number
---@field verticalScale number
---@field locations table
local Atlas = {}
Atlas.__index = Atlas

local intUUIDToString = client.intUUIDToString
local generateUUID = client.generateUUID
local lerp = math.lerp
local maxSize = avatar:getMaxTextureSize()

local function indexToXyz(index, width, height)
    local x = index % width
    local y = math.floor(index / width) % height
    local z = math.floor(index / (width * height))
    return x, y, z
end

function Atlas:new(originalTexWidth, originalTexHeight, frameWidth, frameHeight, frameCount, callback)

    local locations = {}
    local parts = {}

    local columns = math.floor(maxSize / frameWidth)
    local rows = math.floor(maxSize / frameHeight)

    Task(0,frameCount-1,function(i)
        local x,y,z = indexToXyz(i, columns, rows)
        if not parts[z] then
            parts[z] = textures:newTexture(intUUIDToString(generateUUID()), columns*frameWidth, rows*frameHeight)

            -- models:newSprite(intUUIDToString(generateUUID()))
            --     :setTexture(parts[z],columns*frameWidth,rows*frameHeight)
            --     :setRegion(columns*frameWidth,rows*frameHeight)
            --     :setSize(columns*frameWidth,rows*frameHeight)
            --     :setPos(columns*frameWidth/2,30,i)
        end
        table.insert(locations, {texture=parts[z],x=x*frameWidth,y=y*frameHeight})
    end,
    function()
        callback(setmetatable({
            horizontalScale = originalTexWidth/maxSize,
            width = maxSize,
            verticalScale = originalTexHeight/maxSize,
            height = maxSize,
            frameWidth = frameWidth,
            frameHeight = frameHeight,
            frameCount = frameCount,
            locations = locations
        }, self))
    end)
end

function Atlas:get(frameNum)
    local loc = self.locations[frameNum]
    return loc.texture, loc.x, loc.y
end

function Atlas:put(frameNum,texture,x,y)
    local loc = self.locations[frameNum]
    local locX = loc.x
    local locY = loc.y
    local getPixel = texture.getPixel
    Task(0,self.frameHeight-1,function(j)
        loc.texture:applyFunc(locX,locY+j,self.frameWidth,1,function(_, x1, y1)
            return getPixel(texture,x+x1-locX,y+y1-locY)
        end)
    end)
end

function Atlas:putBlend(frameNum,texture,x1,y1,x2,y2,fraction)
    local loc = self.locations[frameNum]
    local locX = loc.x
    local locY = loc.y
    local getPixel = texture.getPixel
    Task(0,self.frameHeight-1,function(j)
        loc.texture:applyFunc(locX,locY+j,self.frameWidth,1,function(_, x, y)
            x = x-locX
            y = y-locY
            return lerp(getPixel(texture,x1+x,y1+y),getPixel(texture,x2+x,y2+y),fraction)
        end)
    end)
end

function Atlas:update()
    for _, location in ipairs(self.locations) do
        location.texture:update()
    end
end

return Atlas