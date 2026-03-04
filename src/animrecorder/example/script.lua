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

    local recording = {{group={scale=vec(1,1,1),rot=vec(0,0,-10.05),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,63.2625),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-7.5499997),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,56.3875),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-5.049999),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,49.512497),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-2.5499985),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,42.637497),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,1.4901161E-6),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,35.624996),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,2.5000005),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,28.749998),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,5.1),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,21.6),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,7.599999),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,14.725002),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,10.099998),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,7.850005),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,12.599996),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,0.9750117),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,15.099997),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-5.89999),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,17.599997),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-12.774992),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,20.15),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-19.7875),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,22.65),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-26.6625),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,25.200003),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-33.67501),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,27.750006),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-40.68752),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,30.300009),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-47.700024),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,32.80001),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-54.575027),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,35.350014),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-61.587536),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,37.14999),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-66.53747),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,34.599995),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-59.524986),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,32.1),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-52.649994),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,29.6),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-45.775),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,27.100002),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-38.90001),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,24.550009),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-31.887524),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,22.05001),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-25.012531),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,19.550014),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-18.137537),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,17.050016),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-11.262544),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,14.550018),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,-4.3875504),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,12.05002),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,2.487443),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,9.550023),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,9.362436),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,7.000023),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,16.374937),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,4.5000257),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,23.24993),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,2.000028),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,30.124924),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-0.5499661),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,37.137405),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-2.249962),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,41.812397),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-4.74996),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,48.68739),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-7.349956),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,55.83738),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-9.799957),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,62.574883),pos=vec(0,0,0),},},{group={scale=vec(1,1,1),rot=vec(0,0,-12.349951),pos=vec(0,0,0),},group2={scale=vec(1,1,1),rot=vec(0,0,69.587364),pos=vec(0,0,0),},},}    
    recorder.play(recording, copy4, "LOOP")

end)
