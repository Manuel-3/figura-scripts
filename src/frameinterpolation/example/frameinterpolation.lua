local frameinterpolation = {}
local scale = 16

---@param texture Texture
---@param direction string
---@param originalFrames number
function frameinterpolation.generate(texture, direction, originalFrames)
    local dims = texture:getDimensions()
    local new = textures:newTexture(texture:getName().."interpolated", dims.x, dims.y*scale)
    local frameSize = (dims.y/originalFrames)
    new:applyFunc(0,0,dims.x,dims.y*scale, function(color, x, y)
        local px1 = texture:getPixel(x,y%frameSize+frameSize*math.floor(y/(scale*frameSize)))
        local y = (y+scale*frameSize)%(dims.y*scale)
        local px2 = texture:getPixel(x,y%frameSize+frameSize*math.floor(y/(scale*frameSize)))
        return math.lerp(px1,px2,(math.floor(y/frameSize)%scale)/scale)
    end)
    return new
end

for y=0,64*3,16 do
    log(((math.floor(y/16)+0)%3)/3)
end

return frameinterpolation