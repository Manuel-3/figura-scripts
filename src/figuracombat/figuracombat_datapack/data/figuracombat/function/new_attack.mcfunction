# clear args
data modify storage figuracombat:args args set value {}
# increase attacks counter and pass into next function
scoreboard players add figuracombat_global figuracombat_registered_attacks 1
execute store result storage figuracombat:args args.n int 1 run scoreboard players get figuracombat_global figuracombat_registered_attacks
# pass attack information into next function
$data modify storage figuracombat:args args.cooldown set value $(cooldown)
$data modify storage figuracombat:args args.max_range set value $(max_range)
$data modify storage figuracombat:args args.max_damage set value $(max_damage)

function figuracombat:new_attack_internal with storage figuracombat:args args