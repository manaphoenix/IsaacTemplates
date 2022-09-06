-- This file control the custom error checker.
---@class ErrorChecker
local module = {}
local errors = {}
local xOffset = 0
local zero = Vector.Zero
local errCol = KColor(0.847058824, 0.31372549, 0.31372549, 1)
local warnCol = KColor(0.584313725, 0.858823529, 0.490196078, 1)
local wrapLen = 33
local noteWrap = 18
local HUD = Game():GetHUD()
local notes = { Mod = "", File = "", Line = "" }

local text = Font()
text:Load("font/terminus.fnt")

local bg = Sprite()
bg:Load("gfx/ui/genericpopup.anm2", true)
bg:Play("Idle")

local mainPaper = Sprite()
mainPaper:Load("gfx/ui/main menu/bestiarymenu.anm2", true)
mainPaper:Play("Idle")
mainPaper.Offset = Vector(-23, -56)

local sidePaper = Sprite()
sidePaper:Load("gfx/ui/main menu/challengemenu.anm2", true)
sidePaper:Play("Idle")
sidePaper.Offset = Vector(-148 / 2, -841 / 2)
sidePaper.Scale = Vector(0.5, 0.5)

local function GetScreenSize() -- By Kilburn himself.
    local room = Game():GetRoom()
    local pos = Isaac.WorldToScreen(zero) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset

    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)

    return rx * 2 + 13 * 26, ry * 2 + 7 * 26
end

Posx, Posy = GetScreenSize()

local errorPos = Vector(Posx / 2, 40)
local notePos = Vector(Posx / 8, 40)
local errorOffset = errorPos.X
local noteOffset = Posx / 7.75
local scale = Vector(0.75, 0.75)

local function render()
    xOffset = 40
    bg:RenderLayer(0, zero)
    mainPaper:RenderLayer(1, errorPos)
    sidePaper:RenderLayer(29, notePos)
    for i = 1, #errors do
        text:DrawStringScaled(errors[i], errorOffset, xOffset, scale.X, scale.Y,
            errCol, 0, true)
        xOffset = xOffset + 10
    end
    xOffset = 45
    for i, v in pairs(notes) do
        if (v:len() > 0) then
            local str = i .. ": " .. v
            str = module.truncate(str, true)
            text:DrawStringScaled(str, noteOffset, xOffset, scale.X, scale.Y,
                warnCol, 0, true)
            xOffset = xOffset + 10
        end
    end
end

local function wordWrap(txt, useNote)
    local wrap = {}
    local cur = ""
    local tChars = 0
    local wrapper = useNote and noteWrap or wrapLen
    for match in txt:gmatch(".-%s") do
        tChars = tChars + match:len()
        if (cur:len() + match:len()) < wrapper then
            cur = cur .. match
        else
            table.insert(wrap, cur)
            cur = match
        end
    end
    local endStr = txt:sub(tChars + 1)
    if (cur:len() + endStr:len()) < wrapper then
        cur = cur .. endStr
    else
        table.insert(wrap, cur)
        cur = endStr
    end
    table.insert(wrap, cur)
    return wrap
end

function module.add(...)
    local s, args, newLine = "", table.pack(...), false
    for i = 1, args.n do
        if args[i] ~= true then
            s = s .. tostring(args[i] or nil) .. " "
        else
            newLine = true
        end
    end

    local wrap = wordWrap(s)
    for i = 1, #wrap do table.insert(errors, wrap[i]) end
    if newLine then
        table.insert(errors, "")
    end
end

function module.truncate(txt, useNote)
    local wrapper = useNote and noteWrap or wrapLen
    if (txt:len() > wrapper) then
        return txt:sub(1, wrapper - 3) .. "..."
    else
        return txt
    end
end

function module.formatError(err)
    if err then
        return err:match(".-(%w+%.lua:%d+:.%w+.*)") or err
    end
    return "UNKNOWN"
end

function module.SetData(data)
    notes.Mod = data.Mod or notes.Mod or "UNKNOWN"
    notes.File = data.File or notes.File or "UNKNOWN"
    notes.Line = data.Line or notes.Line or "UNKNOWN"
end

---dump to log
---@param err string
function module.dump(err)
    module.mod:AddCallback(ModCallbacks.MC_POST_RENDER, render)
    Isaac.DebugString("-- START OF " .. notes.Mod:upper() .. " ERROR --")
    Isaac.DebugString(err)
    Isaac.DebugString("-- END OF " .. notes.Mod:upper() .. " ERROR --")
end

function module.registerError()
    local mod = RegisterMod("CustomErrorChecker", 1)
    module.mod = mod
    
    HUD:SetVisible(false)
end

return module
