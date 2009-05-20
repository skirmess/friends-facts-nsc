--[[
FriendsFacts NSC (no Sea Cosmos)

This add-on is based on version 1.1 of FriendsFacts from AnduinLothar
which did not use Sea nor Cosmos. It is updated to work with WoW 2.0.
This is for all the people who would like to use FriendsFacts without
the huge Sea/Cosmos overhead.

Remember friends level, class, location and the last time you've seen
them online after they've logged off and show then in your friend
list.
]]--

local FriendsFacts_Version = 5
local FriendsFacts_loaded = false
local realm
local L = FRIENDS_FACTS_NSC_CONST

-- The following code returns a table containing
-- {year=years, month=months, day=days, hour=hours, min=minutes, sec=seconds}
-- representing the time between two dates created by os.time - by RichardWarburton.
--
-- http://lua-users.org/wiki/DayOfWeekAndDaysInMonthExample

local function timeDiff(t2,t1)

	if (t2 < t1) then
		return
	end

	local d1,d2,carry,diff = date('*t',t1),date('*t',t2),false,{}
	local colMax = {60,60,24,date('*t',time{year=d1.year,month=d1.month+1,day=0}).day,12}
	d2.hour = d2.hour - (d2.isdst and 1 or 0) + (d1.isdst and 1 or 0) -- handle dst
	for i,v in ipairs({'sec','min','hour','day','month','year'}) do 
		diff[v] = d2[v] - d1[v] + (carry and -1 or 0)
		carry = diff[v] < 0
		if carry then diff[v] = diff[v] + colMax[i] end
	end
	return diff
end

function FriendsFacts_FriendsList_Update()

	local nameLocationText
	local infoText
	local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame)
	local numFriends = GetNumFriends()
	local now = time()

	for i=1, numFriends do
		local name, level, class, area, connected, status = GetFriendInfo(i)

		if ( name ) then
			if ( connected ) then

				if ( not FriendsFacts_Data[realm][name] ) then
					FriendsFacts_Data[realm][name] = {}
				end

				FriendsFacts_Data[realm][name].level = level
				FriendsFacts_Data[realm][name].class = class
				FriendsFacts_Data[realm][name].area = area
				FriendsFacts_Data[realm][name].lastSeen = format('%i', time())

			elseif ( i > friendOffset ) and ( i <= friendOffset+FRIENDS_TO_DISPLAY ) and ( FriendsFacts_Data[realm][name] ) then

				nameLocationText = getglobal("FriendsFrameFriendButton"..(i-friendOffset).."ButtonTextNameLocation")
				infoText = getglobal("FriendsFrameFriendButton"..(i-friendOffset).."ButtonTextInfo")
				level = FriendsFacts_Data[realm][name].level
				class = FriendsFacts_Data[realm][name].class
				local lastSeen = FriendsFacts_Data[realm][name].lastSeen
				if ( not class ) then
					class = "UNKNOWN"
				end
				area = FriendsFacts_Data[realm][name].area
				if ( not area ) then
					area = "UNKNOWN"
				end
				nameLocationText:SetText(format(TEXT(L["OFFLINE_TEMPLATE"]), name, area))
				if ( nameLocationText:GetWidth() > 275 ) then
					nameLocationText:SetText(format(TEXT(L["OFFLINE_TEMPLATE_SHORT"]), name, area))
					nameLocationText:SetJustifyH("LEFT")
					nameLocationText:SetWidth(275)
				end
				if ( level ) and ( class ) and ( lastSeen ) then
					local td = timeDiff(now, tonumber(lastSeen))
					infoText:SetText(format(TEXT(L["LEVEL_TEMPLATE_LONG"]), level, class, RecentTimeDate(td.year, td.month, td.day, td.hour)))
				elseif ( level ) and ( class ) then
					infoText:SetText(format(TEXT(FRIENDS_LEVEL_TEMPLATE), level, class))
				end
			end
		end
	end
end

local function FriendsFacts_init()

	if ( FriendsFacts_loaded ) then
		return
	end

	FriendsFacts_loaded = true

	realm = GetRealmName()

	-- Initialize FriendsFacts_Data
	if ( not FriendsFacts_Data ) then
		FriendsFacts_Data = {}
	end

	if ( not FriendsFacts_Data[realm] ) then
		FriendsFacts_Data[realm] = {}
	end

	-- Hook the FriendsList_Update handler
	hooksecurefunc("FriendsList_Update", FriendsFacts_FriendsList_Update)

	DEFAULT_CHAT_FRAME:AddMessage(string.format("Friends Facts NSC %i loaded.", FriendsFacts_Version))
end

function FriendsFacts_OnEvent(event)

	if ( event == "VARIABLES_LOADED" ) then
		this:UnregisterEvent("VARIABLES_LOADED")
		FriendsFacts_init()
	end
end

