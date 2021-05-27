local stats = include("stats")
if (stats.ModName == "ModName") then
  error("Must have a unique mod name")
  return
end

local mod = RegisterMod(stats.ModName, 1)
local imports = include("includes")

if (type(imports) == "table") then
  imports:Init(mod)
end

-- CODE --

local char = Isaac.GetPlayerTypeByName(stats.playerName, false)
local taintedChar = Isaac.GetPlayerTypeByName(stats.taintedName or stats.playerName, true)
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
      player.Luck = player.Luck + stats.default.luck
    else
      player.Luck = player.Luck + stats.tainted.luck
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
    AddCostume(stats.costume.default, player)
  else
    AddCostume(stats.costume.tainted, player)
  end

  -- Items
  if (#stats.items.default > 0 or #stats.items.tainted) then
    if (not taint) then
      for i, v in ipairs(stats.items.default) do
        player:AddCollectible(v[1])
        if (v[2]) then
          local ic = config:GetCollectible(v[1])
          player:RemoveCostume(ic)
        end
      end
      if (player:GetActiveItem() and stats.charge.default) then
        if (stats.charge.default == true) then
          player:FullCharge()
        else
          player:SetActiveCharge(stats.charge.default)
        end
      end
    else
      for i, v in ipairs(stats.items.tainted) do
        player:AddCollectible(v[1])
        if (v[2]) then
          local ic = config:GetCollectible(v[1])
          player:RemoveCostume(ic)
        end
      end
      if (player:GetActiveItem() and stats.charge.tainted) then
        if (stats.charge.tainted == true) then
          player:FullCharge()
        else
          player:SetActiveCharge(stats.charge.tainted)
        end
      end
    end
  end

  if (REPENTANCE and ((stats.trinket.default ~= 0 and not taint) or (stats.trinket.tainted ~= 0 and taint))) then
    if (not taint) then
      player:AddTrinket(stats.trinket.default, true)
    else
      player:AddTrinket(stats.trinket.tainted, true)
    end
  end

  if (stats.pill.default ~= 0 and not taint) or (stats.pill.tainted ~= 0 and taint) then
    if (not taint) then
      player:SetPill(0, stats.pill.default)
    else
      player:SetPill(0, stats.pill.tainted)
    end
  end

  if (stats.card.default ~= 0 and not taint) or (stats.card.tainted ~= 0 and taint) then
    if (not taint) then
      player:SetCard(0, stats.card.default)
    else
      player:SetCard(0, stats.card.tainted)
    end
  end
end)