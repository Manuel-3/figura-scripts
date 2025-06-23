local editor = require "editor"
local Theme = require "GNUI.theme"
local GNUI = require "GNUI.main"
local Button = require "GNUI.element.button"
local TextField = require "GNUI.element.textField"
local Slider = require "GNUI.element.slider"
local Box = require("GNUI.primitives.box")
local eventLib = require("GNUI.config").event
local utils = require("GNUI.utils")

local uihelper = {}

local function snap(value,step)
	if step > 0.01 then
		return math.floor(value / step + 0.5) * step
	else
		return value
	end
end

function Slider:setValue(value,force)
    ---@cast self GNUI.Slider
    if value == "" then
        return self
    end
    if tonumber(value) then
        local finalValue = snap(value,self.step)
        if force then
            self.value = finalValue
        else
            self.value = self.loop and ((finalValue - self.min) % (self.max - self.min) + self.min) or math.clamp(finalValue,self.min,self.max)
        end
        self:updateSliderBox()
        self.VALUE_CHANGED:invoke(self.value)
        self.sliderBox:setVisible(self.value >= self.min and self.value <= self.max)
    else
        self.expression = value
        self.VALUE_CHANGED:invoke(self.expression)
        self.sliderBox:setVisible(false)
    end
	
	return self
end

local DOUBLE_CLICK_TIME = 300

---@param config {isVertical: boolean?,min: number?,max: number?,step: number,value: number?,showNumber: boolean?, loop: boolean, allowInput: boolean}
---@param variant string|"none"|"default"?
---@return GNUI.Slider
function Slider.new(parent,config,variant)
	config = config or {}
	---@type GNUI.Slider
	local self = setmetatable(Button.new(parent,"none"),Slider)
	
	self.min = config.min or 0
	self.max = config.max or 1
	self.step = config.step or 0
	self.value = config.value or self.min
	self.loop = config.loop or false
	self.keybind = "key.mouse.left"
	self.sliderBox = Box.new(self):setCanCaptureCursor(false)
	self.numberBox = Box.new(self):setAnchor(0,0,1,1):setCanCaptureCursor(false)
	if type(config.isVertical) == "boolean" then
		self.isVertical = config.isVertical
	else
		self.isVertical = true
	end
	
	if type(config.allowInput) == "boolean" then
		self.allowInput = config.allowInput
	else
		self.allowInput = true
	end
	
	self.showNumber = config.showNumber or false
	if not (config.showNumber) then self.numberBox:setVisible(false) end
	
	self.VALUE_CHANGED = eventLib.new()
	
	--self.VALUE_CHANGED:register(function () self:updateSliderBox() end)
	self:updateSliderBox()
	
	local lastClickTime = 0
	---@param event GNUI.InputEvent
	self.INPUT:register(function (event)
        if event.key == self.keybind then
            if event.state == 1 then
                local clickTime = client:getSystemTime()
                if self.allowInput and clickTime - lastClickTime < DOUBLE_CLICK_TIME then
                    self.numberBox:setVisible(false)
                    local numberField = TextField.new(self):setAnchor(0,0,1,1)
                    numberField.textField = tostring(self.numberBox.Text)
                    numberField.Label:setFontScale(__FONT_TEXT)
                    numberField.FIELD_CONFIRMED:register(function (out)
                        numberField:free()
                        if tonumber(out) then
                            self:setValue(math.map(tonumber(out),config.actualMin,config.actualMax,self.min,self.max),true)
                        else
                            self:setValue(out,true)
                        end
                        self.numberBox:setVisible(true)
                    end)
                    numberField:press()
                    self:release()
                    return true
                end
                lastClickTime = clickTime
                self:press()
                return true
            else
                self:release()
            end
        elseif event.key == "key.mouse.scroll" then
            local dir = event.strength > 0 and 1 or -1
            self:setValue(self.value - math.max(self.step,0.1) * dir)
            return true
        end
    end,"GNUI.Input")
	
	---@param event GNUI.InputEventMouseMotion
	self.MOUSE_MOVED:register(function (event)
		if self.isPressed then
				local pos = self:toLocal(event.pos)/self:getSize()
				local gsize = self.cache.grabber_size or 0
				if self.isVertical then
					self:setValue(math.map(pos.y,gsize,1-gsize,self.min,self.max))
				else
					self:setValue(math.map(pos.x,gsize,1-gsize,self.min,self.max))
				end
		end
	end,"GNUI.Input")
	Theme.style(self,variant)
	return self
end

local function sum(t)
    local s = 0
    for _,v in ipairs(t) do
        s = s + v
    end
    return s
end

function uihelper.vertical(weights,funcs)
    if #weights == 0 then
        weights = {}
        for i,_ in ipairs(funcs) do
            weights[i] = 1
        end
    end
    local parts = sum(weights)
    local y = 0
    for i, func in ipairs(funcs) do
        func(vec(0,y,1,y+weights[i]/parts))
        y = y + weights[i]/parts
    end
end

