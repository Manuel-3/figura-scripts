# Task — Process chunking and instruction limit optimization using async for loops

To use, first:
```lua
local Task = require("task.lua")
```

Example `Task(start,finish,process,callback)`
```lua
Task(1,5,function(i)
  --code
end,
function()
  --done
end)
```
basically equivalent to
```lua
for i = 1, 5 do
  --code
end
--done
```

Tasks are basically async for loops.

The process function should handle a small chunk of the overall work you need to do.

Execution of tasks is done as fast as possible using both tick and render events, using the remaining available instructions until cutoff limit is reached, which can be changed at the top of the `task.lua` file.

Example: Nesting tasks to iterate a texture and also show a progress bar
```lua
local progress = Task.ProgressBar("Editing texture", width * height)

Task(0,width-1,function(x)
  Task(0,height-1,function(y)
    texture:setPixel(x,y,vec(1,1,1))
    progress()
  end)
end,
function()
  texture:update()
end)
```
Useful pattern with Tasks, adding a callback function parameter to your function to make it async:
```lua
function factorial(x, callback)
  local result = 1
  Task(1,x,function(i)
    --example
    result = result * i
  end,
  function()
    callback(result)
  end)
end

factorial(5, function(result)
  print(result)
end)
```

Example while loop `while x < 10 do`:
```lua
local x = 0
Task.While(function()return x < 10 end,function()
  x = x + 1
end)
```

One bonus thing you might find useful, normal render event can run multiple times per frame if multiple contexts are happening at the same time, for example doubling your render instructions when opening the inventory etc... Here is render that runs only once per world render:
```lua
Task.SingleRender(function(delta, ctx, matrix)
  -- whatever render event code
end)
```

Real world examples can be seen in the following of my other projects:

- [watersim](https://github.com/Manuel-3/figura-scripts/tree/main/src/watersim)
- [texturelayers](https://github.com/Manuel-3/figura-scripts/tree/main/src/texturelayers)
- [frameinterpolation](https://github.com/Manuel-3/figura-scripts/tree/main/src/frameinterpolation).
