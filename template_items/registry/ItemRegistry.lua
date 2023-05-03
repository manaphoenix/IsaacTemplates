---@class ItemRegistry
local registry = {}

--- the purpose of this module to is contain all of our items registries to make it easier to reference elsewhere.
registry.Elysium = Isaac.GetItemIdByName("Elysium")
registry.Hermes = Isaac.GetItemIdByName("Hermes Boots")
registry.Exodus = Isaac.GetItemIdByName("Exodus")

return registry
