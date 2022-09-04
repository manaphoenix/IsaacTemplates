local itemRegistry = require("Registries/ItemRegistry")
local firstUse = true -- we have to track the first use of our item, or else it will use two charges intead of just one.

-- SEE Items.xml for the other half of what you need to do for this item!

local function TriggerEffect(player)
  local enemies = Isaac.FindInRadius(player.Position, 1000, EntityPartition.ENEMY) -- find all enemies in the room
  for _, enemy in pairs(enemies) do -- for each enemy
    enemy:Kill() -- kill them!
  end
  if firstUse then
    firstUse = not firstUse
  end
end

local function Post_Player_Update(_, player)
  if (player == nil or not player:HasCollectible(itemRegistry.Exodus)) then return end
  -- this update is ran even on the main menu ... so we have to check if player even exists.
  -- next we check if the player does not have our item
  -- in either case, we return b/c there isn't anything to check
  local effects = player:GetEffects()
  local dat = effects:GetCollectibleEffectNum(itemRegistry.Exodus) -- get the number of times the item has already being used.

  if dat > 5 then -- if its being used 5 time, just stop...
    return
  end

  -- effect trigger
  if (Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex)) then -- if our player pushes the use active item button...
    if dat >= 1 and not firstUse then -- weird thing is first click works, so we need to make sure it isn't the first click...
      effects:AddCollectibleEffect(itemRegistry.Exodus, false) -- add one to the number of times we've used the item.
    end
    TriggerEffect(player) -- then attempt to trigger the effect of our active item.
  end

  -- sync
  player:SetActiveCharge(math.max(0, (5 - dat))) -- set it to the minium value between 0, or (5-the number of times the items has being used.)
  -- using math.max just stop the edge case that somehow the dat value gets set to 6, and thus the calculation would become -1
end

callbacks.add(ModCallbacks.MC_POST_PLAYER_UPDATE, Post_Player_Update) -- this runs for every player update.
