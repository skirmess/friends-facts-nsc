
local locale = GetLocale()

if ( locale ~= "frFR" ) then
	return
end

if ( not FRIENDS_FACTS_NSC_CONST ) then
	FRIENDS_FACTS_NSC_CONST = { }
end

FRIENDS_FACTS_NSC_CONST.OFFLINE_TEMPLATE	= "|cffbbbbbb%s- %s - Pas en ligne|r"
FRIENDS_FACTS_NSC_CONST.OFFLINE_TEMPLATE_SHORT	= "|cffbbbbbb%s- %s|r"
FRIENDS_FACTS_NSC_CONST.LEVEL_TEMPLATE_LONG	= FRIENDS_LEVEL_TEMPLATE..' - %s'

