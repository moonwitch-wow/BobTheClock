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
   statsshow = true,
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
   for key, value in pairs(temporary) do
      BobTheClockDB[key] = value
   end
end

------------------------------------------------------------------------
-- GUI methods
------------------------------------------------------------------------
function Panel:CreateCheckbox(text, tooltiptext)
   -- On Phanx' recommendation randomized name
   local checkButton = CreateFrame("CheckButton", "BobCheckbox" .. random(1000000), self, "InterfaceOptionsCheckButtonTemplate")
   checkButton:SetHitRectInsets(0, 0, 0, 0)

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
      checkButton.TooltipText = tooltipText
   else
      checkButton.TooltipText = text
   end

   -- Return it
   return checkButton
end

function Panel:CreateColorpicker(name, text, desc, point, anchor, rpoint)
end

function Panel:CreateButton(parent, text, width, func)
   local button = CreateFrame("Button", nil, parent, "OptionsButtonTemplate")
   button:SetText(text)
   button:SetWidth(width)
   button:SetScript("OnClick", func)

   return button
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
   local framelocker = Panel:CreateButton(Panel, "Toggle Framelock", 150, func)
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
   timeFormat.func = function(self, value)
      BobTheClockDB.timeform24 = value
      BobTheHandler:PLAYER_LOGIN()
   end

   -- enable shadow
   local enDisShadow = self:CreateCheckbox("Check to enable Shadow on the clock.")
   enDisShadow:SetPoint("TOPLEFT", timeFormat, "BOTTOMLEFT", 0, -5)
   enDisShadow.func = function(self, value)
      BobTheClockDB.clockshadow = value
      BobTheHandler:PLAYER_LOGIN()
   end

   -- outline
   local enOutline = self:CreateCheckbox('Check to enable outline on clock.')
   enOutline:SetPoint("TOPLEFT", enDisShadow, "BOTTOMLEFT", 0, -5)
   enOutline.func = function(self, value)
      BobTheClockDB.clockoutline = value
      BobTheHandler:PLAYER_LOGIN()
   end

   -- -- clock size
   -- -- local clockSlide = Panel:CreateSlider(name, text, low, high, step)

   -- -- Stats group
   -- local StatsStettings = self:CreateFontString(nil, nil, 'GameFontNormal')
   -- StatsStettings:SetPoint('TOPLEFT', enOutline, 'BOTTOMLEFT', 0, -10)
   -- StatsStettings:SetPoint('RIGHT', -32, 0)
   -- StatsStettings:SetJustifyH('LEFT')
   -- StatsStettings:SetText('Stats Settings')
   -- self.StatsStettings = StatsStettings

   -- -- show?
   -- local showStats = Panel:CreateCheckBox(Panel, BobTheClockDB, statsshow)
   -- showStats:SetPoint("TOPLEFT", StatsStettings, "BOTTOMLEFT", 0, -5)
   -- showStats.Text:SetText("Check to show stats (FPS, latency and memory)")

   -- -- shadow
   -- local shadowstats = Panel:CreateCheckBox(Panel, BobTheClockDB, statsshadow)
   -- shadowstats:SetPoint("TOPLEFT", showStats, "BOTTOMLEFT", 0, -5)
   -- shadowstats.Text:SetText("Check to show a shadow on the stats.")

   -- -- outline
   -- local outlinestats = Panel:CreateCheckBox(Panel, BobTheClockDB, statsoutline)
   -- outlinestats:SetPoint("TOPLEFT", shadowstats, "BOTTOMLEFT", 0, -5)
   -- outlinestats.Text:SetText("Check to show an outline around the stats.")

   self:SetScript('OnShow', nil)
end)

-----------------------------
-- Add the panel to the Interface Options
InterfaceOptions_AddCategory(Panel)

SLASH_bobtheclock1 = '/bobtheclock'
SlashCmdList[addonName] = function()
   InterfaceOptionsFrame_OpenToCategory(addonName)
end

