-- required variables for the function to function
local Game = Game()
local pool = Game:GetItemPool()
local config = Isaac.GetItemConfig()

local function GetRoomItem(defaultPool, AllowActives, MinQuality)
  defaultPool = defaultPool or ItemPoolType.POOL_GOLDEN_CHEST
  MinQuality = MinQuality or 0
  if AllowActives == nil then
    AllowActives = true
  end

  local room = Game:GetRoom()
  local itemType = pool:GetPoolForRoom(room:GetType(), room:GetAwardSeed())
  itemType = itemType > - 1 and itemType or defaultPool
  local collectible = pool:GetCollectible(itemType, false)

  if (not AllowActives or MinQuality > 0) then
    local itemConfig = config:GetCollectible(collectible)
    local active = (AllowActives == true) and true or itemConfig.Type == ItemType.ITEM_PASSIVE
    local quality = true
    if REPENTANCE then
      quality = MinQuality == 0 and true or itemConfig.Quality >= MinQuality
    end
    while (not quality or not active) do
      collectible = pool:GetCollectible(itemType, false)
      itemConfig = config:GetCollectible(collectible)
      active = (AllowActives == true) and true or itemConfig.Type == ItemType.ITEM_PASSIVE
      quality = MinQuality == 0 and true or itemConfig.Quality >= MinQuality
    end
  end

  return collectible
end