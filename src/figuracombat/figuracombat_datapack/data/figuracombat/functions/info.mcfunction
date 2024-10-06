# if info is the first attack then display heading
execute if score @s figuracombat_info matches 1 run tellraw @s {"text":"-- Available attacks on this server --"}
# store info loop variable in args to use in tellraw in next function
execute store result storage figuracombat:args args.i int 1 run scoreboard players get @s figuracombat_info
function figuracombat:info_internal with storage figuracombat:args args
# increase info loop variable and call this function again if smaller or equal to n (which is amount of attacks available)
scoreboard players add @s figuracombat_info 1
$execute if score @s figuracombat_info matches ..$(n) run function figuracombat:info with storage figuracombat:args args