# Texture Layers

Add layers to your textures. Can set visibility of individual layers. Minimal lua code required.

This dynamically spreads calculations across several frames, so it will even work on the "Low" permission level!

## How to use

1. Put `texturelayers.lua` and `task.lua` into your avatar.

2. Simply name your textures accordingly:

`myTexName` (this can be anything you want) The actual texture which is applied to the model.

`myTexNameLayer1` Now add Layer1 for the first layer. This texture **is not applied to any model parts**. Instead it simply sits there linked inside of the bbmodel file.

`myTexNameLayer2` You get the idea. You can add as many layers as you want.

If you get an error, make sure to put the correct lua texture name, remember that you can print all the texture names in chat with with `logTable(textures:getTextures())` at the top of your script file.

3. Optional: After making **your own script file**, you can now setVisible or setColor individual layers, for example:
```lua
local TextureLayers = require("texturelayers")

TextureLayers:setColor("myTexNameLayer1", vec(1,0.8,0.5))
TextureLayers:setVisible("myTexNameLayer2", false)
TextureLayers:update("myTexName")
```
