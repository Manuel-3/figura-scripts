log("Hold X and scroll your mouse to scale hat.")

local hat = models.model.Head.Hat.Scalable
local smallest_size = 5
local scale_amount = 2

local key = keybinds:newKeybind("Scale Hat", "key.keyboard.x")
local size = smallest_size

function pings.changeSize(x)
    size = x
    hat:setScale(1,size,1)
end

function events.mouse_scroll(dir)
    if key:isPressed() then
        if size + dir >= smallest_size then
            pings.changeSize(size + dir * scale_amount)
        end
    end
end

if host:isHost() then
    function events.tick()
        if key:isPressed() and not renderer:isFirstPerson() then
            renderer:offsetCameraPivot(0,size/16,0)
        else
            renderer:offsetCameraPivot(0,0,0)
        end
        if world.getTime() % 200 then
            pings.changeSize(size)
        end
    end
end