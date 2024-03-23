---- Quick Outline by manuel_2867 ----
modName = "manuel_.quickoutline"

local texture = textures:newTexture("white_pixel",1,1)
texture:setPixel(0,0,vec(1,1,1))
texture:update()

local function centerPivot(cube)
    local center = vec(0,0,0)
    local n = 0
    for _, vertices in pairs(cube:getAllVertices()) do
        for _, vertex in ipairs(vertices) do
            n = n + 1
            center = center + vertex:getPos()
        end
    end
    center = center / vec(n,n,n)
    return center
end

--- Creates an outline model part with a specified thickness and color
---@param cube ModelPart Part around which to create an outline
---@param thickness number|nil Thickness of the outline
---@param color Vector3|nil Outline color
---@param emissive boolean If the outline should glow
---@return ModelPart #The outline modelpart
local function createOutline(cube, thickness, color, emissive)
    assert(cube:getType() ~= "GROUP", "Blockbench Groups are not supported for outlines! Use a Cube or Mesh instead!")
    if not thickness then thickness = 0.1 end
    if not color then color = vec(0,0,0) end
    local outline = cube:copy(cube:getName().."_outline")
    cube:getParent():addChild(outline)
    outline:setPrimaryTexture("CUSTOM",texture)
    if emissive then outline:setSecondaryTexture("CUSTOM", texture) end
    outline:setColor(color)
    outline:setPrimaryRenderType("CUTOUT_CULL")
    outline:setScale(-1-thickness)
    outline:setPivot(centerPivot(outline))
    return outline
end

return {createOutline = createOutline}