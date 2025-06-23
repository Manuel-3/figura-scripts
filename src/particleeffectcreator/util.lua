local util = {}

function util.deepCopy(tbl)
    -- note: this method does not work with function values, userdata values, or non-string keys
    return parseJson(toJson(tbl))
end

function util.logError(...)
    local args = table.pack(...)
    local str = ""
    for i = 1, args.n do
        str = str .. (args[i]==nil and "nil" or args[i])
    end
    logJson(toJson{{color="#fa723c",text=str.."\n"}})
end

function util.setActionbar(text,animated,time)
    local t = 0
    local function f()
        if t % 40 == 0 or t == time-1 then
            host:setActionbar(text,animated)
        end
        t = t + 1
        if t >= time then
            events.tick:remove(f)
        end
    end
    host:setActionbar(text,animated)
    if time > 40 then
        time = time - 40
        events.tick:register(f)
    end
    return host
end

return util