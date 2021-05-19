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
    tearcolor = Color(1.0, 1.0, 1.0, 1.0, 255, 255, 255),
    flying = false,
    luck = 1.00
  },
  tainted = {
    damage = 5.00,
    firedelay = 1.00,
    shotspeed = 1.00,
    range = 1.00,
    speed = 1.00,
    tearflags = TearFlags.TEAR_POISON | TearFlags.TEAR_FREEZE,
    tearcolor = Color(1.0, 1.0, 1.0, 1.0, 255, 255, 255),
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
]]
local items = {
  default = {
    --item1,
    --item2
  },
  tainted = {
    --item1,
    --item2
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
--[[
Fill in the above with the items you want your character to start with.
separated by a comma (like above, only not commented out using the '--')
the items are given to you in the order they put into the table, from top to bottom
that way items that are specific to when you get them work correctly :)

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

]]

-- CODE --

local char = Isaac.GetPlayerTypeByName(playerName, false)
local taintedChar = Isaac.GetPlayerTypeByName(taintedName or playerName, true)
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

  if (cache & CacheFlag.CACHE_SPEED == CacheFlag.SPEED) then
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
      player.CanFly = stats.default.flying
    else
      player.CanFly = stats.tainted.flying
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

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
  if (player:GetPlayerType() ~= char and player:GetPlayerType() ~= taintedChar) then return end
  local TotPlayers = #Isaac.FindByType(EntityType.ENTITY_PLAYER)
  local taint = IsTainted(player)

  if TotPlayers == 0 and game:GetFrameCount() == 0 then
    if (#items.default > 0 or #items.tainted) then
      if (not taint) then
        for i,v in ipairs(items.default) do
          player:AddCollectible(v)
        end
      else
        for i,v in ipairs(items.tainted) do
          player:AddCollectible(v)
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
  end
end)
