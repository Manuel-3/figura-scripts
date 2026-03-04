vanilla_model.ALL:setVisible(false)

-- using runLater just for demonstration of
-- the anims being independent of each other
local runLater = require("runLater")

-- require the animRecorder library
local recorder = require("animRecorder")

-- making a few copies to show off different animation modes later
local copy1 = recorder.deepCopy(models.model.group)
    :moveTo(models.model:newPart("demo1"):setPos(10,0,0))
local copy2 = recorder.deepCopy(models.model.group)
    :moveTo(models.model:newPart("demo2"):setPos(20,0,0))
local copy3 = recorder.deepCopy(models.model.group)
    :moveTo(models.model:newPart("demo3"):setPos(30,0,0))

-- record the animation, and then after it is finished recording we play it
-- on the model copies after different time delays
recorder.record(animations.model.animation, models.model.group, function(recording)
    recorder.play(recording, copy1, "LOOP")
    runLater(7,function()
        recorder.play(recording, copy2, "HOLD")
    end)
    runLater(14,function()
        recorder.play(recording, copy3, "ONCE")
    end)
end)
