local page = action_wheel:newPage()
action_wheel:setPage(page)

local confetti = require("libs/Manuel_#confetti")

confetti.registerMesh("d4", models.dice.d4, 20*10)
confetti.registerMesh("d6", models.dice.d6, 20*10)
confetti.registerMesh("d8", models.dice.d8, 20*10)
confetti.registerMesh("d10", models.dice.d10, 20*10)
confetti.registerMesh("d12", models.dice.d12, 20*10)
confetti.registerMesh("d20", models.dice.d20, 20*10)
confetti.registerMesh("d100", models.dice.d100, 20*10)

function pings.spawnDie(n,pos,dir,r1,r2,r3)
    if not player:isLoaded() then return end
    confetti.newParticle('d'..tostring(n),
        pos,
        dir*0.2,
        {
            rotationOverTime=vec(r1*40,r2*40,r3*40),
            acceleration=vec(0,-0.04,0),
            scale=0.5,
            ticker=function(particle)
                confetti.defaultTicker(particle)
                local x,y,z = particle.velocity:unpack()
                if world.getBlockState(particle._position+vec(x,0,0)):isSolidBlock() or world.getBlockState(particle._position-vec(x,0,0)):isSolidBlock() then
                    particle.velocity.x = -x
                end
                if world.getBlockState(particle._position+vec(0,y-0.35,0)):isSolidBlock() or world.getBlockState(particle._position-vec(0,y+0.35,0)):isSolidBlock() then
                    particle.velocity.y = -y*0.5
                    if math.abs(particle.velocity.y) < 0.05 then particle.velocity.y = 0 end
                    particle.velocity.x = x*0.5
                    particle.velocity.z = z*0.5
                    particle.options.rotationOverTime = particle.options.rotationOverTime*0.7
                end
                if world.getBlockState(particle._position+vec(0,0,z)):isSolidBlock() or world.getBlockState(particle._position-vec(0,0,z)):isSolidBlock() then
                    particle.velocity.z = -z
                end
                particle.position = particle._position + particle.velocity
            end
        }
    )
end

page:newAction()
    :title("D4")
    :item("minecraft:white_wool")
    :onLeftClick(function()
        pings.spawnDie(4, player:getPos():add(0,player:getEyeHeight(),0), player:getLookDir(), math.random(), math.random(), math.random())
    end)

page:newAction()
    :title("D6")
    :item("minecraft:white_wool")
    :onLeftClick(function()
        pings.spawnDie(6, player:getPos():add(0,player:getEyeHeight(),0), player:getLookDir(), math.random(), math.random(), math.random())
    end)

page:newAction()
    :title("D8")
    :item("minecraft:white_wool")
    :onLeftClick(function()
        pings.spawnDie(8, player:getPos():add(0,player:getEyeHeight(),0), player:getLookDir(), math.random(), math.random(), math.random())
    end)

page:newAction()
    :title("D10")
    :item("minecraft:white_wool")
    :onLeftClick(function()
        pings.spawnDie(10, player:getPos():add(0,player:getEyeHeight(),0), player:getLookDir(), math.random(), math.random(), math.random())
    end)

page:newAction()
    :title("D12")
    :item("minecraft:white_wool")
    :onLeftClick(function()
        pings.spawnDie(12, player:getPos():add(0,player:getEyeHeight(),0), player:getLookDir(), math.random(), math.random(), math.random())
    end)

page:newAction()
    :title("D20")
    :item("minecraft:white_wool")
    :onLeftClick(function()
        pings.spawnDie(20, player:getPos():add(0,player:getEyeHeight(),0), player:getLookDir(), math.random(), math.random(), math.random())
    end)

page:newAction()
    :title("D100")
    :item("minecraft:white_wool")
    :onLeftClick(function()
        pings.spawnDie(10, player:getPos():add(-0.5,player:getEyeHeight(),0), player:getLookDir(), math.random(), math.random(), math.random())
        pings.spawnDie(100, player:getPos():add(0.5,player:getEyeHeight(),0), player:getLookDir(), math.random(), math.random(), math.random())
    end)
