local action_wheel_sounds = {
  open={"minecraft:item.bundle.insert", 1.4},
  close={"minecraft:item.bundle.remove_one", 0.7},
  hover={"minecraft:block.copper_bulb.turn_on", 1.5},
  leftClick={"minecraft:block.stone_pressure_plate.click_on", 0.8},
  rightClick={"minecraft:block.stone_pressure_plate.click_off", 0.6},
  toggle={"minecraft:block.wooden_button.click_on", 0.8},
  untoggle={"minecraft:block.wooden_button.click_off", 0.6},
  scroll={"minecraft:block.copper_bulb.turn_on"},
}
if host:isHost() then
  if false then
    ---@diagnostic disable: duplicate-set-field, duplicate-doc-field, duplicate-doc-alias
    ---@diagnostic disable: missing-return, unused-local, lowercase-global, unreachable-code

    ---@class Action
    ---The function that is executed when the mouse starts hovering on this action.
    ---@field hover? function
    local Action

    ---Sets the function that executed when the mouse starts hovering over the action.
    ---@generic self
    ---@param self self
    ---@param func? fun(self?: Action)
    ---@return self
    function Action:setOnHover(func) end

    ---Sets the function that executed when the mouse starts hovering over the action.
    ---@generic self
    ---@param self self
    ---@param func? fun(self?: Action)
    ---@return self
    function Action:onHover(func) end

    ---@diagnostic enable: duplicate-set-field, duplicate-doc-field, duplicate-doc-alias
    ---@diagnostic enable: missing-return, unused-local, lowercase-global, unreachable-code
  end
  setmetatable(action_wheel_sounds, {
    __index={
      onLeftClick=action_wheel_sounds.leftClick,
      setOnLeftClick=action_wheel_sounds.leftClick,
      onRightClick=action_wheel_sounds.rightClick,
      setOnRightClick=action_wheel_sounds.rightClick,
      onToggle=action_wheel_sounds.toggle,
      setOnToggle=action_wheel_sounds.toggle,
      onUntoggle=action_wheel_sounds.untoggle,
      setOnUntoggle=action_wheel_sounds.untoggle,
      onScroll=action_wheel_sounds.scroll,
      setOnScroll=action_wheel_sounds.scroll,
    }
  })
  local scroll = 0
  local acted = false
  local Action__index = figuraMetatables.Action.__index
  local Action__newindex = figuraMetatables.Action.__newindex
  local hovers = {}
  figuraMetatables.Action.__newindex = function(self, key, value)
    if key == "leftClick" or key == "rightClick" or key == "toggle" or key == "untoggle" then
      return Action__newindex(self, key, function(...)
        local nkey = key
        if nkey == "toggle" and not (({...})[1]) then
          nkey = "untoggle"
        end
        sounds:playSound(action_wheel_sounds[nkey][1], player:getPos(), 1, action_wheel_sounds[nkey][2])
        acted = true
        return value(...)
      end)
    elseif key == "scroll" then
      return Action__newindex(self, key, function(...)
        scroll = scroll + ({...})[1]
        local p1 = math.pow(2,(scroll%24 - 12) / 12)
        local p2 = math.pow(2,((scroll+12) % 24 - 12) / 12)
        local v1 = math.abs(math.sin(scroll/7.64))
        local v2 = math.abs(math.sin(((scroll+12)%24)/7.64))
        sounds:playSound(action_wheel_sounds[key][1], player:getPos(), v1, p1)
        sounds:playSound(action_wheel_sounds[key][1], player:getPos(), v2, p2)
        return value(...)
      end)
    elseif key == "hover" then
      hovers[self] = value
      return
    end
    return Action__newindex(self, key, value)
  end
  figuraMetatables.Action.__index = function(self, key)
    if key == "setOnLeftClick" or key == "onLeftClick" or key == "setOnRightClick" or key == "onRightClick" or key == "onToggle" or key == "setOnToggle" or key == "setOnUntoggle" or key == "onUntoggle" then
      return function(slf,callback)
        return Action__index(slf, key)(slf, function(...)
          local nkey = key
          if (nkey == "setOnToggle" or key == "onToggle") and not (({...})[1]) then
            nkey = "setOnUntoggle"
          end
          sounds:playSound(action_wheel_sounds[nkey][1], player:getPos(), 1, action_wheel_sounds[nkey][2])
          acted = true
          return callback(...)
        end)
      end
    elseif key == "setOnScroll" or key == "onScroll" then
      return function(slf,callback)
        return Action__index(slf, key)(slf, function(...)
          scroll = scroll + ({...})[1]
          local p1 = math.pow(2,(scroll%24 - 12) / 12)
          local p2 = math.pow(2,((scroll+12) % 24 - 12) / 12)
          local v1 = math.abs(math.sin(scroll/7.64))
          local v2 = math.abs(math.sin(((scroll+12)%24)/7.64))
          sounds:playSound(action_wheel_sounds[key][1], player:getPos(), v1, p1)
          sounds:playSound(action_wheel_sounds[key][1], player:getPos(), v2, p2)
          return callback(...)
        end)
      end
    elseif key=="hover" then
      return hovers[self]
    elseif key=="setOnHover" or key=="onHover" then
      return function(slf,callback)
        hovers[slf] = callback
        return slf
      end
    end
    return Action__index(self, key)
  end
  local e = action_wheel:isEnabled()
  local x,y,d,r,_d,_r,c = 0,0,0,0,0,0,0
  local function border(n)
    return _r <= n and r > n or r <= n and _r > n
  end
  local regions = {}
  local function changedAction()
    regions = {}
    local dist = 19*client.getGuiScale()
    local ret = _d < dist
    if c == 0 then
      return false
    elseif c == 1 then
      regions[1] = 360
      return d > dist and r > 180 and (_d < dist or border(180))
    elseif c%2 == 0 then
      for i=1,c do
        ret = ret or border(i*(360/c))
        regions[i] = i*(360/c)
      end
    else
      for i=1,c do
        if i < c/2 then
          ret = ret or border(i*(360/(c-1)))
          regions[i] = i*(360/(c-1))
        else
          ret = ret or border((i+1)*(360/(c+1)))
          regions[i] = (i+1)*(360/(c+1))
        end
      end
    end
    return d > dist and ret
  end
  function events.MOUSE_MOVE(dx,dy)
    x,y = x+dx, y+dy
    d = math.sqrt(x*x+y*y)
    r = math.deg(math.atan2(x,y))+180
    if action_wheel:isEnabled() and changedAction() then
      local current = 0
      for index, region in ipairs(regions) do
        if r <= region then
          current = index
          break
        end
      end
      local page = action_wheel:getCurrentPage()
      if page and current ~= 0 then
        current = c - current + 1 + (page:getSlotsShift()-1) * 8
        local action = page:getAction(current)
        if action.hover then action:hover() end
      end
      scroll = 0
      sounds:playSound(action_wheel_sounds["hover"][1], player:getPos(), 1, action_wheel_sounds["hover"][2])
    end
    _d, _r = d, r
  end
  function events.TICK()
    if action_wheel:isEnabled() and not e then
      x,y,d,r,_d,_r = 0,0,0,0,0,0
      sounds:playSound(action_wheel_sounds["open"][1], player:getPos(), 1, action_wheel_sounds["open"][2])
    elseif not action_wheel:isEnabled() and e and not acted then
      sounds:playSound(action_wheel_sounds["close"][1], player:getPos(), 1, action_wheel_sounds["close"][2])
    end
    acted = false
    e = action_wheel:isEnabled()
    local page = action_wheel:getCurrentPage()
    if not page then return end
    c = #page:getActions()
    local s = action_wheel:getCurrentPage():getSlotsShift()
    while s > 1 do
      c = c - 8
      s = s - 1
    end
    c = math.min(c, 8)
  end
end
return action_wheel_sounds