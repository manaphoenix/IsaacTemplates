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

-- Utility Functions
local function IsChar(player)
  if (player == nil) then return nil end
  local ptype = player:GetPlayerType()
  if (ptype ~= char and ptype ~= taintedChar) then return false end
  return true
end
-- this function will return if the player is one of your characters.
-- returns true if it is a character of yours, false if it isn't, and nil if the player doesn't exist.


local function IsTainted(player)
  if (player == nil) then return nil end
  local ptype = player:GetPlayerType()
  if (ptype ~= char and ptype ~= taintedChar) then return nil end
  if (ptype == char) then return false end
  return true
end
-- returns whether the inputted character is a tainted variant of your character.
-- returns true if is tainted, false if not, and nil for any other reason. (like it not being ur character at all)

local function GetPlayers()
  local players = {}
  for i = 0, game:GetNumPlayers() - 1 do
    local player = Isaac.GetPlayer(i)
    local ptype = player:GetPlayerType()
    if (ptype == char or ptype == taintedChar) then
      table.insert(players, player)
    end
  end
  return #players > 0 and players or nil
end
-- will return a table of all players that are your character (or nil if none are)
-- use this to get the players when the function your using doesn't give it to you.

local function GetCorrectStat(tab, player)
  local taint = IsTainted(player)
  if (taint) then
    return tab.tainted
  else
    return tab.default
  end
end
-- used to automatically grab the tainted or default variant of a stat from stats.lua.
-- based on the inputted player.

-- Character Code
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
  if not (IsChar(player)) then return end

  local playerStat = GetCorrectStat(stats, player)

  if (cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
    player.Damage = player.Damage + playerStat.damage
  end

  if (cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
    player.MaxFireDelay = player.MaxFireDelay + playerStat.firedelay
  end

  if (cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
    player.ShotSpeed = player.ShotSpeed + playerStat.shotspeed
  end

  if (cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
    player.TearHeight = player.TearHeight + playerStat.range
  end

  if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
    player.MoveSpeed = player.MoveSpeed + playerStat.speed
  end

  if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
    player.Luck = player.Luck + playerStat.luck
  end

  if (cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING) then
    if (playerStat.flying) then
      player.CanFly = true
    end
  end

  if (cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
    player.TearFlags = player.TearFlags | playerStat.tearflags
  end

  if (cache & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR) then
    player.TearColor = playerStat.tearcolor
  end
end)

local function AddCostume(CostumeName, player) -- actually adds the costume.
  local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. CostumeName .. ".anm2")
  if (cost ~= -1) then
    player:AddNullCostume(cost)
  end
end

local function AddCostumes(AppliedCostume, player) -- costume logic
  if (type(AppliedCostume) == "table") then
    for i = 1, #AppliedCostume do
      AddCostume(AppliedCostume[i], player)
    end
  else
    AddCostume(AppliedCostume, player)
  end
end

local function postPlayerInitLate(player)
  local player = player or Isaac.GetPlayer()
  if not (IsChar(player)) then return end
  local taint = IsTainted(player)
  -- Costume
  AddCostumes(GetCorrectStat(stats.costume, player), player)

  local items = GetCorrectStat(stats.items, player)
  if (#items > 0) then
    for i, v in ipairs(items) do
      player:AddCollectible(v[1])
      if (v[2]) then
        local ic = config:GetCollectible(v[1])
        player:RemoveCostume(ic)
      end
    end
    local charge = GetCorrectStat(stats.charge, player)
    if (player:GetActiveItem() and charge ~= -1) then
      if (charge == true) then
        player:FullCharge()
      else
        player:SetActiveCharge(charge)
      end
    end
  end

  local trinket = GetCorrectStat(stats.trinket, player)
  if (trinket ~= 0) then
    player:AddTrinket(trinket, true)
  end

  local pill = GetCorrectStat(stats.pill, player)
  if (pill ~= 0) then
    player:SetPill(0, pool:ForceAddPillEffect(pill))
  end

  local card = GetCorrectStat(stats.card, player)
  if (card ~= 0) then
    player:SetCard(0, card)
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