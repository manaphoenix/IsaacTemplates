-- vars
local useCustomErrorChecker = true -- should the custom error checker be used?

-- file loc
local suc, err = pcall(require, "")
local modName = err:match("/mods/(.*)/%.lua")
local path = "mods/" .. modName .. "/"

local function loadFile(loc, ...)
  return assert(loadfile(path .. loc .. ".lua"))(...)
end

local status, ogerr = pcall(function()
  local stats = loadFile("mod/stats")
  local imports = loadFile("mod/imports")
  loadFile("mod/MainMod",{modName, path, loadFile, stats, imports, useCustomErrorChecker})
end)

if (ogerr) then
  if (useCustomErrorChecker) then
    local errorChecker = loadFile("lib/cerror")

    errorChecker.mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, IsContin)
      local room = Game():GetRoom()

      for i = 0, 8 do
        room:RemoveDoor(i)
      end

      Game():GetHUD():SetVisible(false)
    end)

    local str = errorChecker.formatError(ogerr)

    if (str) then
      local file = str:match("%w+%.lua")
      local line = str:match(":(%d+):")
      local err = str:match(":%d+: (.*)")
      errorChecker.out(modName .. " has hit an error:")
      errorChecker.out("File:", file)
      errorChecker.out("Line:", line)
      errorChecker.out("Error:", err)
      errorChecker.out("For full error report, open log.txt")
      errorChecker.out("Log Root: C:\\Users\\<YOUR USER>\\Documents\\")
      errorChecker.out("My Games\\Binding of Isaac Repentance\\log.txt")
      errorChecker.out("")
      errorChecker.out("Reload the mod, then start a new run")
      errorChecker.out("Holding R works")
    else
      errorChecker.out("Unexpected error occured, please open log.txt!")
      errorChecker.out("Log Root: C:\\Users\\<YOUR USER>\\Documents\\")
      errorChecker.out("My Games\\Binding of Isaac Repentance\\log.txt")
      errorChecker.out("")
      errorChecker.out(ogerr)
    end
    Isaac.DebugString("-- START OF " .. modName:upper() .. " ERROR --")
    Isaac.DebugString(ogerr)
    Isaac.DebugString("-- END OF " .. modName:upper() .. " ERROR --")

    local room = Game():GetRoom()

    for i = 0, 8 do
      room:RemoveDoor(i)
    end

    Game():GetHUD():SetVisible(false)

    error()
  else
    Isaac.ConsoleOutput(modName .. " has hit an error, see Log.txt for more info\n")
    Isaac.ConsoleOutput("Log Root: C:\\Users\\<YOUR USER>\\Documents\\My Games\\Binding of Isaac Repentance\\log.txt")
    Isaac.DebugString("-- START OF " .. modName:upper() .. " ERROR --")
    Isaac.DebugString(ogerr)
    Isaac.DebugString("-- END OF " .. modName:upper() .. " ERROR --")
    error()
  end
end
