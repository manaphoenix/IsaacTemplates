local registry = include("ItemRegistry")

if EID then
  EID:addCollectible(registry.Elysium, "Multiplies your luck for the room, stacks with multiple uses")
  EID:addCollectible(registry.Hermes, "Doubles your speed")
  EID:addCollectible(registry.Exodus, "Clears 5 rooms, then disappears")
end
