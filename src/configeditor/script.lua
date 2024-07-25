-- Example script using config editor
local configeditor = require("configeditor")

-- Use this at the start of your script to let users of your avatar/libarry/whatever know, that config editor is installed
configeditor:printInfo()

-- Similar to config:setName()
configeditor:setName("myconf")

-- Similar to config:save() except it only saves if there is no value already saved
configeditor:default("bool", false)
configeditor:default("str", "Hello")
configeditor:default("num", 3)
configeditor:default("arr", {1,2,3})
configeditor:default("tbl", {a={1,2,3},b={4,5,6},c={7,8,d={9}}})

-- In game, the /configeditor command can be used to open it
-- /configeditor myconf

-- Or use this line of code:
-- configeditor:open()