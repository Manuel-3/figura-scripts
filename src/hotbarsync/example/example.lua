-- the hotbarsync script provides two global variables:

-- hotbar
-- an table containing the names of the items in each slot, like hotbar[0] is the first slot, hotbar[1] the second slot, and so on

-- selectedSlot
-- an integer for which slot is currently selected, 0 for the first, 1 for the second, and so on


-- EXAMPLES -- 

-- Example to show the hotbar above the player and highlight selected item --

local itemTasks = {}

function events.ENTITY_INIT()
    for i = 1, 9 do
        -- initialize 9 item tasks one for each hotbar slot
        local item = hotbar[i] or "minecraft:air"
        local task = models.model.bone:newItem(i) -- name them each differently, 1 through 9
        task:setDisplayMode("GUI") -- gui type to make them look similar to the hotbar
        task:setScale(0.3,0.3,0.3) -- make a little smaller
        task:setPos((5*4)-(5*i),0,0) -- offset them so they dont all show at the same position
        itemTasks[i] = task -- store the task in the array
    end
end

function events.tick()
    for i = 1, 9 do
        -- highlight selected item (while keeping x pos the same)
        if i == selectedSlot then
            itemTasks[i]:setPos(itemTasks[i]:getPos().x,2,0)
        else
            itemTasks[i]:setPos(itemTasks[i]:getPos().x,0,0)
        end
        -- update item tasks
        itemTasks[i]:setItem(hotbar[i] or "minecraft:air")
    end
end


-- Example to show only the 8 non-selected items --

-- local itemTasks = {}

-- function events.ENTITY_INIT()
--     for i = 1, 8 do
--         local task = models.model.bone:newItem(i) -- name them each differently, 1 through 8
--         task:setDisplayMode("GUI") -- gui type to make them look similar to the hotbar
--         task:setScale(0.3,0.3,0.3) -- make a little smaller
--         task:setPos((5*4)-(5*i),0,0) -- offset them so they dont all show at the same position
--         itemTasks[i] = task -- store the task in the array
--     end
-- end

-- function events.tick()
--     local i = 1
--     for key, value in pairs(hotbar) do
--         if key ~= selectedSlot then
--             itemTasks[i]:setItem(value or "minecraft:air")
--             i = i + 1
--         end
--     end
--     while i <= #itemTasks do
--         itemTasks[i]:setItem("minecraft:air")
--         i = i + 1
--     end
-- end