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
lifetime number "Lifetime in ticks"
acceleration Vector3|number "Vector in world space or a number which accelerates forwards (positive) or backwards (negative) in the current movement direction"
friction number|nil "Number of friction to slow down the particle. Value of 1 is no friction, value <1 slows it down, value >1 speeds it up."
scale Vector3|number "Initial scale when spawning"
scaleOverTime Vector3|number "Change of scale every tick"
rotation Vector3|number "Initial rotation when spawning"
rotationOverTime Vector3|number "Change of rotation every tick"
billboard boolean "Whether the Sprite should always face the camera, only affects Sprite particles"
```
