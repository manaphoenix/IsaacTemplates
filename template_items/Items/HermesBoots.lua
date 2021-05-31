local registry = include("ItemRegistry")
local item = {}

-- SEE Items.xml for the other half of what you need to do for this item!
local function EvalCache(_, player, cache)
  if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
    if (player:HasCollectible(registry.Hermes)) then
      player.MoveSpeed = player.MoveSpeed * 2
    end
  end
end

function item:Init(mod)
  mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvalCache)
end

return item
