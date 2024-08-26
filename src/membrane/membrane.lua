-- MEMBRANE by manuel_2867
local Membrane = {}
---@param membrane ModelPart
---@param positions ModelPart[]
function Membrane:define(membrane,positions)
    assert(membrane:getType()~="GROUP","Can not use a group as a membrane.")
    membrane:setPrimaryRenderType("TRANSLUCENT_CULL")
    local vs = {}
    for _, t in pairs(membrane:getAllVertices()) do
        for _, v in ipairs(t) do
            vs[#vs+1] = v
        end
    end
    function events.POST_RENDER()
        for i, p in ipairs(positions) do
            local n = membrane:partToWorldMatrix():invert():apply(p:partToWorldMatrix():apply())
            vs[i]:setPos(n)
            vs[#vs+1-i]:setPos(n)
        end
    end
end
return Membrane