function uihelper.horizontal(weights,funcs)
    if #weights == 0 then
        weights = {}
        for i, _ in ipairs(funcs) do
            weights[i] = 1
        end
    end
    local parts = sum(weights)
    local x = 0
    for i, func in ipairs(funcs) do
        func(vec(x,0,x+weights[i]/parts,1))
        x = x + weights[i]/parts
    end
end

function uihelper.OnOffButton(parent,default)
    local subscribers = {}
    local state = default==nil and true or default
    local allowInternalStateChange = true
    local btn1 = Button.new(parent):setVisible(state):setTextBehavior("NONE")
    local btn2 = Button.new(parent,"Secondary"):setVisible(not state):setTextBehavior("NONE")
    local function setState(self,value)
        state = value
        btn1:setVisible(state)
        btn2:setVisible(not state)
        return self
    end
    btn1.PRESSED:register(function()
        if allowInternalStateChange then
            setState(nil,not state)
        end
        for _, subscriber in ipairs(subscribers) do
            subscriber(state)
        end
    end)
    btn2.PRESSED:register(function()
        if allowInternalStateChange then
            setState(nil,not state)
        end
        for _, subscriber in ipairs(subscribers) do
            subscriber(state)
        end
    end)
    return {
        free=function()
            btn1:free()
            btn2:free()
        end,
        setAnchor=function(self,x,y,z,w)
            btn1:setAnchor(x,y,z,w)
            btn2:setAnchor(x,y,z,w)
            return self
        end,
        setFontScale=function(self,n)
            btn1:setFontScale(n)
            btn2:setFontScale(n)
            return self
        end,
        setText=function(self,t)
            btn1:setText(t)
            btn2:setText(t)
            return self
        end,
        getText=function()
            return btn1.Text
        end,
        setOffText=function(self,t)
            btn2:setText(t)
            return self
        end,
        setDimensions=function(self,x,y,z,w)
            btn1:setDimensions(x,y,z,w)
            btn2:setDimensions(x,y,z,w)
            return self
        end,
        setState=setState,
        getState=function()
            return state
        end,
        setAllowInternalStateChange=function(value)
            allowInternalStateChange = value
        end,
        PRESSED={
            register=function(self,func)
                table.insert(subscribers,func)
            end,
            invoke=function(self,value)
                if state then
                    btn1.PRESSED:invoke(value)
                else
                    btn2.PRESSED:invoke(value)
                end
                return self
            end
        },
        MOUSE_ENTERED={
            register=function(self,func)
                btn1.MOUSE_ENTERED:register(func)
                btn2.MOUSE_ENTERED:register(func)
            end
        },
        MOUSE_EXITED={
            register=function(self,func)
                btn1.MOUSE_EXITED:register(func)
                btn2.MOUSE_EXITED:register(func)
            end
        },
    }
end

function uihelper.Picker(parent,options,default,direction)
    local box = GNUI.newBox(parent)
    local buttons = {}
    local funcs = {}
    for _, value in ipairs(options) do
        local btn = uihelper.OnOffButton(box,value == default):setText(value)
        btn.setAllowInternalStateChange(false)
        btn.PRESSED:register(function()
            for _, b in ipairs(buttons) do
                b:setState(b:getText() == btn:getText())
            end
        end)
        table.insert(buttons,btn)
        table.insert(funcs,function(anchor)
            btn:setAnchor(anchor:unpack())
        end)
    end
    if direction == "vertical" then
        uihelper.vertical({},funcs)
    else
        uihelper.horizontal({},funcs)
    end
    return {
        free=function()
            for _, btn in ipairs(buttons) do
                btn:free()
            end
            box:free()
        end,
        setOptions=function(self,newoptions)
            for i, btn in ipairs(buttons) do
                btn:setText(newoptions[i])
            end
            return self
        end,
        setValue=function(self,value)
            for _, b in ipairs(buttons) do
                b:setState(b:getText() == value)
            end
            return self
        end,
        setAnchor=function(self,x,y,z,w)
            box:setAnchor(x,y,z,w)
            return self
        end,
        setFontScale=function(self,n)
            for _, btn in ipairs(buttons) do
                btn:setFontScale(n)
            end
            return self
        end,
        MOUSE_ENTERED={
            register=function(self,func)
                box.MOUSE_ENTERED:register(func)
                for _, btn in ipairs(buttons) do
                    btn.MOUSE_ENTERED:register(func)
                end
            end
        },
        MOUSE_EXITED={
            register=function(self,func)
                box.MOUSE_EXITED:register(func)
                for _, btn in ipairs(buttons) do
                    btn.MOUSE_EXITED:register(func)
                end
            end
        },
        PRESSED={
            register=function(self,func)
                for _, btn in ipairs(buttons) do
                    btn.PRESSED:register(function()
                        func(btn:getText())
                    end)
                end
            end,
            invoke=function(self,value)
                for _, b in ipairs(buttons) do
                    b:setState(b:getText() == value)
                    if b:getText() == value then
                        b.PRESSED:invoke(value)
                    end
                end
                return self
            end
        },
    }
end

