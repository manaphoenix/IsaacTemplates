-- Imports --
local stats = include("stats")
local imports = include("includes")
local char = -1
local taintedChar = -1

do
  -- Stupid Person Checking
  local f = Font()
  f:Load("font/terminus.fnt")
  local str = {}
  local x = 0

  local function out(...)
    local s = ""
    local args = table.pack(...)
    for i = 1, args.n do
      local t = args[i] or nil
      s = s .. tostring(t) .. " "
    end
    table.insert(str, s)
  end

  local function render()
    x = 45
    for i = 1, #str do
      f:DrawStringScaled(str[i], 60, x, 0.5, 0.5, KColor(1, 0, 0, 1), 0, true)
      x = x + 7
    end
  end

  local function checkForTable(tab, name, def)
    if (not tab) then
      out("Missing table:", name)
      return false
    end
    if (not tab.default) then
      out("missing default field for", name)
      return false
    elseif (def and tab.default == def) then
      out("default field returned nil for", name)
      return false
    end
    if (not tab.tainted) then
      out("missing tainted field for", name)
      return false
    elseif (def and tab.tainted == def) then
      out("tainted field returned nil for", name)
      return false
    end
    return true
  end

  if (not checkForTable(stats, "stats")) then
    goto tablechecker
  else
    local tab = stats.default
    if not (tab.damage
      and tab.firedelay and
      tab.shotspeed and
      tab.range and
      tab.tearflags and
      tab.tearcolor and
      tab.flying ~= nil and
    tab.luck) then
      out("incomplete stats table for default")
    end
    tab = stats.tainted
    if not (tab.damage
      or tab.firedelay and
      tab.shotspeed and
      tab.range and
      tab.tearflags and
      tab.tearcolor and
      tab.flying ~= nil and
    tab.luck) then
      out("incomplete stats table for default")
    end
  end

  if (not stats.ModName) then
    out("No Mod Name found!")
  elseif (stats.ModName:match("ModName")) then
    out("Mod Name must be unique!")
  end

  if (not stats.playerName) then
    out("No player name specified!")
  else
    char = Isaac.GetPlayerTypeByName(stats.playerName, false)
    taintedChar = Isaac.GetPlayerTypeByName(stats.taintedName or stats.playerName, true)
    if (char == -1) then
      out("Character Not Found:", stats.playerName)
    end
    if (taintedChar == -1) then
      out("Tainted Character Not Found:", (stats.taintedName or stats.playerName))
    end
  end

  -- costume

  if (checkForTable(stats.costume, "costume")) then
    if stats.costume.default ~= "" then
      if (type(stats.costume.default) == "table") then
        for i = 1, #stats.costume.default do
          local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. stats.costume.default[i] .. ".anm2")
          if (cost == -1) then
            out("Costume not found:", stats.costume.default[i])
          end
        end
      else
        local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. stats.costume.default .. ".anm2")
        if (cost == -1) then
          out("Costume not found:", stats.costume.default)
        end
      end
    end
    if stats.costume.tainted ~= "" then
      if (type(stats.costume.tainted) == "table") then
        for i = 1, #stats.costume.tainted do
          local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. stats.costume.tainted[i] .. ".anm2")
          if (cost == -1) then
            out("Costume not found:", stats.costume.tainted[i])
          end
        end
      else
        local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. stats.costume.tainted .. ".anm2")
        if (cost == -1) then
          out("Costume not found:", stats.costume.tainted)
        end
      end
    end
  end

  --TODO more item checks
  if (checkForTable(stats.items, "items")) then
    if (#stats.items.default > 0) then
      if (type(stats.items.default) ~= "table") then
        out("default items is not a table!")
      else
        for i = 1, #stats.items.default do
          if (type(stats.items.default[i]) ~= "table") then
            out("invalid table entry at index:", i, "in default table")
          else
            local item = stats.items.default[i][1]
            if (item == -1) then
              out("item index:", i, "is returning nil for default")
            end
          end
        end
      end
    end
    if (#stats.items.tainted > 0) then
      if (type(stats.items.tainted) ~= "table") then
        out("tainted items is not a table!")
      else
        for i = 1, #stats.items.tainted do
          if (type(stats.items.tainted[i]) ~= "table") then
            out("invalid table entry at index:", i, "in tainted table")
          else
            local item = stats.items.tainted[i][1]
            if (item == -1) then
              out("item index:", i, "is returning nil for tainted")
            end
          end
        end
      end
    end
  end

  checkForTable(stats.trinket, "trinket", - 1)

  checkForTable(stats.card, "card", - 1)

  checkForTable(stats.pill, "pill", - 1)

  checkForTable(stats.charge, "charge")

  -- checker
  ::tablechecker::

  if (#str > 0) then
    local s = {
      "Template Character Errors:"
    }
    for i = 1, #str do
      table.insert(s, str[i])
    end
    str = s

    local mod = RegisterMod("TemplateCharacterError", 1)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, render)

    goto EndOfFile
  end
end

-- Init --
local mod = RegisterMod(stats.ModName, 1)

if (type(imports) == "table") then
  imports:Init(mod)
end


-- CODE --
local config = Isaac.GetItemConfig()
local game = Game()
local pool = game:GetItemPool()
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
      player.Damage = player.Damage + stats.default.damage
    else
      player.Damage = player.Damage + stats.tainted.damage
    end
  end

  if (cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
    if (not taint) then
      player.MaxFireDelay = player.MaxFireDelay + stats.default.firedelay
    else
      player.MaxFireDelay = player.MaxFireDelay + stats.tainted.firedelay
    end
  end

  if (cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
    if (not taint) then
      player.ShotSpeed = player.ShotSpeed + stats.default.shotspeed
    else
      player.ShotSpeed = player.ShotSpeed + stats.tainted.shotspeed
    end
  end

  if (cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
    if (not taint) then
      player.TearHeight = player.TearHeight + stats.default.range
    else
      player.TearHeight = player.TearHeight + stats.tainted.range
    end
  end

  if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
    if (not taint) then
      player.MoveSpeed = player.MoveSpeed + stats.default.speed
    else
      player.MoveSpeed = player.MoveSpeed + stats.tainted.speed
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

local function postPlayerInitLate(player)
  local player = player or Isaac.GetPlayer()
  if (player:GetPlayerType() ~= char and player:GetPlayerType() ~= taintedChar) then return end
  local taint = IsTainted(player)
  -- Costume
  if (not taint) then
    AddCostume(stats.costume.default, player)
  else
    AddCostume(stats.costume.tainted, player)
  end

  if (#stats.items.default > 0 or #stats.items.tainted) then
    if (not taint) then
      for i, v in ipairs(stats.items.default) do
        player:AddCollectible(v[1])
        if (v[2]) then
          local ic = config:GetCollectible(v[1])
          player:RemoveCostume(ic)
        end
      end
      if (player:GetActiveItem() and stats.charge.default ~= -1) then
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
      if (player:GetActiveItem() and stats.charge.tainted ~= -1) then
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
      player:SetPill(0, pool:ForceAddPillEffect(stats.pill.default))
    else
      player:SetPill(0, pool:ForceAddPillEffect(stats.pill.tainted))
    end
  end

  if (stats.card.default ~= 0 and not taint) or (stats.card.tainted ~= 0 and taint) then
    if (not taint) then
      player:SetCard(0, stats.card.default)
    else
      player:SetCard(0, stats.card.tainted)
    end
  end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
  if GetPtrHash(player) ~= GetPtrHash(Isaac.GetPlayer()) then
    postPlayerInitLate (player)
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, IsContin)
  if IsContin then return end

  postPlayerInitLate ()
end)

::EndOfFile::