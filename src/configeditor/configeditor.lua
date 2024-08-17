-- Config Editor by manuel_2867
local ConfigEditor = {}

local indent = "   "
local light_blue = "#5da3fb"

local playername = ""
local selfname = ""
local editing = nil
local renaming = nil
local loading = false
local newentry = false
local newtbl = false

-- Fix figura_function not being recognized in action bar
HostAPIsetActionbar = figuraMetatables.HostAPI.__index.setActionbar
figuraMetatables.HostAPI.__index.setActionbar = function(self,content)
    content = parseJson(content)
    if type(content) == "table" then
        for _, entry in pairs(content) do
            entry.clickEvent = nil
        end
    end
    HostAPIsetActionbar(self,toJson(content))
end
-- End fix

function events.entity_init()
    playername = player:getName()
end

function configeditorglobal_openconfigeditor()
    ConfigEditor:open()
end

function configeditorglobal_newentry()
    newentry = true
    local out = toJson({
        {
            text="Type the ",
            color="yellow"
        },
        {
            text="name",
            color="white"
        },
        {
            text=" of your new entry in chat and send it. Click ",
            color="yellow"
        },
        {
            text="cancel",
            color="white",
            clickEvent={
                action="figura_function",
                value="configeditorglobal_cancel()"
            },
            hoverEvent={
                action="show_text",
                contents="Cancel"
            }
        },
        {
            text=" to cancel. Click ",
            color="yellow"
        },
        {
            text="table",
            color=light_blue,
            clickEvent={
                action="figura_function",
                value="configeditorglobal_newtable()"
            },
            hoverEvent={
                action="show_text",
                contents="New table instead of value"
            }
        },
        {
            text=" to add a table instead.",
            color="yellow"
        }
    })
    host:setActionbar(out)
    logJson(out)
end

function configeditorglobal_newtable()
    newtbl = true
    logJson(toJson({
        {
            text="Type the ",
            color="yellow"
        },
        {
            text="table name",
            color=light_blue
        },
        {
            text=" in chat.",
            color="yellow"
        }
    }))
end

function configeditorglobal_setadd(pathjson)
    editing = parseJson(pathjson)
    local pathjoined = ""
    for i=1,#editing do
        pathjoined = pathjoined .. " > " .. editing[i]
    end
    local out = toJson({
        {
            text="Adding to ",
            color="yellow"
        },
        {
            text=string.sub(pathjoined,4),
            color="white"
        },
        {
            text=", type a ",
            color="yellow"
        },
        {
            text="name",
            color="white"
        },
        {
            text=" in chat and send it. Click ",
            color="yellow"
        },
        {
            text="cancel",
            color="white",
            clickEvent={
                action="figura_function",
                value="configeditorglobal_cancel()"
            },
            hoverEvent={
                action="show_text",
                contents="Cancel"
            }
        },
        {
            text=" to cancel. Click ",
            color="yellow"
        },
        {
            text="table",
            color=light_blue,
            clickEvent={
                action="figura_function",
                value="configeditorglobal_newtable()"
            },
            hoverEvent={
                action="show_text",
                contents="New table instead of value"
            }
        },
        {
            text=" to add a table instead.",
            color="yellow"
        }
    })
    host:setActionbar(out)
    logJson(out)
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
            text=", type a value in chat and send it. Click ",
            color="yellow"
        },
        {
            text="cancel",
            color="white",
            clickEvent={
                action="figura_function",
                value="configeditorglobal_cancel()"
            },
            hoverEvent={
                action="show_text",
                contents="Cancel"
            }
        },
        {
            text=" to cancel.",
            color="yellow"
        }
    })
    host:setActionbar(out)
    logJson(out)
end

function configeditorglobal_setrename(pathjson)
    renaming = parseJson(pathjson)
    local pathjoined = ""
    for i=1,#renaming do
        pathjoined = pathjoined .. " > " .. renaming[i]
    end
    local out = toJson({
        {
            text="Renaming ",
            color="yellow"
        },
        {
            text=string.sub(pathjoined,4),
            color="white"
        },
        {
            text=", type a value in chat and send it. Click ",
            color="yellow"
        },
        {
            text="cancel",
            color="white",
            clickEvent={
                action="figura_function",
                value="configeditorglobal_cancel()"
            },
            hoverEvent={
                action="show_text",
                contents="Cancel"
            }
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
            text=("Which config do you want to load? Type a value in chat and send it. Click "),
            color="yellow"
        },
        {
            text="cancel",
            color="white",
            clickEvent={
                action="figura_function",
                value="configeditorglobal_cancel()"
            },
            hoverEvent={
                action="show_text",
                contents="Cancel"
            }
        },
        {
            text=(" to cancel."),
            color="yellow"
        },
    })
    host:setActionbar(out)
    logJson(out)
end

function configeditorglobal_cancel()
    editing = nil
    loading = false
    newentry = false
    newtbl = false
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

local function logError(err)
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

local function typeParse(input)
    local num = tonumber(input)
    if num then
        return num
    end
    if input == "true" then
        return true
    elseif input == "false" then
        return false
    elseif input == "nil" then
        return nil
    end
    return input
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

