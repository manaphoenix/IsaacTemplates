-- Imports --
local modName, path, loadFile, stats, imports, useCustomErrorChecker =
    table.unpack(...)

do
    if (useCustomErrorChecker) then
        local errorChecker = loadFile("lib/cerror")

        -- Utilities
        local function checkName(name, tainted)
            if (not name) then
                errorChecker.printError("No character name found!")
            else
                local c = Isaac.GetPlayerTypeByName(name, tainted)
                if (c == -1) then
                    errorChecker.printError("No Character Found by the name of", name)
                    errorChecker.printError("Double check your players.xml file!")
                end
            end
        end

        local function costume(costume)
            local cost = Isaac.GetCostumeIdByPath(
                             "gfx/characters/" .. costume .. ".anm2")
            if (cost == -1) then
                errorChecker.printError("No costume found by the name of", costume)
            end
        end

        local function checkCostume(costumes)
            if costumes == "" then return end

            if type(costumes) == "table" then
                for i = 1, #costumes do costume(costumes[i]) end
            else
                costume(costumes)
            end
        end

        local function checkItems(items)
            if (#items > 0) then
                for i = 1, #items do
                    local item = items[i]
                    if type(item) ~= "table" then
                        errorChecker.printError("Item Entry #", i,
                                         " is not in the correct format!")
                        errorChecker.printError(
                            "Please make sure its in the format AddItem(ITEMID, REMOVECOSTUME)")
                    else
                        if (item[1] == -1) then
                            errorChecker.printError("Item Entry #", i, " is not found!")
                            errorChecker.printError("This is in the modded item format")
                            errorChecker.printError(
                                "Double check your items.xml and stats.lua to ensure the name matches")
                        end
                    end
                end
            end
        end

        local function checkGeneric(val, name, def)
            if val == nil then
                errorChecker.printError("Invalid Entry for", name,
                                 "Are you sure your typing it right?")
            end
            if def and val == -1 then
                errorChecker.printError("Entry", name, "is not found!")
                errorChecker.printError("This is in the modded format")
                errorChecker.printError("Double check your spelling it right!")
            end
        end

        -- Default
        errorChecker.printError("Regular Character Checker:")

        local character = stats.default

        checkName(character.name, false)

        checkCostume(character.costume)

        checkItems(character.items)

        checkGeneric(character.trinket, "trinket", -1)

        checkGeneric(character.card, "card", -1)

        checkGeneric(character.pill, "pill", -1)

        checkGeneric(character.charge, "charge")

        if (errorChecker.getErrorCount() == 1) then
            errorChecker.clearErrors()
        end

        -- Tainted
        if (stats.tainted.enabled) then
            errorChecker.printError("Tainted Character Checker:")

            character = stats.tainted

            checkName(character.name, true)

            checkCostume(character.costume)

            checkItems(character.items)

            checkGeneric(character.trinket, "trinket", -1)

            checkGeneric(character.card, "card", -1)

            checkGeneric(character.pill, "pill", -1)

            checkGeneric(character.charge, "charge")
            

            if (errorChecker.getErrorCount() == 1) then
                errorChecker.clearErrors()
            end
        end

        if (stats.default.name == "Alpha" or (stats.tainted.name == "Omega" and stats.tainted.enabled)) then
            errorChecker.printError("You must change the character(s) name from the default!")
            errorChecker.printError("Name: " .. stats.default.name)
            if (stats.tainted.enabled) then
                errorChecker.printError("Name: " .. stats.tainted.name)
            end
        end

        -- checker
        if (errorChecker.getErrorCount() > 0) then
            errorChecker.registerError()
            errorChecker.setMod(modName)
            errorChecker.setFile("stats.lua")

            errorChecker.mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,
                                         function(_, IsContin)
                local room = Game():GetRoom()

                for i = 0, 8 do room:RemoveDoor(i) end
            end)

            local room = Game():GetRoom()

            for i = 0, 8 do room:RemoveDoor(i) end
            goto EndOfFile
        end
    end
end

-- Init --
local mod = RegisterMod(modName, 1)

if (type(imports) == "table") then imports:Init(mod) end

-- CODE --
local config = Isaac.GetItemConfig()
local game = Game()
local pool = game:GetItemPool()
local game_started = false -- a hacky check for if the game is continued.
local is_continued = false -- a hacky check for if the game is continued.
local char = Isaac.GetPlayerTypeByName(stats.default.name, false)
local taintedChar = Isaac.GetPlayerTypeByName(stats.tainted.name, true)
taintedChar = taintedChar == -1 and char or taintedChar

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
        player.TearRange = player.TearRange + playerStat.range
    end

    if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed + playerStat.speed
    end

    if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + playerStat.luck
    end

    if (cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING and
        playerStat.flying) then player.CanFly = true end

    if (cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
        player.TearFlags = player.TearFlags | playerStat.tearflags
    end

    if (cache & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = playerStat.tearcolor
    end
end)

local function AddCostume(CostumeName, player) -- actually adds the costume.
    local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. CostumeName .. ".anm2")
    if (cost ~= -1) then player:AddNullCostume(cost) end
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
    if (trinket ~= 0) then player:AddTrinket(trinket, true) end

    local pill = statTable.pill
    if (pill ~= false) then player:SetPill(0, pool:ForceAddPillEffect(pill)) end

    local card = statTable.card
    if (card ~= 0) then player:SetCard(0, card) end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, Is_Continued)
    if (not Is_Continued) then
        is_continued = false
        postPlayerInitLate()
    end
    game_started = true
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    game_started = false
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_,player)
    if (game_started == false) then return end
    if (not is_continued) then
        postPlayerInitLate(player)
    end
end)

--[[
    // ModCallbacks.MC_POST_PEFFECT_UPDATE (4)
// PlayerTypeCustom.FOO
export function fooPostPEffectUpdate(player: EntityPlayer): void {
  convertRedHeartContainersToBlackHearts(player);
  removeRedHearts(player);
}

function convertRedHeartContainersToBlackHearts(player: EntityPlayer) {
  const maxHearts = player.GetMaxHearts();
  if (maxHearts > 0) {
    player.AddMaxHearts(maxHearts * -1, false);
    player.AddBlackHearts(maxHearts);
  }
}

/**
 * We also have to check for normal red hearts, so that the player is not able to fill bone hearts
 * (by e.g. picking up a healing item like Breakfast).
 */
function removeRedHearts(player: EntityPlayer) {
  const hearts = player.GetHearts();
  if (hearts > 0) {
    player.AddHearts(hearts * -1);
  }
}

/**
 * ModCallbacks.MC_PRE_PICKUP_COLLISION (38)
 * PickupVariant.PICKUP_HEART (10)
 *
 * Even though this character can never have any red heart containers, it is still possible for
 * them to have a bone heart and then touch a red heart to fill the bone heart. If this happened,
 * code in the PostPEffectUpdate callback would immediately cause the red hearts to be removed, but
 * it would still erroneously delete the pickup. To work around this, prevent this character from
 * colliding with any red hearts.
 */
export function fooPrePickupCollisionHeart(
  pickup: EntityPickup,
  collider: Entity,
): boolean | undefined {
  if (!isRedHeart(pickup)) {
    return undefined;
  }

  const player = collider.ToPlayer();
  if (player === undefined) {
    return undefined;
  }

  const character = player.GetPlayerType();
  if (character !== PlayerTypeCustom.FOO) {
    return undefined;
  }

  return false;
}
]]

-- put your custom code here!

::EndOfFile::
