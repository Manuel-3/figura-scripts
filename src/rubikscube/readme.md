This accessory is meant to easily go into any avatar. To merge, simply copy paste all of the files into your avatar (except for the avatar.json, but would be nice if you kept me in the authors field :purple_heart: ).

To use open the action wheel, toggle rubiks cube, toggle solve mode. Then move your mouse and left/right click to turn. The right click direction is previewed by a slight turn in that direction.

It works on default permissions, but will be slow. It will dynamically adjust to use only about two thirds of the instruction limit, to make room for your own script. But for smooth turning, tell your friends to put you into "High" permissions, or just increase tick and render instructions to around 16,000 (but will only use around 9,000)

If you see really high instruction counts when using it, don't worry, these are only client side for you, as you will do all the heavy calculations and then send it in a ping.

There is no setup required, but optionally you can integrate the action wheel page into your own pages system, by telling it to which page you want to go back to when you close it.
```lua
local rubiks = require("rubikscube")

-- in your action that changes to the rubiks page, put this:
rubiks.goBackPage = "page name"
action_wheel:setPage(rubiks.page)
```Settings you can change in the script, or update dynamically:
```lua
--example
rubiks.settings.scrambleDelay = 4
--others
autosolveDelay
vanillaModelPoses
hideHeldItems
disableWorldInteractions
disableWalking
flipLeftRightClick
flipLeftRightOnTopFace
flipLeftRightOnBottomFace
invertCameraHorizontal
invertCameraVertical
cameraSensitivity
previewRightClickTurnDir
smoothPreview
previewAmountDegrees
```To customize your cube, simply open the texture and change colors. If you want more detail, first scale the texture up by a natural factor like 2x or 3x and then draw on it, no need to mess with any UV values.
