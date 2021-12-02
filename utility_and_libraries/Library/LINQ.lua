--[[
Linq + Lambda by manaphoenix

lambda("(params) => predicate")

table.where(table, delegate)
table.any(table, delegate)
table.first(table, delegate)
table.all(table, delegate)
table.count(table)
table.removeAll(table, delegate)
]] local table = _G.table
if (_G.lambda) then return end
local any = "() => true"

---@param delegate string @"(params) => predicate"
---@return function
function _G.lambda(delegate)
    local params, predicate = delegate:gmatch("%(?(.-)%)? => (.*)")()
    local func = "return function(" .. params .. ") " ..
                     (predicate:match("return") and predicate .. " end" or
                         "return " .. predicate .. " end")
    return assert(load(func))()
end

local ILambda = _G.lambda

local function buildDelegate(del)
    return type(del) == "function" and del or ILambda(del)
end

-- returns a table with only elements that match the filter.
---@param self table
---@param del string | function
---@return table
function table.where(self, del)
    local f = {}
    local t = buildDelegate(del)
    for _, v in pairs(self) do if (t(v)) then table.insert(f, v) end end
    return f
end

-- returns a boolean on if at least one element in the table matches the filter.
---@param self table
---@param del string | function
---@return boolean
function table.any(self, del)
    del = del or any
    local t = buildDelegate(del)
    for _, v in pairs(self) do if (t(v)) then return true end end
    return false
end

-- returns a table element of the first element to match the filter.
---@param self table
---@param del string | function
---@return unknown
function table.first(self, del)
    del = del or any
    local t = buildDelegate(del)
    for _, v in pairs(self) do if (t(v)) then return v end end
end

-- this is similar to any, except it only returns true if all elements in the table match the filter
---@param self table
---@param del string | function
---@return boolean
function table.all(self, del)
    local t = buildDelegate(del)
    for _, v in pairs(self) do if (not t(v)) then return false end end
    return true
end

-- this is pretty simple, returns the number of elements in the table as an int.
---@param self table
---@return number
function table.count(self)
    local t = 0
    for _, v in pairs(self) do t = t + 1 end
    return t
end

-- this removes all table elements that match the filter.
---@param self table
---@param del string | function
---@return nil
function table.removeAll(self, del)
    local t = buildDelegate(del)
    for i, v in pairs(self) do if (t(v)) then self[i] = nil end end
end