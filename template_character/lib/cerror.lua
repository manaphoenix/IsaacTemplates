-- This file control the custom error checker.
local module = {}
local f = Font()
f:Load("font/terminus.fnt")
local str = {}
local x = 0
local zero = Vector.Zero
local col = KColor(1.0, 0.58039215686275, 0.58039215686275, 1)

local sp = Sprite()
sp:Load("gfx/ui/main menu/bestiarymenu.anm2")
sp:Play("Idle")

local function GetScreenSize() -- By Kilburn himself.
    local room = Game():GetRoom()
    local pos = Isaac.WorldToScreen(zero) - room:GetRenderScrollOffset() -
                    Game().ScreenShakeOffset

    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)

    return rx * 2 + 13 * 26, ry * 2 + 7 * 26
end

Posx, Posy = GetScreenSize()

local pos = Vector(Posx / 4, -20)

function module.out(...)
    local s, args = "", table.pack(...)
    for i = 1, args.n do s = s .. tostring(args[i] or nil) .. " " end
    table.insert(str, s)
end

function module.formatError(err) return err:match(".-(%w+%.lua:%d+:.%w+.*)") end

function module.getErrors() return #str end

function module.clearErrors() str = {} end

function module.addTitle(inp)
    local s = {}
    for i = 1, #str do table.insert(s, str[i]) end
    str = {}
    str[1] = inp
    for i = 1, #s do str[i + 1] = s[i] end
end

local function render()
    x = 45
    sp:RenderLayer(1, pos)
    for i = 1, #str do
        f:DrawStringScaled(str[i], Posx / 3, x, 0.5, 0.5, col, 0, true)
        x = x + 8
    end
end

function module.registerError()
    local mod = RegisterMod("TemplateCharacterError", 1)
    module.mod = mod
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, render)
end

return module
