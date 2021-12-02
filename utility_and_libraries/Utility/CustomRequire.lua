-- file loc
local _, err = pcall(require, "")
local modName = err:match("/mods/(.*)/%.lua")
local path = "mods/" .. modName .. "/"

local function loadFile(loc, ...)
    return assert(loadfile(path .. loc .. ".lua"))(...)
end