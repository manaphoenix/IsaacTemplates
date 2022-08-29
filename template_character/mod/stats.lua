local Characters = require("lib.CharacterTemplateLib")

-- first we make a new character
local Alpha = Characters.newCharacter("Alpha")
--[[
	When calling newCharacter you can pass in the characters name to set that
	you can also pass in false if this character does not have a tainted variant

	if your tainted character has a different name you will need to set it afterwards
	by doing:
	
	Alpha.tainted.name = "" -- name here

	however, the base game gives the tainted and regular variant of a character the same name in the code
	so if you want to be like the game, it should be the same.
]]

-- next we setup all the characters stuff:
-- Note: anything you don't want you don't need to put, just remove it

Alpha:AddCostume("character_alpha_cat_ears")
--[[
	To add a costume you do
	Character:AddCostume(ID)
	
	you can do this multiple times if you have multiple costumes.

	If your character does not have a costume you can remove this line

	NOTE: your anm2 must be in ".\resources\gfx\characters" or it will not be found.
]]

Alpha:AddItem(CollectibleType.COLLECTIBLE_SAD_ONION) -- I want Sad Onion and give me the costume.
Alpha:AddItem(CollectibleType.COLLECTIBLE_SAD_ONION, false) -- I want Sad Onion and give me the costume.
Alpha:AddItem(CollectibleType.COLLECTIBLE_SAD_ONION, true) -- I want Sad Onion and remove the costume
--[[
  For every item you want to add to your character repeat this line.
  character:AddItem(ItemID, RemoveCostume)
  
  ItemID is the item ID you want to add, you can use the CollectibleType Enum to make this easier (like shown in the example)
  
  RemoveCostume is if you want to remove that items' costume.
  Put true if you want to remove it.
  Put false or just don't include it if you want to keep the costume.
  
  If you do not want to add any items to this character, just remove all of these lines.
	  
  You can find a list of avaliable CollectibleType's here: https://wofsauge.github.io/IsaacDocs/rep/enums/CollectibleType.html
]]

Alpha:SetTrinket(TrinketType.TRINKET_PETRIFIED_POOP)
--[[
	Use the above line to give the character a starting trinket.
	If you do not want a starting trinket, just remove this line

	You can find a list of avaliable TrinketType's here: https://wofsauge.github.io/IsaacDocs/rep/enums/TrinketType.html
]]

Alpha:SetPocketItem(Card.CARD_FOOL)
--[[
	Use the above line to give the character a starting PocketItem.
	
	It can be either a card like above
	or a pill

	if you want a pill you need to do
	SetPocketItem(CardID, true) -- true means that your telling the template that this is a pill not a card.

	if you do not want a starting PocketItem you can just remove this line.

	You can find a list of avaliable Cards here: https://wofsauge.github.io/IsaacDocs/rep/enums/Card.html
	You can find a list of avaliable PillEffect's here: https://wofsauge.github.io/IsaacDocs/rep/enums/PillEffect.html

	NOTE: Exclusive, you cannot give both a Card and a Pill
]]

Alpha:SetCharge(1) -- set the starting charge for your Active item, the value must be greater than 0 or true
--[[
	Use the above line to give your starting active item a default charge
	if you have no active item, or you want no charges, you can just remove this line.
	set to a number for specific charges
	set to true for full charge :)
]]

-- next we need to setup our players stats
local NormalStats = Characters.newStatTable() -- create a new stat table
NormalStats.Damage = 5.50
NormalStats.Firedelay = 3.73
NormalStats.Shotspeed = 2.00
NormalStats.Range = 7.50
NormalStats.Speed = 2.00
NormalStats.Tearflags = TearFlags.TEAR_POISON | TearFlags.TEAR_FREEZE
NormalStats.Tearcolor = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0) -- Color, first four arguments between 0 and 1
NormalStats.Flying = false
NormalStats.Luck = 1.00

Alpha:SetStats(NormalStats)

--[[
	Replace these stats with the values you want, make sure you use the correct type.

	These stats override the base stats (see below), which are based on Isaac,
	
	You only need to include the stats you want to change, if you don't want them, just remove the line

	Base Stats:
	Speed: 1.00
	Firedelay: 2.73
	Damage: 3.50
	Range: 6.50
	Shotspeed: 1.00
	Luck: 0.00
	Tearflags: none
	Flying: false
	Tearcolor: none (defaults to white, so there is no reason to set this)

	Tear Flags:
	For multiple tear effects, you must seperate each tear flag using the '|' (bitwise or) symbol.
	You can find a list of TearFlags here: https://wofsauge.github.io/IsaacDocs/rep/enums/TearFlags.html
]]

--[[
	TAINTED CHARACTER SETUP

	Now do it all again for your tainted character :)
]]
Alpha:SetTrinket(TrinketType.TRINKET_SWALLOWED_PENNY, true)
-- its just like above, except we add a "true" onto the end to tell the template that this is the tainted variant were talking about

Alpha:AddItem(CollectibleType.COLLECTIBLE_INNER_EYE, false, true) -- I want Sad Onion and give me the costume.
-- again just like above, except we need to add true as the third option to let the template know were talking about the tainted variant

Alpha:SetPocketItem(PillEffect.PILLEFFECT_BAD_GAS, true, true) -- this is a pill, so the second option is true, and third option tells the template its the tainted variant
-- even if this is a card you would need the third option
-- so it would look like "Alpha:SetPocketItem(CardType, false, true)" meaning, its a card so set the second one to false, and third tells the template its the tainted variant

local TaintedStats = Characters.newStatTable() -- create a new stat table
TaintedStats.Damage = 5.50
TaintedStats.Firedelay = 3.73
TaintedStats.Shotspeed = 2.00
TaintedStats.Range = 7.50
TaintedStats.Speed = 2.00
TaintedStats.Tearflags = TearFlags.TEAR_POISON | TearFlags.TEAR_FREEZE
TaintedStats.Tearcolor = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0) -- Color, first four arguments between 0 and 1
TaintedStats.Flying = false
TaintedStats.Luck = 1.00

Alpha:SetStats(TaintedStats, true) -- true again at the end, getting the idea now?

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

return Characters.build() -- last thing we call to tell the character builder were done.
