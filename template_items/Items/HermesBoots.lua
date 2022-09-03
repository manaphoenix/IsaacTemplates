local itemRegistry = require("Registries/ItemRegistry")

-- SEE Items.xml for the other half of what you need to do for this item!
local function EvalCache(_, player, cache)
  if (player:HasCollectible(itemRegistry.Hermes)) then -- if the player has our item
    player.MoveSpeed = player.MoveSpeed * 2 -- multiply their speed by 2, Woosh!
  end
end

callbacks.add(ModCallbacks.MC_EVALUATE_CACHE, EvalCache, CacheFlag.CACHE_SPEED) -- Evaluate_Cache callback lets us pass a third argument, saying what eval we want sent to us.
