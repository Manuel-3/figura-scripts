# Figura Combat
Library to create custom attacks in your Figura avatar.
**Key points**
1. Does not need OP permissions.
2. Server owners can configure it in the datapack.
3. Needs Minecraft 1.20.2 or later.
**Installation**
1. Download the datapack and put it in your world/servers datapack folder.
2. Open the `data/figuracombat/functions/_config.mcfunction` file with a text editor to configure the available attacks.
3. Download the library `combat.lua` file and put it inside your own avatar.
4. Custom code your own attack animations (advanced) and call the attack function to attack an entity.
**Example**
```lua
local attackId = 1
local damage = 5
local entity = player:getTargetedEntity()
if entity then
    Combat.attack(attackId, entity, damage)
end
```**Important!**
You can only attack one entity per tick, make sure to not spam the attack function more than this or it might fail!