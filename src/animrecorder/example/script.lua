vanilla_model.ALL:setVisible(false)

-- using runLater just for demonstration of
-- the anims being independent of each other
local runLater = require("runLater")

-- require the animRecorder library
local recorder = require("animRecorder")

-- just some text for clarity
local function text(part,txt)
    part:newText(""):text(txt):alignment("CENTER"):scale(0.3):pos(0,35,0)
end
text(models.model, "Original")
text(models.model:newPart(""):setPos(-42,2,0), "Baked\nRemapped")

-- making a few copies to show off different animation modes later
local demo1 = models.model:newPart("demo1"):setPos(20,0,0)
local copy1 = recorder.deepCopy(models.model.group):moveTo(demo1)
text(demo1, "Loop")

local demo2 = models.model:newPart("demo2"):setPos(40,0,0)
local copy2 = recorder.deepCopy(models.model.group):moveTo(demo2)
text(demo2, "Hold")

local demo3 = models.model:newPart("demo3"):setPos(60,0,0)
local copy3 = recorder.deepCopy(models.model.group):moveTo(demo3)
text(demo3, "Once")

local demo4 = models.model:newPart("demo4"):setPos(-20,0,0)
local copy4 = recorder.deepCopy(models.model.group):moveTo(demo4)
text(demo4, "Baked")

-- record the animation, and then after it is finished recording we play it
-- on the model copies after different time delays
recorder.record(animations.model.animation, models.model.group, function(recording)
    
    recorder.bake(recording) -- copy this animation recording to clipboard, you can then paste it into your script
    
    -- play at different intervals to demonstrate independence
    recorder.play(recording, copy1, "LOOP")
    runLater(7,function()
        recorder.play(recording, copy2, "HOLD")
    end)
    runLater(14,function()
        recorder.play(recording, copy3, "ONCE")
    end)
end)


runLater(2,function() -- this runLater is only for demonstration purposes so it syncs up with the rest

    -- example of a baked animation
    local recording = {name="animation",{group={scale=vec(1,1,1),rot=vec(0,0,-10.900001),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,65.6),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-7.55),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,56.3875),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-5.85),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,51.7125),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-2.499999),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,42.499996),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-0.8499995),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,37.962498),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,2.5000005),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,28.749998),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,4.15),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,24.2125),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,7.5000005),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,14.999999),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,9.15),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,10.462501),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,12.5),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,1.25),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,14.15),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-3.287499),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,17.499998),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-12.499995),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,19.199997),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-17.174992),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,22.499996),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-26.24999),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,24.199995),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-30.924988),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,27.549994),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-40.13748),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,29.199993),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-44.674984),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,32.54999),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-53.887478),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,34.249992),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-58.562477),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,37.40001),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-67.22502),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,35.750008),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-62.687523),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,32.400005),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-53.475018),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,30.750006),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-48.93752),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,27.400005),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-39.725014),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,25.750006),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-35.187515),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,22.400003),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-25.97501),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,20.750004),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-21.437511),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,17.400002),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-12.225007),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,15.700001),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-7.5500016),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,12.400002),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,1.5249965),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,10.699999),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,6.2000017),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,7.3499975),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,15.412506),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,5.699998),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,19.950005),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,2.3499966),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,29.16251),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,0.69999695),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,33.70001),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-2.6500046),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,42.912514),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-4.300004),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,47.450012),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-7.650006),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,56.662518),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-9.350008),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,61.33752),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-12.349987),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,69.58746),pos=vec(0,0,0),},},}
    recorder.play(recording, copy4)

    -- example of remapping group names
    local remapped = recorder.remap(recording, {
        group="group3", -- original was 'group' and new one is 'group3', see in the model
        group2="group5",
    })
    recorder.play(remapped, models.model.group3)

end)
