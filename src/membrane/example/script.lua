local membrane = require("membrane")

membrane:define(models.testmodel.membrane1, {
    models.testmodel.wing.bone1.bone1start,
    models.testmodel.wing.bone1.bone1end,
    models.testmodel.wing.bone1.bone2.bone2end,
    models.testmodel.wing.bone1.bone2.bone3.bone3end
})
membrane:define(models.testmodel.membrane2, {
    models.testmodel.rotate.wing2.bone4.bone1start2,
    models.testmodel.rotate.wing2.bone4.bone1end2,
    models.testmodel.rotate.wing2.bone4.bone5.bone2end2,
    models.testmodel.rotate.wing2.bone4.bone5.bone6.bone3end2
})

animations.testmodel.testanim:play()