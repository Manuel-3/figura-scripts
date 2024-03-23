# Sleepable - Adding sleep() to Figura

Some people who came from Roblox wanted to have a sleep function. Normally you would rethink your code to use tick counting or `world.getTime() % X == 0`, but if you don't want that stuff, try this.

To start, put the `sleepable.lua` file into your avatar, then in another script do:
```lua
local sleepable = require("sleepable")
```
After that, you can either make some functions with sleep in between them execute once(), or make it repeating() in a loop:
```lua
-- Example execute your functions only once in order
sleepable.once()
  :run(function()
    print("multi line")
    print("code here")
  end)
  :sleep(20)
  :run(print, "waited 20 ticks!")
  :start() -- dont forget start so the queued functions start to run

-- Example repeat your functions
sleepable.repeating()
  :run(print, "1")
  :sleep(20)
  :run(print, "2")
  :sleep(20) -- sleep at the end before going back to the first function
  :start()
```
You can stop at any point by using `self`. Stopping will then no longer call the next function in queue:
```lua
sleepable.repeating()
  :run(function(self)
    local self.sleepAmount = math.random()
    if self.sleepAmount < 0.5 then
      self:stop() -- randomly stop with a 50% chance
    end
    print("Current number: " .. i) -- still prints after :stop(), it will still finish current function
  end)
  :sleep() -- sleeps for self.sleepAmount
  :start()
```
It is very handy for waiting for http requests too, using runUntil function:
```lua
sleepable.once()
    :run(function(self)
      local request = net.http:request(uri)
      self.store.myfuture = request:send()
    end)
    :runUntil(function(self)
      return self.store.myfuture:isDone() -- runs each tick until true is returned
    end)
    :run(function(self)
      print(self.store.myfuture:getValue())
    end)
    :start()
```