local function draw(tbl,ind,path)
    path = path or {}
    ind = ind or ""
    ind = ind .. indent
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
                    text="",
                    extra={
                        {
                            text=ind.."[",
                            color="dark_gray"
                        },
                        {
                            text=tostring(k),
                            color="gray"
                        },
                        {
                            text="]",
                            color="dark_gray"
                        }
                    },
                    clickEvent={
                        action="figura_function",
                        value="configeditorglobal_setrename([====["..toJson(newpath).."]====])"
                    },
                    hoverEvent={
                        action="show_text",
                        contents={
                            {
                                text="Click to ",
                                color="white"
                            },
                            {
                                text="rename ",
                                color="yellow"
                            },
                            {
                                text=tostring(k),
                                color="white"
                            }
                        }
                    }
                },
                {
                    text="",
                    extra={
                        {
                            text=" > ",
                            color="black"
                        },
                        {
                            text=tostring(v),
                            color=color(v)
                        },
                        {
                            text="\n"
                        }
                    },
                    clickEvent={
                        action="figura_function",
                        value="configeditorglobal_setedit([====["..toJson(newpath).."]====])"
                    },
                    hoverEvent={
                        action="show_text",
                        contents={
                            {
                                text="Click to ",
                                color="white"
                            },
                            {
                                text="edit ",
                                color="green"
                            },
                            {
                                text=tostring(k),
                                color="white"
                            }
                        }
                    }
                }
            }))
        else
            logJson(toJson({
                text="",
                extra={
                    {
                        text=ind.."[",
                        color="dark_gray"
                    },
                    {
                        text=tostring(k),
                        color=light_blue
                    },
                    {
                        text="]",
                        color="dark_gray"
                    },
                    {
                        text="\n"
                    }
                },
                clickEvent={
                    action="figura_function",
                    value="configeditorglobal_setrename([====["..toJson(newpath).."]====])"
                },
                hoverEvent={
                    action="show_text",
                    contents={
                        {
                            text="Click to ",
                            color="white"
                        },
                        {
                            text="rename ",
                            color="yellow"
                        },
                        {
                            text=tostring(k),
                            color="white"
                        }
                    }
                }
            }))
            draw(v,ind,newpath)
            logJson(toJson({
                text="",
                extra={
                    {
                        text=ind..indent.."[",
                        color="dark_gray"
                    },
                    {
                        text="+",
                        color="yellow"
                    },
                    {
                        text="]",
                        color="dark_gray"
                    },
                    {
                        text="\n"
                    }
                },
                clickEvent={
                    action="figura_function",
                    value="configeditorglobal_setadd([====["..toJson(newpath).."]====])"
                },
                hoverEvent={
                    action="show_text",
                    contents="Add entry in "..k
                }
            }))
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
            color="white"
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
            text="click here.\n",
            color="yellow",
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
            text="Config Editor",
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
            text="",
            extra={
                {
                    text=indent.."[",
                    color="dark_gray"
                },
                {
                    text="+",
                    color="yellow"
                },
                {
                    text="]",
                    color="dark_gray"
                },
                {
                    text="\n"
                }
            },
            clickEvent={
                action="figura_function",
                value="configeditorglobal_newentry()"
            },
            hoverEvent={
                action="show_text",
                contents="Add entry"
            }
        }
    }))
    logJson(toJson({
        text=">> Use your mouse to click and edit.\n>> Scroll up if you can't see the full config.",
        color="gray"
    }))
end

function events.chat_send_message(message)
    if message == nil then return nil end
    if editing then
        local revert = config:getName()
        local success, err = pcall(function()
            config:setName(selfname)
            local container = config:load(editing[1])
            local val = container
            if type(val) == "table" then
                if #editing > 1 then
                    for i = 2, #editing-1 do
                        val = val[editing[i]]
                    end
                    if type(val[editing[#editing]]) == "table" then
                        if message ~= "nil" then
                            val[editing[#editing]][message] = newtbl and {} or ""
                        end
                    else
                        val[editing[#editing]] = typeParse(message)
                    end
                else
                    if message ~= "nil" then
                        val[message] = newtbl and {} or ""
                    end
                end
            else
                container = typeParse(message)
            end
            config:save(editing[1], container)
            newtbl = false
            ConfigEditor:open(selfname)
        end)
        if not success then
            logError(err)
        end
        config:setName(revert)
        editing = nil
        return nil
    elseif renaming then
        local revert = config:getName()
        local success, err = pcall(function()
            if message == "nil" then message = nil end
            config:setName(selfname)
            local container = config:load(renaming[1])
            local val = container
            if type(val) == "table" and #renaming > 1 then
                for i = 2, #renaming-1 do
                    val = val[renaming[i]]
                end
                if message then val[message] = val[renaming[#renaming]] end
                val[renaming[#renaming]] = nil
                config:save(renaming[1], container)
            else
                if message then config:save(message, config:load(renaming[1])) end
                config:save(renaming[1], nil)
            end
            ConfigEditor:open(selfname)
        end)
        if not success then
            logError(err)
        end
        config:setName(revert)
        renaming = nil
        return nil
    elseif loading then
        loading = false
        ConfigEditor:open(message)
        return nil
    elseif newentry then
        newentry = false
        local revert = config:getName()
        config:setName(selfname)
        config:save(message, newtbl and {} or "")
        newtbl = false
        config:setName(revert)
        ConfigEditor:open()
        return nil
    elseif string.find(message, "^/configeditor") then
        ConfigEditor:open(string.sub(message,15))
        return nil
    end
    return message
end

return ConfigEditor