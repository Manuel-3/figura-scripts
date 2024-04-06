vanilla_model.ALL:setVisible(false)

tex = textures["Skin"]
models.model:setPrimaryTexture("CUSTOM",tex)

scroll_speed = 3
wobble_speed = 0.05

hsvToRGB = vectors.hsvToRGB
sin = math.sin

for y = 0, 43, 1 do
    for x = 0, 15, 1 do
        tex:setPixel(x+24,y,(x+y+1)%2==0 and vec(0,0,0,1) or vec(0,0,0,0))
    end
end

function events.tick()
    local t = world.getTime()
    hue = t*scroll_speed/360
    local wobble = sin(t*wobble_speed)

    for y = 0, 43, 1 do
        for x = 4, 11, 1 do
            tex:setPixel(x,y,(x+y)%2==0 and vec(0,0,0,1) or hsvToRGB(
                hue
                +(y/64) -- spread on y
                +(
                    sin((x+2)/2)/20 -- static wave (+2 to center, /2 for horizontal size, /20 for vertical size)
                    *wobble -- change direction of wave
                ),
                1,1))
        end
    end
    for y = 12, 31, 1 do
        for x = 0, 3, 1 do
            tex:setPixel(x,y,(x+y)%2==0 and vec(0,0,0,1) or hsvToRGB(
                hue
                +(y/64)
                +(
                    sin((x+2)/2)/20
                    *wobble
                ),
                1,1))
        end
    end
    for y = 12, 31, 1 do
        for x = 12, 15, 1 do
            tex:setPixel(x,y,(x+y)%2==0 and vec(0,0,0,1) or hsvToRGB(
                hue
                +(y/64)
                +(
                    sin((x+2)/2)/20
                    *wobble
                ),
                1,1))
        end
    end
    -- Full area, takes ~4000 instructions more than splitting into 3 sections
    -- for y = 0, 43, 1 do
    --     for x = 0, 15, 1 do
    --         tex:setPixel(x,y,(x+y)%2==0 and vec(0,0,0,1) or hsvToRGB(
    --             hue
    --             +(y/64)
    --             +(
    --                 sin((x+2)/2)/20
    --                 *wobble
    --             ),
    --             1,1))
    --     end
    -- end
    tex:update()
end

