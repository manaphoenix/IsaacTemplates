-- Imports --
local stats = include("mod/stats")
local imports = include("mod/includes")

do
  -- Stupid Person Checking
  local f = Font()
  f:Load("font/terminus.fnt")
  local str = {}
  local x = 0
  local zero = Vector.Zero

  local sp = Sprite()
  sp:Load("gfx/ui/main menu/bestiarymenu.anm2")
  sp:Play("Idle")

  local function GetScreenSize() -- By Kilburn himself.
    local room = Game():GetRoom()
    local pos = Isaac.WorldToScreen(zero) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset

    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)

    return rx * 2 + 13 * 26, ry * 2 + 7 * 26
  end

  posx, posy = GetScreenSize()

  local pos = Vector(posx / 4, - 20)

  local function out(...)
    local s, args = "", table.pack(...)
    for i = 1, args.n do
      s = s .. tostring(args[i] or nil) .. " "
    end
    table.insert(str, s)
  end

  local function render()
    x = 45
    sp:RenderLayer(1, pos)
    for i = 1, #str do
      f:DrawStringScaled(str[i], posx / 3, x, 0.5, 0.5, KColor(1.0, 0.58039215686275, 0.58039215686275, 1), 0, true)
      x = x + 8
    end
  end

  -- Utilities
  local function checkName(name, tainted)
    if (not name) then
      out("No character name found!")
    else
      local c = Isaac.GetPlayerTypeByName(name, tainted)
      if (c == -1) then
        out("No Character Found by the name of", name)
        out("Double check your players.xml file!")
      end
    end
  end

  local function costume(costume)
    local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. costume .. ".anm2")
    if (cost == -1) then
      out("No costume found by the name of", costumes)
    end
  end

  local function checkCostume(costumes)
    if costumes == "" then return end

    if type(costumes) == "table" then
      for i = 1, #costumes do
        costume(costumes[i])
      end
    else
      costume(costumes)
    end
  end

  local function checkItems(items)
    if (#items > 0) then
      for i = 1, #items do
        local item = items[i]
        if type(item) ~= "table" then
          out("Item Entry #", i, " is not in the correct format!")
          out("Please make sure its in the format AddItem(ITEMID, REMOVECOSTUME)")
        else
          if (item[1] == -1) then
            out("Item Entry #", i, " is not found!")
            out("This is in the modded item format")
            out("Double check your items.xml and stats.lua to ensure the name matches")
          end
        end
      end
    end
  end

  local function checkGeneric(val, name, def)
    if val == nil then
      out("Invalid Entry for", name, "Are you sure your typing it right?")
    end
    if def and val == -1 then
      out("Entry", name, "is not found!")
      out("This is in the modded format")
      out("Double check your spelling it right!")
    end
  end

  -- Default
  out("Regular Character Checker:")

  local character = stats.default

  checkName(character.name, false)

  checkCostume(character.costume)

  checkItems(character.items)

  checkGeneric(character.trinket, "trinket", - 1)

  checkGeneric(character.card, "card", - 1)

  checkGeneric(character.pill, "pill", - 1)

  checkGeneric(character.charge, "charge")

  str = #str == 1 and {} or str

  -- Tainted
  out("Tainted Character Checker:")

  character = stats.tainted

  checkName(character.name, true)

  checkCostume(character.costume)

  checkItems(character.items)

  checkGeneric(character.trinket, "trinket", - 1)

  checkGeneric(character.card, "card", - 1)

  checkGeneric(character.pill, "pill", - 1)

  checkGeneric(character.charge, "charge")

  str = #str == 1 and {} or str

  -- Mod Name Check

  if (stats.ModName:match("ModName")) then
    out("Mod Name must be unique!")
  end

  -- checker

  if (#str > 0) then
    local s = {
      "Template Character PreCheck hit an Error:"
    }
    for i = 1, #str do
      table.insert(s, str[i])
    end
    str = s

    local mod = RegisterMod("TemplateCharacterError", 1)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, render)

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, IsContin)
      local room = Game():GetRoom()

      for i = 0, 8 do
        room:RemoveDoor(i)
      end

      Game():GetHUD():SetVisible(false)
    end)

    local room = Game():GetRoom()

    for i = 0, 8 do
      room:RemoveDoor(i)
    end

    Game():GetHUD():SetVisible(false)

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
local iscontin = true -- a hacky check for if the game is continued.
local char = Isaac.GetPlayerTypeByName(stats.default.name, false)
local taintedChar = Isaac.GetPlayerTypeByName(stats.tainted.name, true)

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

local function GetPlayerStatTable(player)
  local taint = IsTainted(player)
  if (taint == nil) then return nil end

  return (taint and stats.tainted) or stats.default
end
-- used to automatically grab the tainted or default variant of a stat from stats.lua.
-- based on the inputted player.

local function FindVariant(Tainted)
  local players = GetPlayers()
  local variantFound = false
  if (players) then
    for _, player in ipairs(players) do
      if (Tainted) then -- search for tainted only
        if (IsTainted(player)) then
          variantFound = true
          return variantFound, player
        end
      else -- search for regular
        if (not IsTainted(player)) then
          variantFound = true
          return variantFound, player
        end
      end
    end

  end
  return false, nil
end
-- use this function to automatically return if one of the current players is a specific variant of your character.
-- also returns the player that is your variant (WARNING: returns the first one found, their could be multiple!)
-- FindVariant(true) will return true if one of the players is a tainted version of your character, false otherwise
-- FindVariant(false) will return true if one the players is a regular version of your character, false otherwise
--[[
Use:

local tainted, player = FindVariant(true)
player:Kill() -- lol
]]

-- Character Code
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
  if not (IsChar(player)) then return end

  local playerStat = GetPlayerStatTable(player).stats

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

  if (cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING and playerStat.flying) then
    player.CanFly = true
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
  local statTable = GetPlayerStatTable(player)
  -- Costume
  AddCostumes(statTable.costume, player)

  local items = statTable.items
  if (#items > 0) then
    for i, v in ipairs(items) do
      player:AddCollectible(v[1])
      if (v[2]) then
        local ic = config:GetCollectible(v[1])
        player:RemoveCostume(ic)
      end
    end
    local charge = statTable.charge
    if (player:GetActiveItem() and charge ~= -1) then
      if (charge == true) then
        player:FullCharge()
      else
        player:SetActiveCharge(charge)
      end
    end
  end

  local trinket = statTable.trinket
  if (trinket ~= 0) then
    player:AddTrinket(trinket, true)
  end

  local pill = statTable.pill
  if (pill ~= false) then
    player:SetPill(0, pool:ForceAddPillEffect(pill))
  end

  local card = statTable.card
  if (card ~= 0) then
    player:SetCard(0, card)
  end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
  if not iscontin then
  postPlayerInitLate (player)
end
end)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, IsContin)
if IsContin then return end

iscontin = false
postPlayerInitLate ()
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
iscontin = true
end)

-- put your custom code here!

::EndOfFile::