-- vars
local useCustomErrorChecker = true -- should the custom error checker be used?

-- file loc
local _, _err = pcall(require, "")
---@type string
local modName = _err:match("/mods/(.*)/%.lua")
---@type string
local path = "mods/" .. modName .. "/"

---loads a file, with no cache
---@param loc string
---@param ... any
---@return any
local function loadFile(loc, ...)
    return assert(loadfile(path .. loc .. ".lua", "bt", _ENV), "File not found at: " .. path .. loc .. ".lua")(...)
end

local _, ogerr = pcall(function()
    ---@type AllCharacters
    local stats = loadFile("mod/stats", loadFile)
    loadFile("mod/MainMod", { modName, path, loadFile, stats, useCustomErrorChecker })
end)

if (ogerr) then
    if (useCustomErrorChecker) then
        local errorChecker = require("lib.cerror")
        errorChecker.registerError()

        local str = errorChecker.formatError(ogerr)

        if (str) then
            local file = str:match("%w+%.lua")
            local line = str:match(":(%d+):")
            local err = str:match(":%d+: (.*)")
            errorChecker.SetData({
                Mod = modName,
                File = file,
                Line = line
            })
            errorChecker.add("Error:", err, true)
            errorChecker.add("For full error report, open log.txt", true)
            errorChecker.add("Log Root: C:\\Users\\<YOUR USER>\\Documents\\My Games\\Binding of Isaac Repentance\\log.txt"
                , true)
            errorChecker.add("Restart your game after fixing the error!")
        else
            errorChecker.add("Unexpected error occured, please open log.txt!")
            errorChecker.add("Log Root: C:\\Users\\<YOUR USER>\\Documents\\My Games\\Binding of Isaac Repentance\\log.txt"
                , true)
            errorChecker.add(ogerr)
        end

        local room = Game():GetRoom()
        for i = 0, 7 do room:RemoveDoor(i) end

        errorChecker.dump(ogerr)
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
