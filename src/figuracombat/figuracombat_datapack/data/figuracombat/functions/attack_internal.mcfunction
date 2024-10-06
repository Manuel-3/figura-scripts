# set cooldown of this player
$scoreboard players set @s figuracombat_cooldown $(cooldown)
# perform the attack
$execute as @s at @s run damage @e[nbt={UUID:[I;$(uuid1),$(uuid2),$(uuid3),$(uuid4)]}, limit=1, distance=..$(max_range)] $(damage) generic by @s
# clear args because why not, we are done here
data modify storage figuracombat:args args set value {}