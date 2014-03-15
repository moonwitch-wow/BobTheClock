------------------------------------------------------------------------
-- Base Setup
------------------------------------------------------------------------
local addonName, ns = ...

local BACKDROP = {
   bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], tile = true, tileSize = 16,
   -- edgeFile = [=[Interface\Tooltips\UI-Tooltip-Border]=], edgeSize = 0,
   insets = {left = 4, right = 4, top = 4, bottom = 4}
}

------------------------------------------------------------------------
-- Local
------------------------------------------------------------------------

local gameHours, gameMinutes = GetGameTime()
local UPDATEPERIOD = 0.5
local elapsed = 0.5
local GetNetStats, GetFramerate, collectgarbage = GetNetStats, GetFramerate, collectgarbage

local BobTheHandler = CreateFrame("Frame", 'BobTheHandler') -- frame for the updates

------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------
local function formatMemory(n)
   if n > 999 then
      return string.format("%.1f%s", n / 1024, 'MB')
   else
      return string.format("%.0f%s", n, 'KB')
   end
end

local BobTheClock = CreateFrame("Frame", 'BobTheClock', UIParent) -- baseframe
BobTheClock:SetSize(175, 50)
-- BobTheClock:RegisterForClicks()
BobTheClock:EnableMouse(true)

local BobTheClockStats = BobTheClock:CreateFontString(nil, nil, nil)
local BobTheClockTime = BobTheClock:CreateFontString(nil, nil, nil)

function BobTheHandler:PLAYER_LOGIN()
   -- Bob wanted a huge clock
   BobTheClockTime:SetFont(BobTheClockDB.clockfont, BobTheClockDB.clocksize, BobTheClockDB.clockoutline)
   BobTheClockTime:SetTextColor(unpack(BobTheClockDB.clockcolor))
   if BobTheClockDB.clockshadow == true then
      BobTheClockTime:SetShadowColor(unpack(BobTheClockDB.shadowcolor))
      BobTheClockTime:SetShadowOffset(1, -1)
   else
      BobTheClockTime:SetShadowColor(0,0,0,0)
      BobTheClockTime:SetShadowOffset(0,0)
   end

   BobTheClockStats:SetFont(BobTheClockDB.statsfont, BobTheClockDB.statssize, BobTheClockDB.statsoutline)
   BobTheClockStats:SetTextColor(unpack(BobTheClockDB.statscolor))
   if BobTheClockDB.statsshadow == true then
      BobTheClockStats:SetShadowColor(unpack(BobTheClockDB.shadowcolor))
      BobTheClockStats:SetShadowOffset(1, -1)
   else
      BobTheClockStats:SetShadowColor(0,0,0,0)
      BobTheClockStats:SetShadowOffset(0,0)
   end
   if (not BobTheClock:IsUserPlaced()) then
      BobTheClock:SetPoint('TOP', UIParent, 'TOP', 0, -5)
   end
   BobTheClockTime:SetPoint("TOP", BobTheClock, 'TOP', 0, 0)
   BobTheClockStats:SetPoint("TOP", BobTheClockTime, 'BOTTOM', 0, -5)
end

------------------------------------------------------------------------
-- OnUpdate - getting the info
------------------------------------------------------------------------
BobTheHandler:SetScript("OnUpdate", function(self, count)
   elapsed = elapsed + count
   if elapsed < UPDATEPERIOD then return end

   elapsed = 0
   local fps = floor(GetFramerate())
   local _, _, lag = GetNetStats()
   local mem = collectgarbage("count")
   UpdateAddOnMemoryUsage()

   local bobtime
   if (BobTheClockDB.timeform24 == true) then
      bobtime = date("%H:%M")
   else
      bobtime = date('%I:%M %p')
   end

   BobTheClockTime:SetText(bobtime)

   BobTheClockStats:SetText(fps .. 'fps  ' .. lag .. 'ms  ' .. formatMemory(mem))
end)

BobTheClock:SetScript("OnMouseDown", function(self, button)
   if button == "LeftButton" then
      collectgarbage('collect')
      SendChatMessage("Hey Bob!", "RAID_WARNING")
   elseif button == "RightButton" then
      SendChatMessage("I am teh Bob, who drank the awesomesauce!", "GUILD")
   end
end)

------------------------------------------------------------------------
-- Popping the frame
------------------------------------------------------------------------

