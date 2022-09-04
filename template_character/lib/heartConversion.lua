---@type number
local ConversionHeartSubType = HeartSubType.SOUL | HeartSubType.BLACK

---@class characterHealthReplacementMap
local characterHealthReplacementMap = {}

---sets the player type
---@param playerType PlayerType
---@param HeartST HeartSubType
function characterHealthReplacementMap.set(playerType, HeartST)
    characterHealthReplacementMap[playerType] = HeartST
end

---returns if the table already contains subtype
---@param playerType PlayerType
---@return boolean
function characterHealthReplacementMap.has(playerType)
    return characterHealthReplacementMap[playerType] and true or false
end

---returns the subtype
---@param playerType PlayerType
---@return HeartSubType | nil
function characterHealthReplacementMap.get(playerType)
    return characterHealthReplacementMap[playerType] or nil
end

---removes normal red hearts
---@param player EntityPlayer
local function removeRedHearts(player)
    local hearts = player:GetHearts();
    if hearts > 0 then
        player:AddHearts(hearts * -1)
    end
end

---converts heart containers to the right type
---@param player EntityPlayer
---@param conversionType HeartSubType
local function convertRedHeartContainers(player, conversionType)
    local maxHearts = player:GetMaxHearts();
    if (maxHearts == 0) then
      return;
    end

    player:AddMaxHearts(maxHearts * -1, false);

    if conversionType == HeartSubType.SOUL then
        player:AddSoulHearts(maxHearts);
    elseif conversionType == HeartSubType.BLACK then
        player:AddBlackHearts(maxHearts);
    end
end

---returns if the pickup is a red heart
---@param pickup EntityPickup
local function isRedHeart(pickup)
 -- TODO
    return pickup.Variant == PickupVariant.HEART and (pickup.SubType == HeartSubType.HEART_HALF or pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_DOUBLEPACK)
end

---stop player from colliding with hearts their not allowed to pickup
---@param pickup EntityPickup
---@param collider Entity
local function prePickupCollisionHeart(pickup, collider)
    if (not isRedHeart(pickup)) then
        return nil
    end

    local player = collider:ToPlayer()
    if player == nil then
        return nil
    end

    local ptype = player:GetPlayerType()
    local conversionHeartSubType = characterHealthReplacementMap.get(ptype);
    if (conversionHeartSubType == nil) then
        return nil
    end

    return false
end

---PEffect Update
---@param _ any
---@param player EntityPlayer
local function postPEffectUpdate(_, player)
    local ptype = player:GetPlayerType();
    local conversionHeartSubType = characterHealthReplacementMap.get(ptype);
    if (conversionHeartSubType == nil) then
      return;
    end

    convertRedHeartContainers(player, conversionHeartSubType);
    removeRedHearts(player);
end

local module = {}

---registers the callback, internal
---@param mod mod
function module.characterHealthConversionInit(mod)
    mod:AddCallback(ModCallbacks.POST_PEFFECT_UPDATE, postPEffectUpdate)
    mod:AddCallback(ModCallbacks.PRE_PICKUP_COLLISION, prePickupCollisionHeart, PickupVariant.HEART)
end

---helper function to make a character have the same health mechanic as Blue Baby or Dark Judas
---@param playerType PlayerType
---@param conversionHeartSubType HeartSubType
function module.registerCharacterHealthConversion(playerType, conversionHeartSubType)
    if characterHealthReplacementMap.has(playerType) then
        error("Failed to register a character of type " .. playerType .. " because there is already an existing registered character with taht type.")
    end

    characterHealthReplacementMap.set(playerType, conversionHeartSubType);
end

return module