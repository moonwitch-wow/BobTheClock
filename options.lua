------------------------------------------------------------------------
-- Namespaceing
------------------------------------------------------------------------
local addonName, ns = ...
local buttons = {}

-----------------------------
-- Defaults
local defaults = {
   timeform24 = true,
   clockcolor = {255/255, 204/255, 0/255},
   clockshadow = true,
   clocksize = 32,
   clockfont = STANDARD_TEXT_FONT,
   statsshow = true,
   statscolor = {255/255, 204/255, 0/255},
   statsshadow = true,
   statssize = 14,
   statsfont = STANDARD_TEXT_FONT,
   framelock = true,
   framescale = 2,
}

------------------------------------------------------------------------
-- Main Catefgory Frame
-- Register in the Interface Addon Options GUI
-- Set the name for the Category for the Options Panel
------------------------------------------------------------------------
local Panel = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
Panel.name = addonName
Panel:Hide()

function Panel:AddCheckbox(checkname, checktext, point, anchor, rpoint)
   local template = "UICheckButtonTemplate"
   local checkButton = CreateFrame("Button", checkname, UIParent, template) --frameType, frameName, frameParent, frameTemplate
   checkButton:SetPoint(point, anchor, rpoint, 0, -5)
   checkButton.text = checkname.."Text"
   checkButton.text:SetText(checktext)
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
   local timeFormat = self:CreateFontString(nil, nil, 'GameFontNormal')
   timeFormat:SetPoint("TOPLEFT", Description, 'BOTTOMLEFT', 0, -10)
   timeFormat:SetText('Check for 24H timeformat')
   local timeFormatButton = Panel:AddCheckbox('TimeFormatBox', 'Check to enable 24h format', 'LEFT', timeFormat, 'RIGHT')

   self:SetScript('OnShow', nil)
end)

-----------------------------
-- Add the panel to the Interface Options
InterfaceOptions_AddCategory(Panel)

