# Quick Outline

Replaces all the manual steps, that you would need to take in BlockBench to create outlines, with a single line of code instead.

This script does *exactly* what you could manually do in BlockBench, nothing more! If you want a different version of the outline that has a script that attempts to fix a few visual glitches that appear with many overlapping cubes with this method check out: https://discord.com/channels/1129805506354085959/1146318090771103764 <-- alternative version

Example Usage:
```lua
local outline = require("quickoutline")

local head_outlines_array = outline.createOutline(models.model.Head.cube, 0.2, vec(0,0,0), false)
--                                                ^cube/group    thickness^    ^color      ^emissive
```
If you select a group it will make outlines for all cubes within it.

If you use meshes, make sure you center the pivot point of the mesh in blockbench first.

![Quick Outline Logo](./images/image.png)
