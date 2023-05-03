local ItemLib = include("lib.itemLib")  -- important to use include here, require will only make one copy and we each item to get its own copy
local itemRegistry = ItemLib
.registries                             -- each item will also need access to the item registry for filtering purpose or what have you.

-- SEE Items.xml for the other half of what you need to do for this item!
local function EvalCache(_, player, cache)
  if (player:HasCollectible(itemRegistry.Hermes)) then -- if the player has our item
    player.MoveSpeed = player.MoveSpeed * 2            -- multiply their speed by 2, Woosh!
  end
end

ItemLib:add(ModCallbacks.MC_EVALUATE_CACHE, EvalCache, CacheFlag.CACHE_SPEED)

return ItemLib
