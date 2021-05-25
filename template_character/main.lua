local mod = RegisterMod("MODNAME", 1) -- Replace the Mod name with something unique.
local playerName = "Alpha" -- the name of your character (from the players.xml file)
local taintedName = "Omega" -- set this to nil if your tainted character doens't use a different name

local stats = {
  default = {
    damage = 2.00,
    firedelay = 1.00,
    shotspeed = 1.00,
    range = 1.00,
    speed = 1.00,
    tearflags = TearFlags.TEAR_POISON | TearFlags.TEAR_FREEZE,
    tearcolor = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0),
    flying = false,
    luck = 1.00
  },
  tainted = {
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
}

--[[
The way stats work all characters start with isaac's base.
then you affect starting stats from there.
fill in the above table as multipliers
aka

if you set damage to 1.00, then your character will start with 3.50 damage (the default)

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
local costume = {
  default = "character_alpha_cat_ears",
  tainted = ""
}
--[[
for costumes if you have one just type the name of the file without the .anm2 extension.
if you have multiple make it a table {"costume1","costume2"}.
 
if you have no costume just put "".

NOTE: your anm2 must be in ".\resources\gfx\characters" or it will not be found.
]]

local items = {
  default = {
    --{item1, true},
    --{item2, false}
  },
  tainted = {
    --{item1, true},
    --{item2, false}
  }
}

local trinket = {
  default = TrinketType.TRINKET_SWALLOWED_PENNY,
  tainted = TrinketType.TRINKET_SWALLOWED_PENNY
}

local card = {
  default = Card.CARD_FOOL,
  tainted = Card.CARD_FOOL
}
local pill = {
  default = 0,
  tainted = 0
}
local charge = {
  default = nil,
  tainted = nil
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
(trinket variable only workks in rep, will be ignored otherwise)

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

-- CODE --

local char = Isaac.GetPlayerTypeByName(playerName, false)
local taintedChar = Isaac.GetPlayerTypeByName(taintedName or playerName, true)
local config = Isaac.GetItemConfig()
local game = Game()
local function IsTainted(player)
  if (player:GetPlayerType() ~= char and player:GetPlayerType() ~= taintedChar) then return nil end

  if player:GetPlayerType() == char then return false end

  return true
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
  if (player:GetPlayerType() ~= char and player:GetPlayerType() ~= taintedChar) then return end
  local taint = IsTainted(player)

  if (cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
    if (not taint) then
      player.Damage = player.Damage * stats.default.damage
    else
      player.Damage = player.Damage * stats.tainted.damage
    end
  end

  if (cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
    if (not taint) then
      player.MaxFireDelay = player.MaxFireDelay * stats.default.firedelay
    else
      player.MaxFireDelay = player.MaxFireDelay * stats.tainted.firedelay
    end
  end

  if (cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
    if (not taint) then
      player.ShotSpeed = player.ShotSpeed * stats.default.shotspeed
    else
      player.ShotSpeed = player.ShotSpeed * stats.tainted.shotspeed
    end
  end

  if (cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
    if (not taint) then
      player.TearHeight = player.TearHeight * stats.default.range
    else
      player.TearHeight = player.TearHeight * stats.tainted.range
    end
  end

  if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
    if (not taint) then
      player.MoveSpeed = player.MoveSpeed * stats.default.speed
    else
      player.MoveSpeed = player.MoveSpeed * stats.tainted.speed
    end
  end

  if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
    if (not taint) then
      player.Luck = player.Luck * stats.default.luck
    else
      player.Luck = player.Luck * stats.tainted.luck
    end
  end

  if (cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING) then
    if (not taint) then
      if (stats.default.flying) then
        player.CanFly = true
      end
    else
      if (stats.tainted.flying) then
        player.CanFly = true
      end
    end
  end

  if (cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
    if (not taint) then
      player.TearFlags = player.TearFlags | stats.default.tearflags
    else
      player.TearFlags = player.TearFlags | stats.tainted.tearflags
    end
  end

  if (cache & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR) then
    if (not taint) then
      player.TearColor = stats.default.tearcolor
    else
      player.TearColor = stats.tainted.tearcolor
    end
  end
end)

local function AddCostume(AppliedCostume, player)
  if (type(AppliedCostume) == "table") then
    for i = 1, #AppliedCostume do
      local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. AppliedCostume[i] .. ".anm2")
      if (cost ~= -1) then
        player:AddNullCostume(cost)
      else
        print("Could not find gfx/characters/" .. AppliedCostume[i] .. ".anm2!")
      end
    end
    return
  end
  local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. AppliedCostume .. ".anm2")
  if (cost ~= -1) then
    player:AddNullCostume(cost)
  else
    if (AppliedCostume ~= "") then
      print("Could not find gfx/characters/" .. AppliedCostume .. ".anm2!")
    end
  end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
  if (player:GetPlayerType() ~= char and player:GetPlayerType() ~= taintedChar) then return end
  local taint = IsTainted(player)
  -- Costume
  if (not taint) then
    AddCostume(costume.default, player)
  else
    AddCostume(costume.tainted, player)
  end

  -- Items
  if (#items.default > 0 or #items.tainted) then
    if (not taint) then
      for i, v in ipairs(items.default) do
        player:AddCollectible(v[1])
        if (v[2]) then
          local ic = config:GetCollectible(v[1])
          player:RemoveCostume(ic)
        end
      end
      if (player:GetActiveItem() and charge.default) then
        if (charge.default == true) then
          player:FullCharge()
        else
          player:SetActiveCharge(charge.default)
        end
      end
    else
      for i, v in ipairs(items.tainted) do
        player:AddCollectible(v[1])
        if (v[2]) then
          local ic = config:GetCollectible(v[1])
          player:RemoveCostume(ic)
        end
      end
      if (player:GetActiveItem() and charge.tainted) then
        if (charge.tainted == true) then
          player:FullCharge()
        else
          player:SetActiveCharge(charge.tainted)
        end
      end
    end
  end

  if (REPENTANCE and ((trinket.default ~= 0 and not taint) or (trinket.tainted ~= 0 and taint))) then
    if (not taint) then
      player:AddTrinket(trinket.default, true)
    else
      player:AddTrinket(trinket.tainted, true)
    end
  end

  if (pill.default ~= 0 and not taint) or (pill.tainted ~= 0 and taint) then
    if (not taint) then
      player:SetPill(0, pill.default)
    else
      player:SetPill(0, pill.tainted)
    end
  end

  if (card.default ~= 0 and not taint) or (card.tainted ~= 0 and taint) then
    if (not taint) then
      player:SetCard(0, card.default)
    else
      player:SetCard(0, card.tainted)
    end
  end
end)
