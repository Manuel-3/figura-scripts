# Texture Layers

Dynamically add layers to your textures. Can set visibility of individual layers. Minimal lua code required.

To use simply name your textures accordingly:
`myTexName` (this can be anything you want) The actual texture which is applied to the model.
`myTexNameLayer1` Now add Layer1 for the first layer. This texture **is not applied to any model parts**. Instead it simply sits there linked inside of the bbmodel file.
`myTexNameLayer2` You get the idea. You can add as many layers as you want.

If you get an error, make sure to put the correct lua texture name, remember that you can print all the texture names in chat with with `logTable(textures:getTextures())` at the top of your script file.

Optional: After adding **your own empty script file**, you can now setVisible or setColor individual layers, for example:
```lua
local TextureLayers = require("texturelayers")
TextureLayers:setColor("myTexNameLayer1", vec(1,0.8,0.5))
TextureLayers:setVisible("myTexNameLayer2", false)
TextureLayers:update("myTexName")
```
**Disclaimer**
This uses an enormous amount of instructions so don't expect it to work on default permission limits!