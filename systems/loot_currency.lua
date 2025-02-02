local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local m_floor = _G.math.floor
local m_random = _G.math.random
local next = _G.next
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring

-- Blizz
local Enum = _G.Enum
local C_CurrencyInfo = _G.C_CurrencyInfo

--[[ luacheck: globals
	FormatLargeNumber GameTooltip

	ITEM_QUALITY_COLORS
]]

-- Mine
local NO_GAIN_SOURCE = Enum.CurrencySource.Last

-- https://wow.tools/dbc/?dbc=currencytypes&hotfixes=true
local BLACKLIST = {
	-- 41 (Test)
	[  22] = true, -- Birmingham Test Item 3
	-- 82 (Archaeology)
	[ 384] = true, -- Dwarf Archaeology Fragment
	[ 385] = true, -- Troll Archaeology Fragment
	[ 393] = true, -- Fossil Archaeology Fragment
	[ 394] = true, -- Night Elf Archaeology Fragment
	[ 397] = true, -- Orc Archaeology Fragment
	[ 398] = true, -- Draenei Archaeology Fragment
	[ 399] = true, -- Vrykul Archaeology Fragment
	[ 400] = true, -- Nerubian Archaeology Fragment
	[ 401] = true, -- Tol'vir Archaeology Fragment
	[ 676] = true, -- Pandaren Archaeology Fragment
	[ 677] = true, -- Mogu Archaeology Fragment
	[ 754] = true, -- Mantid Archaeology Fragment
	[ 821] = true, -- Draenor Clans Archaeology Fragment
	[ 828] = true, -- Ogre Archaeology Fragment
	[ 829] = true, -- Arakkoa Archaeology Fragment
	[ 830] = true, -- n/a
	[1172] = true, -- Highborne Archaeology Fragment
	[1173] = true, -- Highmountain Tauren Archaeology Fragment
	[1174] = true, -- Demonic Archaeology Fragment
	[1534] = true, -- Zandalari Archaeology Fragment
	[1535] = true, -- Drust Archaeology Fragment
	-- 89 (Meta)
	[ 483] = true, -- Conquest Arena Meta
	[ 484] = true, -- Conquest Rated BG Meta
	[ 692] = true, -- Conquest Random BG Meta
	-- 142 (Hidden)
	[ 395] = true, -- Justice Points
	[ 396] = true, -- Valor Points
	[1171] = true, -- Artifact Knowledge
	[1324] = true, -- Horde Qiraji Commendation
	[1325] = true, -- Alliance Qiraji Commendation
	[1347] = true, -- Legionfall Building - Personal Tracker - Mage Tower (Hidden)
	[1349] = true, -- Legionfall Building - Personal Tracker - Command Tower (Hidden)
	[1350] = true, -- Legionfall Building - Personal Tracker - Nether Tower (Hidden)
	[1501] = true, -- Writhing Essence
	[1506] = true, -- Argus Waystone
	-- [1540] = true, -- Wood
	-- [1541] = true, -- Iron
	-- [1559] = true, -- Essence of Storms
	[1579] = true, -- Champions of Azeroth
	[1592] = true, -- Order of Embers
	[1593] = true, -- Proudmoore Admiralty
	[1594] = true, -- Storm's Wake
	[1595] = true, -- Talanji's Expedition
	[1596] = true, -- Voldunai
	[1597] = true, -- Zandalari Empire
	[1598] = true, -- Tortollan Seekers
	[1599] = true, -- 7th Legion
	[1600] = true, -- Honorbound
	[1703] = true, -- PVP Season Rated Participation Currency
	[1705] = true, -- Warfronts - Personal Tracker - Iron in Chest (Hidden)
	[1714] = true, -- Warfronts - Personal Tracker - Wood in Chest (Hidden)
	[1722] = true, -- Azerite Ore
	[1723] = true, -- Lumber
	[1728] = true, -- Phantasma
	[1738] = true, -- Unshackled
	[1739] = true, -- Ankoan
	[1740] = true, -- Rustbolt Resistance (Hidden)
	[1742] = true, -- Rustbolt Resistance
	[1744] = true, -- Corrupted Memento
	[1745] = true, -- Nazjatar Ally - Neri Sharpfin
	[1746] = true, -- Nazjatar Ally - Vim Brineheart
	[1747] = true, -- Nazjatar Ally - Poen Gillbrack
	[1748] = true, -- Nazjatar Ally - Bladesman Inowari
	[1749] = true, -- Nazjatar Ally - Hunter Akana
	[1750] = true, -- Nazjatar Ally - Farseer Ori
	[1752] = true, -- Honeyback Hive
	[1757] = true, -- Uldum Accord
	[1758] = true, -- Rajani
	[1761] = true, -- Enemy Damage
	[1762] = true, -- Enemy Health
	[1763] = true, -- Deaths
	[1769] = true, -- Quest Experience (Standard, Hidden)
	[1794] = true, -- Atonement Anima
	[1804] = true, -- Ascended
	[1805] = true, -- Undying Army
	[1806] = true, -- Wild Hunt
	[1807] = true, -- Court of Harvesters
	[1808] = true, -- Channeled Anima
	[1810] = true, -- Redeemed Soul
	[1822] = true, -- Renown
	[1837] = true, -- The Ember Court
	[1838] = true, -- The Countess
	[1839] = true, -- Rendle and Cudgelface
	[1840] = true, -- Stonehead
	[1841] = true, -- Cryptkeeper Kassir
	[1842] = true, -- Baroness Vashj
	[1843] = true, -- Plague Deviser Marileth
	[1844] = true, -- Grandmaster Vole
	[1845] = true, -- Alexandros Mograine
	[1846] = true, -- Sika
	[1847] = true, -- Kleia and Pelegos
	[1848] = true, -- Polemarch Adrestes
	[1849] = true, -- Mikanikos
	[1850] = true, -- Choofa
	[1851] = true, -- Droman Aliothe
	[1852] = true, -- Hunt-Captain Korayn
	[1853] = true, -- Lady Moonberry
	[1877] = true, -- Bonus Experience
	[1878] = true, -- Stitchmasters
	[1880] = true, -- Ve'nari
	[1883] = true, -- Soulbind Conduit Energy
	[1884] = true, -- The Avowed
	[1887] = true, -- Court of Night
	[1888] = true, -- Marasmius
	[1889] = true, -- Adventure Campaign Progress
	[1891] = true, -- Honor from Rated
	[1902] = true, -- 9.1 - Torghast XP - Prototype - LJS
	[1903] = true, -- Invisible Reward
	[1907] = true, -- Death's Advance
	[1947] = true, -- Bonus Valor
	[1982] = true, -- The Enlightened
	[1997] = true, -- Archivists' Codex
	[2000] = true, -- Motes of Fate
	[2002] = true, -- Renown-Maruuk Centaur
	[2021] = true, -- Renown-Dragonscale Expedition
	[2023] = true, -- Dragon Isles Blacksmithing Knowledge
	[2024] = true, -- Dragon Isles Alchemy Knowledge
	[2025] = true, -- Dragon Isles Leatherworking Knowledge
	[2026] = true, -- Dragon Isles Tailoring Knowledge
	[2027] = true, -- Dragon Isles Engineering Knowledge
	[2028] = true, -- Dragon Isles Inscription Knowledge
	[2029] = true, -- Dragon Isles Jewelcrafting Knowledge
	[2030] = true, -- Dragon Isles Enchanting Knowledge
	[2031] = true, -- Dragonscale Expedition
	[2033] = true, -- Dragon Isles Skinning Knowledge
	[2034] = true, -- Dragon Isles Herbalism Knowledge
	[2035] = true, -- Dragon Isles Mining Knowledge
	[2036] = true, -- Ancient Waygate Energy
	[2087] = true, -- Renown-Tuskarr
	[2088] = true, -- Renown-Valdrakken
	[2094] = true, -- [DNT] AC Major Faction Test Renown
	[2106] = true, -- Valdrakken Accord
	[2107] = true, -- Artisan's Consortium
	[2108] = true, -- Maruuk Centaur
	[2109] = true, -- Iskaara Tuskarr
	[2148] = true, -- Red Whelp (Fire Shot)
	[2149] = true, -- Red Whelp (Lobbing Fire Nova)
	[2150] = true, -- Red Whelp (Curing Whiff)
	[2151] = true, -- Red Whelp (Mending Breath)
	[2152] = true, -- Red Whelp (Sleepy Ruby Warmth)
	[2153] = true, -- Red Whelp (Under Red Wings)
	[2165] = true, -- Profession - Public Order Capacity - Blacksmithing
	[2166] = true, -- Inspiration Catalyst Account-Wide Currency
	[2167] = true, -- Inspiration Catalyst Anti-Currency
	[2169] = true, -- Profession - Public Order Capacity - Leatherworking
	[2170] = true, -- Profession - Public Order Capacity - Alchemy
	[2171] = true, -- Profession - Public Order Capacity - Tailoring
	[2172] = true, -- Profession - Public Order Capacity - Engineering
	[2173] = true, -- Profession - Public Order Capacity - Enchanting
	[2174] = true, -- Profession - Public Order Capacity - Jewelcrafting
	[2175] = true, -- Profession - Public Order Capacity - Inscription
	-- 144 (Virtual)
	[1553] = true, -- Azerite
	[1585] = true, -- Account Wide Honor
	[1586] = true, -- Honor Level
	-- 248 (Torghast UI (Hidden))
	[1909] = true, -- Torghast - Scoreboard - Clear Percent
	[1910] = true, -- Torghast - Scoreboard - Souls Percent
	[1911] = true, -- Torghast - Scoreboard - Urns Percent
	[1912] = true, -- Torghast - Scoreboard - Hot Streak Percent
	[1913] = true, -- Torghast - Scoreboard - Total Time
	[1914] = true, -- Torghast - Scoreboard - Par Time
	[1915] = true, -- Torghast - Scoreboard - Deaths Excess Count
	[1916] = true, -- Torghast - Scoreboard - Deaths Start Count
	[1917] = true, -- Torghast - Scoreboard - Floor Reached
	[1918] = true, -- Torghast - Scoreboard - Toast Display - Time Score
	[1919] = true, -- Torghast - Scoreboard - Toast Display - Hot Streak Score
	[1920] = true, -- Torghast - Scoreboard - Toast Display - Deaths Excess Score
	[1921] = true, -- Torghast - Scoreboard - Toast Display - Total Score
	[1922] = true, -- Torghast - Scoreboard - Toast Display - Total Rewards
	[1923] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Souls Rescued
	[1924] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Urns Broken
	[1925] = true, -- Torghast - Scoreboard - Toast Display - Deaths Zero
	[1926] = true, -- Torghast - Scoreboard - Toast Display - Stars
	[1932] = true, -- Torghast - Scoreboard - Toast Display - Boss Killed
	[1933] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Chests Opened
	[1934] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Escorts Complete
	[1935] = true, -- Torghast - Scoreboard - Toast Display - Bonus - No Trap Damage
	[1936] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Kill Boss Fast
	[1937] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Single Stacks
	[1938] = true, -- Torghast - Scoreboard - Toast Display - Bonus - 5 Stacks
	[1939] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Broker Killer
	[1940] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Elite Slayer
	[1941] = true, -- Torghast - Scoreboard - Toast Display - Bonus - 1000 Phantasma
	[1942] = true, -- Torghast - Scoreboard - Toast Display - Bonus - 500 Phant Left
	[1943] = true, -- Torghast - Scoreboard - Toast Display - Bonus - No Deaths
	[1944] = true, -- Torghast - Scoreboard - Toast Display - Bonus - No Epics
	[1945] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Elite Unnatural
	[1946] = true, -- Torghast - Scoreboard - Toast Display - Total Rewards - AV Bonus
	[1948] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Kill Boss Faster
	[1949] = true, -- Torghast - Scoreboard - Toast Display - Bonus - 30+ Count
	[1950] = true, -- Torghast - Scoreboard - Toast Display - 1 Star Value
	[1951] = true, -- Torghast - Scoreboard - Toast Display - 2 Star Value
	[1952] = true, -- Torghast - Scoreboard - Toast Display - 3 Star Value
	[1953] = true, -- Torghast - Scoreboard - Toast Display - 4 Star Value
	[1954] = true, -- Torghast - Scoreboard - Toast Display - 5 Star Value
	[1955] = true, -- Torghast - Scoreboard - Toast Display - Points While Empowered
	[1956] = true, -- Torghast - Scoreboard - Toast Display - Points Empowered Score
	[1957] = true, -- Torghast - Scoreboard - Floor Clear Percent Floor 1
	[1958] = true, -- Torghast - Scoreboard - Floor Clear Percent Floor 2
	[1959] = true, -- Torghast - Scoreboard - Floor Clear Percent Floor 3
	[1960] = true, -- Torghast - Scoreboard - Floor Clear Percent Floor 4
	[1961] = true, -- Torghast - Scoreboard - Floor Empowered Percent Floor 1
	[1962] = true, -- Torghast - Scoreboard - Floor Empowered Percent Floor 2
	[1963] = true, -- Torghast - Scoreboard - Floor Empowered Percent Floor 3
	[1964] = true, -- Torghast - Scoreboard - Floor Empowered Percent Floor 4
	[1965] = true, -- Torghast - Scoreboard - Floor Time Floor 1
	[1966] = true, -- Torghast - Scoreboard - Floor Time Floor 2
	[1967] = true, -- Torghast - Scoreboard - Floor Time Floor 3
	[1968] = true, -- Torghast - Scoreboard - Floor Time Floor 4
	[1969] = true, -- Torghast - Scoreboard - Floor Par Time Floor 1
	[1970] = true, -- Torghast - Scoreboard - Floor Par Time Floor 2
	[1971] = true, -- Torghast - Scoreboard - Floor Par Time Floor 3
	[1972] = true, -- Torghast - Scoreboard - Floor Par Time Floor 4
	[1976] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Phant Left Group
	[1980] = true, -- Torghast - Scoreboard - Run Layer
	[1981] = true, -- Torghast - Scoreboard - Run ID
	-- 251 (Dragon Racing UI (Hidden))
	[2016] = true, -- Dragon Racing - Scoreboard - Race Complete Time
	[2017] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Fraction 1
	[2018] = true, -- Dragon Racing - Scoreboard - Race Quest ID
	[2019] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Silver
	[2020] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Gold
	[2022] = true, -- Dragon Racing - Multiplayer Race Placement
	[2037] = true, -- Dragon Racing - Scoreboard - Race Complete Time -Silver Fract 1
	[2038] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Gold Fract 1
	[2039] = true, -- Dragon Racing - Scoreboard - Personal Best - Waking Shores 1
	[2040] = true, -- Dragon Racing - Scoreboard - Personal Best Time
	[2041] = true, -- Dragon Racing - Scoreboard - Personal Best Time - Fraction 1
	[2042] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 Easy
	[2043] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 Medium
	[2044] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 Hard
	[2046] = true, -- Dragon Racing - Personal Best Record - Waking Shores 07 Easy
	[2047] = true, -- Dragon Racing - Personal Best Record - Waking Shores 07 Hard
	[2048] = true, -- Dragon Racing - Personal Best Record - Waking Shores 02 Easy
	[2049] = true, -- Dragon Racing - Personal Best Record - Waking Shores 02 Hard
	[2050] = true, -- Dragon Racing - Personal Best Record - Waking Shores 08 Easy
	[2051] = true, -- Dragon Racing - Personal Best Record - Waking Shores 08 Hard
	[2052] = true, -- Dragon Racing - Personal Best Record - Waking Shores 03 Easy
	[2053] = true, -- Dragon Racing - Personal Best Record - Waking Shores 03 Hard
	[2054] = true, -- Dragon Racing - Personal Best Record - Waking Shores 04 Easy
	[2055] = true, -- Dragon Racing - Personal Best Record - Waking Shores 04 Hard
	[2056] = true, -- Dragon Racing - Personal Best Record - Waking Shores 05 Easy
	[2057] = true, -- Dragon Racing - Personal Best Record - Waking Shores 05 Hard
	[2058] = true, -- Dragon Racing - Personal Best Record - Waking Shores 06 Easy
	[2059] = true, -- Dragon Racing - Personal Best Record - Waking Shores 06 Hard
	[2060] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 01 Easy
	[2061] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 01 Hard
	[2062] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 02 Easy
	[2063] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 02 Hard
	[2064] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 03 Easy
	[2065] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 03 Hard
	[2066] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 04 Easy
	[2067] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 04 Hard
	[2069] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains D05 Easy
	[2070] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains D06 Easy
	[2074] = true, -- Dragon Racing - Personal Best Record - Azure Span 01 Easy
	[2075] = true, -- Dragon Racing - Personal Best Record - Azure Span 01 Hard
	[2076] = true, -- Dragon Racing - Personal Best Record - Azure Span 02 Easy
	[2077] = true, -- Dragon Racing - Personal Best Record - Azure Span 02 Hard
	[2078] = true, -- Dragon Racing - Personal Best Record - Azure Span 03 Easy
	[2079] = true, -- Dragon Racing - Personal Best Record - Azure Span 03 Hard
	[2080] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 01 Easy
	[2081] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 01 Hard
	[2082] = true, -- Dragon Racing - Personal Best Record - Waking Shores MP 1
	[2083] = true, -- Dragon Racing - Personal Best Record - Azure Span 04 Easy
	[2084] = true, -- Dragon Racing - Personal Best Record - Azure Span 04 Hard
	[2085] = true, -- Dragon Racing - Personal Best Record - Azure Span 05 Easy
	[2086] = true, -- Dragon Racing - Personal Best Record - Azure Span 05 Hard
	[2089] = true, -- Dragon Racing - Personal Best Record - Azure Span 06 Easy
	[2090] = true, -- Dragon Racing - Personal Best Record - Azure Span 06 Hard
	[2091] = true, -- Dragon Racing - Tracking [DNT]
	[2092] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 02 Easy
	[2093] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 02 Hard
	[2095] = true, -- Dragon Racing - Personal Best Record - Thaldraszus MP 1
	[2096] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 03 Easy
	[2097] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 03 Hard
	[2098] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 04 Easy
	[2099] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 04 Hard
	[2100] = true, -- Dragon Racing - Versioning [DNT]
	[2101] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 05 Easy
	[2102] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 05 Hard
	[2103] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 06 Easy
	[2104] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 06 Hard
	[2110] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains MP 1
	[2111] = true, -- Dragon Racing - Personal Best Record - Azure Span MP 1
	[2119] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 07 Easy
	[2120] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 07 Hard
	[2124] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Fraction 10
	[2125] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Fraction 100
	[2126] = true, -- Dragon Racing - Scoreboard - Race Complete Time -Silver Fract 10
	[2128] = true, -- Dragon Racing - Scoreboard - Race Complete Time -Silver Fract100
	[2129] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Gold Fract 10
	[2130] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Gold Fract 100
	[2131] = true, -- Dragon Racing - Scoreboard - Personal Best Time - Fraction 10
	[2132] = true, -- Dragon Racing - Scoreboard - Personal Best Time - Fraction 100
	[2133] = true, -- Dragonriding - Accepting Passengers [DNT]
	[2154] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 Test
	[2155] = true, -- Dragon Racing - Best Time Display - Whole
	[2156] = true, -- Dragon Racing - Best Time Display - Fraction 1
	[2157] = true, -- Dragon Racing - Best Time Display - Fraction 10
	[2158] = true, -- Dragon Racing - Best Time Display - Fraction 100
	[2159] = true, -- Dragon Racing - Best Time Display - Advanced - Whole
	[2160] = true, -- Dragon Racing - Best Time Display - Advanced - Fraction 1
	[2161] = true, -- Dragon Racing - Best Time Display - Advanced - Fraction 10
	[2162] = true, -- Dragon Racing - Best Time Display - Advanced - Fraction 100
	-- 252 (Tuskarr - Fishing Nets (Hidden))
	[2113] = true, -- Tuskarr - Fishing Net - Location 01 - Net 01 - Loot
	[2114] = true, -- Tuskarr - Fishing Net - Location 01 - Net 04 (Quest) - Loot
	[2115] = true, -- Tuskarr - Fishing Net - Location 01 - Net 02 - Loot
	[2116] = true, -- Tuskarr - Fishing Net - Location 01 - Net 03 - Loot
	[2135] = true, -- Tuskarr - Fishing Net - Location 02 - Net 01 - Loot
	[2136] = true, -- Tuskarr - Fishing Net - Location 02 - Net 02 - Loot
	[2137] = true, -- Tuskarr - Fishing Net - Location 03 - Net 01 - Loot
	[2138] = true, -- Tuskarr - Fishing Net - Location 03 - Net 02 - Loot
	[2139] = true, -- Tuskarr - Fishing Net - Location 04 - Net 01 - Loot
	[2140] = true, -- Tuskarr - Fishing Net - Location 04 - Net 02 - Loot
	[2141] = true, -- Tuskarr - Fishing Net - Location 05 - Net 01 - Loot
	[2142] = true, -- Tuskarr - Fishing Net - Location 05 - Net 02 - Loot
}

