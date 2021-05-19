local mod = RegisterMod("TemplateItems", 1)
local handler = include("CallbackHandler.lua")
handler.mod = mod;
include("EIDRegistry")

-- Import Items
handler:AddCallbacks(include("Items/Elysium.lua"))

-- initialize all the callbacks
handler:Init()
