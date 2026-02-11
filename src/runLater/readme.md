# Run Later (Former Wait Function)

Schedules a function to run after a specified amount of ticks or when a predicate function returns true.

## How to use

Download the `runLater.lua` file and put it next to your other files in your avatar.

Then use the example code below in *a different script* (dont edit the downloaded file).

The most simple usage is to just run a function after a number of ticks:

```lua
local runLater = require("runLater")

log("This is right now!")

runLater(20, function()
    log("This is 1 second (20 ticks) later!")
end)
```

For more advanced usage, you can also wait for a certain predicate function to return true. For example, to wait for an animation:

```lua
anim1:play() -- play first animation
runLater(
    function() return not anim1:isPlaying() end, -- wait for this to return true
    function() anim2:play() end -- play second animation afterwards
)
```

Finally, there is also a runLaterMs.lua, which takes milliseconds instead of ticks as the input. DISCLAIMER: Uses WORLD_RENDER so whatever you do it will most likely ERROR on the default permission setting as the limit is very low! Ideally use the regular tick based runLater instead of this! This function also isn't perfectly accurate, as it depends on the framerate, therefore in the callback the amount of overshot milliseconds is passed in.

```lua
local runLaterMs = require("runLaterMs")

log("This is right now!")

runLaterMs(1000, function(delta)
    log("This is roughly 1 second (1000 milliseconds) later! We were off by "..tostring(delta).." ms.")
end)
```

## Snippets with runLater

### Http Requests

Here is an example of a httpRequest function that uses runLater to wait for the networking.

It would be used like this:

```lua
httpRequest("https://pastebin.com/raw/h2X9G9XN", function(data)
  log(data)
end)
```

The snippet code:

```lua
local runLater = require("runLater")
---@param url string
---@param callback fun(data: string)
local function httpRequest(url, callback)
  local request = net.http:request(url):send()
  runLater(
    function() return request:isDone() end,
    function()
      local stream, data, future = request:getValue():getData(), {}, nil
      local function read()
        future = stream:readAsync(2^20)
        runLater(
          function() return future:isDone() end,
          function()
            local value = future:getValue()
            table.insert(data, value)
            if value == "" then
              callback(table.concat(data))
            else
              read()
            end
          end
        )
      end
      read()
    end
  )
end
```
If you don't care about it blocking the main thread you can also use this shorter version:
```lua
local runLater = require("runLater")
---@param url string
---@param callback fun(data: string)
local function httpRequest(url, callback)
  local request = net.http:request(url):send()
  runLater(
    function() return request:isDone() end,
    function()
      local response = {}
      local data = request:getValue():getData():read()
      while data ~= -1 do
          table.insert(response, string.char(data))
          data = request:getValue():getData():read()
      end
      callback(table.concat(response))
    end
  )
end
```
