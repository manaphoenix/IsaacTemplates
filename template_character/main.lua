local status, ogerr = pcall(function()
  --  if (_G.include) then
  require("mod/MainMod")
  --else
  --  error("This template does not work with luadebug!")
  --end
end)

if (ogerr) then
  local f = Font()
  f:Load("font/terminus.fnt")
  local str = {}
  local x = 0
  local zero = Vector.Zero

  local sp = Sprite()
  sp:Load("gfx/ui/main menu/bestiarymenu.anm2")
  sp:Play("Idle")
  local function GetScreenSize() -- By Kilburn himself.
    local room = Game():GetRoom()
    local pos = Isaac.WorldToScreen(zero) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset

    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)

    return rx * 2 + 13 * 26, ry * 2 + 7 * 26
  end

  posx, posy = GetScreenSize()

  local pos = Vector(posx / 4, - 20)

  local function out(...)
    local s, args = "", table.pack(...)
    for i = 1, args.n do
      s = s .. tostring(args[i] or nil) .. " "
    end
    table.insert(str, s)
  end

  local function render()
    x = 45
    sp:RenderLayer(1, pos)
    for i = 1, #str do
      f:DrawStringScaled(str[i], posx / 3, x, 0.5, 0.5, KColor(1.0, 0.58039215686275, 0.58039215686275, 1), 0, true)
      x = x + 8
    end
  end

  local mod = RegisterMod("TemplateCharacterError", 1)
  mod:AddCallback(ModCallbacks.MC_POST_RENDER, render)

  mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, IsContin)
    local room = Game():GetRoom()

    for i = 0, 8 do
      room:RemoveDoor(i)
    end

    Game():GetHUD():SetVisible(false)
  end)

  local str = ogerr:match(".-(%w+%.lua:%d+:.%w+.*)")

  if (str) then
    local file = str:match("%w+%.lua")
    local line = str:match(":(%d+):")
    local err = str:match(":%d+: (.*)")
    out("Character Template has hit an error:")
    out("File:", file)
    out("Line:", line)
    out("Error:", err)
    out("For full error report, open log.txt")
    out("")
    out("Reload the mod, then start a new run")
    out("Holding R works")
    out("")
    local stat = require("mod/stats")
    if (stat) then
      out("Mod Name: " .. stat.ModName)
    end
  else
    out("Unexpected error occured, please open log.txt!")
    out("")
    out(ogerr)
  end
  Isaac.DebugString("-- START OF CHARACTER TEMPLATE ERROR --")
  Isaac.DebugString(ogerr)
  Isaac.DebugString("-- END OF CHARACTER TEMPLATE ERROR --")

  local room = Game():GetRoom()

  for i = 0, 8 do
    room:RemoveDoor(i)
  end

  Game():GetHUD():SetVisible(false)

  error()
end
