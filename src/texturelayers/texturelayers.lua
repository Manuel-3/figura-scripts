-- Texture Layers By manuel_2867

local TextureLayers = {}

local function blend(c1, c2)
    local A1, A2 = c1.a, c2.a
    local Ar = A1 + A2 * (1 - A1)
    local blendChannel = function(ch1, ch2)
        return (ch1 * A1 + ch2 * A2 * (1 - A1)) / Ar
    end
    return vec(
        blendChannel(c1.r, c2.r),
        blendChannel(c1.g, c2.g),
        blendChannel(c1.b, c2.b),
        Ar
    )
end

local layerTextures = {}

local function refreshTextures()
    for _,texture in ipairs(textures:getTextures()) do
        local baseName, layerNum = string.match(texture:getName(), "(.+)[Ll]ayer(%d+)")
        if baseName and layerNum then
            if not layerTextures[baseName] then
                local baseTexture = textures[baseName]
                if not baseTexture then
                    logJson(toJson({{color="white",text="["},{color="yellow",text="Warning"},{color="white",text="] "},{color="gray",text="Base texture "..baseName.." not found for layer texture "..texture:getName().."!\nHere is your texture list, make sure to spell everyhing correctly:\n"}}))
                    logTable(textures:getTextures())
                else
                    layerTextures[baseName] = {
                        layers={}
                    }
                end
            end
            if not layerTextures[baseName].layers[layerNum] then
                layerTextures[baseName].layers[layerNum] = {}
            end
            layerTextures[baseName].layers[layerNum].texture = texture
            layerTextures[baseName].layers[layerNum].visible = true
            layerTextures[baseName].layers[layerNum].color = vec(1,1,1,1)
        end
    end
end

refreshTextures()

local additionalTextures = {} -- fix for a figura bug

local textureAPI__index = figuraMetatables.TextureAPI.__index
function figuraMetatables.TextureAPI.__index(self, index)
    if index == "copy" or index == "read" or index == "newTexture" or index == "fromVanilla" then
        return function(...)
            local ret = textureAPI__index(self, index)(...)
            table.insert(additionalTextures,ret)
            refreshTextures()
            return ret
        end
    elseif index == "getTextures" then -- fix for a figura bug
        return function(...)
            local ret = textureAPI__index(self, index)(...)
            for _,a in ipairs(additionalTextures) do
                local add = true
                for _,t in ipairs(ret) do
                    add = add or a==t
                end
                if add then
                    table.insert(ret,a)
                end
            end
            return ret
        end
    end
    return textureAPI__index(self, index)
end

--- Set visibility of a layer. Must use update() afterwards to apply changes.
---@param name string Full texture name
---@param visibility boolean
function TextureLayers:setVisible(name, visibility)
    local baseName, layerNum = string.match(name, "(.+)[Ll]ayer(%d+)")
    if baseName and layerNum then
        layerTextures[baseName].layers[layerNum].visible = visibility
    end
end

--- Get the visibility of a layer.
---@param name string Full texture name
---@return boolean
function TextureLayers:getVisible(name)
    local baseName, layerNum = string.match(name, "(.+)[Ll]ayer(%d+)")
    if baseName and layerNum then
        return layerTextures[baseName].layers[layerNum].visible
    else
        error('Malformed layer name "'..name..'"')
    end
end

--- Set color overlay of a layer. Uses multiplicative blending, same as the ModelPart:setColor() function.
---@param name string Full texture name
---@param color Vector3|Vector4
function TextureLayers:setColor(name, color)
    local baseName, layerNum = string.match(name, "(.+)[Ll]ayer(%d+)")
    if baseName and layerNum then
        layerTextures[baseName].layers[layerNum].color = vec(color.r, color.g, color.b, color.a or 1)
    end
end

--- Draw texture layers onto the base texture.
---@param name string Full texture name
function TextureLayers:update(name)
    local baseName, _ = string.match(name, "(.+)[Ll]ayer(%d+)")
    if not baseName then
        baseName = name
    end
    local keys = {}
    for key in pairs(layerTextures[baseName].layers) do
        table.insert(keys, key)
    end
    table.sort(keys)
    local baseTexture = textures[baseName]
    local dims = baseTexture:getDimensions()
    baseTexture:restore()
    for _, key in ipairs(keys) do
        if layerTextures[baseName].layers[key].visible then
            local layer = layerTextures[baseName].layers[key].texture
            local colMul = layerTextures[baseName].layers[key].color
            baseTexture:applyFunc(0,0,dims.x,dims.y,function(col,x,y)
                return blend(layer:getPixel(x,y)*colMul,col)
            end)
        end
    end
    baseTexture:update()
end

--- Draw texture layers onto all base textures.
function TextureLayers:updateAll()
    for name in pairs(layerTextures) do
        self:update(name)
    end
end

function events.ENTITY_INIT()
    TextureLayers:updateAll()
end

return TextureLayers
