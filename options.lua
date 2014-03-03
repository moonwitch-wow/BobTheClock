-------------------------------------------------------------------------------
-- Gui functions
-------------------------------------------------------------------------------
local addonName, ns = ...
local buttons = {}
local temporary = {}

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

------------------------------------------------------------------------
-- GUI methods
------------------------------------------------------------------------
function Panel:AddCheckbox(parent, text, table, key)
   local checkButton = CreateFrame("Button", nil, parent, "UICheckButtonTemplate")

   local label = checkButton:CreateFontString(nil, 'ARTWORK', "GameFontHighlight")
   label:SetPoint("LEFT", checkButton, "RIGHT", 2, 1)
   label:SetText(text)
   checkButton.label = label

   -- hook functions into this shithole of doom
   checkButton:SetScript("OnClick",
      function (self, checkButton, down)
         if ( checkButton:GetChecked() ) then
            PlaySound("igMainMenuOptionCheckBoxOn")
         else
            PlaySound("igMainMenuOptionCheckBoxOff")
         end
         -- InterfaceOptionsPanel_CheckButton_OnClick(self);
      end)

   return checkButton
end

function Panel:AddColorPicker(name, text, desc, point, anchor, rpoint)
end

function Panel:CreateSlider(name, text, low, high, step)
   local slider = CreateFrame('Slider', name, 'Panel', 'OptionsSliderTemplate')
   slider:SetScript('OnMouseWheel', Slider_OnMouseWheel)
   slider:SetMinMaxValues(low, high)
   slider:SetValueStep(step)
   slider:EnableMouseWheel(true)
   slider.text:SetText(text)
   _G[name .. 'Low']:SetText('')
   _G[name .. 'High']:SetText('')
   local text = slider:CreateFontString(nil, 'BACKGROUND')
   text:SetFontObject('GameFontHighlightSmall')
   text:SetPoint('LEFT', slider, 'RIGHT', 7, 0)
   slider.valText = text
   return slider
end

function Panel:CreateButton(parent, text, width, func)
   local button = CreateFrame("Button", nil, parent, "OptionsButtonTemplate")
   button:SetText(text)
   button:SetWidth(width)
   button:SetScript("OnClick", func)

   return button
end

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

function Panel:cancel()
   table.wipe(temporary)
end


function Panel:default()
   BobTheClockDB = defaults
   table.wipe(temporary)
end

function Panel:refresh()
   for key, button in pairs(buttons) do
      if(button:IsObjectType('CheckButton')) then
         button:SetChecked(BobTheClockDB[key])
      elseif(button:IsObjectType('Button')) then
         UIDropDownMenu_SetSelectedValue(button, BobTheClockDB[key])

         -- This is for some reason needed, gotta take a look into it later
         UIDropDownMenu_SetText(button, _G[BobTheClockDB[key] .. '_KEY'])
      end
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
   local timeFormatButton = Panel:AddCheckbox(Panel, BobTheClockDB, timeform24)
   timeFormatButton:SetPoint("TOPLEFT", ClockSettings, "BOTTOMLEFT", 0, -5)
   timeFormatButton:SetText('Check to enable 24h format.')

   -- enable shadow
   local enDisShadow = Panel:AddCheckbox(Panel, "Check to enable a shadow on the clock.", BobTheClockDB, clockshadow)
   enDisShadow:SetPoint("TOPLEFT", timeFormatButton, "BOTTOMLEFT", 0, -5)

   -- outline
   local enOutline = Panel:AddCheckbox(Panel, "Check to enable an outline on the clock.", BobTheClockDB, clockoutline)
   enOutline:SetPoint("TOPLEFT", enDisShadow, "BOTTOMLEFT", 0, -5)

   -- clock size
   -- local clockSlide = Panel:CreateSlider(name, text, low, high, step)

   -- Stats group
   local StatsStettings = self:CreateFontString(nil, nil, 'GameFontNormal')
   StatsStettings:SetPoint('TOPLEFT', enOutline, 'BOTTOMLEFT', 0, -10)
   StatsStettings:SetPoint('RIGHT', -32, 0)
   StatsStettings:SetJustifyH('LEFT')
   StatsStettings:SetText('Stats Settings')
   self.StatsStettings = StatsStettings

   -- show?
   local showStats = Panel:AddCheckbox(Panel, "Check to show stats (FPS, latency and memory)", BobTheClockDB, statsshow)
   showStats:SetPoint("TOPLEFT", StatsStettings, "BOTTOMLEFT", 0, -5)

   -- shadow
   local shadowstats = Panel:AddCheckbox(Panel, "Check to show a shadow on the stats.", BobTheClockDB, statsshadow)
   shadowstats:SetPoint("TOPLEFT", showStats, "BOTTOMLEFT", 0, -5)

   -- outline
   local outlinestats = Panel:AddCheckbox(Panel, "Check to show an outline around the stats.", BobTheClockDB, statsoutline)
   outlinestats:SetPoint("TOPLEFT", shadowstats, "BOTTOMLEFT", 0, -5)

   Panel:refresh()
   self:SetScript('OnShow', nil)
end)

-----------------------------
-- Add the panel to the Interface Options
InterfaceOptions_AddCategory(Panel)

SLASH_bobtheclock1 = '/bobtheclock'
SlashCmdList[addonName] = function()
   InterfaceOptionsFrame_OpenToCategory(addonName)
end

