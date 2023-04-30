
-- Imports --
local characters = include("mod.stats")
local heartConverter = include("lib.heartConversion")
-- file loc
local _, _err = pcall(require, "")
---@type string
local modName = _err:match("/mods/(.*)/%.lua")

-- Init --
local mod = RegisterMod(modName, 1)
-- CODE --
local config = Isaac.GetItemConfig()
local game = Game()
local pool = game:GetItemPool()
local game_started = false -- a hacky check for if the game is continued.
local is_continued = false -- a hacky check for if the game is continued.

-- Utility Functions

---converts tearRate to the FireDelay formula, then modifies the FireDelay by the request amount, returns Modified FireDelay
---@param currentTearRate number
---@param offsetBy number
---@return number
local function calculateNewFireDelay(currentTearRate, offsetBy)
    local currentTears = 30 / (currentTearRate + 1)
    local newTears = currentTears + offsetBy
    return math.max((30 / newTears) - 1, -0.9999)
end

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

-- go through each our characters and register them to the heartConverter if need be
local didConvert = false

for i,v in pairs(characters) do
    if type(v) == "table" then
        ---@cast v CharacterSet
        local normalPType = Isaac.GetPlayerTypeByName(v.normal.name)
        if v.normal.soulHeartOnly then
            didConvert = true
            heartConverter.registerCharacterHealthConversion(normalPType, HeartSubType.HEART_SOUL)
        elseif v.normal.blackHeartOnly then
            didConvert = true
            heartConverter.registerCharacterHealthConversion(normalPType, HeartSubType.HEART_BLACK)
        end
        if v.hasTainted then
            local taintedPType = Isaac.GetPlayerTypeByName(v.tainted.name, true)
            if v.tainted.soulHeartOnly then
                didConvert = true
                heartConverter.registerCharacterHealthConversion(taintedPType, HeartSubType.HEART_SOUL)
            elseif v.tainted.blackHeartOnly then
                didConvert = true
                heartConverter.registerCharacterHealthConversion(taintedPType, HeartSubType.HEART_BLACK)
            end
        end
    end
end

if didConvert then
    heartConverter.characterHealthConversionInit(mod)
end

---@param _ any
---@param player EntityPlayer
---@param cache CacheFlag | BitSet128
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
    if not (characters:isACharacterDescription(player)) then return end

    local playerStat = characters:getCharacterDescription(player).stats

    if (playerStat.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage + playerStat.Damage
    end

    if (playerStat.Firedelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = calculateNewFireDelay(player.MaxFireDelay, playerStat.Firedelay)
    end

    if (playerStat.Shotspeed and cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed + playerStat.Shotspeed
    end

    if (playerStat.Range and cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange + playerStat.Range
    end

    if (playerStat.Speed and cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed + playerStat.Speed
    end

    if (playerStat.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + playerStat.Luck
    end

    if (cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING and playerStat.Flying == true) then player.CanFly = true end

    if (playerStat.Tearflags and cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
        player.TearFlags = player.TearFlags | playerStat.Tearflags
    end

    if (playerStat.Tearcolor and cache & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = playerStat.Tearcolor
    end
end)

---applies the costume to the player
---@param CostumeName string
---@param player EntityPlayer
local function applyCostume(CostumeName, player) -- actually adds the costume.
    local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. CostumeName .. ".anm2")
    if (cost ~= -1) then player:AddNullCostume(cost) end
end

---goes through each costume and applies it
---@param AppliedCostume table
---@param player EntityPlayer
local function addCostumes(AppliedCostume, player) -- costume logic
    if #AppliedCostume == 0 then return end
    if (type(AppliedCostume) == "table") then
        for i = 1, #AppliedCostume do
            applyCostume(AppliedCostume[i], player)
        end
    end
end

---@param player EntityPlayer
local function CriticalHitCacheCallback(player)
    if not (characters:isACharacterDescription(player)) then return end

    local playerStat = characters:getCharacterDescription(player).stats
    local data = player:GetData()

    if (playerStat.criticalChance) then
        data.critChance = data.critChance + playerStat.criticalChance
    end

    if (playerStat.criticalMultiplier) then
        data.critMultiplier = data.critMultiplier + playerStat.criticalMultiplier
    end
end

---@param player? EntityPlayer
local function postPlayerInitLate(player)
    player = player or Isaac.GetPlayer()
    if not (characters:isACharacterDescription(player)) then return end
    local statTable = characters:getCharacterDescription(player)
    if statTable == nil then return end
    -- Costume
    addCostumes(statTable.costume, player)

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

    if CriticalHit then
        CriticalHit:AddCacheCallback(CriticalHitCacheCallback)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
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

-- put your custom code here!

::EndOfFile::
