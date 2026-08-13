-- theoretical backend rate limit:
-- bytes per second: 1024
-- pings per second: 32
-- in practice much lower
-- max supported in this script: 20 pings per second
local bytes_per_second = 250
local pings_per_second = 10

--------------------------------------------------------------------------------

---@param url string
---@param callback fun(data: string)
function HttpRequest(url, callback)
  if not host:isHost() then return end
  local stream, data, future
  local function await_download()
    if not future:isDone() then return end
    local value = future:getValue()
    if not value then callback(nil) events.world_render:remove(await_download) return end
    table.insert(data, value)
    if value == "" then
      callback(table.concat(data))
      events.world_render:remove(await_download)
    else
      future = stream:readAsync(2^20)
    end
  end
  local request = net.http:request(url):send()
  local function await_request()
    if not request:isDone() then return end
    local value = request:getValue()
    if not value then callback(nil) events.world_render:remove(await_request) return end
    stream, data = value:getData(), {}
    future = stream:readAsync(2^20)
    events.world_render:register(await_download)
    events.world_render:remove(await_request)
  end
  events.world_render:register(await_request)
end

---@param str string
---@return string
function EncodeBase64(str)
  local buffer = data:createBuffer()
  buffer:writeByteArray(str)
  buffer:setPosition(0)
  local data = buffer:readBase64()
  buffer:close()
  return data
end

local tickDelay = math.max(1,math.floor(20/pings_per_second))
local bytesPerPing = math.floor(bytes_per_second/pings_per_second)
local time = 0
local ttsCaches = {}
local waitingList = {}
local timeoutList = {}

local function playSound(bytes)
    if not player:isLoaded() then return end
    local success, error = pcall(function()
        sounds:newSound("tts",bytes)
        local sound = sounds["tts"]:pos(player:getPos()):play()
        local function tick()
            sound:pos(player:getPos())
            if not sound:isPlaying() then
                events.tick:remove(tick)
            end
        end
        events.tick:register(tick)
    end)
    if not success then
        print(error)
    end
end

local function getCache(ttsId)
    if ttsCaches[ttsId] then
        return ttsCaches[ttsId]
    end
    ttsCaches[ttsId] = {}
    timeoutList[ttsId] = time+20*60*3 -- 3 minutes
    return ttsCaches[ttsId]
end

function pings.streamTTS(ttsId,idx,bytes)
    getCache(ttsId)[idx] = bytes
end

function events.tick()
    time = time + 1
    for key in pairs(ttsCaches) do
        if time >= timeoutList[key] then
            timeoutList[key] = nil
            ttsCaches[key] = nil
            waitingList[key] = nil
        else
            if waitingList[key] == #ttsCaches[key] then
                local byteArr = {}
                for j=1,#ttsCaches[key] do
                    local bytes = ttsCaches[key][j]
                    if bytes then
                        for i=1,#bytes do
                            table.insert(byteArr,string.byte(bytes,i,i))
                        end
                    end
                end
                playSound(byteArr)
                timeoutList[key] = nil
                ttsCaches[key] = nil
                waitingList[key] = nil
            end
        end
    end
end

function pings.playTTS(ttsId,length)
    getCache(ttsId)
    waitingList[ttsId] = length
end

if not host:isHost() then return end

local queue = {}
local processing = false
local hostTtsId = 0

local function stream(bytes,ttsId,callback)
    local position = 1
    local i = 1
    local function tick()
        if time % tickDelay ~= 0 then return end
        host:setActionbar("Streaming "..(math.floor(#bytes/10)/100).."KB "..math.clamp(math.floor(100*i/#bytes),0,100).."%")
        pings.streamTTS(ttsId,position,bytes:sub(i,i+bytesPerPing-1))
        if i >= #bytes then
            pings.playTTS(ttsId,position)
            events.tick:remove(tick)
            callback()
        end
        i = i + bytesPerPing
        position = position + 1
    end
    events.tick:register(tick)
end

local function readFile()
    local success, result = pcall(function()
        local buffer = data:createBuffer()
        local stream = file:openReadStream("tts/tts.ogg")
        buffer:readFromStream(stream)
        buffer:setPosition(0)
        local bytes = buffer:readByteArray(buffer:available())
        buffer:close()
        stream:close()
        return bytes
    end)
    if success then
        return result
    else
        print(result)
        return ""
    end
end

function events.chat_send_message(msg)
    table.insert(queue, {hostTtsId,msg})
    hostTtsId = hostTtsId + 1
    return nil
end

function events.tick()
    if not processing and #queue > 0 then
        processing = true
        local element = table.remove(queue,1)
        local ttsId = element[1]
        local msg = element[2]
        host:setActionbar("Generating TTS")
        HttpRequest("http://localhost:80/tts?text="..EncodeBase64(msg),function(result)
            if result ~= "ok" then
                print("Request failed.")
                host:sendChatMessage(msg)
                processing = false
                return
            end
            local bytes = readFile()
            stream(bytes,ttsId,function()
                processing = false
                host:sendChatMessage(msg)
            end)
        end)
    end
end