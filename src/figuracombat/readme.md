# Figura Combat
Library to create custom attacks in your Figura avatar.
## Key points
* Does not need OP permissions.
* Server owners can configure it in the datapack.
* Needs Minecraft 1.20.2 or later.
## Installation
1. [Download the datapack](https://github.com/Manuel-3/figura-scripts/blob/main/src/figuracombat/figuracombat_datapack.zip) and put it in your world/servers datapack folder.
2. Open the `data/figuracombat/functions/_config.mcfunction` file with a text editor to configure the available attacks.
3. [Download the library](https://github.com/Manuel-3/figura-scripts/blob/main/src/figuracombat/combat.lua) `combat.lua` file and put it inside your own avatar.
4. Custom code your own attack animations (advanced) and call the attack function to attack an entity.
## Example
[Full Example Avatar Download](https://github.com/Manuel-3/figura-scripts/blob/main/src/figuracombat/example_avatar.zip)

Quick example:
```lua
local Combat = require("combat")
local attackId = 1
Combat.attack(attackId, entity, damage)
```
**Important!**
You can only attack one entity per tick, make sure to not spam the attack function or it will fail!

## Datapack configuration
In the `_config.mcfunction` file you can define any number of attacks with damage, range, and cooldown.
They are automatically numbered in the order you define them starting at ID 1.
To view which attacks are available on a specific world/server you can use the `/showinfo` command if you have the script in your avatar, or call `Combat.showInfo()`. You can also visualize an attack range by calling `Combat.previewRadius(number)` or use `/preview number` command.
```js
function figuracombat:new_attack {cooldown:20, max_damage:5, max_range:12}
function figuracombat:new_attack {cooldown:40, max_damage:14, max_range:5}
```

## All functions

### Combat.showInfo
Ask the server to show attack information
```lua
Combat.showInfo()
```

### Combat.attack
Attack an entity with a given attackId and damage amount.

**Important!** You can only call this at max once per tick!

Ideally less, to let the server update properly. Best practice to keep track of your current cooldown, and only call it when its over.

To determine your cooldown, go check which attack cooldowns are set on this server by calling Config.showInfo() or run the /showinfo command.

Then whenever you use an attack, remember its cooldown amount of ticks and count them down to 0. Your player is on cooldown for **all attacks** after using an attack! (Not just the attack you used to get the cooldown! Cooldown is applied to your entire player when you use any attack, and you can't use another attack until it has reached 0.)

It is advised to work with a cooldown of one or two ticks above what the server tells you, to account for a little bit of potential lag.

If you have server permissions, you can use `/scoreboard objectives setdisplay sidebar figuracombat_cooldown` to display your current cooldown.

`attackId: number` To see which attacks are available call Combat.showInfo() or run the /showinfo command

`entity: Entity|number[]` The entity to attack, or it's uuid as an integer array

`damage: number` Damage amount, will be capped by the attacks max damage if it's above
```lua
Combat.attack(attackId, entity, damage)
Combat.attack(1, player:getTargetedEntity(), 5)
```

### Combat.attackAll

Attack all entities in the given list. This takes the given cooldown into account and attacks them over the next several ticks.

It is advised to put a cooldown of one or two ticks above what the server tells you, to account for a little bit of potential lag.

`attackId: number` To see which attacks are available call Combat.showInfo() or run the /showinfo command

`entities: Entity[]|number[][]` List of entities, or list of uuid integer arrays

`damage: number` Damage amount, will be capped by the attacks max damage if it's above

`cooldown: number` The cooldown of the attack with the give attackId

```lua
Combat.attackAll(attackId, entities, damage, cooldown)
Combat.attackAll(1, {entity1, entity2, entity3}, 5, 20)
```

### Combat.getEntities

Get entities in a radius around a position.


`position: Vector3`


`radius: number`


`predicate: nil|fun(entity: Entity):boolean` Predicate to check wheter to include an entity. If not provided, will use a default predicate that excludes dropped items and experience orbs, as well as the own player entity.

returns `Entity[] entities` Array of entities

```lua
local entities1 = Combat.getEntities(position, radius)
local entities2 = Combat.getEntities(position, radius, predicate)
local entities3 = Combat.getEntities(player:getPos(), 5, function(entity)
    return entity:getType()=="minecraft:cow" -- only get cows
end)
```

### Combat.previewRadius

Display attack radius preview in world

You can also use the /preview command

`radius: number`

```lua
Combat.previewRadius(radius)
Combat.stopPreview()
```

### Combat.stopPreview

Stop attack radius preview

```lua
Combat.stopPreview()
```