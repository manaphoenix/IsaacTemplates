-- vars
local useCustomErrorChecker = true -- should the custom error checker be used?

-- file loc
local _, err = pcall(require, "")
local modName = err:match("/mods/(.*)/%.lua")
local path = "mods/" .. modName .. "/"

local function loadFile(loc, ...)
    return assert(loadfile(path .. loc .. ".lua"))(...)
end

local _, ogerr = pcall(function()
    local stats = loadFile("mod/stats")
    local imports = loadFile("mod/imports")
    loadFile("mod/MainMod", { modName, path, loadFile, stats, imports, useCustomErrorChecker })
end)

if (ogerr) then
    if (useCustomErrorChecker) then
        local errorChecker = loadFile("lib/cerror")
        errorChecker.registerError()

        errorChecker.mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,
            function(_, IsContin)
                local room = Game():GetRoom()

                for i = 0, 8 do room:RemoveDoor(i) end
            end)

        local str = errorChecker.formatError(ogerr)

        if (str) then
            local file = str:match("%w+%.lua")
            local line = str:match(":(%d+):")
            local err = str:match(":%d+: (.*)")
            errorChecker.setMod(modName)
            errorChecker.setFile(file)
            errorChecker.setLine(line)
            errorChecker.printError("Error:", err)
            errorChecker.printError("")
            errorChecker.printError("For full error report, open log.txt")
            errorChecker.printError("")
            errorChecker.printError("Log Root: C:\\Users\\<YOUR USER>\\Documents\\My Games\\Binding of Isaac Repentance\\log.txt")
            errorChecker.printError("")
            errorChecker.printError("Reload the mod, then start a new run, Holding R works")
        else
            errorChecker.printError("Unexpected error occured, please open log.txt!")
            errorChecker.printError("Log Root: C:\\Users\\<YOUR USER>\\Documents\\My Games\\Binding of Isaac Repentance\\log.txt")
            errorChecker.printError("")
            errorChecker.printError(ogerr)
        end
        Isaac.DebugString("-- START OF " .. modName:upper() .. " ERROR --")
        Isaac.DebugString(ogerr)
        Isaac.DebugString("-- END OF " .. modName:upper() .. " ERROR --")

        local room = Game():GetRoom()

        for i = 0, 8 do room:RemoveDoor(i) end

        error()
    else
        Isaac.ConsoleOutput(modName ..
            " has hit an error, see Log.txt for more info\n")
        Isaac.ConsoleOutput(
            "Log Root: C:\\Users\\<YOUR USER>\\Documents\\My Games\\Binding of Isaac Repentance\\log.txt")
        Isaac.DebugString("-- START OF " .. modName:upper() .. " ERROR --")
        Isaac.DebugString(ogerr)
        Isaac.DebugString("-- END OF " .. modName:upper() .. " ERROR --")
        error()
    end
end
