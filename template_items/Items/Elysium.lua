local itemRegistry = require("Registries/ItemRegistry")

--- This item needs the Game() so we init it here.
local Game = Game()

-- SEE Items.xml for the other half of what you need to do for this item!
local function EvalCache(_, player, _) -- when the cache eval is triggered
  if (player:HasCollectible(itemRegistry.Elysium)) then -- check to make sure the player has our collectible.
    local dat = player:GetEffects():GetCollectibleNum(itemRegistry.Elysium)-- dat is equal to whatever ElysiumUses equals, or 0 if it doesn't have a value.
    player.Luck = player.Luck * (dat + 1) -- multiply luck by the number of times Elysium has being used for the room + 1 (because 1 times anything is itself otherwise)
  end
end

callbacks.add(ModCallbacks.MC_EVALUATE_CACHE, EvalCache, CacheFlag.CACHE_LUCK) -- Evaluate_Cache callback lets us pass a third argument, saying what eval we want sent to us.
