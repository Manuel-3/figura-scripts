# enable scoreboards for players
scoreboard players enable @a figuracombat_attack
scoreboard players enable @a figuracombat_uuid_1
scoreboard players enable @a figuracombat_uuid_2
scoreboard players enable @a figuracombat_uuid_3
scoreboard players enable @a figuracombat_uuid_4
scoreboard players enable @a figuracombat_damage
scoreboard players enable @a figuracombat_info
scoreboard players enable @a figuracombat_cooldown
# put default value
execute as @a unless score @s figuracombat_cooldown = @s figuracombat_cooldown run scoreboard players set @s figuracombat_cooldown 1

# info trigger
data modify storage figuracombat:args args set value {}
execute store result storage figuracombat:args args.n int 1 run scoreboard players get figuracombat_global figuracombat_registered_attacks
execute as @a[scores={figuracombat_info=1..}] run function figuracombat:info with storage figuracombat:args args
scoreboard players set @a[scores={figuracombat_info=1..}] figuracombat_info 0

# execute for anyone with no cooldown and attack of 1 or above (0 means do nothing)
execute as @a[scores={figuracombat_attack=1.., figuracombat_cooldown=0}] run function figuracombat:attack
scoreboard players set @a[scores={figuracombat_attack=1..}] figuracombat_attack 0
# reduce cooldown
scoreboard players remove @a[scores={figuracombat_cooldown=1..}] figuracombat_cooldown 1

# health display for testing
# scoreboard objectives add Health health
# scoreboard objectives setdisplay below_name Health
# execute as @e[type=cow] store result score @s Health run data get entity @s Health