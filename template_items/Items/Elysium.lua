-- we grab what was passed to us through "..."
local registry, callback = ...
---@cast registry ItemRegistry
---@cast callback ItemCallbacks

--- ItemRegistry is our registry that stores all of our items IDs for use.
--- callback is our custom class to store what each item needs in terms of callbacks, so we can combine them later into one big callback

--- This item needs the Game() so we init it here.
local Game = Game()

-- SEE Items.xml for the other half of what you need to do for this item!
local function EvalCache(_, player, cache) -- when the cache eval is triggered
  if (player:HasCollectible(registry.Elysium)) then -- check to make sure the player has our collectible.
    local dat = player:GetData()["ElysiumUses"] or 0 -- dat is equal to whatever ElysiumUses equals, or 0 if it doesn't have a value.
    player.Luck = player.Luck * (dat + 1) -- multiply luck by the number of times Elysium has being used for the room + 1 (because 1 times anything is itself otherwise)
  end
end

local function UseItem(_, collecitble, rng, player)
  local dat = player:GetData()["ElysiumUses"] -- grab the value of ElysiumUses
  player:GetData()["ElysiumUses"] = (dat and dat + 1) or 1
  -- set the ElysiumUses to what it currently is plus one, or if it doesn't exist yet, set it to 1
end

local function NewRoom()
  for i = 0, Game:GetNumPlayers() - 1 do -- starting at 0, for every player that is in the session minus one (b/c player index starts at 0)
    local player = Isaac.GetPlayer(i) -- get the player at index [i]
    player:GetData()["ElysiumUses"] = 0 -- set their ElysiumUses to 0
  end
end

callback.add(ModCallbacks.MC_USE_ITEM, UseItem, registry.Elysium) -- USE_ITEM lets us give a third arg of a filter of what collectible we want to detect got used.
callback.add(ModCallbacks.MC_POST_NEW_ROOM, NewRoom) -- this callback is triggered anytime isaac enters a new room (NOTE: this triggers on re-entering rooms we've already been in too...)
callback.add(ModCallbacks.MC_EVALUATE_CACHE, EvalCache, CacheFlag.CACHE_LUCK) -- Evaluate_Cache callback lets us pass a third argument, saying what eval we want sent to us.
