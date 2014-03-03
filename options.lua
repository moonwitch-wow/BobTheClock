-------------------------------------------------------------------------------
-- Gui functions
-------------------------------------------------------------------------------
local addonName, ns = ...

-----------------------------
-- Defaults
local defaults = {
   timeform24 = true,
   clockcolor = {255/255, 204/255, 0/255},
   clockshadow = true,
   clockoutline = nil, -- nil, OUTLINE, THICKOUTLINE, MONOCHROMEOUTLINE
   clocksize = 32,
   clockfont = STANDARD_TEXT_FONT,
   statscolor = {255/255, 204/255, 0/255},
   statsshadow = true,
   statsoutline = nil, -- nil, OUTLINE, THICKOUTLINE, MONOCHROMEOUTLINE
   statssize = 14,
   statsfont = STANDARD_TEXT_FONT,
   locked = true,
   shadowcolor = {0, 0, 0, .8} -- keeping it universal
}

------------------------------------------------------------------------
-- Frame creation
------------------------------------------------------------------------
local Panel = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
Panel.name = addonName
Panel:Hide()

-----------------------------
-- Adding the reading of the DB to this
Panel:RegisterEvent('PLAYER_LOGIN')
Panel:SetScript('OnEvent', function()
   BobTheClockDB = BobTheClockDB or defaults

   for key, value in pairs(defaults) do
      if(BobTheClockDB[key] == nil) then
         BobTheClockDB[key] = value
      end
   end

   BobTheHandler:PLAYER_LOGIN() -- Hi there, without me, you can't see!
end)

function Panel:okay()
   BobTheClockDB[key] = value
end

function Panel:Refresh()

end

------------------------------------------------------------------------
-- GUI methods
------------------------------------------------------------------------
function Panel:CreateCheckbox(text, tooltiptext)
   -- On Phanx' recommendation randomized name
   local checkButton = CreateFrame("CheckButton", "BobCheckbox" .. random(1000000), self, "InterfaceOptionsCheckButtonTemplate")

   -- hook functions into this shithole of doom
   checkButton:SetScript("OnClick",
      function(self)
         local checked = not not self:GetChecked() -- convert 1/nil to true/false
         PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
         if self.func then
            self:func(checked)
         end
      end)

   -- Customize it
   checkButton.Text:SetText(text)
   if tooltiptext then
      checkButton.tooltipText = tooltipText
   else
      checkButton.tooltipText = text
   end

   -- Return it
   return checkButton
end

function Panel:CreateColorpicker(name, text, desc, point, anchor, rpoint)
end

function Panel:CreateButton(text, width, func)
   local button = CreateFrame("Button", nil, self, "OptionsButtonTemplate")
   button:SetText(text)
   button:SetWidth(width)
   button:SetScript("OnClick", func)

   return button
end

do
    local function Slider_OnMouseWheel(self, delta)
        local step = self:GetValueStep() * delta
        local minValue, maxValue = self:GetMinMaxValues()
        if step > 0 then
            self:SetValue(min(self:GetValue() + step, maxValue))
        else
            self:SetValue(max(self:GetValue() + step, minValue))
        end
    end

    local function Slider_OnValueChanged(self)
        local value = self:GetValue()

        -- Work around for Blizzard bug that ignores the step value while dragging:
        local valueStep, minValue = self:GetValueStep(), self:GetMinMaxValues()
        if valueStep and valueStep > 0 then
            value = floor((value - minValue) / valueStep + 0.5) * valueStep + minValue
        end

        self.value:SetText(value)

        if self.func then
            self:func(value)
        end
    end

    function Panel:CreateSlider(text, tooltipText, minValue, maxValue, stepValue)
        local slider = CreateFrame("Slider", "BobSlider" .. random(1000000), self, "OptionsSliderTemplate")
        slider.text = _G[slider:GetName() .. "Text"]
        slider.lowText = _G[slider:GetName() .. "Low"]
        slider.highText = _G[slider:GetName() .. "High"]

        slider:EnableMouseWheel(true)
        slider:SetScript("OnMouseWheel", Slider_OnMouseWheel)
        slider:SetScript("OnValueChanged", Slider_OnValueChanged)

        local value = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        value:SetPoint("LEFT", slider, "RIGHT", 7, 0)
        slider.value = value

        slider.lowText:Hide()
        slider.highText:Hide()

        slider.text:SetText(text)
        slider.tooltipText = tooltipText
        slider:SetMinMaxValues(minValue or 0, maxValue or 100)
        slider:SetValueStep(stepValue or 1)

        return slider
    end
