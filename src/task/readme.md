# Task

Add a new Task to the stack. Tasks are basically async for loops.

The process function should handle a small chunk of the overall work you need to do.

You can nest Tasks by making new ones inside of the process function.

Execution of tasks is done as fast as possible using both tick and render events.

System tries to use the remaining available instructions, cutoff before limit is reached can be changed at the top of the `task.lua` file.

These events are registered in entity_init to run after all other registered events, because the system uses up all the remaining instructions (up to the cutoff).

To use, first:
```lua
local Task = require("task.lua")
```

Example
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

Example Progress Bar, target amount matches the loops done
```lua
local progress = Task.ProgressBar("My Task", 5)

Task(1,5,function(i)
    --code
    progress()
end)
```

Example nested
```lua
local progress = Task.ProgressBar("My Task", 5*20)

Task(1,5,function(i)
    Task(1,20,function(j)
        --code
        progress()
    end)
end)
```

Example of useful pattern with Tasks, allowing async processing by using callbacks
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

As an example how it is used in a real project see [frameinterpolation](https://github.com/Manuel-3/figura-scripts/tree/main/src/frameinterpolation).
