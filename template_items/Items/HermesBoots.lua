local registry = include("ItemRegistry")
local mod = include("CallbackHandler.lua")

-- SEE Items.xml for the other half of what you need to do for this item!

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
  if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
    if (player:HasCollectible(registry.Hermes)) then
      player.MoveSpeed = player.MoveSpeed * 2
    end
  end
end)

return mod:GetCallbacks()
