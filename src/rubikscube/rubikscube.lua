-- Rubiks Cube by manuel_2867

-- Settings
---@class RubiksCubeSettings
local settings = {}
settings.scrambleDelay = 4
settings.autosolveDelay = 6
settings.vanillaModelPoses = true
settings.hideHeldItems = true
settings.disableWorldInteractions = true
settings.disableWalking = false
settings.flipLeftRightClick = true
settings.flipLeftRightOnTopFace = true
settings.flipLeftRightOnBottomFace = false
settings.invertCameraHorizontal = false
settings.invertCameraVertical = false
settings.cameraSensitivity = 0.3
settings.previewRightClickTurnDir = true
settings.smoothPreview = true
settings.previewAmountDegrees = 5
-- End Of Settings

---@class RubiksCube
---@field page Page
---@field goBackPage Page|string|nil
local export = {}
export.settings = settings

local yRotOffset = 0
local solvedState = true
local solveMode = false
local autosolving = false
local history = {}
local autosolveprogress = 1
local scrambling = false
local scramble = {}
local scrambleprogress = 1
local timing = false
local timer = 0
local actionWasSelected = false

-- Creates a rotation matrix for rotation around the X-axis
local function rotateX(theta)
    local rad = math.rad(theta)
    return {
        {1, 0, 0},
        {0, math.cos(rad), -math.sin(rad)},
        {0, math.sin(rad), math.cos(rad)}
    }
end

-- Creates a rotation matrix for rotation around the Y-axis
local function rotateY(theta)
    local rad = math.rad(theta)
    return {
        {math.cos(rad), 0, math.sin(rad)},
        {0, 1, 0},
        {-math.sin(rad), 0, math.cos(rad)}
    }
end

-- Creates a rotation matrix for rotation around the Z-axis
local function rotateZ(theta)
    local rad = math.rad(theta)
    return {
        {math.cos(rad), -math.sin(rad), 0},
        {math.sin(rad), math.cos(rad), 0},
        {0, 0, 1}
    }
end

-- Multiplies two 3x3 matrices
local function multiplyMatrices(a, b)
    local result = {}
    for i = 1, 3 do
        result[i] = {}
        for j = 1, 3 do
            result[i][j] = 0
            for k = 1, 3 do
                result[i][j] = result[i][j] + a[i][k] * b[k][j]
            end
        end
    end
    return result
end

-- Combines multiple rotation matrices
local function combineRotations(...)
    local result = {...}
    local combined = result[1]
    for i = 2, #result do
        combined = multiplyMatrices(combined, result[i])
    end
    return combined
end

-- Extract Euler angles from a rotation matrix
local function extractEulerAngles(matrix)
    local sy = math.sqrt(matrix[1][1] * matrix[1][1] + matrix[2][1] * matrix[2][1])
    local singular = sy < 1e-6

    local x, y, z

    if not singular then
        x = math.atan2(matrix[3][2], matrix[3][3])
        y = math.atan2(-matrix[3][1], sy)
        z = math.atan2(matrix[2][1], matrix[1][1])
    else
        x = math.atan2(-matrix[2][3], matrix[2][2])
        y = math.atan2(-matrix[3][1], sy)
        z = 0
    end

    return math.deg(x), math.deg(y), math.deg(z)
end

local function matrixToQuaternion(m)
    local tr = m[1][1] + m[2][2] + m[3][3]

    local qw, qx, qy, qz
    if tr > 0 then
        local S = math.sqrt(tr + 1.0) * 2
        qw = 0.25 * S
        qx = (m[3][2] - m[2][3]) / S
        qy = (m[1][3] - m[3][1]) / S
        qz = (m[2][1] - m[1][2]) / S
    elseif (m[1][1] > m[2][2]) and (m[1][1] > m[3][3]) then
        local S = math.sqrt(1.0 + m[1][1] - m[2][2] - m[3][3]) * 2
        qw = (m[3][2] - m[2][3]) / S
        qx = 0.25 * S
        qy = (m[1][2] + m[2][1]) / S
        qz = (m[1][3] + m[3][1]) / S
    elseif m[2][2] > m[3][3] then
        local S = math.sqrt(1.0 + m[2][2] - m[1][1] - m[3][3]) * 2
        qw = (m[1][3] - m[3][1]) / S
        qx = (m[1][2] + m[2][1]) / S
        qy = 0.25 * S
        qz = (m[2][3] + m[3][2]) / S
    else
        local S = math.sqrt(1.0 + m[3][3] - m[1][1] - m[2][2]) * 2
        qw = (m[2][1] - m[1][2]) / S
        qx = (m[1][3] + m[3][1]) / S
        qy = (m[2][3] + m[3][2]) / S
        qz = 0.25 * S
    end

    return {qw, qx, qy, qz}
end

local function slerp(q1, q2, t)
    local dot = q1[1] * q2[1] + q1[2] * q2[2] + q1[3] * q2[3] + q1[4] * q2[4]

    -- If the dot product is negative, SLERP won't take the shorter path.
    -- Note: q and -q are equivalent when applied to rotations.
    if dot < 0.0 then
        q2 = {-q2[1], -q2[2], -q2[3], -q2[4]}
        dot = -dot
    end

    if dot > 0.9995 then
        -- If the inputs are too close for comfort, linearly interpolate
        -- and normalize the result.
        local result = {
            q1[1] + t * (q2[1] - q1[1]),
            q1[2] + t * (q2[2] - q1[2]),
            q1[3] + t * (q2[3] - q1[3]),
            q1[4] + t * (q2[4] - q1[4])
        }
        local len = math.sqrt(result[1]^2 + result[2]^2 + result[3]^2 + result[4]^2)
        return {result[1] / len, result[2] / len, result[3] / len, result[4] / len}
    end

    local theta_0 = math.acos(dot)  -- theta_0 = angle between input vectors
    local sin_theta_0 = math.sqrt(1.0 - dot * dot)  -- compute sin(theta_0)
    
    local theta = theta_0 * t  -- theta = angle between q1 and result
    local sin_theta = math.sin(theta)  -- compute sin(theta)
    local sin_theta_1 = math.sin(theta_0 - theta)  -- compute sin(theta_0 - theta)

    local s1 = sin_theta_1 / sin_theta_0
    local s2 = sin_theta / sin_theta_0

    return {
        s1 * q1[1] + s2 * q2[1],
        s1 * q1[2] + s2 * q2[2],
        s1 * q1[3] + s2 * q2[3],
        s1 * q1[4] + s2 * q2[4]
    }
end

