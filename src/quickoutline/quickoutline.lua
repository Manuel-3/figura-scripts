---- Quick Outline by manuel_2867 ----
modName = "manuel_.quickoutline"

local texture = textures:newTexture("white_pixel",1,1)
texture:setPixel(0,0,vec(1,1,1))
texture:update()

local function minVec(x,y)
    return vec(math.min(x.x,y.x),math.min(x.y,y.y),math.min(x.z,y.z))
end

local function maxVec(x,y)
    return vec(math.max(x.x,y.x),math.max(x.y,y.y),math.max(x.z,y.z))
end

--- Creates an outline model part with a specified thickness and color
---@param cube ModelPart Part around which to create an outline
---@param thickness number|nil Thickness of the outline
---@param color Vector3|nil Outline color
---@param emissive boolean If the outline should glow
---@return ModelPart[] #List of outline model parts
local function createOutline(cube, thickness, color, emissive)
    local outlines = {}
    if cube:getType() == "GROUP" then
        for _, child in pairs(cube:getChildren()) do
            for _, outline in ipairs(createOutline(child, thickness, color, emissive)) do
                table.insert(outlines, outline)
            end
        end
    else
        if not thickness then thickness = 0.1 end
        if not color then color = vec(0,0,0) end
        local outline = cube:copy(cube:getName().."_outline")
        cube:getParent():addChild(outline)
        outline:setPrimaryTexture("CUSTOM",texture)
        if emissive then outline:setSecondaryTexture("CUSTOM", texture) end
        outline:setColor(color)
        outline:setPrimaryRenderType("CUTOUT_CULL")
        local min = vec(math.huge,math.huge,math.huge)
        local max = vec(-math.huge,-math.huge,-math.huge)
        local newCenter = vec(0,0,0)
        local rotMat = matrices.rotation3(outline:getRot())
        local pivot = outline:getPivot()
        local invRotMat = rotMat:transposed()
        local n = 0
        for _, vertices in pairs(outline:getAllVertices()) do
            for _, vertex in ipairs(vertices) do
                n = n + 1
                local vPos = vertex:getPos()
                local transformedPos = (((vPos - pivot) * rotMat) + pivot)
                newCenter = newCenter + transformedPos
                vertex:setNormal(0,1,0)
                min = minVec(min, vPos)
                max = maxVec(max, vPos)
            end
        end
        newCenter = newCenter / n
        if outline:getType() ~= "MESH" then
            outline:setPivot(newCenter)
            for _, vertices in pairs(outline:getAllVertices()) do
                for _, vertex in ipairs(vertices) do
                    -- credit to soomuchlag for the pivot transformation
                    local transformedPos = (((vertex:getPos() - pivot) * rotMat) + pivot)
                    vertex:setPos((transformedPos - newCenter) * invRotMat + newCenter)
                end
            end
        end
        local size = max-min
        local ref = math.max(size.x,size.y,size.z)
        local scaling = vec(ref,ref,ref) / size
        outline:setScale(-1-thickness*scaling)
        if outline:getType() == "MESH" then
            outline:setScale(outline:getScale()*-1)
            for _, vertices in pairs(outline:getAllVertices()) do
                local m = 1
                while true do
                    if not pcall(function()
                        local v1 = vertices[m]
                        local v2 = vertices[m+1]
                        local v3 = vertices[m+2]
                        local v4 = vertices[m+3]
                        local p1 = v1:getPos()
                        local p2 = v2:getPos()
                        local p3 = v3:getPos()
                        local p4 = v4:getPos()                
                        v1:setPos(p4)
                        v2:setPos(p3)
                        v3:setPos(p2)
                        v4:setPos(p1)
                        m = m + 4
                    end) then break end
                end
            end
        end
        table.insert(outlines, outline)
    end
    return outlines
end

return {createOutline = createOutline}
