-- MEMBRANE by manuel_2867
local Membrane = {}
--- Define a cube as a membrane attached to the 4 groups in the positions table.
---@param membrane ModelPart
---@param positions ModelPart[]
function Membrane:define(membrane,positions)
    assert(membrane, "The cube you provided doesn't exist.")
    assert(membrane:getType()~="GROUP","Can not use a group as a membrane.")
    for i=1,4 do
        assert(positions[i],"The group at position "..i.." doesn't exist.")
    end
    membrane:setPrimaryRenderType("TRANSLUCENT_CULL")
    local vs = {}
    for _, t in pairs(membrane:getAllVertices()) do
        for _, v in ipairs(t) do
            vs[#vs+1] = v
        end
    end
    function events.POST_RENDER()
        if not membrane:getVisible() then return end
        for i, p in ipairs(positions) do
            local n = membrane:partToWorldMatrix():invert():apply(p:partToWorldMatrix():apply())
            vs[i]:setPos(n)
            vs[#vs+1-i]:setPos(n)
        end
    end
end
return Membrane