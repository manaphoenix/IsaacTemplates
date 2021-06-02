--[[
DO NOT CHANGE SCROLL DOWN TO CONFIG
]]
local mt = {
  __index = {
    items = {},
    costume = "",
    trinket = 0,
    card = 0,
    pill = 0,
    charge = -1,
    name = ""
  }
}
local stats = {
  default = {},
  tainted = {}
}
setmetatable(stats.default, mt)
setmetatable(stats.tainted, mt)
local character = stats.default
local tainted = stats.tainted

--[[
CONFIG (THIS WHERE YOU CHANGE STUFF)
]]

stats.ModName = "ModName" -- Replace this with a unique ModName

--[[
REGULAR CHARACTER SETUP
]]
character.name = "Alpha" -- the name of your character (from the players.xml file)
character.stats = {
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
--[[
These are the base stats of your character OFFSET FROM Isaac's Default Stats.
Meaning if you put Damage as 2.00 it will ADD 2 MORE damage from 3.50 (The Base)
making it a total of 5.50.
Put negatives to subtract from base stats.

Base Stats:
Speed: 1.00
Firedelay: 2.73
Damage: 3.50
Range: 6.50
Shotspeed: 1.00
Luck: 0.00

NOTE: Range is currently bugged in the API changing it will do nothing :(
set tearflags to TearFlags.TEAR_NORMAL if you don't want your character to have any innate tear effects.
]]


character.costume = "character_alpha_cat_ears"
--[[
Put the name of the costume file here.
If you have multiple, you need to make it a "table"
like this:
{"costume 1","costume 2"}

If you do not have or want a costume for this character put "".

NOTE: your anm2 must be in ".\resources\gfx\characters" or it will not be found.
]]

character.items = {
  {CollectibleType.COLLECTIBLE_SAD_ONION},
  {CollectibleType.COLLECTIBLE_CRICKETS_HEAD, true}
}
--[[
  Fill in the above table with all of the items you want your character to start with.
  you can add a comma, and put "true" if you want to remove the costume that comes with that item.
  
  IF you do not want to add any items to this character here, just put
  character.items = {}
  
  Format:
  {COLLECTIBLETYPE, REMOVECOSTUME}
]]

character.trinket = TrinketType.TRINKET_SWALLOWED_PENNY
--[[
  Use the above line to give the character a starting trinket.
  If you do not want a starting trinket, put 0
]]

character.card = Card.CARD_FOOL
--[[
  Use the above line to give the character a starting Card.
  If you do not want a starting card, put 0
  NOTE: Exclusive, you cannot give both a card and a pill
]]

character.pill = 0
--[[
  Use the above line to give the character a starting Pill.
  If you do not want a starting Pill, put 0
  NOTE: Exclusive, you cannot give both a card and a pill
]]

character.charge = -1
--[[
Use the above line to give your starting active item a default charge
set to -1 for no charge.
set to a number for specific charges
set to true for full charge :)

If you do not have an active item, just leave at -1 :)
]]

--[[
TAINTED CHARACTER SETUP

Now do it all again for your tainted character :)
]]
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

tainted.items = {}

tainted.trinket = TrinketType.TRINKET_SWALLOWED_PENNY

tainted.card = Card.CARD_FOOL

tainted.pill = 0

tainted.charge = -1


--[[
MORE INFO:
-- tear color info
for tearcolor the first 4 numbers are the color of the base tear, and the last 3 numbers are for shifting the first 3.
default value is (1,1,1,1,0,0,0)

color is R,G,B,A,R0,G0,B0
Red
Green
Blue
Alpha (Transparency)
Red offset
Green offset
Blue Offset

Offset values are from -inf to inf.
what "Shifting" or "Offsetting" actually does is manipulate the intensity of the RGB values.
if you don't know what that means, I highly suggest leaving it at 0,0,0 (or ya know play with it :shrug: it won't hurt anything)

the first four numbers are normalized, basically to get a normalized RGB value take the RGB value from 0-255 and divide by 255. thats the normalized number.

-- Links
Vanilla Items: https://wofsauge.github.io/IsaacDocs/rep/enums/CollectibleType/
Trinkets: (https://wofsauge.github.io/IsaacDocs/rep/enums/TrinketType/)
Cards: (https://wofsauge.github.io/IsaacDocs/rep/enums/Card/)
Pills: (https://wofsauge.github.io/IsaacDocs/rep/enums/PillColor/)

-- Modded Items
-- Name refers to what it is in the items.xml file.
Isaac.GetItemIdByName("CUSTOMITEM")
Isaac.GetPillEffectByName("CUSTOMPILL")
Isaac.GetCardIdByName("cardHudName")
Isaac.GetTrinketIdByName("trinketName")
]]

return stats