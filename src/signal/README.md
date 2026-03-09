## Signal

Defer your stuff in order.

```lua
local Signal = require "signal";
local mySignal = Signal.new();
mySignal:connect(function(...)
    print("foo:", ...)
end)

-- [lua] YOU : foo bar baz qux quux corge grault garply waldo
mySignal:fire("bar", "baz", "qux", "quux", "corge", "grault", "garply", "waldo")
```
