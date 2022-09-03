local itemRegistry = require("Registries/ItemRegistry")

-- SEE Items.xml for the other half of what you need to do for this item!

local function TriggerEffect(player)
  if (not player:GetData()["ExodusCharge"] or player:GetData()["ExodusCharge"] < 1) then return end -- if we don't have any uses, or we have ran out of uses, return we can't use this anymore
  player:GetData()["ExodusCharge"] = player:GetData()["ExodusCharge"] - 1 -- remove 1 from our use charge, we used our items

  local enemies = Isaac.FindInRadius(player.Position, 1000, EntityPartition.ENEMY) -- find all enemies in the room
  for _, enemy in pairs(enemies) do -- for each enemy
    enemy:Kill() -- kill them!
  end
end

local function Post_Player_Update(_, player)
  if (player == nil or not player:HasCollectible(itemRegistry.Exodus)) then return end
  -- this update is ran even on the main menu ... so we have to check if player even exists.
  -- next we check if the player does not have our item
  -- in either case, we return b/c there isn't anything to check.

  -- first pickup
  if (not player:GetData()["ExodusCharge"]) then -- if this is our first time picking up this item...
    player:GetData()["ExodusCharge"] = 5 -- set our uses to 5
  end

  -- effect trigger
  if (Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex)) then -- if our player pushes the use active item button...
    TriggerEffect(player) -- then attempt to trigger the effect of our active item.
  end

  -- sync
  if (player:GetActiveCharge() ~= player:GetData()["ExodusCharge"]) then -- Just an update code to have the in-game charge bar be equal to the number of uses we have remaining...
    player:SetActiveCharge(player:GetData()["ExodusCharge"]) -- just setting the charge bar equal to w/e our charges is...
  end
end

callbacks.add(ModCallbacks.MC_POST_PLAYER_UPDATE, Post_Player_Update) -- this runs for every player update.
