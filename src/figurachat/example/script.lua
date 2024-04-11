local messages = models.messages.Skull:newText("")
messages:setText("")
messages:setScale(0.2)
messages:alignment("CENTER")

function pings.sendMessage(author, message)
    messages:setText(messages:getText()..author..": "..message.."\n")
    local _, lineCount = messages:getText():gsub("\n", "")
    messages:setPos(0,2+2*lineCount,0)
end

function events.chat_receive_message(message, json)
    if message:match("^%[lua") then return end
    local tbl = parseJson(json)
    pings.sendMessage(tbl.with[1].text, tbl.with[2].text)
end

pings.sendMessage("Steve", "Hello there!")
pings.sendMessage("Alex", "General Kenobi!")