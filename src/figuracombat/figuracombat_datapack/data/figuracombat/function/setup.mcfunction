# clear things first
scoreboard objectives remove figuracombat_registered_attacks
scoreboard objectives remove figuracombat_attack
scoreboard objectives remove figuracombat_uuid_1
scoreboard objectives remove figuracombat_uuid_2
scoreboard objectives remove figuracombat_uuid_3
scoreboard objectives remove figuracombat_uuid_4
scoreboard objectives remove figuracombat_damage
scoreboard objectives remove figuracombat_cooldown
data modify storage figuracombat:args args set value {}
data modify storage figuracombat:config attacks set value {}

# create counter for registered attacks
scoreboard objectives add figuracombat_registered_attacks dummy
scoreboard players enable figuracombat_global figuracombat_registered_attacks
# load config
function figuracombat:_config
# attack trigger, when set to anything other than 0 it will trigger that specific attack
scoreboard objectives add figuracombat_attack trigger
# info trigger to display attack information, set to 1 to display all
scoreboard objectives add figuracombat_info trigger
# uuid target 4 integers
scoreboard objectives add figuracombat_uuid_1 trigger
scoreboard objectives add figuracombat_uuid_2 trigger
scoreboard objectives add figuracombat_uuid_3 trigger
scoreboard objectives add figuracombat_uuid_4 trigger
# damage to deal, will be reduced to maximum damage of the attack if its above
scoreboard objectives add figuracombat_damage trigger
# cooldown tracker
scoreboard objectives add figuracombat_cooldown dummy