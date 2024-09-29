-- EXAMPLE SCRIPT --
-- If you want to view an example for longer time, change the example number below, and the time to some big value
-- By the way, all newParticle lines are called in a tick event!
local example = 1
local time_each_example = 100

-- Example code begins here --
local confetti = require("confetti")

confetti.registerMesh("spark", models.model.Spark)
confetti.registerSprite("leaf", textures["model.mytexture"], vec(0,5,4,9), 30)
confetti.registerSprite("fire", textures["model.mytexture"], vec(0,10,4,15))

function example1()
    -- Example 1 bouncing sparks
    confetti.newParticle(
        "spark",
        player:getPos()+vec(0,math.random(),0),
        vec((math.random()-0.5)*0.3,0.2+math.random()*0.2,(math.random()-0.5)*0.3),
        {
            acceleration=vec(0,-0.04,0),
            lifetime=50,
            emissive=true,
            ticker=function(particle)
                -- make sure to call the default ticker which will calculate the regular particle movement
                confetti.defaultTicker(particle)
                -- get velocity so we can check for collision
                local x,y,z = particle.velocity:unpack()
                -- check if previous tick _position plus velocity in each direction would be inside a block, if so flip the velocity to bounce
                if world.getBlockState(particle._position+vec(x,0,0)):isSolidBlock() or world.getBlockState(particle._position-vec(x,0,0)):isSolidBlock() then
                    particle.velocity.x = -x
                end
                if world.getBlockState(particle._position+vec(0,y,0)):isSolidBlock() or world.getBlockState(particle._position-vec(0,y,0)):isSolidBlock() then
                    particle.velocity.y = -y*0.7 -- for y velocity slow down when bouncing
                end
                if world.getBlockState(particle._position+vec(0,0,z)):isSolidBlock() or world.getBlockState(particle._position-vec(0,0,z)):isSolidBlock() then
                    particle.velocity.z = -z
                end
                -- overwrite position with our own calculation.
                -- using _position (which is the position from previous tick) because
                -- the defaultTicker() already modified the current position,
                -- so we want to overwrite that with the previous tick value as a base
                particle.position = particle._position + particle.velocity
            end
        }
    )
end

function example2()
    -- Example 2 leaves falling
    confetti.newParticle(
        "leaf",
        player:getPos()+vec(math.random()*2-1,4,math.random()*2-1),
        vec((math.random()-0.5)*0.2,-math.random()*0.3,(math.random()-0.5)*0.2),
        {
            rotationOverTime=10+math.random()*5
        }
    )
end

function example3()
    -- Example 3 animated texture
    confetti.newParticle(
        "fire",
        player:getPos()+vec(1-math.random()*2,0.1+math.random()*2,1-math.random()*2),
        vec(0,0,0),
        {
            scale=0.6,
            frame=0, -- custom variable "frame" added into options
            billboard=true,
            ticker=function(particle)
                -- we dont need the default ticker in this case, but in general always call it
                -- check out the code to see what it does to determine if you need it

                -- set uv to original bounds plus a frame offset
                particle.task:setUVPixels(particle.bounds.x+particle.options.frame*5, particle.bounds.y)
                -- increase animation frame
                if world.getTime()%2==0 then -- slows down the animation because i like it better
                    particle.options.frame = particle.options.frame + 1
                end
                -- cycle back to first frame, i need this because my texture is a weird size
                if particle.options.frame == 3 then
                    particle.options.frame = 0
                end
            end
        }
    )
end

function example4()
    -- Example 4 sparks reversing and rotating wildly
    confetti.newParticle(
        "spark",
        player:getPos()+vec(0,math.random(),0),
        vec(0.25-math.random()*0.5,0.25-math.random()*0.5,0.25-math.random()*0.5),
        {
            rotationOverTime=30,
            acceleration=-0.02,
            lifetime=30,
            emissive=true
        }
    )
end

function example5()
    -- Example 5 trail when walking around
    confetti.newParticle("spark",player:getPos()+vec(0,math.random(),0),vec(0,0,0),{emissive=true})
end

function example6()
    -- Example 6 billboard
    confetti.newParticle(
        "leaf",
        player:getPos()+vec(0,math.random(),0),
        vec((math.random()-0.5)*0.2,math.random()*0.2,(math.random()-0.5)*0.2),
        {
            billboard = true,
            scale=0.5+math.random()*0.5
        }
    )
end

function example7()
    -- Example 7 sparks getting bigger
    confetti.newParticle(
        "spark",
        player:getPos()+vec(0,math.random(),0),
        vec((math.random()-0.5)*0.2,math.random()*0.2,(math.random()-0.5)*0.2),
        {
            scale=0,
            scaleOverTime=0.1,
            emissive=true
        }
    )
end

function example8()
    -- Example 8 sparks slowing down and getting smaller at the end
    confetti.newParticle(
        "spark",
        player:getPos()+vec(0,math.random(),0),
        vec((math.random()-0.5)*0.3,math.random()*0.3,(math.random()-0.5)*0.3),
        {
            emissive=true,
            friction=0.83,
            ticker=function(particle)
                confetti.defaultTicker(particle)
                -- some fancy math stuff to only scale it near the end of lifetime
                particle.scale = math.clamp(math.map(particle.lifetime, particle.options.lifetime, 2, 4, 0), 0, 1)
            end
        }
    )
end

-- Example 9 cloud of sparks following player
-- Note that this one is not in tick event because 
-- these particles will stick around permanently
function events.ENTITY_INIT()
    for _=0,30 do
        confetti.newParticle(
            "spark",
            player:getPos():add(0,1,0),
            vec((math.random()-0.5)*0.3,math.random()*0.3,(math.random()-0.5)*0.3),
            {
                emissive=true,
                friction=0.99, -- makes them slow down when you stand still for a while
                ticker=function(particle)
                    confetti.defaultTicker(particle)
                    -- this one is always active, so for the example switcher its visibility is being set here
                    particle.mesh:setVisible(example_9_currently_showing)
                    -- set lifetime to at least two all the time so they never disappear
                    particle.lifetime = 2
                    -- accelerate towards the player
                    particle.options.acceleration = (player:getPos():add(0,1,0)-particle.position):normalized()*0.05
                    particle.velocity = particle.velocity:normalized()*math.min(particle.velocity:length(), 0.8)
                end
            }
        )
    end
end

-- Code below just switches between the examples
local num_examples = 9
local t = 0
example = example - 1
example_9_currently_showing = false
function events.TICK()
    if t%time_each_example==0 then
        example = (example%num_examples)+1
        log("Showing example "..example)
    end
    t = t + 1
    example_9_currently_showing = example == 9
    if not example_9_currently_showing then
        _G["example"..example]()
    end
end