-- Register our mod
local mod = RegisterMod("TemplateItems", 1)
-- get the item registry
local itemRegistry = require("Registries/ItemRegistry")

-- register the EID entries, so our items have descriptions
require("Registries/EIDRegistry")

--- next we setup an easy to use table to automatically go through each item and register it.
--- We only need to put the file name, w/o the .Lua as our file loader will do the extension and folder for us
local items = {
    "Elysium",
    "Exodus",
    "HermesBoots"
}

--- callbacks
--- we use this table to store each and every callback so we can make one big callback, instead of a bunch of tiny ones.
--- all of our globals go to _ENV, so we can safely make this a global without messing anything up for anyone else.
---@class ItemCallbacks
callbacks = {}

---a custom add to our callback class, it will keeps all of our items sorted based on callbacks, so we can make one combined callback later.
---@param callback ModCallbacks
---@param f function
---@param opt any
function callbacks.add(callback, f, opt)
    --TODO: Add Callback Logic
    callbacks[callback] = callbacks[callback] or {} -- just make sure the callback table exists, and if it doesn't, create it.
    table.insert(callbacks[callback], {func = f, opt = opt}) -- insert into that callback, a new callback function; and its optional parameter.
end

--- now for each item:
for _, item in ipairs(items) do
    require("Items/" .. item) -- we load the file.
end

for callback, callbackInfo in pairs(callbacks) do -- for each callback in our callback class
    if type(callback) == "number" then -- if the callback is infact a callback (just to ensure we don't try to register something that isn't a callback)
        mod:AddCallback(callback, callbackInfo.func, callbackInfo.opt) -- register our callback
        -- TODO: Combine callbacks if possible (IF you are reading this, its not strictly necessary; but it could cause lag... if you have ALOT of items...)
    end
end