# Quick Outline

Replaces all the manual steps, that you would need to take in BlockBench to create outlines, with a single line of code instead.

This script does *exactly* what you could manually do in BlockBench, nothing more! If you want a different version of the outline that has a script that attempts to fix a few visual glitches that appear with this method check out: https://discord.com/channels/1129805506354085959/1146318090771103764 <-- alternative version

Example Usage:
```lua
local outline = require("quickoutline")

local head_outline = outline.createOutline(models.model.Head.cube, 0.2, vec(0,0,0), false)
--                                         ^cube          thickness^    ^color      ^emissive
```
Note that it must be a cube! Groups do not work here, you must put a new line for each cube individually!

![Quick Outline Logo](./images/image.png)