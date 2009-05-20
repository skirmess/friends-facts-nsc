--[[
FriendsFacts NSC (no Sea Cosmos) 4

This add-on is based on version 1.1 of FriendsFacts from AnduinLothar
which did not use Sea nor Cosmos. It is updated to work with WoW 2.0.
This is for all the people who would like to use FriendsFacts without
the huge Sea/Cosmos overhead.

Remember friends level, class, location and the last time you've seen
them online after they've logged off and show then in your friend
list.
]]--

local FriendsFacts_Version = 4
local FriendsFacts_loaded = false
local realm = ''


function FriendsFacts_FriendsList_Update()

	local nameLocationText
	local infoText
	local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame)
	local numFriends = GetNumFriends()

	for i=1, numFriends do
		local name, level, class, area, connected, status = GetFriendInfo(i)

		if (name) then
			if (connected) then

				if ( not FriendsFacts_Data[realm][name] ) then
					FriendsFacts_Data[realm][name] = {}
				end

				FriendsFacts_Data[realm][name].level = level
				FriendsFacts_Data[realm][name].class = class
				FriendsFacts_Data[realm][name].area = area
				FriendsFacts_Data[realm][name].lastSeen = format('%i', time())

			elseif (i > friendOffset) and (i <= friendOffset+FRIENDS_TO_DISPLAY) and (FriendsFacts_Data[realm][name]) then

				nameLocationText = getglobal("FriendsFrameFriendButton"..(i-friendOffset).."ButtonTextNameLocation")
				infoText = getglobal("FriendsFrameFriendButton"..(i-friendOffset).."ButtonTextInfo")
				level = FriendsFacts_Data[realm][name].level
				class = FriendsFacts_Data[realm][name].class
				local lastSeen = FriendsFacts_Data[realm][name].lastSeen
				if ( not class ) then
					class = TEXT(UNKNOWN)
				end
				area = FriendsFacts_Data[realm][name].area
				if ( not area ) then
					area = TEXT(UNKNOWN)
				end
				nameLocationText:SetText(format(TEXT(FriendsFacts_Constants.FRIENDS_FACTS_OFFLINE_TEMPLATE), name, area))
				if ( nameLocationText:GetWidth() > 275 ) then
					nameLocationText:SetText(format(TEXT(FriendsFacts_Constants.FRIENDS_FACTS_OFFLINE_TEMPLATE_SHORT), name, area))
					nameLocationText:SetJustifyH("LEFT")
					nameLocationText:SetWidth(275)
				end
				if ( level ) and ( class ) and ( lastSeen ) then
					infoText:SetText(format(TEXT(FriendsFacts_Constants.FRIENDS_FACTS_LEVEL_TEMPLATE_LONG), level, class, date('%a %d %b %y %H:%M', lastSeen)))
				elseif ( level ) and ( class ) then
					infoText:SetText(format(TEXT(FRIENDS_LEVEL_TEMPLATE), level, class))
				end
			end
		end
	end
end


function FriendsFacts_init()

	if ( FriendsFacts_loaded ) then
		return
	end
	FriendsFacts_loaded = true

	realm = GetRealmName()

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


