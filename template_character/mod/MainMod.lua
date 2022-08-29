-- Imports --

---@type string, string, function, AllCharacters, boolean
local modName, path, loadFile, characters, useCustomErrorChecker = table.unpack(...)

-- Init --
local mod = RegisterMod(modName, 1)
-- CODE --
local config = Isaac.GetItemConfig()
local game = Game()
local pool = game:GetItemPool()
local game_started = false -- a hacky check for if the game is continued.
local is_continued = false -- a hacky check for if the game is continued.

-- Utility Functions

---Gets all players that is one of your characters, returns a table of all players, or nil if none are
---@return table|nil
local function GetPlayers()
    local players = {}
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if (characters:isACharacterDescription(player)) then
            table.insert(players, player)
        end
    end
    return #players > 0 and players or nil
end

-- Character Code

---@param _ any
---@param player EntityPlayer
---@param cache CacheFlag | BitSet128
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
    if not (characters:isACharacterDescription(player)) then return end

    local playerStat = characters:getCharacterDescription(player).stats

    if (cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage + playerStat.Damage
    end

    if (cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay + playerStat.Firedelay
    end

    if (cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed + playerStat.Shotspeed
    end

    if (cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange + playerStat.Range
    end

    if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed + playerStat.Speed
    end

    if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + playerStat.Luck
    end

    if (cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING and
        playerStat.Flying) then player.CanFly = true end

    if (cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
        player.TearFlags = player.TearFlags | playerStat.Tearflags
    end

    if (cache & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = playerStat.Tearcolor
    end
end)

---applies the costume to the player
---@param CostumeName string
---@param player EntityPlayer
local function AddCostume(CostumeName, player) -- actually adds the costume.
    local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. CostumeName .. ".anm2")
    if (cost ~= -1) then player:AddNullCostume(cost) end
end

---goes through each costume and applies it
---@param AppliedCostume table
---@param player EntityPlayer
local function AddCostumes(AppliedCostume, player) -- costume logic
    if #AppliedCostume == 0 then return end
    if (type(AppliedCostume) == "table") then
        for i = 1, #AppliedCostume do
            AddCostume(AppliedCostume[i], player)
        end
    end
end

---@param player? EntityPlayer
local function postPlayerInitLate(player)
    player = player or Isaac.GetPlayer()
    if not (characters:isACharacterDescription(player)) then return end
    local statTable = characters:getCharacterDescription(player)
    if statTable == nil then return end
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
        if (charge and player:GetActiveItem()) then
            if (charge == true) then
                player:FullCharge()
            else
                player:SetActiveCharge(charge)
            end
        end
    end

    local trinket = statTable.trinket
    if (trinket) then player:AddTrinket(trinket, true) end

    if (statTable.PocketItem) then
        if statTable.isPill then
            player:SetPill(0, pool:ForceAddPillEffect(statTable.PocketItem))
        else
            player:SetCard(0, statTable.PocketItem)
        end
    end
end

---@param _ any
---@param Is_Continued boolean
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

---@param _ any
---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
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
