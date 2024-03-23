#Hotbar Sync

This script sends item names and the selected slot id using pings.
You can just drop this script into your avatar folder, and it will create two global variables that you can use:

`hotbar` and `selectedSlot`

`hotbar`  is a table containing the item name strings, like `hotbar[1]` returns the item id in the first slot for example `"minecraft:grass_block"` and another global variable called `selectedSlot` which is the selected slot id like `1` for the first slot, `2` for the second slot and so on.

I havent tested this, but in theory it should also work with modded items. I also tried making it use only very few pings, thats why it updates only every 5 ticks and only if there are changes. Also it only ever updates one hotbar item every 5 ticks and waits another 5 before sending the next.

This script was made because I saw this hellp post: https://discord.com/channels/1129805506354085959/1148711197307310121

NOTE: in certain cases you might need to make sure this runs before your custom script, so in your custom script put `require("hotbarsync")` at the top

NOTE: this DOES NOT sync item count, nbt data, or enchantments, etc.. it ONLY syncs the item name!
