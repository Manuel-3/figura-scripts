local SwingingPhysics = require("swinging_physics")
local swingOnHead = SwingingPhysics.swingOnHead
local swingOnBody = SwingingPhysics.swingOnBody

-- Example usage --

-- Syntax: swingOnHead(modelpart, direction, limits, root, depth, globalLimits)
-- modelpart: the modelpart to swing
-- direction: basically imagine it dangling from a stick thats pointing in this direction
--     0 means forward, 45 is 45 degree to the left, 90 is 90 degree to the left, and so on all the way around
-- limits: limit rotation for each axis, table layout {xLow, xHigh, yLow, yHigh, zLow, zHigh} (optional)
-- root: if chaining, put the root group of the chain
-- depth: for each chain element increase this number. used for increasing friction to make it look better. recommended to play around with it a bit to find values you like,
--     also dont make it too high otherwise it will almost look stiff. mostly good values are between 1 and 5
-- globalLimits: either true or false, if set to true it will negate the vanilla model rotation before applying the limits. this means if you for example look up or
--     down, the limits arent local to the head rotation. this can help preventing it going into other body parts when the limits were only designed for the default head position.

-- Demonstration of collision with head (walk side to side to test):
swingOnHead(models.example.Head.left, 90, {-90,90,-90,90,-90,10})

-- Without collision (takes less instructions):
swingOnHead(models.example.Head.back, 180)
swingOnHead(models.example.Head.forwardleft, 45)
local head_right_swinghandler = swingOnHead(models.example.Head.right, 270)

-- Demonstration of chaining
swingOnHead(models.example.Head.chain, 0)
swingOnHead(models.example.Head.chain.chain2, 0, nil, models.example.Head.chain, 1)
swingOnHead(models.example.Head.chain.chain2.chain3, 0, nil, models.example.Head.chain, 2)

-- Body needs a different function than head
swingOnBody(models.example.Body.front, 0)
swingOnBody(models.example.Body.left, 90)
swingOnBody(models.example.Body.back, 180)

-- Example to enable or disable swinging
local body_right_swinghandler = swingOnBody(models.example.Body.right, 270)
body_right_swinghandler:setEnabled(false)
-- Example of changing limits
head_right_swinghandler:setLimits({-90,90,-90,90,-10,90})