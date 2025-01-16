# Action Wheel Sounds
## How to use
Put this script into your avatar.
Then in your own script, put `require("action_wheel_sounds")` **before** any of your action wheel code!

## Optional Stuff

### Changing Sounds

You can edit the sound IDs at the top of the script. The individual sounds are in the format

`{name, pitch}`

so for example like this:

`{"minecraft:item.bundle.insert", 1.4}`

If you want, you can also edit the sound IDs from within your own script, for example:

`require("action_wheel_sounds").onLeftClick = {"minecraft:entity.sheep.ambient", 1}`

### Hover Event

This also adds a hover event to actions. It runs whenever the mouse starts to hover over an action.

It works the same as other action events like left click, has variants like `setOnHover` and `onHover` as well as the field `hover`.

Example:

```lua
page:newAction()
  :title("Hover Event Test")
  :item("item_frame")
  :onHover(function()
    log("hello from hover")
  end)
```