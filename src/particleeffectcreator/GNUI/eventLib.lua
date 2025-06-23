
---@class EventLibAPI
local EventLibAPI = {}
EventLibAPI.__index = EventLibAPI

function EventLibAPI.new()
	return setmetatable({}, EventLibAPI)
end

EventLibAPI.newEvent = EventLibAPI.new

function EventLibAPI:register(func, name)
	self[name or func] = func
end

function EventLibAPI:clear()
	for key in pairs(self) do self[key] = nil end
end

function EventLibAPI:remove(name)
	self[name] = nil
end

function EventLibAPI:getRegisteredCount() return #self end

function EventLibAPI:__len() return #self end

function EventLibAPI:__call(...)
	local flush = {}
	for _, func in pairs(self) do
		flush[#flush+1] = {func(...)}
	end
	return flush
end

---@type fun(self: EventLibAPI, ...: any): any[]
EventLibAPI.invoke = EventLibAPI.__call

function EventLibAPI.__index(t, i)
	return rawget(t,i)or rawget(t,i:upper()) or EventLibAPI[i]
end

function EventLibAPI.__newindex(t, i, v)
	rawset(t,type(i) == "string" and t[i:upper()] or i,v)
end

return EventLibAPI