local function quaternionToMatrix(q)
    local qw, qx, qy, qz = table.unpack(q)

    return {
        {
            1 - 2*qy*qy - 2*qz*qz,
            2*qx*qy - 2*qz*qw,
            2*qx*qz + 2*qy*qw
        },
        {
            2*qx*qy + 2*qz*qw,
            1 - 2*qx*qx - 2*qz*qz,
            2*qy*qz - 2*qx*qw
        },
        {
            2*qx*qz - 2*qy*qw,
            2*qy*qz + 2*qx*qw,
            1 - 2*qx*qx - 2*qy*qy
        }
    }
end

local function interpolateMatrices(m1, m2, t)
    -- Convert matrices to quaternions
    local q1 = matrixToQuaternion(m1)
    local q2 = matrixToQuaternion(m2)
    
    -- Interpolate between quaternions
    local qInterp = slerp(q1, q2, t)
    
    -- Convert the result back to a rotation matrix
    return quaternionToMatrix(qInterp)
end

local pieces = models.rubikscube.Rubiks:getChildren()
local rotations = {}
local currentRotations = {}
local previousRotations = {}
local identity = {{1,0,0},{0,1,0},{0,0,1}}
for _, piece in pairs(pieces) do
    rotations[piece] = identity
    currentRotations[piece] = identity
    previousRotations[piece] = identity
end
local function configSave(key,value)
    local prevName = config:getName()
    config:setName("manuel_2867_rubikscube")
    config:save(key,value)
    config:setName(prevName)
end
local function configLoad(key)
    local prevName = config:getName()
    config:setName("manuel_2867_rubikscube")
    local ret = config:load(key)
    config:setName(prevName)
    return ret
end
local cube = {}
cube.m = {}
local logMoves = configLoad("logMoves")
local rubiksEnabled = configLoad("rubiksEnabled")
local distance = configLoad("distance")
local timerEnabled = configLoad("timerEnabled")
local cubeMode = configLoad("cubeMode")

local slicePieces = {1,2,3,4,5,6,7,8,9,11,13,15,17,18,20,22,24,26}
local cornerPieces = {10,12,14,16,19,21,23,25}
local function setCubeMode(x)
    cubeMode = x
    configSave("cubeMode", cubeMode)
    for _, i in ipairs(slicePieces) do
        pieces[i]:setVisible(not x)
    end
    for _, i in ipairs(cornerPieces) do
        pieces[i]:getChildren()[1]:setScale(x and 1.5 or 1)
    end
    models.rubikscube.Rubiks:setScale(x and 0.9 or 1)
end
setCubeMode(cubeMode or false)

