---- Sleepable by manuel_2867 ----

---@class Sleepable
local s = {}
local tmrs = {}
local time = 0
local function rl(tks,nx)
  table.insert(tmrs,{t=time+tks,n=nx})
end
function events.TICK()
  time = time + 1
  for k,tmr in pairs(tmrs) do
    if time >= tmr.t then
      tmr.n()
      tmrs[k] = nil
    end
  end
end
---Create a new Repeating Sleepable
---Runs the queued functions in order forever, unles stop() is called
---@return Repeating
s.repeating = function()
  ---@class Repeating
  ---@field private tsks any
  ---@field private ptr any
  ---@field private stp any
  ---@field store table An empty table that you can use to store things between sleepable functions. You can also technically just add keys into self directly, but to ensure compatibility with future updates you shouldnt rely on those keys being available in the future.
  local o = {}
  o.tsks = {}
  o.store = {}
  o.ptr = 0
  o.stp = false
  o.sleepAmount = 1
  ---@param func fun(self: Repeating) Function to run after the previous one. This self is passed in, if you want to modify it, for example you can call this:stop()
  ---@param ... any Arguments to pass into the func instead of self, allows calling Figura functions directly
  ---@return self
  function o:run(func, ...)
    local varargs = {...}
    table.insert(self.tsks, function()
      if self.stp then return end
      if #varargs > 0 then
        func(table.unpack(varargs))
      else
        func(self)
      end
      o.ptr = (o.ptr+1) % #o.tsks
      o.tsks[o.ptr+1]()
    end)
    return self
  end
  ---@param ticks number|nil Amount of ticks to sleep before running the next function. If nil, uses the self.sleepAmount.
  ---@return self
  function o:sleep(ticks)
    table.insert(self.tsks, function()
      rl(ticks or o.sleepAmount, function()
        o.ptr = (o.ptr+1) % #o.tsks
        o.tsks[o.ptr+1]()
      end)
    end)
    return self
  end
  ---@param func fun(self: Repeating) Function to run after the previous one. Repeats every tick until the return value of the function is true. Only then continues on to the next one. This self is passed in, if you want to modify it, for example you can call this:stop()
  ---@return self
  function o:runUntil(func)
    table.insert(self.tsks, function()
      if self.stp then return end
      rl(1, function()
        if func(self) then
          o.ptr = o.ptr+1
        end
        if o.ptr < #o.tsks then
          o.tsks[o.ptr+1]()
        end
      end)
    end)
    return self
  end
  ---Starts executing the queued functions
  ---@return self
  function o:start()
    o.tsks[o.ptr+1]()
    return self
  end
  ---@return self
  function o:stop()
    self.stp = true
    return self
  end
  return o
end
---Create a new Once Sleepable
---Runs the queued functions only once
---@return Once
s.once = function()
  ---@class Once
  ---@field private tsks any
  ---@field private ptr any
  ---@field private stp any
  ---@field store table An empty table that you can use to store things between sleepable functions. You can also technically just add keys into self directly, but to ensure compatibility with future updates you shouldnt rely on those keys being available in the future.
  local o = {}
  o.tsks = {}
  o.store = {}
  o.ptr = 0
  o.stp = false
  o.sleepAmount = 1
  ---@param func fun(self: Once) Function to run after the previous one. This self is passed in, if you want to modify it, for example you can call this:stop()
  ---@param ... any Arguments to pass into the func instead of self, allows calling Figura functions directly
  ---@return self
  function o:run(func, ...)
    local varargs = {...}
    table.insert(self.tsks, function()
      if self.stp then return end
      if #varargs > 0 then
        func(table.unpack(varargs))
      else
        func(self)
      end
      o.ptr = o.ptr+1
      if o.ptr < #o.tsks then
        o.tsks[o.ptr+1]()
      end
    end)
    return self
  end
  ---@param ticks number Amount of ticks to sleep before running the next function. If nil, uses the self.sleepAmount.
  ---@return self
  function o:sleep(ticks)
    table.insert(self.tsks, function()
      rl(ticks or o.sleepAmount, function()
        o.ptr = o.ptr+1
        if o.ptr < #o.tsks then
          o.tsks[o.ptr+1]()
        end
      end)
    end)
    return self
  end
  ---@param func fun(self: Once) Function to run after the previous one. Repeats every tick until the return value of the function is true. Only then continues on to the next one. This self is passed in, if you want to modify it, for example you can call this:stop()
  ---@return self
  function o:runUntil(func)
    table.insert(self.tsks, function()
      if self.stp then return end
      rl(1, function()
        if func(self) then
          o.ptr = o.ptr+1
        end
        if o.ptr < #o.tsks then
          o.tsks[o.ptr+1]()
        end
      end)
    end)
    return self
  end
  ---Starts executing the queued functions
  ---@return self
  function o:start()
    o.tsks[o.ptr+1]()
    return self
  end
  ---@return self
  function o:stop()
    self.stp = true
    return self
  end
  return o
end
return s