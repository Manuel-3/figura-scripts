local membrane = require("membrane")

membrane:define(models.testmodel.membrane, {
    models.testmodel.wing.bone1.bone1start,
    models.testmodel.wing.bone1.bone1end,
    models.testmodel.wing.bone1.bone2.bone2end,
    models.testmodel.wing.bone1.bone2.bone3.bone3end
})

animations.testmodel.testanim:play()