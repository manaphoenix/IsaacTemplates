-- vars
local useCustomErrorChecker = true -- should the custom error checker be used?
local mainFileName = "MainMod"

-- file loc
local _, _err = pcall(require, "")
---@type string
local modName = _err:match("/mods/(.*)/%.lua")
---@type string
local dir = "mods/" .. modName .. "/"

local preload = {}
local loaded = {
    _G = _G,
    coroutine = coroutine,
    math = math,
    string = string,
    table = table,
    utf8 = utf8
}
local sentinel = {}

local package = {
    path = "/?;/?.lua;/?/init.lua;/lib/?.lua;/mod/?.lua",
    config = "/\n;\n?\n!\n-",
    loaded = loaded,
    preload = preload
}

---searches along a series of paths, seperated by ;
---@param name string
---@param path string
---@param sep? string
---@param rep? string
function package.searchpath(name, path, sep, rep)
    sep = sep or "."
    rep = rep or "/"
    --local pathSep, pathRep = ";", "?"

    local fname = string.gsub(name, sep:gsub("%.", "%%."), rep)
    local sError = ""
    for pattern in string.gmatch(path, "[^;]+") do
        local sPath = string.gsub(pattern, "%?", fname)
        local fn, err = loadfile(dir .. sPath)
        if fn then
            return dir .. sPath
        else
            if #sError > 0 then
                sError = sError .. "\n  "
            end
            sError = sError .. "no file '" .. sPath .. "'"
        end
    end
    return nil, sError
end

local function preloader(pckg)
    return function(name)
        if pckg.preload[name] then
            return pckg.preload[name]
        else
            return nil, "package.preload[" .. name .. "]: no such field"
        end
    end
end

local function from_file(pckg, _env)
    return function(name)
        local sPath, sError = pckg.searchpath(name, package.path)
        if not sPath then
            return nil, sError
        end
        local fnFile, lError = loadfile(sPath, nil, _env)
        if fnFile then
            return fnFile, lError
        else
            return nil, lError
        end
    end
end

local env = {
    package = package,
    modName = modName,
    _HOST = [[_ENV Loader 1.0.5 (by manaphoenix)]],
    _TEMPLATEITEMS = [[Item Template V2.0.1]]
}

package.loaders = { preloader(package), from_file(package, env) }

---requires a module
---@param modname string
function env.require(modname)
    if package.loaded[modname] == sentinel then
        error("loop or previous error loading module '" .. modname .. "'", 0)
    end

    if package.loaded[modname] then
        return package.loaded[modname]
    end

    local sError = "module '" .. modname .. "' not found:"
    for _, searcher in ipairs(package.loaders) do
        local loader = table.pack(searcher(modname))
        if loader[1] then
            package.loaded[modname] = sentinel
            local result = loader[1](modname, table.unpack(loader, 2, loader.n))
            if result == nil then result = true end

            package.loaded[modname] = result
            return result
        else
            sError = sError .. "\n  " .. loader[2]
        end
    end
    error(sError, 2)
end

env.include = env.require
setmetatable(env, {
    __newindex = function(self, key, value)
        rawset(self, key, value)
    end,
    __index = _G
})

local function errHandler(err)
    if (useCustomErrorChecker) then
        local errorChecker = env.require("lib.cerror")
        errorChecker.registerError()

        local str = errorChecker.formatError(err)

        if (str) then
            local file = str:match("%w+%.lua")
            local line = str:match(":(%d+):")
            local merr = str:match(":%d+: (.*)")
            errorChecker.SetData({
                Mod = modName,
                File = file,
                Line = line
            })
            errorChecker.add("Error:", merr, true)
            errorChecker.add("For full error report, open log.txt", true)
            errorChecker.add("Log Root: C:\\Users\\<YOUR USER>\\Documents\\My Games\\Binding of Isaac Repentance\\log.txt"
                , true)
            errorChecker.add("Restart your game after fixing the error!")
        else
            errorChecker.add("Unexpected error occured, please open log.txt!")
            errorChecker.add("Log Root: C:\\Users\\<YOUR USER>\\Documents\\My Games\\Binding of Isaac Repentance\\log.txt"
                , true)
            errorChecker.add(err)
        end

        local room = Game():GetRoom()
        for i = 0, 7 do room:RemoveDoor(i) end

        errorChecker.dump(err)
        error()
    else
        Isaac.ConsoleOutput(modName .. " has hit an error, see Log.txt for more info\n")
        Isaac.ConsoleOutput("Log Root: C:\\Users\\<YOUR USER>\\Documents\\My Games\\Binding of Isaac Repentance\\log.txt")
        Isaac.DebugString("-- START OF " .. modName:upper() .. " ERROR --")
        Isaac.DebugString(err)
        Isaac.DebugString("-- END OF " .. modName:upper() .. " ERROR --")
        error()
    end
end

xpcall(function()
    local fn, err = loadfile(dir .. "mod/" .. mainFileName .. ".lua", "bt", env)
    if fn then
        fn()
    else
        errHandler(err)
    end
end, errHandler)
