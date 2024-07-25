-- Config Editor by manuel_2867
local ConfigEditor = {}

local indent = 2
local light_blue = "#5da3fb"

local playername = ""
local selfname = ""
local editing = nil
local loading = false

function events.entity_init()
    playername = player:getName()
end

function configeditorglobal_openconfigeditor()
    ConfigEditor:open()
end

function configeditorglobal_setedit(pathjson)
    editing = parseJson(pathjson)
    local pathjoined = ""
    for i=1,#editing do
        pathjoined = pathjoined .. " > " .. editing[i]
    end
    local out = toJson({
        {
            text="Editing ",
            color="yellow"
        },
        {
            text=string.sub(pathjoined,4),
            color="white"
        },
        {
            text=", type a value in chat and send it. Type ",
            color="yellow"
        },
        {
            text="cancel",
            color="white"
        },
        {
            text=" to cancel.",
            color="yellow"
        }
    })
    host:setActionbar(out)
    logJson(out)
end

function configeditorglobal_loadconfig()
    loading = true
    local out = toJson({
        {
            text=("Which config do you want to load? Type a value in chat and send it. Type cancel to cancel."),
            color="yellow"
        }
    })
    host:setActionbar(out)
    logJson(out)
end

local function flush(n)
    for _=1,n do
        logJson("\n")
    end
end

local function color(v)
    if type(v) == "boolean" then
        return "#9f54d6"
    elseif type(v) == "number" then
        return "aqua"
    end
    return "white"
end

local function draw(tbl,lvl,path)
    path = path or {}
    lvl = lvl or 0
    local ind = ""
    for _=0,lvl+indent-1 do
        ind = ind.." "
    end
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end
    pcall(table.sort,keys)
    for _, k in ipairs(keys) do
        local v = tbl[k]
        local newpath = {table.unpack(path)}
        newpath[#newpath+1] = k
        if (type(v)~="table") then
            logJson(toJson({
                {
                    text=ind.."[",
                    color="dark_gray",
                    clickEvent={
                        action="figura_function",
                        value="configeditorglobal_setedit([====["..toJson(newpath).."]====])"
                    },
                    hoverEvent={
                        action="show_text",
                        contents="Click to edit "..k
                    }
                },
                {
                    text=k,
                    color="gray",
                    clickEvent={
                        action="figura_function",
                        value="configeditorglobal_setedit([====["..toJson(newpath).."]====])"
                    },
                    hoverEvent={
                        action="show_text",
                        contents="Click to edit "..k
                    }
                },
                {
                    text="]",
                    color="dark_gray",
                    clickEvent={
                        action="figura_function",
                        value="configeditorglobal_setedit([====["..toJson(newpath).."]====])"
                    },
                    hoverEvent={
                        action="show_text",
                        contents="Click to edit "..k
                    }
                },
                {
                    text=" > ",
                    color="black",
                    clickEvent={
                        action="figura_function",
                        value="configeditorglobal_setedit([====["..toJson(newpath).."]====])"
                    },
                    hoverEvent={
                        action="show_text",
                        contents="Click to edit "..k
                    }
                },
                {
                    text=v,
                    color=color(v),
                    clickEvent={
                        action="figura_function",
                        value="configeditorglobal_setedit([====["..toJson(newpath).."]====])"
                    },
                    hoverEvent={
                        action="show_text",
                        contents="Click to edit "..k
                    }
                },
                {
                    text="\n"
                }
            }))
        else
            logJson(toJson({
                {
                    text=ind.."[",
                    color="dark_gray"
                },
                {
                    text=k,
                    color=light_blue
                },
                {
                    text="]",
                    color="dark_gray"
                },
                {
                    text="\n"
                }
            }))
            draw(v,lvl+indent,newpath)
        end
    end
end

--- Set the name of the config to use. Optional, as you can also just pass the name into the :open() function.
---@param name string
function ConfigEditor:setName(name)
    selfname = name
end

--- Similar to figuras config:save() except it will only put the value if nothing else is already in there. Useful for setting a default, but not overwriting it again on each script start.
---@param key string
---@param value any
function ConfigEditor:default(key,value)
    local revert = config:getName()
    config:setName(selfname)
    if key and type(config:load(key)) == "nil" then
        config:save(key,value)
    end
    config:setName(revert)
end

function ConfigEditor:printInfo()
    logJson(toJson({
        {
            text="[!] ",
            color="yellow"
        },
        {
            text="This avatar contains ",
            color="gray"
        },
        {
            text="[[",
            color="dark_gray"
        },
        {
            text="Config Editor",
            color="gray"
        },
        {
            text="]]",
            color="dark_gray"
        },
        {
            text="\n    To use simply type ",
            color="gray"
        },
        {
            text="/configeditor",
            color="white"
        },
        {
            text=" or ",
            color="gray"
        },
        {
            text="click here",
            color=light_blue,
            clickEvent={
                action="figura_function",
                value="configeditorglobal_openconfigeditor()"
            },
            hoverEvent={
                action="show_text",
                contents="Open Config Editor"
            }
        }
    }))
end

--- Open the Config Editor with a given config name, or if none is specified using the name previously set with the :setName() function.
---@param name string|nil
function ConfigEditor:open(name)
    selfname = name or selfname
    local revert = config:getName()
    config:setName(selfname)
    local cfg = config:load()
    config:setName(revert)
    flush(20)
    logJson(toJson({
        {
            text="[[",
            color="dark_gray"
        },
        {
            text=" Config Editor ",
            color="white"
        },
        {
            text="]]",
            color="dark_gray"
        },
        {
            text=" >> ",
            color="gray"
        },
        {
            text=(selfname~="" and selfname or "<select>").."\n",
            color="yellow",
            clickEvent={
                action="figura_function",
                value="configeditorglobal_loadconfig()"
            },
            hoverEvent={
                action="show_text",
                contents="Load different config"
            }
        }
    }))
    draw(cfg)
    logJson(toJson({
        {
            text=">> Use your mouse to click and edit.\n>> Scroll up if you can't see the full config.",
            color="gray"
        }
    }))
end

function events.chat_send_message(message)
    if editing then
        if string.lower(message) == "cancel" then
            editing = nil
            local out = toJson({
                {
                    text="Canceled editing.",
                    color="red"
                }
            })
            host:setActionbar(out)
            logJson(out)
            return nil
        end
        local success, err = pcall(function()
            local revert = config:getName()
            config:setName(selfname)
            local container = config:load(editing[1])
            local val = container
            log(val)
            if type(val) == "table" then
                for i = 2, #editing-1 do
                    val = val[editing[i]]
                end
                val[editing[#editing]] = message
            else
                container = message
            end
            config:save(editing[1], container)
            config:setName(revert)
            editing = nil
            ConfigEditor:open(selfname)
        end)
        if not success then
            logJson(toJson({
                {
                    text="[error] ",
                    color="red"
                },
                {
                    text=playername,
                    color="white"
                },
                {
                    text=" : "..err,
                    color="red"
                }
            }))
        end
        return nil
    elseif loading then
        ConfigEditor:open(message)
        return nil
    elseif string.find(message, "^/configeditor") then
        ConfigEditor:open(string.sub(message,15))
        return nil
    end
    return message
end

return ConfigEditor