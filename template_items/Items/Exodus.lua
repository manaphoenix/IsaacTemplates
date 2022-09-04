local itemRegistry = require("Registries/ItemRegistry")

-- SEE Items.xml for the other half of what you need to do for this item!

local function TriggerEffect(player)
  local dat = player:GetEffects():GetCollectibleEffectNum(itemRegistry.Exodus)
  if dat >= 5 then return end

  local enemies = Isaac.FindInRadius(player.Position, 1000, EntityPartition.ENEMY) -- find all enemies in the room
  for _, enemy in pairs(enemies) do -- for each enemy
    enemy:Kill() -- kill them!
  end
end

local function Post_Player_Update(_, player)
  if (player == nil or not player:HasCollectible(itemRegistry.Exodus)) then return end
  -- this update is ran even on the main menu ... so we have to check if player even exists.
  -- next we check if the player does not have our item
  -- in either case, we return b/c there isn't anything to check

    -- effect trigger
    if (Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex)) then -- if our player pushes the use active item button...
      TriggerEffect(player) -- then attempt to trigger the effect of our active item.
    end

    local dat = player:GetEffects():GetCollectibleEffectNum(itemRegistry.Exodus) -- get the number of times the item has already being used.
    -- sync
    if (dat and dat < 5 and player:GetActiveCharge() ~= (5 - dat)) then -- Just an update code to have the in-game charge bar be equal to the number of uses we have remaining...
      player:SetActiveCharge((5 - dat)) -- just setting the charge bar equal to w/e our charges is...
    end
end

callbacks.add(ModCallbacks.MC_POST_PLAYER_UPDATE, Post_Player_Update) -- this runs for every player update.
