local ItemLib = include("lib.itemLib")  -- important to use include here, require will only make one copy and we each item to get its own copy
local itemRegistry = ItemLib
.registries                             -- each item will also need access to the item registry for filtering purpose or what have you.

-- SEE Items.xml for the other half of what you need to do for this item!
local function EvalCache(_, player, _)                                            -- when the cache eval is triggered
  if (player:HasCollectible(itemRegistry.Elysium)) then                           -- check to make sure the player has our collectible.
    local dat = player:GetEffects():GetCollectibleEffectNum(itemRegistry.Elysium) -- dat is equal to whatever ElysiumUses equals, or 0 if it doesn't have a value.
    player.Luck = player.Luck *
    (dat + 1)                                                                     -- multiply luck by the number of times Elysium has being used for the room + 1 (because 1 times anything is itself otherwise)
  end
end

ItemLib:add(ModCallbacks.MC_EVALUATE_CACHE, EvalCache)

return ItemLib
