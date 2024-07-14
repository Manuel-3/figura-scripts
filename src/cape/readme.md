# Cape

Recreate the vanilla cape movement.

To use, add this script into your avatar, then in your own script you can access the global `cape_rotation` variable to apply it to a model part. Make sure the model part doesnt have any of the Figura cape keywords, so ideally just name them all in lowercase.

```lua
function events.render()
    models.model.Body.cape:setRot(cape_rotation)
end
```