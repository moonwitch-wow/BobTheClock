-------------------------------------------------------------------------------
-- Gui functions
-------------------------------------------------------------------------------
local addonName, ns = ...
local buttons = {}

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
   framelock = true,
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
function Panel:AddCheckbox(name, text, point, anchor, rpoint)
   local checkButton = CreateFrame("Button", name, Panel, "UICheckButtonTemplate")
   checkButton.text = name.."Text"
   checkButton.text:SetText(text)
end

function Panel:AddColorPicker(name, text, desc, point, anchor, rpoint)
end

function Panel:CreateSlider(name, text, parent, low, high, step)
   local slider = CreateFrame('Slider', name, parent, 'OptionsSliderTemplate')
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
   BobTheHandler:PLAYER_LOGIN()
end)

function Panel:okay()
   for key, value in pairs(temporary) do
      BobTheClockDB[key] = value
   end
end

function Panel:cancel()

end


function Panel:default()
   BobTheClockDB = defaults
   table.wipe(temporary)
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

   -- local Color = self:CreateFontString(nil, nil, 'GameFontNormal')
   local timeFormatButton = Panel:AddCheckbox('TimeFormatBox', 'Check to enable 24h format', 'LEFT', timeFormat, 'RIGHT')
   -- timeFormatButton:SetScript("OnClick", function() end)

   self:SetScript('OnShow', nil)
end)

-----------------------------
-- Add the panel to the Interface Options
InterfaceOptions_AddCategory(Panel)

