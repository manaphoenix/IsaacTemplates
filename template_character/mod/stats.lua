--[[
	DO NOT CHANGE, SCROLL DOWN TO CONFIG
]] local mt = {
    __index = {
        items = {},
        costume = {},
        trinket = {},
        card = {},
        pill = {},
        charge = {},
        name = ""
    }
}
function mt.__index:AddItem(id, costume)
    costume = costume or false
    table.insert(self.items, {id, costume})
end

local stats = {default = {}, tainted = {}}
setmetatable(stats.default, mt)
setmetatable(stats.tainted, mt)
local character = stats.default
local tainted = stats.tainted

character.items = {}
tainted.items = {}

--[[
	CONFIG (THIS WHERE YOU CAN CHANGE STUFF)
	Try looking at MORE_INFO at the bottom of the page if you get stuck :)
]]

--[[
	REGULAR CHARACTER SETUP
]]
character.name = "Alpha" -- The name of your character (must match the players.xml file).

character.stats = {
    damage = 2.00, -- float
    firedelay = 1.00, -- float
    shotspeed = 1.00, -- float
    range = 1.00, -- float
    speed = 1.00, -- float
    tearflags = TearFlags.TEAR_POISON | TearFlags.TEAR_FREEZE, -- Enum "TearFlags"
    tearcolor = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0), -- Color, first four arguments between 0 and 1
    flying = false, -- boolean
    luck = 1.00 -- float
}

--[[
	Replace these stats with the values you want, make sure you use the correct type.

	These stats are ADDED TO Isaac's Default Stats.
	This means that if you put damage as 2.00, it will ADD 2 damage to 3.50 (The Base),
	giving a total damage of 5.50.
	Put negative values to subtract from base stats.

	Base Stats:
	Speed: 1.00
	Firedelay: 2.73
	Damage: 3.50
	Range: 6.50
	Shotspeed: 1.00
	Luck: 0.00

	Tear Flags:
	For multiple tear effects, you must seperate each tear flag using the '|' (bitwise or) symbol.
	You can find a list of TearFlags here: https://wofsauge.github.io/IsaacDocs/rep/enums/TearFlags.html?h=tears
	Write tearflags = TearFlags.TEAR_NORMAL, if you don't want your character to have any innate tear effects.
]]

character.costume = "character_alpha_cat_ears"
--[[
	Put the name of the costume file here.
	If you have multiple, you need to make it a "table"
	like this:
	character.costume = {"costume 1","costume 2"}

	If you are not using a costume for this character, put character.costume =  "".

	NOTE: your anm2 must be in ".\resources\gfx\characters" or it will not be found.
]]

character:AddItem(CollectibleType.COLLECTIBLE_SAD_ONION) -- I want Sad Onion and give me the costume.
character:AddItem(CollectibleType.COLLECTIBLE_SAD_ONION, false) -- I want Sad Onion and give me the costume.
character:AddItem(CollectibleType.COLLECTIBLE_SAD_ONION, true) -- I want Sad Onion and remove the costume
--[[
  For every item you want to add to your character repeat this line.
  character:AddItem(ItemID, RemoveCostume)
  
  ItemID is the item ID you want to add, you can use the CollectibleType Enum to make this easier (like shown in the example)
  
  RemoveCostume is if you want to remove that items' costume.
  Put true if you want to remove it.
  Put false or just don't include it if you want to keep the costume.
  
  If you do not want to add any items to this character, just remove all of these lines.
	  
	You can find a list of avaliable CollectibleType's here: https://wofsauge.github.io/IsaacDocs/rep/enums/CollectibleType?q=coll
]]

character.trinket = TrinketType.TRINKET_NULL
--[[
	Use the above line to give the character a starting trinket.
	If you do not want a starting trinket, put
	character.trinket = TrinketType.TRINKET_NULL

	You can find a list of avaliable TrinketType's here: https://wofsauge.github.io/IsaacDocs/rep/enums/TrinketType?q=trinket
]]

character.card = Card.CARD_FOOL
--[[
	Use the above line to give the character a starting Card.
	
	If you do not want a starting Card, put
	character.card = Card.CARD_NULL

	You can find a list of avaliable Cards here: https://wofsauge.github.io/IsaacDocs/rep/enums/Card?q=card

	NOTE: Exclusive, you cannot give both a Card and a Pill
]]

character.pill = false
--[[
	Use the above line to give the character a starting Pill.
	If you do not want a starting Pill, put false

	You can find a list of avaliable PillEffect's here: https://wofsauge.github.io/IsaacDocs/rep/enums/PillEffect?q=pill

	NOTE: Exclusive, you cannot give both a card and a pill
]]

character.charge = -1
--[[
	Use the above line to give your starting active item a default charge
	set to -1 for no charge.
	set to a number for specific charges
	set to true for full charge :)

	If you do not have an active item, leave it at -1 :)
]]

--[[
	TAINTED CHARACTER SETUP

	Now do it all again for your tainted character :)
]]
tainted.enabled = true -- set this to false if you don't want a tainted character.

tainted.name = "Omega"
tainted.stats = {
    damage = 2.00,
    firedelay = 1.00,
    shotspeed = 1.00,
    range = 1.00,
    speed = 1.00,
    tearflags = TearFlags.TEAR_POISON | TearFlags.TEAR_FREEZE,
    tearcolor = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0),
    flying = false,
    luck = 1.00
}

tainted.costume = ""

tainted.trinket = TrinketType.TRINKET_SWALLOWED_PENNY

tainted.card = Card.CARD_FOOL

tainted.pill = false

tainted.charge = -1

tainted:AddItem(CollectibleType.COLLECTIBLE_SAD_ONION) -- I want Sad Onion and give me the costume.

--[[
	--MORE INFO:--
	
	--Tear Color Info:--
	for tearcolor the first 4 numbers are the color of the base tear, and the last 3 numbers are for the "overlay" tear color
	default value is (1,1,1,1,0,0,0)

	color is R,G,B,A,R0,G0,B0
	Red
	Green
	Blue
	Alpha (Transparency)
	Red offset
	Green offset
	Blue Offset

	The first four numbers are normalized between 0 and 1, basically to get a normalized RGB value take the RGB value from 0-255 and divide by 255. thats the normalized number.
	
	Offset values are input directly as 0-255 instead of being normalized.
	
	--Item Info:--
	For vanilla items, here are links to vanilla Enumerators:
	Vanilla Items: https://wofsauge.github.io/IsaacDocs/rep/enums/CollectibleType.html
	Trinkets: https://wofsauge.github.io/IsaacDocs/rep/enums/TrinketType.html
	Cards: https://wofsauge.github.io/IsaacDocs/rep/enums/Card.html
	Pills: https://wofsauge.github.io/IsaacDocs/rep/enums/PillColor.html

	For modded items, use these functions instead:
	Isaac.GetItemIdByName("CUSTOMITEM")
	Isaac.GetPillEffectByName("CUSTOMPILL")
	Isaac.GetCardIdByName("cardHudName")
	Isaac.GetTrinketIdByName("trinketName")
	Make sure to use the same name as in the items.xml file.
]]

return stats
