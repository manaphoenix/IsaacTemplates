-- we pass in the itemRegistry in the main file, so we can use it here
local itemRegistry = ...
---@cast itemRegistry ItemRegistry


if EID then
  EID:addCollectible(itemRegistry.Elysium, "Multiplies your luck for the room, stacks with multiple uses")
  EID:addCollectible(itemRegistry.Hermes, "Doubles your speed")
  EID:addCollectible(itemRegistry.Exodus, "Clears 5 rooms, then disappears")
end
