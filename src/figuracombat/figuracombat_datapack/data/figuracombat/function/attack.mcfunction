# clear args
data modify storage figuracombat:args args set value {}
# get pass information of attack into next function
execute as @s run execute store result storage figuracombat:args args.uuid1 int 1 run scoreboard players get @s figuracombat_uuid_1
execute as @s run execute store result storage figuracombat:args args.uuid2 int 1 run scoreboard players get @s figuracombat_uuid_2
execute as @s run execute store result storage figuracombat:args args.uuid3 int 1 run scoreboard players get @s figuracombat_uuid_3
execute as @s run execute store result storage figuracombat:args args.uuid4 int 1 run scoreboard players get @s figuracombat_uuid_4
execute as @s run execute store result storage figuracombat:args args.attack int 1 run scoreboard players get @s figuracombat_attack
execute as @s run execute store result storage figuracombat:args args.damage int 1 run scoreboard players get @s figuracombat_damage

function figuracombat:attack_fetch with storage figuracombat:args args