local frameinterpolation = require("frameinterpolation")

-- Example 1: Using the vanilla prismarine texture
-- Generating 20 interpolated frames for each existing frame.
-- Because it could be a different amount of frames than normal if someone is using a resource pack,
-- we use frame count of "unknown". Make sure in that the UV of your model is set to the entire texture for that to work.
local texture = textures:fromVanilla("prismarine", "minecraft:textures/block/prismarine.png")
frameinterpolation.interpolate(texture, "unknown", 20, function(atlas)
    frameinterpolation.animate({models.model.cube1}, atlas)
end)

-- Example 2: Using custom vertical texture strip
-- Generating 10 interpolated frames for each existing frame.
-- This time you can either put the amount of frames your texture has, or "auto" to determine it from the width.
-- In this case, make sure the UV is set to the first frame (top left corner) of your texture.
frameinterpolation.interpolate(textures["model.texture1-sheet"], "auto", 10, function(atlas)
    frameinterpolation.animate({models.model.cube2}, atlas)
end)
