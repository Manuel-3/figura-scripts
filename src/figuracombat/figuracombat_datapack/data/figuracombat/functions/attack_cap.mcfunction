# cap damage to max_damage of this attack
$execute as @s if score @s figuracombat_damage matches $(max_damage).. run scoreboard players set @s figuracombat_damage $(max_damage)
# update argument to pass into next function
execute as @s run execute store result storage figuracombat:args args.damage int 1 run scoreboard players get @s figuracombat_damage

function figuracombat:attack_internal with storage figuracombat:args args