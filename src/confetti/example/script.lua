local confetti = require("confetti")

confetti.registerMesh("spark", models.model.Spark)
confetti.registerSprite("leaf", textures["mytexture"], vec(0,5,4,9), 30)

function events.TICK()    
    
    -- Example 1
    confetti.newParticle(
        "spark",
        player:getPos()+vec(0,math.random(),0),
        vec((math.random()-0.5)*0.3,math.random()*0.3,(math.random()-0.5)*0.3),
        {
            acceleration=vec(0,-0.04,0)
        }
    )

    -- Example 2
    confetti.newParticle(
        "leaf",
        player:getPos()+vec(math.random()*2-1,4,math.random()*2-1),
        vec((math.random()-0.5)*0.2,-math.random()*0.3,(math.random()-0.5)*0.2),
        {
            rotationOverTime=10+math.random()*5
        }
    )

    -- Example 3
    -- confetti.newParticle(
    --     "spark",
    --     player:getPos()+vec(0,math.random(),0),
    --     vec((math.random()-0.5)*0.3,math.random()*0.3,(math.random()-0.5)*0.3),
    --     {
    --         friction=0.83
    --     }
    -- )

    -- Example 4
    -- confetti.newParticle(
    --     "spark",
    --     player:getPos()+vec(0,math.random(),0),
    --     vec((math.random()-0.5)*0.0001,math.random()*0.0001,(math.random()-0.5)*0.0001),
    --     {
    --         rotationOverTime=30,
    --         acceleration=0.03
    --     }
    -- )

    -- Example 5
    -- confetti.newParticle("spark",player:getPos()+vec(0,math.random(),0),vec(0,0,0))

    -- Example 6
    -- confetti.newParticle(
    --     "leaf",
    --     player:getPos()+vec(0,math.random(),0),
    --     vec((math.random()-0.5)*0.2,math.random()*0.2,(math.random()-0.5)*0.2),
    --     {
    --         billboard = true,
    --         scale=0.5+math.random()*0.5
    --     }
    -- )

    -- Example 7
    -- confetti.newParticle(
    --     "spark",
    --     player:getPos()+vec(0,math.random(),0),
    --     vec((math.random()-0.5)*0.2,math.random()*0.2,(math.random()-0.5)*0.2),
    --     {
    --         scale=3,
    --         scaleOverTime=-0.2,
    --     }
    -- )

end

-- Example 8
-- local myparticles = {}
-- function events.ENTITY_INIT()
--     for _=0,20 do
--         table.insert(myparticles,confetti.newParticle(
--             "spark",
--             player:getPos():add(0,1,0),
--             vec((math.random()-0.5)*0.3,math.random()*0.3,(math.random()-0.5)*0.3)
--         ))
--     end
-- end
-- function events.TICK()
--     for _, particle in ipairs(myparticles) do
--         -- keep lifetime above 1
--         particle.lifetime = 2
--         -- accelerate towards player
--         particle.options.acceleration = (player:getPos():add(0,1,0)-particle.position):normalized()*0.05
--         -- set a maximum speed
--         particle.velocity = particle.velocity:normalized()*math.min(particle.velocity:length(), 0.8)
--     end
-- end
