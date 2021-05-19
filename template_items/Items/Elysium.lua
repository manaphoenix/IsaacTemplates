local registry = include("ItemRegistry")
local mod = include("CallbackHandler.lua")

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, player, playerTouched)
  
end, PickupVariant.PICKUP_COLLECTIBLE)

return mod:GetCallbacks()
