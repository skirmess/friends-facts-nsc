
-- Copyright (c) 2010, Sven Kirmess

local Version = 12
local Loaded = false
local Realm

function FriendsFacts_FriendsFrame_SetButton(button, index, firstButton)

	local noteColor = "|cfffde05c"

	-- Add note to BNet button
	if ( button.buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
		local presenceID, givenName, surname,  toonName, toonID, client, isOnline,  lastOnline, isAFK, isDND, messageText,  noteText, isFriend, unknown =  BNGetFriendInfo(button.id)

		if ( noteText ) then
			button.info:SetText(button.info:GetText().." "..noteColor.."("..noteText..")")
		end
	end

	-- We only do the "keep history" magic for WoW friends
	if ( button.buttonType ~= FRIENDS_BUTTON_TYPE_WOW ) then
		return
	end

	local name, level, class, area, connected, status, note = GetFriendInfo(button.id)
	
	if ( not name ) then
		-- friends list not yet loaded
		return
	end

	local n = nil
	if ( note ) then
		n = noteColor.."("..note..")"
	end

	if ( not FriendsFacts_Data[Realm][name] ) then
		FriendsFacts_Data[Realm][name] = {}
	end

	if ( connected ) then

		FriendsFacts_Data[Realm][name].level = level
		FriendsFacts_Data[Realm][name].class = class
		FriendsFacts_Data[Realm][name].area = area
		FriendsFacts_Data[Realm][name].lastSeen = format('%i', time())

		if ( n ) then
			button.info:SetText(button.info:GetText().." "..n)
		end
	else

		level = FriendsFacts_Data[Realm][name].level
		class = FriendsFacts_Data[Realm][name].class

		if ( class and level ) then
			local nameText = name..", "..format(FRIENDS_LEVEL_TEMPLATE, level, class)
			button.name:SetText(nameText)
		end

		local lastSeen = FriendsFacts_Data[Realm][name].lastSeen

		if ( lastSeen ) then
			local infoText = string.format("last seen %s ago", FriendsFrame_GetLastOnline(lastSeen))
			if ( n ) then
				button.info:SetText(infoText.." "..n)
			else
				button.info:SetText(infoText)
			end
		elseif ( n ) then
			button.info:SetText(n)
		end
	end
end

local function Initialize()

	if ( Loaded ) then
		return
	end

	Loaded = true

	Realm = GetRealmName()

	-- Initialize FriendsFacts_Data
	if ( not FriendsFacts_Data ) then
		FriendsFacts_Data = {}
	end

	if ( not FriendsFacts_Data[Realm] ) then
		FriendsFacts_Data[Realm] = {}
	end

	-- Hook the FriendsList_Update handler
	hooksecurefunc(FriendsFrameFriendsScrollFrame, 'buttonFunc', FriendsFacts_FriendsFrame_SetButton)
end

local function EventHandler(self, event, ...)

        if ( event == "PLAYER_ENTERING_WORLD" ) then

                self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		Initialize()

		DEFAULT_CHAT_FRAME:AddMessage(string.format("Friends Facts NSC %i loaded.", Version))
	end
end

-- main
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", EventHandler)

