# Swinging Physics

To get started, download `swinging_physics.lua` and put it into your avatar.
Then at the top of your own script add:
```lua
local SwingingPhysics = require("swinging_physics")
```
You can make things swing either when they are attached to the Body or Head. Body can work for limbs too but don't account for their additional forces so it might not look as good.
```lua
SwingingPhysics.swingOnHead(part, dir, limits, root, depth)
SwingingPhysics.swingOnBody(part, dir, limits, root, depth)
```
Check the example avatar to learn how to use it.

![Swinging Physics Logo](./images/image.png)