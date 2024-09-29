# Confetti

A particle library for the Figura Minecraft Mod.

Spawn Mesh and Sprite particles with options like acceleration, scale or rotation.

Setup:
1) Add the `confetti.lua` lua file into your avatar
2) Import library and define particles with name and lifetime
```lua
confetti = require("confetti")
confetti.registerMesh("myMeshParticle", models.model.MyParticle, 15)
confetti.registerSprite("mySpriteParticle", textures["mytexture"], vec(0,0,5,5), 10)
```
3) Spawn particles
```lua
confetti.newParticle(name, pos, vel, options)
```
Options is a table with the following supported fields:
```elm
lifetime number|nil Initial lifetime in ticks
acceleration Vector3|number|nil Vector in world space or a number which accelerates forwards (positive) or backwards (negative) in the current movement direction
friction number|nil Number of friction to slow down the particle. Value of 1 is no friction, value <1 slows it down, value >1 speeds it up.
scale Vector3|number|nil Initial scale when spawning
scaleOverTime Vector3|number|nil Change of scale every tick
rotation Vector3|number|nil Initial rotation when spawning
rotationOverTime Vector3|number|nil Change of rotation every tick
billboard boolean|nil Makes the particle always face the camera
emissive boolean|nil Makes the particle emissive, only works for mesh. Alternative for sprite is to make a flat cube with the sprite on it as a mesh particle.
ticker fun(particle: Confetto)|nil Function called each tick. To keep default behavior, call `Confetti.defaultTicker(particle)` before your own code.
renderer fun(particle: Confetto, delta: number, context: Event.Render.context, matrix: Matrix4)|nil Function called each frame. To keep default behavior, call `Confetti.defaultRenderer(particle, delta, context, matrix)` before your own code.
```

![Confetti Logo](./images/image.png)