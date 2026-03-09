local uuid_v4 = require(listFiles("./uuid")[1]);
	

---
---
---@class (exact) SignalConstructor
---@field __prototype SignalPrototype
---@field _signals Signal[]
local Signal = {};

---@class SignalConnection
---@field disconnect fun(self: SignalConnection): nil

---@generic T, K..
---@class SignalPrototype<T>
---@field fire fun(self: SignalPrototype<T>, ...: K..)
---@field connect fun(self: SignalPrototype<T>, callback: fun(...: K..)): SignalConnection
---@field once fun(self: SignalPrototype<T>, callback: fun(...: K..)): SignalConnection
---@field _registeredConnections T[]
---@field _guid string
Signal.__prototype = {
	batches_to_fire = {};
}
Signal._signals = {};


---@overload fun(self: SignalPrototype<T>, signalCallback: T)
function Signal.__prototype:connect(...)
	local signalCallback, signalInternalOps = ...;
	assert(Signal._signals[self], "i do not exist (i was destroyed)")
	-- ok well because of fuck my life, i could just wrap
	-- turn the signalcallback into a metatable?
	local wrapped_cb = setmetatable({}, {
		__index = function()
			error("attempt to index a SignalCallback value", 2);
		end,
		__call = function(_, ...)
			return signalCallback(...)
		end
	})

	for k, v in pairs(default(signalInternalOps, {})) do
		getmetatable(wrapped_cb)["_" .. k] = v;
	end

	table.insert(self._registeredConnections, wrapped_cb)

	local disconnector = function(_)
		assert(self, "why do you act this way (call me as a method)");
		local idx = table.findIndex(self._registeredConnections, function(v)
			return v == wrapped_cb;
		end);

		table.remove(self._registeredConnections, idx)
		getmetatable(wrapped_cb).disconnecting = true;
		self._isListening = #self._registeredConnections > 0
	end

	self._isListening = #self._registeredConnections > 0
	return {
		disconnect = disconnector;
	}
end

function Signal.__prototype:once(signalCallback)
	assert(Signal._signals[self], "i do not exist (i was destroyed)")
	local connector; connector = self:connect(function(...)
		if (connector) then
			connector:disconnect();
			connector = nil;
			signalCallback(...);
		end
	end, 
	---@diagnostic disable-next-line: redundant-parameter -- I already know
	{
		once = true
	})

	return connector;
end

function Signal.__prototype:destroy()
	assert(Signal._signals[self], "i do not exist (i was destroyed)")
	
	Signal._signals[self] = nil;
	self._isListening = false;
	events.TICK:remove(self._guid)
	self._registeredConnections = {};
end

function Signal.__prototype:fire(...)
	local batches_to_fire = {
		params = {...},
		batches = {};
		
	};
	
	for k, v in pairs(self._registeredConnections) do 
		batches_to_fire.batches[k] = v;
	end

	table.insert(self.batches_to_fire, batches_to_fire);
end


function Signal.new()
	---@class Signal : SignalPrototype
	local self = setmetatable({
		_registeredConnections = {},
		_guid = uuid_v4.getUUID(), -- lol code smell
		_isListening = false, --only listen when there is more than one connection
	}, {
		__index = Signal.__prototype;
	})
	
	events.TICK:register(function()
		if not self._isListening then
			return;
		end

		local currentBatch = self.batches_to_fire[1];
		if (currentBatch) then
			local firstEntry = default(currentBatch.batches, {})[1];
			if (not firstEntry) then
				table.remove(self.batches_to_fire, 1)
			else
				firstEntry(table.unpack(currentBatch.params))
				table.remove(currentBatch.batches, 1)
			end
		end
	end, self._guid)
	
	Signal._signals[self] = self;
	return self;
end



return Signal;
