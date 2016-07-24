
-- Copyright (c) 2010-2016, Sven Kirmess

local Version = 22
local Loaded = false
local Realm
local noteColor = "|cfffde05c"

-- Add note to BNet button
local function FriendsFrame_UpdateBNETButton(button)

	local _, _, _, _, _, _, _, _, _, _, _, _, noteText, unknown = BNGetFriendInfo(button.id)

	if ( ( noteText ) and ( noteText ~= "" ) ) then
		local existingButtonText = button.info:GetText()
		if ( existingButtonText == nil ) then
			existingButtonText = ""
		else
			existingButtonText = existingButtonText.." "
		end
		button.info:SetText(existingButtonText..noteColor.."("..noteText..")")
	end
end

-- We only do the "keep history" magic for WoW friends
local function FriendsFrame_UpdateWoWButton(button)

	local name, level, class, area, connected, status, note = GetFriendInfo(button.id)

	if ( not name ) then
		-- friends list not yet loaded
		return
	end

	nameWithRealm = string.lower(name)
	if ( string.match(nameWithRealm, "-") == nil ) then
		nameWithRealm = nameWithRealm .. "-" .. string.lower(Realm)
	end

	local n = nil
	if ( ( note ) and ( note ~= "" ) ) then
		n = noteColor.."("..note..")"
	end

	if ( connected ) then

		if ( not FriendsFacts_Data2[nameWithRealm] ) then
			FriendsFacts_Data2[nameWithRealm] = {}
		end

		FriendsFacts_Data2[nameWithRealm].level = level
		FriendsFacts_Data2[nameWithRealm].class = class
		FriendsFacts_Data2[nameWithRealm].area = area
		FriendsFacts_Data2[nameWithRealm].lastSeen = format('%i', time())

		if ( n ) then
			button.info:SetText(button.info:GetText().." "..n)
		end

		return
	end

	if ( not FriendsFacts_Data2[nameWithRealm] ) then
		return
	end

	level = FriendsFacts_Data2[nameWithRealm].level
	class = FriendsFacts_Data2[nameWithRealm].class

	if ( class and level ) then
		local nameText = name..", "..format(FRIENDS_LEVEL_TEMPLATE, level, class)
		button.name:SetText(nameText)
	end

	local lastSeen = FriendsFacts_Data2[nameWithRealm].lastSeen

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

local function FriendsFrame_Update()

	local scrollFrame = FriendsFrameFriendsScrollFrame
	local buttons = scrollFrame.buttons

	local i

	for i = 1, #buttons do

		local button = buttons[i]

		if(button:IsShown()) then

			if ( button.buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
				FriendsFrame_UpdateBNETButton(button)
			end

			if ( button.buttonType == FRIENDS_BUTTON_TYPE_WOW ) then
				FriendsFrame_UpdateWoWButton(button)
			end
		end
	end
end

local function Initialize()

	if ( Loaded ) then
		return
	end

	Loaded = true

	-- Realms like "Die Arguswacht" must be called "DieArguswacht" in the friends list.
	Realm = string.gsub(GetRealmName(), "%s", "")

	-- Initialize FriendsFacts_Data2
	if ( not FriendsFacts_Data2 ) then
		FriendsFacts_Data2 = {}
	end

	-- Hook the friends list update handlers
	hooksecurefunc(FriendsFrameFriendsScrollFrame, 'update', FriendsFrame_Update)
	hooksecurefunc('FriendsFrame_UpdateFriends', FriendsFrame_Update)
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

