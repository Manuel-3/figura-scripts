-- These two variables are being synced to other players -- 
hotbar = {}
selectedSlot = 1
-- End of synced variables --

-- Start of host code --
local previousSelectedSlot = 1

function pings.updateSelectedSlot(slot)
    selectedSlot = slot
end

function pings.updateHotbar(slot, itemid)
    hotbar[slot] = itemid
end

if host:isHost() then
    function events.tick()
        if world.getTime() % 5 ~= 0 then return end -- update only every 5 ticks to not send too many pings

        selectedSlot = player:getNbt().SelectedItemSlot + 1
        if previousSelectedSlot ~= selectedSlot then
            -- send a ping whenever a different slot is selected
            hotbar[selectedSlot] = nil -- act like the hotbar doesnt have an item there which will cause it to update with pings later. that way it syncs better for players that just loaded in. this is as an alternative to sending the entire hotbar every ten or so seconds
            pings.updateSelectedSlot(selectedSlot)
        end
        previousSelectedSlot = selectedSlot

        local newHotbar = {}

        for _, itemstack in ipairs(player:getNbt().Inventory) do
            -- the items are in order, so if the slot is bigger than 8 no other hotbar slots will come after
            if itemstack.Slot > 8 then
                break
            end
            newHotbar[itemstack.Slot + 1] = itemstack.id
        end

        local hasAlreadySentAHotbarPingThisTick = false -- if sent once, then stop. this is to avoid sending too many pings in one tick. it will send another in the next tick

        -- send pings for every hotbar slot that has changed
        for i = 1, 9 do
            if hotbar[i] ~= newHotbar[i] then
                hotbar[i] = newHotbar[i] -- this is setting the hotbar only locally, yes the ping after this line would also set the local one, but since we clear the selected slot above it would have an empty slot for the host player until the ping is properly sent
                if not hasAlreadySentAHotbarPingThisTick then
                    hasAlreadySentAHotbarPingThisTick = true
                    pings.updateHotbar(i, newHotbar[i])
                end
            end
        end
    end
end
-- End of host code --
