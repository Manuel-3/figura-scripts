local path = require "path"
local util = require "util"

local configName = "particle_effect_creator"
local particleSuffix = ".particle.json"
local defaultparticle = {}

local io = {}
local lastLoadedParticle = nil

function io:save(key,value)
    local _name = config:getName()
    config:setName(configName)
    config:save(key,value)
    config:setName(_name)
end

function io:load(key)
    local _name = config:getName()
    config:setName(configName)
    local value = config:load(key)
    config:setName(_name)
    return value
end

function io:setDefaultParticle(value)
    defaultparticle = value
end

local function stateFromString(str)
    local success, result = pcall(function()
        return parseJson(str)
    end)
    if not success or type(result) ~= "table" then
        util.logError("Malformed json.")
        return util.deepCopy(defaultparticle)
    end
    local particle = util.deepCopy(defaultparticle) -- downwards compatibility, include default for missing entries
    for key, value in pairs(result) do
        particle[key] = value
    end
    lastLoadedParticle = util.deepCopy(particle) -- dont return this, need a copy here
    return particle
end

local function stringFromState(state)
    return toJson(state)
end

function io:saveParticle(name, state)
    local p = path.applyPath("./"..name..particleSuffix)
    path.mkdir(p)
    file:writeString(name..particleSuffix, stringFromState(state), "utf-8")
    util.setActionbar("Saved \""..p.."\"",false,70)
end

function io:loadParticle(name,hideError)
    local path = "./"..name..particleSuffix
    if not file:exists(path) then
        if not hideError then
            util.logError("File doesn't exist.")
        end
        return util.deepCopy(defaultparticle)
    end
    return stateFromString(file:readString(path, "utf-8"))
end

function io:saveParticleToClipboard(state)
    host:setClipboard(stringFromState(state))
    host:setActionbar("Copied to clipboard")
end

function io:loadParticleFromClipboard()
    host:setActionbar("Loaded from clipboard")
    return stateFromString(host:getClipboard())
end

function io:listParticles()
    local particles = {}
    local function walk(p)
        for _, fileName in pairs(file:list(p)) do
            local pathName = path.join(p,fileName)
            if file:isDirectory(pathName) then
                walk(pathName)
            else
                if fileName:match(".*"..particleSuffix:gsub("%.","%%.").."$") then
                    local particleName = path.dirpath(pathName):gsub("^%./","") .. path.filenameonly(fileName)
                    table.insert(particles, particleName)
                end
            end
        end
    end
    walk("./")
    return particles
end

function io:lastLoadedParticle()
    return lastLoadedParticle
end

return io