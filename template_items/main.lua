local mod = RegisterMod("TemplateItems", 1)

local itemRegistry = include("registry.ItemRegistry")
local eidRegistry = include("registry.EIDRegistry")
eidRegistry.register(itemRegistry) -- actually register the items

local items = {                    -- list of file names in the items folder, so it can go through each one and run their callbacks
    "Elysium",
    "Exodus",
    "HermesBoots"
}

local function registerCallback(callback, f, opt) -- register a callback function
    if opt then
        mod:AddCallback(callback, f, opt)         -- add the callback + optional filter
    else
        mod:AddCallback(callback, f)              -- add the callback
    end
end

-- go through each item and run its callbacks
for i = 1, #items do
    ---@type ItemObject
    local item = include("items." .. items[i])                     -- get the item file
    for c = 1, #item.callbacks do                      -- for each one of the callbacks
        local cb = item.callbacks[c]                   -- get the callback
        registerCallback(cb.callback, cb.func, cb.opt) -- register the callback
    end
end
