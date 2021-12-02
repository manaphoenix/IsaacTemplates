local function GetPedestals()
    local game = game or Game()
    local pool = pool or game:GetItemPool()
    local config = config or Isaac.GetItemConfig()
    local Pedestals = {}

    local items = Isaac.FindByType(EntityType.ENTITY_PICKUP,
                                   PickupVariant.PICKUP_COLLECTIBLE)
    if (#items == 0) then return nil end
    for i = 1, #items do
        local item = items[i]:ToPickup()
        local iConfig = config:GetCollectible(item.SubType)
        table.insert(Pedestals, {
            CollectibleType = item.SubType,
            Pedestal = item,
            Pool = pool:GetLastPool(),
            Tags = iConfig.Tags,
            Quality = iConfig.Quality,
            Config = iConfig
        })
    end

    return Pedestals
end
