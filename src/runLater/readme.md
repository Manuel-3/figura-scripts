# Run Later (Former Wait Function)

Schedules a function to run after a specified amount of ticks or when a predicate function returns true.

## How to use

Download the file and put it next to your other files in your avatar.

Then use the example code below in *another script* (dont edit the downloaded file).

Example:
```lua
local runLater = require("runLater")

log("This is right now!")

runLater(20, function()
    log("This is 1 second (20 ticks) later!")
end)
```
For more advanced usage, you can also wait for a certain predicate function to return true. Here is an example for Figura Networking API:
```lua
local request = net.http:request("https://example.com")
local future = request:send()

runLater(
  function() return future:isDone() end, -- wait for this to return true
  function()
    log(future:getValue())
  end
)
```