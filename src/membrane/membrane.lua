-- MEMBRANE by manuel_2867
local Membrane = {}
--- Define a cube or plane mesh as a membrane attached to the 4 groups in the positions table.
---@param membrane ModelPart
---@param positions ModelPart[]
function Membrane:define(membrane,positions)
    assert(membrane, "The cube you provided doesn't exist.")
    assert(membrane:getType()~="GROUP","Can not use a group as a membrane.")
    membrane:moveTo(models)
    for i=1,4 do
        assert(positions[i],"The group at position "..i.." doesn't exist.")
    end
    membrane:setPrimaryRenderType(membrane:getType() == "MESH" and "TRANSLUCENT" or "TRANSLUCENT_CULL")
    local vs = {}
    for _, t in pairs(membrane:getAllVertices()) do
        for _, v in ipairs(t) do
            vs[#vs+1] = v
        end
    end
    membrane:setPostRender(function()
        local worldToPartMat = membrane:partToWorldMatrix():invert()
        local p1 = positions[1]:partToWorldMatrix():apply()
        local p3 = positions[3]:partToWorldMatrix():apply()
        local n1 = (positions[2]:partToWorldMatrix():apply()-p1):cross(p3-p1)
        local n2 = (p3-p1):cross(positions[4]:partToWorldMatrix():apply()-p1)
        local worldNormal = (n1+n2)/2
        local normal = (worldToPartMat * worldNormal.xyz_).xyz:normalize()
        for i, p in ipairs(positions) do
            local pos = worldToPartMat:apply(p:partToWorldMatrix():apply())
            vs[i]:setPos(pos)
            vs[i]:setNormal(normal)
            if #vs > 4 then
                vs[#vs+1-i]:setPos(pos)
                vs[#vs+1-i]:setNormal(normal*-1)
            end
        end
    end)
end
return Membrane