local solvedCube, slices, switch, rearrange, isSolved, lookUpIdx, copyCube, toBinaryString, encode, formatTime, turn, slice, preview, rotateLocalYaw, rotatePitch
if host:isHost() then
    rotateLocalYaw = function(rotationMatrix, angle)
        local yawMatrix = rotateY(angle)
        return multiplyMatrices(rotationMatrix, yawMatrix)
    end
    rotatePitch = function(rotationMatrix, angle)
        -- Calculate the camera's right vector
        local rightDir = vec(0,1,0):cross(player:getLookDir())
    
        -- Create a rotation matrix around this right vector
        local c, s = math.cos(math.rad(angle)), math.sin(math.rad(angle))
        local pitchMatrix = {
            {c + rightDir[1]^2 * (1 - c), rightDir[1] * rightDir[2] * (1 - c) - rightDir[3] * s, rightDir[1] * rightDir[3] * (1 - c) + rightDir[2] * s},
            {rightDir[2] * rightDir[1] * (1 - c) + rightDir[3] * s, c + rightDir[2]^2 * (1 - c), rightDir[2] * rightDir[3] * (1 - c) - rightDir[1] * s},
            {rightDir[3] * rightDir[1] * (1 - c) - rightDir[2] * s, rightDir[3] * rightDir[2] * (1 - c) + rightDir[1] * s, c + rightDir[3]^2 * (1 - c)}
        }
    
        -- Apply pitch rotation
        return multiplyMatrices(pitchMatrix, rotationMatrix)
    end
    local function containsValue(tbl,value)
        for _, v in pairs(tbl) do
            if v == value then return true end
        end
        return false
    end
    preview = function(piece,side)
        if not solveMode or autosolving or scrambling or not containsValue(cube[side],lookUpIdx(piece)) then
            return identity
        end
        local flip = not export.settings.flipLeftRightClick
        if side=="yellow" and export.settings.flipLeftRightOnTopFace or side=="white" and export.settings.flipLeftRightOnBottomFace then
            flip = not flip
        end
        if side == "red" then
            return rotateX(flip and -export.settings.previewAmountDegrees or export.settings.previewAmountDegrees),rotations[piece]
        elseif side == "orange" then
            return rotateX(flip and export.settings.previewAmountDegrees or -export.settings.previewAmountDegrees),rotations[piece]
        elseif side == "blue" then
            return rotateZ(flip and -export.settings.previewAmountDegrees or export.settings.previewAmountDegrees),rotations[piece]
        elseif side == "green" then
            return rotateZ(flip and export.settings.previewAmountDegrees or -export.settings.previewAmountDegrees),rotations[piece]
        elseif side == "white" then
            return rotateY(flip and -export.settings.previewAmountDegrees or export.settings.previewAmountDegrees),rotations[piece]
        elseif side == "yellow" then
            return rotateY(flip and export.settings.previewAmountDegrees or -export.settings.previewAmountDegrees),rotations[piece]
        end
    end
    slice = function(side,prime)
        if logMoves then
            logJson(toJson{text=(string.upper(string.sub(side,1,1))).."M"..(prime and "'" or ""),color=(side=="orange" and "#ff8800" or side)})
        end
        if not autosolving then
            table.insert(history, {side=side,prime=prime,m=true})
        end
        local changedPieces = {}
        for _, i in ipairs(cube.m[side]) do
            local piece = pieces[i]
            if side == "red" then
                rotations[piece] = multiplyMatrices(rotateX(prime and -90 or 90),rotations[piece])
            elseif side == "orange" then
                rotations[piece] = multiplyMatrices(rotateX(prime and 90 or -90),rotations[piece])
            elseif side == "blue" then
                rotations[piece] = multiplyMatrices(rotateZ(prime and -90 or 90),rotations[piece])
            elseif side == "green" then
                rotations[piece] = multiplyMatrices(rotateZ(prime and 90 or -90),rotations[piece])
            elseif side == "white" then
                rotations[piece] = multiplyMatrices(rotateY(prime and -90 or 90),rotations[piece])
            elseif side == "yellow" then
                rotations[piece] = multiplyMatrices(rotateY(prime and 90 or -90),rotations[piece])
            end
            changedPieces[lookUpIdx(piece)] = rotations[piece]
        end
        rearrange(side,prime,true)
        pings.manuel_2867_rubikscube_update(encode(changedPieces))
    end
    turn = function(side,prime)
        if logMoves then
            logJson(toJson{text=(string.upper(string.sub(side,1,1)))..(prime and "'" or ""),color=(side=="orange" and "#ff8800" or side)})
        end
        if not autosolving then
            table.insert(history, {side=side,prime=prime,m=false})
        end
        local changedPieces = {}
        for _, i in ipairs(cube[side]) do
            local piece = pieces[i]
            if side == "red" then
                rotations[piece] = multiplyMatrices(rotateX(prime and -90 or 90),rotations[piece])
            elseif side == "orange" then
                rotations[piece] = multiplyMatrices(rotateX(prime and 90 or -90),rotations[piece])
            elseif side == "blue" then
                rotations[piece] = multiplyMatrices(rotateZ(prime and -90 or 90),rotations[piece])
            elseif side == "green" then
                rotations[piece] = multiplyMatrices(rotateZ(prime and 90 or -90),rotations[piece])
            elseif side == "white" then
                rotations[piece] = multiplyMatrices(rotateY(prime and -90 or 90),rotations[piece])
            elseif side == "yellow" then
                rotations[piece] = multiplyMatrices(rotateY(prime and 90 or -90),rotations[piece])
            end
            changedPieces[lookUpIdx(piece)] = rotations[piece]
        end
        rearrange(side,prime,false)
        pings.manuel_2867_rubikscube_update(encode(changedPieces))
    end
    formatTime = function(ticks)
        local totalSeconds = ticks / 20
        local minutes = math.floor((totalSeconds % 3600) / 60)
        local seconds = totalSeconds % 60
        return string.format("%02d:%05.2f", minutes, seconds)
    end
    toBinaryString = function(num)
        local binaryString = ""
        repeat
            local bit = num % 2
            binaryString = bit .. binaryString
            num = math.floor(num / 2)
        until num == 0
        return binaryString
    end
    copyCube = function(c)
        local ret = {}
        for key, value in pairs(c) do
            if key == "m" then
                ret.m = copyCube(c.m)
            else
                ret[key] = {}
                for i = 1, #value do
                    ret[key][i] = value[i]
                end
            end
        end
        return ret
    end
    if logMoves == nil then
        logMoves = true
        configSave("logMoves",logMoves)
    end
    if rubiksEnabled == nil then
        rubiksEnabled = false
        configSave("rubiksEnabled",rubiksEnabled)
    end
    if distance == nil then
        distance = 1
        configSave("distance",distance)
    end
    if timerEnabled == nil then
        timerEnabled = true
        configSave("timerEnabled",timerEnabled)
    end
    cube.blue = {10, 11, 12, 1, 2, 3, 19, 20, 21}
    cube.red = {12, 13, 14, 3, 4, 5, 21, 22, 23}
    cube.green = {14, 15, 16, 5, 6, 7, 23, 24, 25}
    cube.orange = {16, 9, 10, 7, 26, 1, 25, 18, 19}
    cube.yellow = {16, 15, 14, 9, 8, 13, 10, 11, 12}
    cube.white = {19, 20, 21, 18, 17, 22, 25, 24, 23}
    cube.m.blue = {9,8,13,4,22,17,18,26}
    cube.m.green = cube.m.blue
    cube.m.red = {11,8,15,6,24,17,20,2}
    cube.m.orange = cube.m.red
    cube.m.white = {1,2,3,4,5,6,7,26}
    cube.m.yellow = cube.m.white

    local pairslist = {}
    for side, pieces in pairs(cube) do
        if side ~= "m" then
            for index, value in ipairs(pieces) do
                for otherside, otherpieces in pairs(cube) do
                    if otherside ~= "m" then
                        for otherindex, othervalue in ipairs(otherpieces) do
                            if value==othervalue then
                                pairslist[#pairslist+1] = {{side,index},{otherside,otherindex}}
                            end
                        end
                    else
                        for otherside2,otherpieces2 in pairs(otherpieces) do
                            for otherindex2, othervalue2 in ipairs(otherpieces2) do
                                if value==othervalue2 then
                                    pairslist[#pairslist+1] = {{side,index},{otherside2,otherindex2,"M"}}
                                end
                            end
                        end
                    end
                end
            end
        else
            for side, pieces2 in pairs(pieces) do
                for index, value in ipairs(pieces2) do
                    for otherside, otherpieces in pairs(cube) do
                        if otherside ~= "m" then
                            for otherindex, othervalue in ipairs(otherpieces) do
                                if value==othervalue then
                                    pairslist[#pairslist+1] = {{side,index,"M"},{otherside,otherindex}}
                                end
                            end
                        else
                            for otherside2,otherpieces2 in pairs(otherpieces) do
                                for otherindex2, othervalue2 in ipairs(otherpieces2) do
                                    if value==othervalue2 then
                                        pairslist[#pairslist+1] = {{side,index,"M"},{otherside2,otherindex2,"M"}}
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    events.TICK:register(function ()
        for _, pair in ipairs(pairslist) do
            if pair[1][3] == "M" and pair[2][3] == "M" then
                if cube.m[pair[1][1]][pair[1][2]] ~= cube.m[pair[2][1]][pair[2][2]] then
                    log("Mismatch",pair[1][1].."M"..pair[1][2],pair[2][1].."M"..pair[2][2])
                end
            elseif pair[1][3] == "M" then
                if cube.m[pair[1][1]][pair[1][2]] ~= cube[pair[2][1]][pair[2][2]] then
                    log("Mismatch",pair[1][1].."M"..pair[1][2],pair[2][1]..pair[2][2])
                end
            elseif pair[2][3] == "M" then
                if cube[pair[1][1]][pair[1][2]] ~= cube.m[pair[2][1]][pair[2][2]] then
                    log("Mismatch",pair[1][1]..pair[1][2],pair[2][1].."M"..pair[2][2])
                end
            else
                if cube[pair[1][1]][pair[1][2]] ~= cube[pair[2][1]][pair[2][2]] then
                    log("Mismatch",pair[1][1]..pair[1][2],pair[2][1]..pair[2][2])
                end
            end
        end
    end)

    local mblue = function(fullold)
        cube.yellow[4] = fullold.orange[8]
        cube.yellow[5] = fullold.orange[5]
        cube.yellow[6] = fullold.orange[2]
        cube.orange[8] = fullold.white[6]
        cube.orange[5] = fullold.white[5]
        cube.orange[2] = fullold.white[4]
        cube.white[6] = fullold.red[2]
        cube.white[5] = fullold.red[5]
        cube.white[4] = fullold.red[8]
        cube.red[2] = fullold.yellow[4]
        cube.red[5] = fullold.yellow[5]
        cube.red[8] = fullold.yellow[6]
        cube.m.red[2] = fullold.m.blue[8]
        cube.m.red[6] = fullold.m.blue[4]
        cube.m.white[4] = fullold.m.blue[2]
        cube.m.white[8] = fullold.m.blue[6]
        cube.m.orange = cube.m.red
        cube.m.yellow = cube.m.white
    end
    local mred = function(fullold)
        cube.yellow[2] = fullold.blue[2]
        cube.yellow[5] = fullold.blue[5]
        cube.yellow[8] = fullold.blue[8]
        cube.blue[2] = fullold.white[2]
        cube.blue[5] = fullold.white[5]
        cube.blue[8] = fullold.white[8]
        cube.white[2] = fullold.green[8]
        cube.white[5] = fullold.green[5]
        cube.white[8] = fullold.green[2]
        cube.green[8] = fullold.yellow[2]
        cube.green[5] = fullold.yellow[5]
        cube.green[2] = fullold.yellow[8]

        cube.m.blue[2] = fullold.m.red[8]
        cube.m.blue[6] = fullold.m.red[4]
        cube.m.white[2] = fullold.m.red[6]
        cube.m.white[6] = fullold.m.red[2]
        cube.m.green = cube.m.blue
        cube.m.yellow = cube.m.white
    end
    local mwhite = function(fullold)
        cube.blue[4] = fullold.orange[4]
        cube.blue[5] = fullold.orange[5]
        cube.blue[6] = fullold.orange[6]
        cube.orange[4] = fullold.green[4]
        cube.orange[5] = fullold.green[5]
        cube.orange[6] = fullold.green[6]
        cube.green[4] = fullold.red[4]
        cube.green[5] = fullold.red[5]
        cube.green[6] = fullold.red[6]
        cube.red[4] = fullold.blue[4]
        cube.red[5] = fullold.blue[5]
        cube.red[6] = fullold.blue[6]

        cube.m.red[4] = fullold.m.white[4]
        cube.m.red[8] = fullold.m.white[8]
        cube.m.blue[4] = fullold.m.white[2]
        cube.m.blue[8] = fullold.m.white[6]
        cube.m.orange = cube.m.red
        cube.m.green = cube.m.blue
    end

    slices = {
        ["blue"] = mblue,
        ["red"] = mred,
        ["green"] = mblue,
        ["orange"] = mred,
        ["yellow"] = mwhite,
        ["white"] = mwhite,
    }

    solvedCube = copyCube(cube)
    switch = {
        ["blue"] = function(old)
            cube.orange[3] = old[7]
            cube.orange[6] = old[8]
            cube.orange[9] = old[9]
            cube.red[1] = old[1]
            cube.red[4] = old[2]
            cube.red[7] = old[3]
            cube.yellow[7] = old[7]
            cube.yellow[8] = old[4]
            cube.yellow[9] = old[1]
            cube.white[1] = old[9]
            cube.white[2] = old[6]
            cube.white[3] = old[3]
            cube.m.red[1] = old[4]
            cube.m.red[7] = old[6]
            cube.m.white[1] = old[8]
            cube.m.white[3] = old[2]
            cube.m.orange = cube.m.red
            cube.m.yellow = cube.m.white
        end,
        ["red"] = function(old)
            cube.blue[3] = old[7]
            cube.blue[6] = old[8]
            cube.blue[9] = old[9]
            cube.green[1] = old[1]
            cube.green[4] = old[2]
            cube.green[7] = old[3]
            cube.yellow[3] = old[1]
            cube.yellow[6] = old[4]
            cube.yellow[9] = old[7]
            cube.white[3] = old[9]
            cube.white[6] = old[6]
            cube.white[9] = old[3]
            cube.m.blue[3] = old[4]
            cube.m.blue[5] = old[6]
            cube.m.white[3] = old[8]
            cube.m.white[5] = old[2]
            cube.m.green = cube.m.blue
            cube.m.yellow = cube.m.white
        end,
        ["green"] = function(old)
            cube.red[3] = old[7]
            cube.red[6] = old[8]
            cube.red[9] = old[9]
            cube.orange[1] = old[1]
            cube.orange[4] = old[2]
            cube.orange[7] = old[3]
            cube.yellow[1] = old[1]
            cube.yellow[2] = old[4]
            cube.yellow[3] = old[7]
            cube.white[7] = old[3]
            cube.white[8] = old[6]
            cube.white[9] = old[9]
            cube.m.red[3] = old[4]
            cube.m.red[5] = old[6]
            cube.m.white[5] = old[8]
            cube.m.white[7] = old[2]
            cube.m.orange = cube.m.red
            cube.m.yellow = cube.m.white
        end,
        ["orange"] = function(old)
            cube.green[3] = old[7]
            cube.green[6] = old[8]
            cube.green[9] = old[9]
            cube.blue[1] = old[1]
            cube.blue[4] = old[2]
            cube.blue[7] = old[3]
            cube.yellow[1] = old[7]
            cube.yellow[4] = old[4]
            cube.yellow[7] = old[1]
            cube.white[1] = old[3]
            cube.white[4] = old[6]
            cube.white[7] = old[9]
            cube.m.blue[1] = old[4]
            cube.m.blue[7] = old[6]
            cube.m.white[7] = old[8]
            cube.m.white[1] = old[2]
            cube.m.green = cube.m.blue
            cube.m.yellow = cube.m.white
        end,
        ["yellow"] = function(old)
            cube.orange[1] = old[7]
            cube.orange[2] = old[8]
            cube.orange[3] = old[9]
            cube.red[1] = old[3]
            cube.red[2] = old[2]
            cube.red[3] = old[1]
            cube.blue[1] = old[9]
            cube.blue[2] = old[6]
            cube.blue[3] = old[3]
            cube.green[1] = old[1]
            cube.green[2] = old[4]
            cube.green[3] = old[7]
            cube.m.red[1] = old[6]
            cube.m.red[3] = old[4]
            cube.m.blue[1] = old[8]
            cube.m.blue[3] = old[2]
            cube.m.orange = cube.m.red
            cube.m.green = cube.m.blue
        end,
        ["white"] = function(old)
            cube.orange[7] = old[9]
            cube.orange[8] = old[8]
            cube.orange[9] = old[7]
            cube.red[7] = old[1]
            cube.red[8] = old[2]
            cube.red[9] = old[3]
            cube.blue[7] = old[7]
            cube.blue[8] = old[4]
            cube.blue[9] = old[1]
            cube.green[7] = old[3]
            cube.green[8] = old[6]
            cube.green[9] = old[9]
            cube.m.red[7] = old[4]
            cube.m.red[5] = old[6]
            cube.m.blue[7] = old[8]
            cube.m.blue[5] = old[2]
            cube.m.orange = cube.m.red
            cube.m.green = cube.m.blue
        end
    }
    local slicePiecesOnSideId = {2,4,5,6,8}
    isSolved = function()
        for piece, value in pairs(rotations) do
            local idx = lookUpIdx(piece)
            if cubeMode and not containsValue(slicePieces,idx) or not cubeMode then
                if idx ~= 2 and idx ~= 4 and idx ~= 6 and idx ~= 8 and idx ~= 17 and idx ~= 26 then
                    local x,y,z = extractEulerAngles(value)
                    if math.round(x) ~= 0 or math.round(y) ~= 0 or math.round(z) ~= 0 then
                        return false
                    end
                end
            end
        end
        for side, contents in pairs(solvedCube) do
            for i = 1, 9 do
                if cubeMode and not containsValue(slicePiecesOnSideId,i) or not cubeMode then
                    if cube[side][i] ~= contents[i] then
                        return false
                    end
                end
            end
        end
        return true
    end
    local opposite = {
        ["blue"] = "green",
        ["red"] = "orange",
        ["white"] = "yellow",
        ["green"] = "blue",
        ["orange"] = "red",
        ["yellow"] = "white",
    }
    rearrange = function(side,prime,m)
        local repeats = prime and 3 or 1
        if m and (side=="orange" or side=="green" or side=="yellow") then
            repeats = prime and 1 or 3
        end
        for _ = 1,repeats do
            if m then
                local old = cube.m[side]
                slices[side](copyCube(cube))
                cube.m[side] = {}
                cube.m[side][1] = old[7]
                cube.m[side][2] = old[8]
                cube.m[side][3] = old[1]
                cube.m[side][4] = old[2]
                cube.m[side][5] = old[3]
                cube.m[side][6] = old[4]
                cube.m[side][7] = old[5]
                cube.m[side][8] = old[6]
                cube.m[opposite[side]] = cube.m[side]
            else
                local old = cube[side]
                cube[side] = {}
                cube[side][1] = old[7]
                cube[side][2] = old[4]
                cube[side][3] = old[1]
                cube[side][4] = old[8]
                cube[side][5] = old[5]
                cube[side][6] = old[2]
                cube[side][7] = old[9]
                cube[side][8] = old[6]
                cube[side][9] = old[3]
                switch[side](old)
            end
        end
    end
    lookUpIdx = function(piece)
        for idx, cur in ipairs(pieces) do
            if piece == cur then
                return idx
            end
        end
    end
    encode = function(pieces)
        local data = {}
        for idx, mat in pairs(pieces) do
            local bits = 0
            bits = bit32.bor(bits,bit32.lshift(idx,18))
            bits = bit32.bor(bits,bit32.lshift(bit32.band(mat[1][1],3),16))
            bits = bit32.bor(bits,bit32.lshift(bit32.band(mat[1][2],3),14))
            bits = bit32.bor(bits,bit32.lshift(bit32.band(mat[1][3],3),12))
            bits = bit32.bor(bits,bit32.lshift(bit32.band(mat[2][1],3),10))
            bits = bit32.bor(bits,bit32.lshift(bit32.band(mat[2][2],3),8))
            bits = bit32.bor(bits,bit32.lshift(bit32.band(mat[2][3],3),6))
            bits = bit32.bor(bits,bit32.lshift(bit32.band(mat[3][1],3),4))
            bits = bit32.bor(bits,bit32.lshift(bit32.band(mat[3][2],3),2))
            bits = bit32.bor(bits,bit32.band(mat[3][3],3))
            data[#data+1] = bits
        end
        return table.unpack(data)
    end
end

local queue = {}

function pings.manuel_2867_rubikscube_update(...)
    if host:isHost() then return end
    if #{...} == 10 then
        error({...})
    end
    queue[#queue+1] = {data={...},i=1,temp={}}
end

local rubiksrotationmatrix = {{1,0,0},{0,1,0},{0,0,1}}
local anchor = models:newPart("rubikscube_anchor_point")
local selected = "blue"
models.rubikscube.Rubiks:setParentType("World")

function pings.manuel_2867_rubikscube_updateRotation(rot,offset)
    if not host:isHost() then
        yRotOffset = offset
        rubiksrotationmatrix = rot
    end
end

local faceNormals = {
    {name = "blue", normal = {0, 0, 1}},
    {name = "green", normal = {0, 0, -1}},
    {name = "orange", normal = {-1, 0, 0}},
    {name = "red", normal = {1, 0, 0}},
    {name = "white", normal = {0, 1, 0}},
    {name = "yellow", normal = {0, -1, 0}},
}
local function applyRotation(rotationMatrix, vector)
    local x = rotationMatrix[1][1] * vector[1] + rotationMatrix[1][2] * vector[2] + rotationMatrix[1][3] * vector[3]
    local y = rotationMatrix[2][1] * vector[1] + rotationMatrix[2][2] * vector[2] + rotationMatrix[2][3] * vector[3]
    local z = rotationMatrix[3][1] * vector[1] + rotationMatrix[3][2] * vector[2] + rotationMatrix[3][3] * vector[3]
    return {x, y, z}
end
local function dotProduct(v1, v2)
    return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
end
local function getVisibleFace(rotationMatrix)
    local maxDot = -math.huge
    local visibleFace = nil
    
    for _, face in ipairs(faceNormals) do
        -- Rotate the face normal
        local rotatedNormal = applyRotation(rotationMatrix, face.normal)
        
        -- Compute dot product with the camera's forward vector
        local dot = dotProduct(rotatedNormal, player:getLookDir())
        
        -- Check if this face is the most aligned with the camera
        if dot > maxDot then
            maxDot = dot
            visibleFace = face.name
        end
    end
    
    return visibleFace
end

local function goBack()
    if export.goBackPage then
        action_wheel:setPage(export.goBackPage)
    end
end

local page = action_wheel:newPage("Rubiks Cube")
export.page = page

local solveModeAction = page:newAction()
    :title("Toggle Solve Mode")
    :item("minecraft:lever")
    :toggleItem("minecraft:redstone_torch")
    :toggleColor(0,0,0)
    :onToggle(function(x)
        actionWasSelected = true
        solveMode = x
        if player:isLoaded() then
            pings.manuel_2867_rubikscube_updateRotation(rubiksrotationmatrix, player:getRot().y)
        end
        if solveMode then
            rubiksrotationmatrix = multiplyMatrices(rotateY(yRotOffset-player:getRot().y),rubiksrotationmatrix)
            if player:isLoaded() then
                yRotOffset = player:getRot().y
            end
        end
    end)
    :toggled(solveMode)

function pings.manuel_2867_rubikscube_enabled(x)
    rubiksEnabled = x
end

function pings.manuel_2867_rubikscube_reset()
    if host:isHost() then return end
    for _, piece in ipairs(pieces) do
        rotations[piece] = identity
        currentRotations[piece] = identity
        previousRotations = identity
    end
end

if host:isHost() then
    local enabledAction = page:newAction()
        :title("Toggle Rubiks Cube")
        :item([==[minecraft:player_head{SkullOwner:{Id:"",Properties:{textures:[{Value:"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYzdlMmFhNzlmYzYyZmE0ZjVhODkxOWYzZGQwZjEyYWIzNWUyZDMwZjhlMjM0YmZlYTg5NmM0ZWYzMWVlZTNkYiJ9fX0="}]}}}]==])
        :toggleColor(0,0,0)
        :onToggle(function(x)
            actionWasSelected = true
            rubiksEnabled = x
            configSave("rubiksEnabled", x)
            pings.manuel_2867_rubikscube_enabled(x)
        end)
        :toggled(rubiksEnabled)

    local scrambleAction = page:newAction()
        :title("Scramble")
        :item([==[minecraft:player_head{SkullOwner:{Id:"",Properties:{textures:[{Value:"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMmY2ZDMwOWM1Yjc4ZTBiZDQ3MTZkNWY1OTcyNGZkM2U3MDU3NGI2MjE1YWQwOTBlNWVkMjY3MzlkZGJhMDcxNCJ9fX0="}]}}}]==])
        :toggleColor(0,0,0)
        :onLeftClick(function()
            actionWasSelected = true
            if autosolving then return end
            pings.manuel_2867_rubikscube_reset()
            cube = copyCube(solvedCube)
            for _, piece in ipairs(pieces) do
                piece:setRot(0,0,0)
                rotations[piece] = identity
                currentRotations[piece] = identity
                previousRotations[piece] = identity
            end
            timing = false
            timer = 0
            scramble = {}
            history = {}
            for _ = 1, 25 do
                table.insert(scramble,{side=faceNormals[math.random(#faceNormals)].name,prime=math.random(2)==1})
            end
            scrambling = true
            scrambleprogress = 1
        end)

    local autosolveAction = page:newAction()
        :title("Auto Solve (Reverse)")
        :item([==[minecraft:player_head{SkullOwner:{Id:"",Properties:{textures:[{Value:"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvODk5Zjg4MmI0ZWNjYTRhMzcyNjkyYTdhZTFjZDA4YmRmMzQwNzAwMzM3MjQwZDAwNDE5MTY4NTg4ZDk4YmI3NSJ9fX0="}]}}}]==])
        :toggleColor(0,0,0)
        :onLeftClick(function()
            actionWasSelected = true
            if scrambling then return end
            timing = false
            timer = 0
            if #history >= 1 then
                autosolving = true
                autosolveprogress = #history
            end
        end)

    local logMovesAction = page:newAction()
        :title("Log Moves (Off)")
        :toggleTitle("Log Moves (On)")
        :item("minecraft:stripped_oak_log")
        :toggleItem("minecraft:oak_log")
        :toggleColor(0,0,0)
        :onToggle(function(x)
            actionWasSelected = true
            logMoves = x
            configSave("logMoves", x)
        end)
        :toggled(logMoves)

    local spyglass = textures:fromVanilla("spyglass","minecraft:textures/item/spyglass.png")
    local distanceAction distanceAction = page:newAction()
        :title("Distance "..distance.." (Scroll)")
        :item("minecraft:spyglass")
        :hoverItem("minecraft:air")
        :hoverTexture(spyglass,0,0,spyglass:getDimensions().x,spyglass:getDimensions().y,2-distance)
        :onScroll(function(x)
            actionWasSelected = true
            distance = distance + x*0.05
            distanceAction:title("Distance "..distance.." (Scroll)"):hoverTexture(spyglass,0,0,spyglass:getDimensions().x,spyglass:getDimensions().y,2-distance)
            configSave("distance", distance)
        end)
    local timerEnabledActionCounter = timerEnabled and 0 or 32
    local timerEnabledAction = page:newAction()
        :title("Timer (Off)")
        :toggleTitle("Timer (On)")
        :toggleColor(0,0,0)
        :onToggle(function(x)
            actionWasSelected = true
            timerEnabled = x
            timing = false
            timer = 0
            configSave("timerEnabled", x)
        end)
        :toggled(timerEnabled)

    local timerEnabledActionTextures = {}
    for i = 0, 32 do
        timerEnabledActionTextures[i] = textures:fromVanilla("clock"..i,"minecraft:textures/item/clock_"..string.format("%02d", i)..".png")
    end

    local showTimesAction = page:newAction()
        :title("Show Solve Times")
        :item("minecraft:writable_book")
        :toggleColor(0,0,0)
        :onLeftClick(function()
            actionWasSelected = true
            local times = configLoad("times")
            if times == nil then times = {} end
            local pb = math.huge
            local j = 0
            for i, entry in ipairs(times) do
                if entry.amount < pb then
                    pb = entry.amount
                    j = i
                end
            end
            local resave = false
            local prevDate = ""
            for i, entry in ipairs(times) do
                local date = string.sub(entry.date, 1, string.find(entry.date, " ") - 1)
                local time = string.sub(entry.date, string.find(entry.date, " ") + 1)
                if entry.mode == nil then
                    entry.mode = "3x3"
                    resave = true
                end
                logJson(toJson{
                    {text=date.." ",color=(prevDate ~= date) and "white" or "gray"},
                    {text=time,color="gray"},
                    {text=" => ", color="gray"},
                    {text=formatTime(entry.amount), color=(j==i and "gold" or "yellow")},
                    {text=" - ", color="gray"},
                    {text=entry.mode.."\n", color=(entry.mode=="3x3" and "green" or "aqua")}
                })
                prevDate = date
            end
            if resave then 
                configSave("times",times)
            end
        end)

    function pings.manuel_2867_rubikscube_mode(x)
        setCubeMode(x)
    end

    local switchCubeAction = page:newAction()
        :title("Switch to 2x2")
        :toggleTitle("Switch to 3x3")
        :item("minecraft:light_blue_wool")
        :toggleItem("minecraft:lime_wool")
        :toggleColor(0,0,0)
        :onToggle(function(x)
            actionWasSelected = true
            pings.manuel_2867_rubikscube_mode(x)
        end)

    local action_wheel_wasEnabled = false
    local wasOnPage = false

    function events.TICK()
        if wasOnPage and action_wheel_wasEnabled and not action_wheel:isEnabled() then
            if not actionWasSelected then
                goBack()
            end
            actionWasSelected = false
        end
        wasOnPage = action_wheel:getCurrentPage()==page
        action_wheel_wasEnabled = action_wheel:isEnabled()
        timerEnabledActionCounter = math.round(math.lerp(timerEnabledActionCounter,timerEnabled and 0 or 32, 0.3))
        timerEnabledAction:texture(timerEnabledActionTextures[timerEnabledActionCounter])
        if timerEnabled then
            if timing then
                timer = timer + 1
            end
            if rubiksEnabled then
                host:setActionbar(formatTime(timer))
            end
        end
        if player:getNbt()["HurtTime"] > 0 then
            solveMode = false
            solveModeAction:toggled(false)
        end
        if world.getTime() % (20*5) == 0 then
            pings.manuel_2867_rubikscube_enabled(rubiksEnabled)
            pings.manuel_2867_rubikscube_mode(cubeMode)
        end
        if rubiksEnabled and solveMode and world.getTime() % (20*0.5) == 0 then
            pings.manuel_2867_rubikscube_updateRotation(rubiksrotationmatrix, player:getRot().y)
        end
        if scrambling and world.getTime()%export.settings.scrambleDelay==0 then
            turn(scramble[scrambleprogress].side, scramble[scrambleprogress].prime)
            scrambleprogress = scrambleprogress + 1
            if scrambleprogress > #scramble then
                scrambling = false
            end
        end
        if autosolving and world.getTime()%export.settings.autosolveDelay==0 then
            if history[autosolveprogress].m then
                slice(history[autosolveprogress].side, not history[autosolveprogress].prime)
            else
                turn(history[autosolveprogress].side, not history[autosolveprogress].prime)
            end
            history[autosolveprogress] = nil
            autosolveprogress = autosolveprogress - 1
            if autosolveprogress < 1 then
                autosolving = false
                solvedState = true
                if logMoves then
                    logJson(toJson{text="\nSolved!",color="white"})
                end
            end
        end
    end

    function events.ENTITY_INIT()
        if action_wheel:getCurrentPage() == nil then
            action_wheel:setPage(page)
        end
    end
    
    function events.MOUSE_MOVE(x,y)
        if not rubiksEnabled then return end
        if solveMode then
            -- Convert delta to angles based on sensitivity
            local yawAngle = x * export.settings.cameraSensitivity * (export.settings.invertCameraHorizontal and -1 or 1)
            local pitchAngle = y * export.settings.cameraSensitivity * (export.settings.invertCameraVertical and 1 or -1)
    
            -- Apply yaw rotation
            rubiksrotationmatrix = rotateLocalYaw(rubiksrotationmatrix, yawAngle)
    
            -- Apply pitch rotation (around the camera's perpendicular axis)
            rubiksrotationmatrix = rotatePitch(rubiksrotationmatrix, pitchAngle)

            
            selected = getVisibleFace(rubiksrotationmatrix)
        end
        return solveMode
    end
    
    local function whenSolved()
        history = {}
        if logMoves then
            logJson(toJson{text="\nSolved!",color="white"})
        end
        solveMode = false
        solveModeAction:toggled(false)
        if timerEnabled then
            timing = false
            local times = configLoad("times")
            if times == nil then times = {} end
            local date = client.getDate()
            table.insert(times, {date=date.month.."/"..date.day.."/"..date.year.." "..string.format("%02d", date.hour)..":"..string.format("%02d", date.minute)..":"..string.format("%02d", date.second),amount=timer,mode=cubeMode and "2x2" or "3x3"})
            configSave("times",times)
        end
    end
    
    keybinds:newKeybind("Rubiks Unturn", "key.mouse.left"):onPress(function()
        local wasSolveMode = solveMode
        if not (rubiksEnabled and solveMode and not scrambling and not autosolving) then return false end
        if not timing then
            timing = true
            timer = 0
        end
        local prime = export.settings.flipLeftRightClick
        if selected=="yellow" and export.settings.flipLeftRightOnTopFace or selected=="white" and export.settings.flipLeftRightOnBottomFace then
            prime = not prime
        end
        turn(selected,prime)
        solvedState = isSolved()
        if solvedState then
            whenSolved()
        end
        return export.settings.disableWorldInteractions and wasSolveMode
    end)
    
    keybinds:newKeybind("Rubiks Turn","key.mouse.right"):onPress(function()
        local wasSolveMode = solveMode
        if not (rubiksEnabled and solveMode and not scrambling and not autosolving) then return false end
        if not timing then
            timing = true
            timer = 0
        end
        local prime = export.settings.flipLeftRightClick
        if selected=="yellow" and export.settings.flipLeftRightOnTopFace or selected=="white" and export.settings.flipLeftRightOnBottomFace then
            prime = not prime
        end
        turn(selected,not prime)
        solvedState = isSolved()
        if solvedState then
            whenSolved()
        end
        return export.settings.disableWorldInteractions and wasSolveMode
    end)

    --[[
    function events.MOUSE_SCROLL(dir)
        
        local wasSolveMode = solveMode
        if not (rubiksEnabled and solveMode and not scrambling and not autosolving) then return false end
        if not timing then
            timing = true
            timer = 0
        end
        local prime = export.settings.flipLeftRightClick
        if selected=="yellow" and export.settings.flipLeftRightOnTopFace or selected=="white" and export.settings.flipLeftRightOnBottomFace then
            prime = not prime
        end
        if dir == -1 then
            prime = not prime
        end
        slice(selected,not prime)
        solvedState = isSolved()
        if solvedState then
            whenSolved()
        end
        return export.settings.disableWorldInteractions and wasSolveMode
    end
    ]]
    
    keybinds:fromVanilla("key.forward"):onPress(function()
        return export.settings.disableWalking and solveMode
    end)
    keybinds:fromVanilla("key.back"):onPress(function()
        return export.settings.disableWalking and solveMode
    end)
    keybinds:fromVanilla("key.left"):onPress(function()
        return export.settings.disableWalking and solveMode
    end)
    keybinds:fromVanilla("key.right"):onPress(function()
        return export.settings.disableWalking and solveMode
    end)
end

local function c(d)
    if d == 3 then return -1 end return d
end

local softCapTickRemaining = avatar:getMaxTickCount()/3
local restorePointDecode = 0
local restorePointTurn = 0
function events.TICK()
    models.rubikscube.Rubiks:setVisible(rubiksEnabled)
    -- Decode pings
    local toremove = {}
    for i, entry in ipairs(queue) do
        if i >= restorePointDecode then
            if avatar:getMaxTickCount()-avatar:getCurrentInstructions() > (330+softCapTickRemaining) then
                restorePointDecode = 0
                local data = entry.data
                local value = data[entry.i]
                entry.i = entry.i + 1
                local idx = bit32.band(bit32.rshift(value,18),31)
                local mat = {{},{},{}}
                mat[1][1] = c(bit32.band(bit32.rshift(value,16),3))
                mat[1][2] = c(bit32.band(bit32.rshift(value,14),3))
                mat[1][3] = c(bit32.band(bit32.rshift(value,12),3))
                mat[2][1] = c(bit32.band(bit32.rshift(value,10),3))
                mat[2][2] = c(bit32.band(bit32.rshift(value,8),3))
                mat[2][3] = c(bit32.band(bit32.rshift(value,6),3))
                mat[3][1] = c(bit32.band(bit32.rshift(value,4),3))
                mat[3][2] = c(bit32.band(bit32.rshift(value,2),3))
                mat[3][3] = c(bit32.band(value,3))
                entry.temp[pieces[idx]] = mat
                if entry.i >= (#data+1) then
                    table.insert(toremove,i)
                    for key, matrix in pairs(entry.temp) do
                        rotations[key] = matrix
                    end
                end
            else
                restorePointDecode = i
                break
            end
        end
    end
    local n = 0
    for i = 1, #toremove-n do
        table.remove(queue,toremove[i]-n)
        n = n + 1
    end
    -- Turn pieces
    for i, piece in ipairs(pieces) do
        if i >= restorePointTurn then
            restorePointTurn = 0
            if avatar:getMaxTickCount()-avatar:getCurrentInstructions() > (410+softCapTickRemaining) then
                previousRotations[piece] = currentRotations[piece]
                if export.settings.smoothPreview and host:isHost() then
                    currentRotations[piece] = interpolateMatrices(currentRotations[piece],multiplyMatrices(preview(piece,selected),rotations[piece]),0.35)
                else
                    currentRotations[piece] = interpolateMatrices(currentRotations[piece],rotations[piece],0.35)
                end
            else
                restorePointTurn = i
                break
            end
        end
    end
end

local softCapRenderRemaining = avatar:getMaxRenderCount()/3
local restorePointTurnRender = 0
local _rubiksrotationmatrix = rubiksrotationmatrix
local render = host:isHost() and events.WORLD_RENDER or events.POST_RENDER
render:register(function(delta)
    if not player:isLoaded() then return end
    local pitch = player:getRot(delta).x
    local yaw = player:getRot(delta).y-player:getBodyYaw(delta)
    local sin = math.sin(math.rad(135+pitch))
    local cos = math.cos(math.rad(135+pitch))
    local siny = math.sin(math.rad(-90-yaw))
    local cosy = math.cos(math.rad(-90-yaw))
    if not host:isHost() then
        _rubiksrotationmatrix = interpolateMatrices(_rubiksrotationmatrix,rubiksrotationmatrix,0.15)
        models.rubikscube.Rubiks:setRot(extractEulerAngles(multiplyMatrices(rotateY(yRotOffset-player:getRot().y),_rubiksrotationmatrix)))
    else
        models.rubikscube.Rubiks:setRot(extractEulerAngles(multiplyMatrices(rotateY(yRotOffset-player:getRot().y),rubiksrotationmatrix)))
    end
    if renderer:isFirstPerson() then
        models.rubikscube.Rubiks:setPos((player:getPos(delta)+vec(0,player:getEyeHeight(),0)+player:getLookDir()*distance)*16)
    else
        local r = vec(0,(player:isCrouching()and 19 or 22)+7*sin+7*cos,7*cos-7*sin)
        models.rubikscube.Rubiks:setPos((anchor:partToWorldMatrix():apply(r.x*siny+r.z*cosy, r.y, r.x*cosy-r.z*siny))*16)
    end
    for i, piece in ipairs(pieces) do
        if i >= restorePointTurnRender then
            restorePointTurnRender = 0
            if avatar:getMaxRenderCount()-avatar:getCurrentInstructions() > (410+softCapRenderRemaining) then
                if export.settings.previewRightClickTurnDir and host:isHost() then
                    piece:setRot(extractEulerAngles(multiplyMatrices(preview(piece,selected),interpolateMatrices(previousRotations[piece] or identity,currentRotations[piece],delta))))
                else
                    piece:setRot(extractEulerAngles(interpolateMatrices(previousRotations[piece] or identity,currentRotations[piece],delta)))
                end
            else
                restorePointTurnRender = i
                break
            end
        end
    end
    if export.settings.vanillaModelPoses then
        if rubiksEnabled then
            local anim = math.sin(world.getTime(delta)*0.1)
            local r = vec(90+anim-pitch,15+anim*2-yaw,(sin+cos)*10)
            local l = vec(90-anim-pitch,-15-anim*2-yaw,(-sin-cos)*10)
            vanilla_model.RIGHT_ARM:setRot(r)
            vanilla_model.RIGHT_SLEEVE:setRot(r)
            vanilla_model.LEFT_ARM:setRot(l)
            vanilla_model.LEFT_SLEEVE:setRot(l)
        else
            vanilla_model.RIGHT_ARM:setRot()
            vanilla_model.RIGHT_SLEEVE:setRot()
            vanilla_model.LEFT_ARM:setRot()
            vanilla_model.LEFT_SLEEVE:setRot()
        end
    end
    if export.settings.hideHeldItems then
        vanilla_model.HELD_ITEMS:setVisible(not rubiksEnabled)
    end
end)

return export

-- Rubiks Cube by manuel_2867