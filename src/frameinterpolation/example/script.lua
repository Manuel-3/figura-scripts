local frameinterpolation = require("frameinterpolation")

local tex1 = frameinterpolation.generate(textures["prismarine"],"vertical",4)
models.model.cube2:setPrimaryTexture("CUSTOM",tex1)

logTable(textures:getTextures())

speed = 2
scale = 16

function events.tick()
    local time = world.getTime()
    models.model.cube1:setUV(0, math.floor(time/(speed*scale))/4)
    models.model.cube2:setUV(0, math.floor(time/speed)/(4*scale))
end