-- we grab what was passed to us through "..."
local registry, callback = ...
---@cast registry ItemRegistry
---@cast callback ItemCallbacks

--- ItemRegistry is our registry that stores all of our items IDs for use.
--- callback is our custom class to store what each item needs in terms of callbacks, so we can combine them later into one big callback


-- SEE Items.xml for the other half of what you need to do for this item!
local function EvalCache(_, player, cache)
  if (player:HasCollectible(registry.Hermes)) then -- if the player has our item
    player.MoveSpeed = player.MoveSpeed * 2 -- multiply their speed by 2, Woosh!
  end
end

callback.add(ModCallbacks.MC_EVALUATE_CACHE, EvalCache, CacheFlag.CACHE_SPEED) -- Evaluate_Cache callback lets us pass a third argument, saying what eval we want sent to us.
