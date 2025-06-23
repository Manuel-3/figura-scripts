vanilla_model.ALL:setVisible(false)
models:setPos(0,24,0)

local t = vec(0,0,0)

events.MOUSE_MOVE:register(function (x,y)
    t = t:add(x,0,y)
    t = ((t+180) % 360) - 180
end)



local rope = models.model:newPart("rope")
local startpos = vec(0,0,0)
events.ENTITY_INIT:register(function ()
    startpos = player:getPos()
    models.model.bone:setVisible(false)
    rope:setParentType("World")
    for i = 1, 30, 1 do
        models.model.bone:copy("a"):moveTo(rope)
        :setPos(player:getPos()*16)
        :setVisible(true)
    
    end
        
end)


-- Assuming a vector implementation exists, with common functionality.
-- Creating a rope with a series of points.
-- `vec(x, y, z)` is the vector constructor.

local GRAVITY = vec(0, -9.81, 0)  -- Gravity vector (points downward in the y-axis)

-- Rope simulation parameters
local NUM_POINTS = 20  -- Number of points in the rope
local REST_LENGTH = 2  -- The natural length of each segment
local SPRING_CONSTANT = 100  -- Stiffness of the spring
local DAMPING = 0.99  -- Damping factor to simulate friction (energy loss)
local TIME_STEP = 1/20  -- Time step for simulation (60 FPS)

-- Rope points (each with position and velocity)
local points = {}
local velocities = {}

-- Global fixed points (start and end positions)

local fixed_start = vec(0, 10, 0)  -- Fixed position for the start of the rope
local fixed_end = vec(5, 10, 0)    -- Fixed position for the end of the rope
events.ENTITY_INIT:register(function ()
    fixed_start = startpos+vec(3,math.sin(world.getTime()/8),3)
    fixed_end = startpos+vec(-3,math.sin(world.getTime()/8),3)
end)

-- Initialize rope points
for i = 1, NUM_POINTS do
    local t = (i - 1) / (NUM_POINTS - 1)
    local x = fixed_start.x + t * (fixed_end.x - fixed_start.x)
    local y = fixed_start.y + t * (fixed_end.y - fixed_start.y)
    local z = fixed_start.z + t * (fixed_end.z - fixed_start.z)
    points[i] = vec(x, y, z)
    velocities[i] = vec(0, 0, 0)  -- Initially at rest
end

-- Function to apply gravity to non-fixed points
local function apply_gravity()
    for i = 2, NUM_POINTS - 1 do  -- Skip the fixed points
        velocities[i] = velocities[i] + GRAVITY * TIME_STEP
    end
end

-- Function to apply spring forces between two points
local function apply_spring_forces()
    for i = 1, NUM_POINTS - 1 do
        local p1 = points[i]
        local p2 = points[i + 1]
        local v1 = velocities[i]
        local v2 = velocities[i + 1]

        local direction = p2 - p1
        local distance = direction:length()  -- Get the distance between points
        local force = direction:normalize() * (distance - REST_LENGTH) * SPRING_CONSTANT

        -- Apply force on both points (spring force between them)
        velocities[i] = velocities[i] + force * TIME_STEP
        velocities[i + 1] = velocities[i + 1] - force * TIME_STEP
    end
end

-- Function to apply damping (simulate friction or air resistance)
local function apply_damping()
    for i = 1, NUM_POINTS do
        if i ~= 1 and i ~= NUM_POINTS then  -- Skip fixed points
            velocities[i] = velocities[i] * DAMPING
        end
    end
end

-- Function to update positions based on velocities
local function update_positions()
    for i = 1, NUM_POINTS do
        if i ~= 1 and i ~= NUM_POINTS then  -- Skip fixed points
            points[i] = points[i] + velocities[i] * TIME_STEP
        end
    end
end

-- Function to resolve the rope's constraints (collisions, etc.)
local function resolve_constraints()
    -- For simplicity, we can just fix the positions of the endpoints here.
    points[1] = fixed_start
    points[NUM_POINTS] = fixed_end
end

local function simulate_rope()
    apply_gravity()            -- Apply gravity to the rope points
    apply_spring_forces()      -- Apply spring forces between connected points
    apply_damping()            -- Apply damping to the velocities
    update_positions()         -- Update the positions based on velocities
    resolve_constraints()      -- Ensure fixed endpoints stay in place
end


events.tick:register(function (delta)
    -- local t = world.getTime()
    -- log(t)

    -- models.model.piv.pivPXNZ:setRot(vec(t.x>=0 and t.z>=0 and t.x or 0, 0, t.x>=0 and t.z>=0 and t.z or 0))
    -- models.model.piv.pivPXNZ.pivNXNZ:setRot(t.x>=0 and t.z<0 and t.x or 0, 0, t.x>=0 and t.z<0 and t.z or 0)
    -- models.model.piv.pivPXNZ.pivNXNZ.pivPXPZ:setRot(t.x<0 and t.z>=0 and t.x or 0,0,t.x<0 and t.z>=0 and t.z or 0)
    -- models.model.piv.pivPXNZ.pivNXNZ.pivPXPZ.pivNXPZ:setRot(t.x<0 and t.z<0 and t.x or 0,0,t.x<0 and t.z<0 and t.z or 0)

    -- models.model.piv2.piv3:setRot(t)

    models.model.piv:setVisible(false)
    models.model.piv2:setVisible(false)

    
    simulate_rope()

    for k,v in ipairs(points) do
        rope:getChildren()[k]:setPos(v*16)
    end

    -- for i = 2, n do
    --     local current_point = points[i]:getPos()
    --     local prev_point = points[i - 1]:getPos()
    --     local delta = (current_point-prev_point)
    --     local distance = delta:length()
    --     local correction = (distance - restlen) / distance
    --     local correction_vector = scale(delta, correction * 0.5)

    --     -- Apply correction to both points
    --     points[i]:setPos((points[i]:getPos()+scale(correction_vector, -1)))
    --     points[i - 1]:setPos((points[i - 1]:getPos()+correction_vector))
    -- end

    -- for i=1,n do
    --     if i == 1 then
    --     elseif i == n then
    --     else
    --         local mypos = segs[i]:getPos()
    --         segs[i]:setPos(mypos+vec(0,-grav,0))
    --     end
    -- end
    -- for i=1,n do
    --     if i == 1 then
    --         segs[i]:setPos(player:getPos(delta)*16)
    --         segs[i]:setPos(anchor2*16)
    --     elseif i == n then
    --         segs[i]:setPos(anchor*16)
    --     else
    --         local mypos = segs[i]:getPos()
    --         local prevpos = segs[i-1]:getPos()
    --         local dir = (prevpos-mypos)
    --         if dir:length() > seglen then
    --             dir = dir:normalized()*(dir:length()-seglen)
    --             segs[i]:setPos(mypos+dir)
    --         end
    --     end
    -- end
    -- for i=n,1,-1 do
    --     if i == 1 then
    --     elseif i == n then
    --     else
    --         local mypos = segs[i]:getPos()
    --         local prevpos = segs[i+1]:getPos()
    --         local dir = (prevpos-mypos)
    --         if dir:length() > seglen then
    --             dir = dir:normalized()*(dir:length()-seglen)
    --             segs[i]:setPos(mypos+dir)
    --         end
    --     end
    -- end

end)