function uihelper.NumberField(parent,name,default,min,max,floating)
    local subscribers = {}
    local value = default
    local textfield, slider, label
    local box = GNUI.newBox(parent)
    local pauseUpdate = false
    uihelper.vertical({2,1},{
        function(anchor)
            local box = GNUI.newBox(box):setAnchor(anchor:unpack())
            uihelper.horizontal({1,2},{
                function(anchor)
                    label = GNUI.newBox(box):setAnchor(anchor:unpack())
                        :setText(name)
                        :setTextAlign(0.5,0.5)
                end,
                function(anchor)
                    textfield = TextField.new(box):setAnchor(anchor:unpack())
                        :setTextField(tostring(value))
                    textfield.FIELD_CONFIRMED:register(function (text)
                        if not tonumber(text) then
                            require "runLater" (1,function()
                                textfield.Label.TextPart:getTask()["1"]:setText('[{"color":"yellow","text":"'..textfield.textField:gsub("\"","\\\"")..'"}]')
                            end)
                            for _, subscriber in ipairs(subscribers) do
                                subscriber(text)
                            end
                        else
                            require "runLater" (2,function() -- 2 here to make this be priority over when creating
                                textfield.Label.TextPart:getTask()["1"]:setText(textfield.textField)
                            end)
                            value = tonumber(text)
                            pauseUpdate = true
                            slider:setValue(math.map(value,min,max,slider.min,slider.max))
                            pauseUpdate = false
                            for _, subscriber in ipairs(subscribers) do
                                subscriber(value)
                            end
                        end
                    end)
                end,
            })
        end,
        function(anchor)
            slider = Slider.new(box, {isVertical=false, allowInput=false}):setAnchor(anchor:unpack())
                :setMin(1)
                :setMax(3)
            if tonumber(value) then
                slider:setValue(math.map(value,min,max,slider.min,slider.max))
            else
                slider:setValue(math.map(0,min,max,slider.min,slider.max))
                require "runLater" (1,function()
                    textfield.Label.TextPart:getTask()["1"]:setText('[{"color":"yellow","text":"'..textfield.textField:gsub("\"","\\\"")..'"}]')
                end)
            end
            slider.VALUE_CHANGED:register(function(value)
                if pauseUpdate then return end
                local newvalue = math.map(value,slider.min,slider.max,min,max)
                if floating then
                    if newvalue-math.floor(newvalue) < 0.08 then
                        newvalue = math.floor(newvalue)
                    elseif math.ceil(newvalue)-newvalue < 0.08 then
                        newvalue = math.ceil(newvalue)
                    end
                else
                    newvalue = math.floor(newvalue)
                end
                textfield:setTextField(tostring(
                    newvalue
                ))
                for _, subscriber in ipairs(subscribers) do
                    subscriber(newvalue)
                end
            end)
        end,
    })
    return {
        setError=function(self)
            textfield.Label.TextPart:getTask()["1"]:setText('[{"color":"red","text":"'..textfield.textField:gsub("\"","\\\"")..'"}]')
            return self
        end,
        setAnchor=function(self,x,y,z,w)
            box:setAnchor(x,y,z,w)
            return self
        end,
        setName=function(self,name)
            label:setText(name)
            return self
        end,
        setValue=function(self,value)
            textfield:setTextField(tostring(value))
            textfield.FIELD_CONFIRMED:invoke(tostring(value))
            return self
        end,
        setFontScale=function(self,n)
            label:setFontScale(n)
            textfield.Label:setFontScale(n)
            slider.numberBox:setFontScale(n)
            return self
        end,
        MOUSE_ENTERED={
            register=function(self,func)
                box.MOUSE_ENTERED:register(func)
                label.MOUSE_ENTERED:register(func)
                textfield.MOUSE_ENTERED:register(func)
                slider.MOUSE_ENTERED:register(func)
            end
        },
        MOUSE_EXITED={
            register=function(self,func)
                box.MOUSE_EXITED:register(func)
                label.MOUSE_EXITED:register(func)
                textfield.MOUSE_EXITED:register(func)
                slider.MOUSE_EXITED:register(func)
            end
        },
        VALUE_CHANGED={
            register=function(self,func)
                table.insert(subscribers,func)
            end
        },
    }
end

function uihelper.disableCamera(container)
    container.MOUSE_ENTERED:register(function()
        editor.inputOverride(true)
    end)
    container.MOUSE_EXITED:register(function()
        editor.inputOverride(false)
    end)
end

local visibleChecks = {}

function uihelper.visibleWhen(element,condition)
    local anchor = type(element) == "ModelPart" and vec(0,0,0,0) or element.Anchor
    local cover = GNUI.newBox(element.Parent):setAnchor(anchor)
    uihelper.disableCamera(cover)
    -- Theme.style(cover,"Background")
    table.insert(visibleChecks,{element=element,condition=condition})
    table.insert(visibleChecks,{element=cover,condition=function()return not condition()end})
end

function events.tick()
    for _, visibleCheck in ipairs(visibleChecks) do
        visibleCheck.element:setVisible(visibleCheck.condition())
    end
end

return uihelper