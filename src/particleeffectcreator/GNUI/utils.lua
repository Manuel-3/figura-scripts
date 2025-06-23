---@diagnostic disable: assign-type-mismatch
---@class GNUI.UtilsAPI
local utils = {}

---Returns the same vector but the `X` `Y` are the **min** and `Z` `W` are the **max**.  
---vec4(1,2,0,-1) --> vec4(0,-1,1,2)
---@param vec4 Vector4
---@return Vector4
function utils.vec4FixNegativeSize(vec4)
  return vec(
    math.min(vec4.x,vec4.z),
    math.min(vec4.y,vec4.w),
    math.max(vec4.x,vec4.z),
    math.max(vec4.y,vec4.w)
  )
end

---Sets the position`(x,y)` while translating the other position`(x,z)`
---@param vec4 Vector4
---@param x number
---@param y number
---@return Vector4
function utils.vec4SetPos(vec4,x,y)
  local lpos = vec4.xy
  vec4.x,vec4.y = x,y
  vec4.z,vec4.w = x-lpos.x,y-lpos.y
  return vec4
end

---Sets the other position`(x,z)` while translating the position`(x,y)`
---@param vec4 Vector4
---@param z number
---@param w number
---@return Vector4
function utils.vec4SetOtherPos(vec4,z,w)
  local lpos = vec4.zw
  vec4.z,vec4.w = z,w
  vec4.x,vec4.y = z-lpos.x,w-lpos.y
  return vec4
end

---Gets the size of a vec4
---@param vec4 Vector4
---@return Vector2
function utils.vec4Size(vec4)
  return (vec4.zw - vec4.xy) ---@type Vector2
end

---@param posx number|Vector2
---@param y number?
---@return Vector2
function utils.vec2(posx,y)
  local typa, typb = type(posx), type(y)
  
  if typa == "Vector2" then
    return posx:copy()
  elseif typa == "number" and typb == "number" then
    return vec(posx,y)
  else
    error("Invalid Vector2 parameter, expected Vector2 or (number, number), instead got ("..typa..", "..typb..")")
  end
end

---@param posx number|Vector3
---@param y number?
---@param z number?
---@return Vector3
function utils.vec3(posx,y,z)
  local typa, typb, typc = type(posx), type(y), type(z)
  
  if typa == "Vector3" then
    return posx:copy()
  elseif typa == "number" and typb == "number" and typc == "number" then
    return vec(posx,y,z)
  else
    error("Invalid Vector3 parameter, expected Vector3 or (number, number, number), instead got ("..typa..", "..typb..", "..typc..")")
  end
end

---@param posx number|Vector4
---@param y number?
---@param z number?
---@param w number?
---@return Vector4
function utils.vec4(posx,y,z,w)
  local typa, typb, typc, typd = type(posx), type(y), type(z), type(w)
  
  if typa == "Vector4" then
    return posx:copy()
  elseif typa == "number" and typb == "number" and typc == "number"  and typd == "number" then
    return vectors.vec4(posx,y,z,w)
  else
    error("Invalid Vector4 parameter, expected Vector4 or (number, number, number, number), instead got ("..typa..", "..typb..", "..typc.. ", "..typd..")")
  end
end


function utils.deepCopy(original)
	local copy = {}
  local meta = getmetatable(original)
  if meta then
    setmetatable(copy,meta)
  end
	for key, value in pairs(original) do
		if type(value) == "table" then
			value = utils.deepCopy(value)
		end
    
    if type(value):find("Vector") then
			value = value:copy()
		end
		copy[key] = value
	end
	return copy
end

return utils