-- flag[0] = 0x8
local MULT = {
	[ 944] = 0.01, -- Artifact Fragment
	[ 980] = 0.01, -- Dingy Iron Coins
	[1268] = 0.01, -- Timeworn Artifact
	[1565] = 0.01, -- Rich Azerite Fragment
	[1602] = 0.01, -- Conquest
	[2123] = 0.01, -- Bloody Tokens
	[2134] = 0.01, -- Cobalt Assembly
}

local function Toast_OnEnter(self)
	if self._data.tooltip_link then
		GameTooltip:SetHyperlink(self._data.tooltip_link)
		GameTooltip:Show()
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or FormatLargeNumber(m_abs(value)))
end

local function Toast_SetUp(event, id, quantity, isGain)
	local link = "currency:" .. id
	local toast, isNew, isQueued = E:GetToast(event, "link", link)
	if isNew then
		if C.db.profile.types.loot_currency.filters[id] and quantity < C.db.profile.types.loot_currency.filters[id] then
			toast:Recycle()

			return
		end

		local info = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
		if info then
			local color = ITEM_QUALITY_COLORS[info.quality] or ITEM_QUALITY_COLORS[1]

			toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

			if info.quality >= C.db.profile.colors.threshold then
				if C.db.profile.colors.name then
					toast.Text:SetTextColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.border then
					toast.Border:SetVertexColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.icon_border then
					toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
				end
			end

			toast.Title:SetText(isGain and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])
			toast.Text:SetText(info.name)
			toast.Icon:SetTexture(info.iconFileID)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data.count = quantity * (isGain and 1 or -1)
			toast._data.event = event
			toast._data.link = link
			toast._data.sound_file = C.db.profile.types.loot_currency.sfx and 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST
			toast._data.tooltip_link = link

			toast:HookScript("OnEnter", Toast_OnEnter)
			toast:Spawn(C.db.profile.types.loot_currency.anchor, C.db.profile.types.loot_currency.dnd)
		else
			toast:Recycle()
		end
	else
		toast._data.count = toast._data.count + quantity * (isGain and 1 or -1)
		toast.Title:SetText(toast._data.count > 0 and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])

		if isQueued then
			toast.IconText1:SetAnimatedValue(toast._data.count, true)
		else
			toast.IconText1:SetAnimatedValue(toast._data.count)

			toast.IconText2:SetText((isGain and "+" or "-") .. quantity)
			toast.IconText2.Blink:Stop()
			toast.IconText2.Blink:Play()

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function CURRENCY_DISPLAY_UPDATE(id, _, quantity, gainSource)
	if not id or BLACKLIST[id] or C.db.profile.types.loot_currency.filters[id] == -1 then
		return
	end

	if not C.db.profile.types.loot_currency.track_loss and gainSource == NO_GAIN_SOURCE then
		return
	end

	quantity = m_floor(quantity * (MULT[id] or 1))
	if quantity < 1 then
		return
	end

	Toast_SetUp("CURRENCY_DISPLAY_UPDATE", id, quantity, gainSource ~= NO_GAIN_SOURCE)
