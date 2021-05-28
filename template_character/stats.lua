local stats = {}

stats.playerName = "Alpha" -- the name of your character (from the players.xml file)
stats.taintedName = "Omega" -- set this to nil if your tainted character doens't use a different name
stats.ModName = "ModName" -- Replace this with a unique ModName

stats.default = { -- Stats of your regular characters
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

stats.tainted = { -- stats of the tainted variant of your character.
  damage = 5.00,
  firedelay = 1.00,
  shotspeed = 1.00,
  range = 1.00,
  speed = 1.00,
  tearflags = TearFlags.TEAR_ECOLI,
  tearcolor = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0),
  flying = false,
  luck = 1.00
}

--[[
The way stats work all characters start with isaac's base.
then you affect starting stats from there.
fill in the above table as multipliers
aka

if you set damage to 1.00, then your character will start with 3.50 damage (the default)

EXCEPTION: Luck in game is added or subtracted from :shrug:, so the number you put there is what you want your luck to be added or subtracted from 0 (the base)

set tearflags to TearFlags.TEAR_NORMAL if you don't want your character to have any innate tear effects
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

offset values are input directly as 0-255 instead of being normalized.

the first four numbers are normalized, basically to get a normalized RGB value take the RGB value from 0-255 and divide by 255. thats the normalized number.
]]
stats.costume = {
  default = "character_alpha_cat_ears",
  tainted = ""
}
--[[
for costumes if you have one just type the name of the file without the .anm2 extension.
if you have multiple make it a table {"costume1","costume2"}.
 
if you have no costume just put "".

NOTE: your anm2 must be in ".\resources\gfx\characters" or it will not be found.
]]

stats.items = {
  default = {
    --{item1, true},
    --{item2, false}
  },
  tainted = {
    --{item1, true},
    --{item2, false}
  }
}

stats.trinket = {
  default = TrinketType.TRINKET_SWALLOWED_PENNY,
  tainted = TrinketType.TRINKET_SWALLOWED_PENNY
}
stats.card = {
  default = Card.CARD_FOOL,
  tainted = Card.CARD_FOOL
}
stats.pill = {
  default = 0,
  tainted = 0
}
stats.charge = {
  default = -1,
  tainted = -1
}
--[[
Fill in the above with the items you want your character to start with.
separated by a comma (like above, only not commented out using the '--')
the items are given to you in the order they put into the table, from top to bottom
that way items that are specific to when you get them work correctly :)

the second statement is if you want the item to render its costume. put true to remove it.

for vanilla items you can use the CollectibleType Enum
(https://wofsauge.github.io/IsaacDocs/rep/enums/CollectibleType/)

example: CollectibleType.COLLECTIBLE_BROTHER_BOBBY

for your own modded items, you use
Isaac.GetItemIdByName("CUSTOMITEM")
the Name is whatever you used in the Items.xml file

trinket is what trinket the player should start with.
if you don't want a trinket just set it to 0

pill and card is what card/pill/rune etc.. the player should start with.
if you don't want one set it 0
ONLY ONE CAN BE USED set the other to 0!

trinkets: (https://wofsauge.github.io/IsaacDocs/rep/enums/TrinketType/)
cards: (https://wofsauge.github.io/IsaacDocs/rep/enums/Card/)
pills: (https://wofsauge.github.io/IsaacDocs/rep/enums/PillColor/)

another way to get these ids is to go to the wiki, the you should see a 3 numbers separated by a period
the last number is the ID
(https://bindingofisaacrebirth.fandom.com/wiki/)

the charge variable is for how many charges you want your active item of choice to start with.
set to nil for no charge.
set to a number for specific charges
set to true for full charge :)
]]

return stats