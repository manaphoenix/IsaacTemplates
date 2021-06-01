local registry = include("ItemRegistry")
local Game = Game()
local item = {}


-- SEE Items.xml for the other half of what you need to do for this item!
local function EvalCache(_, player, cache)
  if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
    if (player:HasCollectible(registry.Elysium)) then
      local dat = player:GetData()["ElysiumUses"] or 0 -- dat is equal to whatever ElysiumUses equals, or 0 if it doesn't have a value.
      player.Luck = player.Luck * (dat + 1) -- multiply luck by the number of times Elysium has being used for the room + 1 (because 1 times anything is itself otherwise)
    end
  end
end

local function UseItem(_, collecitble, rng, player)
  local dat = player:GetData()["ElysiumUses"] -- grab the value of ElysiumUses
  player:GetData()["ElysiumUses"] = (dat and dat + 1) or 1
  -- set the ElysiumUses to what it currently is plus one, or if it doesn't exist yet, set it to 1
end

local function NewRoom()
  for i = 0, Game:GetNumPlayers() do -- simple code to reset ElysiumUses for every player on a new room.
    local player = Isaac.GetPlayer(i)
    player:GetData()["ElysiumUses"] = 0
  end
end

function item:Init(mod)
  mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvalCache)
  mod:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, registry.Elysium) -- USE_ITEM lets us give a third arg of a filter of what collectible we want to detect got used.
  mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewRoom)
end

return item
