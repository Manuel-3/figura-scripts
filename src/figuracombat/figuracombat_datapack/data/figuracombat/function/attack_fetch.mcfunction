# get stored information about this specific attack to pass into next function
$execute as @s run execute store result storage figuracombat:args args.cooldown int 1 run data get storage figuracombat:config attacks.attack$(attack).cooldown
$execute as @s run execute store result storage figuracombat:args args.max_damage int 1 run data get storage figuracombat:config attacks.attack$(attack).max_damage
$execute as @s run execute store result storage figuracombat:args args.max_range int 1 run data get storage figuracombat:config attacks.attack$(attack).max_range
function figuracombat:attack_cap with storage figuracombat:args args