# Animation Recorder

Record and play back BlockBench animations. This can be used to play the same animation on different copies of a model independently. While recording, the animation will have to play at least once.

Basic example below, also check out the example.zip download for a full example avatar. Functions are annotated with lua docs.

```lua
local recorder = require("animRecorder")

local copy = recorder.deepCopy(models.model):moveTo(models):setPos(10,0,0)

recorder.record(animations.model.animation, models.model.group, function(recording)
    recorder.play(recording, copy.group, "LOOP")
end)
```