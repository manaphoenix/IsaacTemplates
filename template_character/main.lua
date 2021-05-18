local mod = RegisterMod("MODNAME", 1) -- Replace the Mod name with something unique.
local playerName = "MyCustomCharacter" -- the name of your character (from the players.xml file)
local isTainted = false -- is this a tainted character?

local stats = {
  damage = 1.00,
  firedelay = 1.00,
  shotspeed = 1.00,
  range = 1.00,
  speed = 1.00,
  tearflags = TearFlags.TEAR_POISON | TearFlags.TEAR_FREEZE,
  tearcolor = Color(1.0, 1.0, 1.0, 1.0, 255, 255, 255),
  flying = false,
  luck = 1.00
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
  -- item1,
  -- item2
}
local trinket = TrinketType.TRINKET_SWALLOWED_PENNY
local card = Card.CARD_FOOL
local pill = 0
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

local char = Isaac.GetPlayerTypeByName(playerName, isTainted)
local game = Game()

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
  if (player:GetPlayerType() ~= char) then return end

  if (cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
    player.Damage = player.Damage * stats.damage
  end

  if (cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
    player.MaxFireDelay = player.MaxFireDelay * stats.firedelay
  end

  if (cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
    player.ShotSpeed = player.ShotSpeed * stats.shotspeed
  end

  if (cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
    player.TearHeight = player.TearHeight * stats.range
  end

  if (cache & CacheFlag.CACHE_SPEED == CacheFlag.SPEED) then
    player.MoveSpeed = player.MoveSpeed * stats.speed
  end

  if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
    player.Luck = player.Luck * stats.luck
  end

  if (cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING) then
    player.CanFly = stats.flying
  end

  if (cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
    player.TearFlags = player.TearFlags | stats.tearflags
  end

  if (cache & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR) then
    player.TearColor = stats.tearcolor
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
  local TotPlayers = #Isaac.FindByType(EntityType.ENTITY_PLAYER)

  if TotPlayers == 0 and game:GetFrameCount() == 0 then
    if (#items > 0) then
      for i,v in ipairs(items) do
        player:AddCollectible(v)
      end
    end

    if (REPENTANCE and trinket ~= 0) then
      player:AddTrinket(trinket, true)
    end

    if pill ~= 0 then
      player:SetPill(0, pill)
    end

    if card ~= 0 then
      player:SetCard(0, card)
    end
  end
end)