end

local listSize = 0
local newID

local function validateThreshold(_, value)
	value = tonumber(value) or 0
	return value >= -1
end

local function setThreshold(info, value)
	value = tonumber(value)
	C.db.profile.types.loot_currency.filters[tonumber(info[#info - 1])] = value
end

local function getThreshold(info)
	return tostring(C.db.profile.types.loot_currency.filters[tonumber(info[#info - 1])])
end

local function populateFilters()
	listSize = C_CurrencyInfo.GetCurrencyListSize()
	if listSize > 0 then
		local info, link, id

		for i = 1, listSize do
			info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if not info.isHeader then
				link = C_CurrencyInfo.GetCurrencyListLink(i)
				if link then
					id = tonumber(link:match("currency:(%d+)"))
					if id then
						if not C.db.profile.types.loot_currency.filters[id] then
							C.db.profile.types.loot_currency.filters[id] = 0 -- disabled by default
						end
					end
				end
			end
		end
	end
end

local function updateFilterOptions()
	if not C.db.profile.types.loot_currency.enabled then
		return
	end

	local options = t_wipe(C.options.args.types.args.loot_currency.plugins.filters)
	local nameToIndex = {}
	local info

	for id in next, C.db.profile.types.loot_currency.filters do
		info = C_CurrencyInfo.GetBasicCurrencyInfo(id)
		t_insert(nameToIndex, info.name)
	end

	t_sort(nameToIndex)

	for i = 1, #nameToIndex do
		nameToIndex[nameToIndex[i]] = i
	end

	for id in next, C.db.profile.types.loot_currency.filters do
		info = C_CurrencyInfo.GetBasicCurrencyInfo(id)

		options[tostring(id)] = {
			order = nameToIndex[info.name] + 10,
			type = "group",
			name = ("|T%s:0:0:0:0:64:64:4:60:4:60|t %s"):format(info.icon, info.name),
			args = {
				desc = {
					order = 1,
					type = "description",
					name = info.description,
				},
				threshold = {
					order = 2,
					type = "input",
					name = L["THRESHOLD"],
					desc = L["CURRENCY_THRESHOLD_DESC"],
					validate = validateThreshold,
					set = setThreshold,
					get = getThreshold,
				},
			},
		}
	end
end

-- Update filters and options when users discover new currencies
local function updateFilters()
	if C_CurrencyInfo.GetCurrencyListSize() == listSize then
		return
	end

	populateFilters()
	updateFilterOptions()
end

local function Enable()
	if C.db.profile.types.loot_currency.enabled then
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateFilters)

		populateFilters()
		updateFilterOptions()
	end
end

local function Disable()
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", updateFilters)
end

local function Test()
	-- Order Resources
	Toast_SetUp("LOOT_CURRENCY_TEST", 1220, m_random(300, 600), (NO_GAIN_SOURCE * m_random(0, 1)) == NO_GAIN_SOURCE)
end

E:RegisterOptions("loot_currency", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	track_loss = false,
	filters = {
		[1792] = 25,
	},
}, {
	name = L["TYPE_LOOT_CURRENCY"],
	get = function(info)
		return C.db.profile.types.loot_currency[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_currency[info[#info]] = value
	end,
	disabled = function(info)
		if info[#info] == "loot_currency" then
			return false
		else
			return not C.db.profile.types.loot_currency.enabled
		end
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			disabled = false,
			set = function(_, value)
				C.db.profile.types.loot_currency.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
		},
		dnd = {
			order = 2,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_TOOLTIP"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
		},
		track_loss = {
			order = 4,
			type = "toggle",
			name = L["TRACK_LOSS"],
		},
		test = {
			type = "execute",
			order = 7,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
		spacer_1 = {
			order = 8,
			type = "description",
			name = " ",
		},
		header_1 = {
			order = 9,
			type = "description",
			name = "   |cffffd200".. L["FILTERS"] .. "|r",
			fontSize = "medium",
		},
		new = {
			order = 10,
			type = "group",
			name = L["NEW"],
			args = {
				desc = {
					order = 1,
					type = "description",
					name = L["NEW_CURRENCY_FILTER_DESC"],
				},
				id = {
					order = 2,
					type = "input",
					name = L["ID"],
					dialogControl = "LSPreviewBoxCurrency",
					validate = function(_, value)
						value = tonumber(value)
						if value then
							return not not C_CurrencyInfo.GetCurrencyLink(value, 0)
						else
							return true
						end
					end,
					set = function(_, value)
						value = tonumber(value)
						if value and C_CurrencyInfo.GetCurrencyLink(value, 0) then
							newID = value
						else
							newID = nil -- jic
						end
					end,
					get = function()
						return tostring(newID or "")
					end,
				},
				add = {
					type = "execute",
					order = 3,
					name = L["ADD"],
					disabled = function()
						return not newID or C.db.profile.types.loot_currency.filters[newID] or BLACKLIST[newID]
					end,
					func = function()
						C.db.profile.types.loot_currency.filters[newID] = 0 -- disabled by default
						newID = nil

						updateFilterOptions()
					end
				},
			},
		},
	},
	plugins = {
		filters = {},
	},
})

E:RegisterSystem("loot_currency", Enable, Disable, Test)
