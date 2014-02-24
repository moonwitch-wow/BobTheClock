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
      return string.format("%.1f %s", n / 1024, 'MB')
   else
      return string.format("%.0f %s", n, 'KB')
   end
end

local BobTheClock = CreateFrame("Button", 'BobTheClock', UIParent) -- baseframe
BobTheClock:SetSize(175, 50)
BobTheClock:RegisterForClicks()

local BobTheClockStats = BobTheClock:CreateFontString(nil, nil, nil)
local BobTheClockTime = BobTheClock:CreateFontString(nil, nil, nil)

function BobTheHandler:PLAYER_LOGIN()
   local bobtime
   if (BobTheClockDB.timeform24 == true) then
      bobtime = date("%H:%M")
   else
      bobtime = date('%I:%M %p')
   end

   -- Bob wanted a huge clock
   BobTheClockTime:SetFont(BobTheClockDB.clockfont, BobTheClockDB.clocksize)
   BobTheClockTime:SetTextColor(unpack(BobTheClockDB.clockcolor))
   BobTheClockStats:SetFont(BobTheClockDB.statsfont, BobTheClockDB.statssize)
   BobTheClockStats:SetTextColor(unpack(BobTheClockDB.statscolor))

   BobTheClock:SetPoint("TOP", UIParent, 'TOP', 0, -5)
   BobTheClockTime:SetPoint("TOP", BobTheClock, 'TOP', 0, 0)
   BobTheClockStats:SetPoint("TOP", BobTheClockTime, 'BOTTOM', 0, -5)

   BobTheClockTime:SetText(bobtime)

   -- if BobTheClockDB.framelock == false then
   --    -- BobTheClock:SetBackdrop(BACKDROP)
   --    -- BobTheClock:SetBackdropColor(0, 1, 0, .5)
   --    BobTheClock:SetMovable(true)
   --    BobTheClock:EnableMouse(true)
   --    BobTheClock:SetUserPlaced(true)
   --    BobTheClock:RegisterForDrag('RightButton')
   --    BobTheClock:SetScript("OnDragStart", function() BobTheClock:StartMoving() end)
   --    BobTheClock:SetScript("OnDragStop", function() BobTheClock:StopMovingOrSizing() end)
   -- end
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

   BobTheClockStats:SetText(fps .. 'fps  ' .. lag .. 'ms  ' .. formatMemory(mem))
end)

BobTheClock:SetScript("OnMouseDown", function(self)
   collectgarbage('collect')
   SendChatMessage("Hey Bob!", "RAID_WARNING")
end)

------------------------------------------------------------------------
-- Popping the frame
------------------------------------------------------------------------