end

-----------------------------
-- Populating the panel itself (main panel)
Panel:SetScript('OnShow', function(self)
   local Title = self:CreateFontString(nil, nil, 'GameFontNormalLarge')
   Title:SetPoint('TOPLEFT', 16, -16)
   Title:SetText(addonName)

   local Description = self:CreateFontString(nil, nil, 'GameFontHighlightSmall')
   Description:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -10)
   Description:SetPoint('RIGHT', -32, 0)
   Description:SetJustifyH('LEFT')
   Description:SetText('Just for Bob, we wrote The Bob Clock!')
   self.Description = Description

   -- general
   local framelocker = Panel:CreateButton("Toggle Framelock", 150, func)
   framelocker:SetPoint("TOPRIGHT", Panel, "TOPRIGHT", -30, -30)

   -- Clock group
   local ClockSettings = self:CreateFontString(nil, nil, 'GameFontNormal')
   ClockSettings:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', 0, -10)
   ClockSettings:SetPoint('RIGHT', -32, 0)
   ClockSettings:SetJustifyH('LEFT')
   ClockSettings:SetText('Clock Settings')
   self.ClockSettings = ClockSettings

   -- time format
   local timeFormat = self:CreateCheckbox("Use 24-hour time format", "Uncheck this box to switch to 12-hour time format.", BobTheClockDB, timeform24)
   timeFormat:SetPoint("TOPLEFT", ClockSettings, "BOTTOMLEFT", 0, -5)
   timeFormat:SetChecked(BobTheClockDB.timeform24)
   timeFormat.func = function(self, value)
      BobTheClockDB.timeform24 = value
      BobTheHandler:PLAYER_LOGIN()
   end

   -- enable shadow
   local enDisShadow = self:CreateCheckbox("Check to enable shadow on the clock.")
   enDisShadow:SetPoint("TOPLEFT", timeFormat, "BOTTOMLEFT", 0, -5)
   enDisShadow:SetChecked(BobTheClockDB.clockshadow)
   enDisShadow.func = function(self, value)
      BobTheClockDB.clockshadow = value
      BobTheHandler:PLAYER_LOGIN()
   end

   -- clock size
   local clocksizeSlider = self:CreateSlider("Clock size", "Adjust the size of the clock text.", 8, 32, 1)
   clocksizeSlider:SetPoint("RIGHT", ClockSettings, "RIGHT", -45, -10)
   clocksizeSlider:SetValue(BobTheClockDB.clocksize)
   clocksizeSlider.func = function(self, value)
      BobTheClockDB.clocksize = value
      BobTheHandler:PLAYER_LOGIN()
   end

   -- Stats group
   local StatsStettings = self:CreateFontString(nil, nil, 'GameFontNormal')
   StatsStettings:SetPoint('TOPLEFT', enDisShadow, 'BOTTOMLEFT', 0, -10)
   StatsStettings:SetPoint('RIGHT', -32, 0)
   StatsStettings:SetJustifyH('LEFT')
   StatsStettings:SetText('Stats Settings')
   self.StatsStettings = StatsStettings

   -- shadow
   local shadowstats = self:CreateCheckbox("Check to enable shadow on stats.")
   shadowstats:SetPoint("TOPLEFT", StatsStettings, "BOTTOMLEFT", 0, -5)
   shadowstats:SetChecked(BobTheClockDB.statsshadow)
   shadowstats.func = function(self, value)
      BobTheClockDB.statsshadow = value
      BobTheHandler:PLAYER_LOGIN()
   end

   -- stats size
   local statssizeSlider = self:CreateSlider("Stats size", "Adjust the size of the stats text.", 8, 32, 1)
   statssizeSlider:SetPoint("RIGHT", StatsStettings, "RIGHT", -45, -10)
   statssizeSlider:SetValue(BobTheClockDB.statssize)
   statssizeSlider.func = function(self, value)
      BobTheClockDB.statssize = value
      BobTheHandler:PLAYER_LOGIN()
   end

   self:SetScript('OnShow', nil)
end)

-----------------------------
-- Add the panel to the Interface Options
InterfaceOptions_AddCategory(Panel)
