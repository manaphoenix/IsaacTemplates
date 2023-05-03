---@class ItemObject
local ItemObject = {}
ItemObject.callbacks = {} -- to store all the callbacks each item needs to function
---@type ItemRegistry
ItemObject.registries = include("Registries.ItemRegistry")

---add a callback to added later
---@param callback ModCallbacks
---@param f function
---@param opt? any
function ItemObject:add(callback, f, opt)
    self.callbacks = self.callbacks or {} -- just make sure the callback table exists, and if it doesn't, create it.
    table.insert(self.callbacks, {callback = callback,func = f, opt = opt}) -- insert into that callback, a new callback function; and its optional parameter.
end

return ItemObject