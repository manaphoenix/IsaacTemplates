local module = {}

---@class AllCharacters
local _characters = {}

---returns the CharacterSet that the player is playing
---@param player EntityPlayer the player
---@return CharacterSet | nil
function _characters:getCharacterSet(player)
    local ptype = player:GetPlayerType()

    for _, v in ipairs(self) do
        if type(v) == "table" then
            ---@cast v CharacterSet
            local normalVar = Isaac.GetPlayerTypeByName(v.normal.name)
            if ptype == normalVar then return v end
            if v.hasTainted then
                local taintedVar = Isaac.GetPlayerTypeByName(v.tainted.name, true)
                if ptype == taintedVar then return v end
            end
        end
    end
end

---Returns the Character based on variant
---@param player EntityPlayer the player
---@return Character | nil
function _characters:getCharacterByVariant(player)
    local ptype = player:GetPlayerType()

    for _, v in ipairs(self) do
        if type(v) == "table" then
            ---@cast v CharacterSet
            local normalVar = Isaac.GetPlayerTypeByName(v.normal.name)
            if ptype == normalVar then return v.normal end
            if v.hasTainted then
                local taintedVar = Isaac.GetPlayerTypeByName(v.tainted.name, true)
                if ptype == taintedVar then return v.tainted end
            end
        end
    end
end

---returns if given player is one of your characters
---@param player EntityPlayer the player
---@return boolean
function _characters:isChar(player)
    local ptype = player:GetPlayerType()

    for _, v in ipairs(self) do
        if type(v) == "table" then
            ---@cast v CharacterSet
            local normalVar = Isaac.GetPlayerTypeByName(v.normal.name)
            if ptype == normalVar then return true end
            if v.hasTainted then
                local taintedVar = Isaac.GetPlayerTypeByName(v.tainted.name, true)
                if ptype == taintedVar then return true end
            end
        end
    end
    return false
end

---@class Stats
---@field Damage number how much damage the character should have (Base: 3.50)
---@field Speed number how fast the character should move (Base: 1.00)
---@field Firedelay number how often the character can shoot (Base: 2.73)
---@field Range number how far the characters tears travel (Base: 6.50)
---@field Shotspeed number how fast the characters tears travel (Base: 1.00)
---@field Luck number how lucky is the character (Base: 0)
---@field Tearflags BitSet128 | TearFlags used to give the character innate special tears
---@field Tearcolor Color used to give the character a special tear color
---@field Flying boolean is the character able to innately fly? (Base: False)

---@class Character
---@field name string The name of the character
---@field stats Stats The stats of the character
---@field costume table|nil The costume the character should wear
---@field items table The items the character should start with
---@field PocketItem PillEffect|Card the PocketItem the character starts with (Pill or Card)
---@field isPill boolean is the PocketItem a pill?
---@field charge number|boolean the charge level the active item should start at (if the character starts with one)
---@field trinket TrinketType
local character = {}

---@class CharacterSet
---@field normal Character the normal variant of the character
---@field tainted Character the tainted variant of the character
---@field hasTainted boolean whether this set has a tainted variant
local CharacterSet = {}

---@param id string The string id of the costume
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:AddCostume(id, tainted)
    if tainted then
        table.insert(self.tainted.costume, id)
    else
        table.insert(self.normal.costume, id)
    end
end

---@param charge number The string id of the costume
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:SetCharge(charge, tainted)
    if tainted then
        self.tainted.charge = charge
    else
        self.normal.charge = charge
    end
end

---@param trinket TrinketType The string id of the costume
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:SetTrinket(trinket, tainted)
    if tainted then
        self.tainted.trinket = trinket
    else
        self.normal.trinket = trinket
    end
end

---@param id CollectibleType the Id of the collectible
---@param costume? boolean whether to show that collectibles costume (if it has one), defaults to false
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:AddItem(id, costume, tainted)
    costume = costume or false
    if tainted then
        table.insert(self.tainted.items, { id, costume })
    else
        table.insert(self.normal.items, { id, costume })
    end
end

---@param id PillEffect|Card the Id of the pocket item
---@param isPill? boolean whether pocket item is a pill, defaults to false
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:SetPocketItem(id, isPill, tainted)
    if tainted then
        self.tainted.isPill = isPill or false
        self.tainted.PocketItem = id
    else
        self.normal.isPill = isPill or false
        self.normal.PocketItem = id
    end
end

local baseTable = {
    Damage = 3.50,
    Speed = 1.00,
    Firedelay = 2.73,
    Range = 6.50,
    Shotspeed = 1.00,
    Luck = 0.00
}

---@param statTable Stats
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:SetStats(statTable, tainted)
    -- offset stats by base
    local t = {}
    for i, v in pairs(statTable) do
        if baseTable[i] then
            local stat = baseTable[i]
            if stat > v then
                t[i] = -(stat - v) -- subtract the difference
            elseif stat < v then
                t[i] = v - stat -- add the difference
            else
                t[i] = 0 -- their equal, don't change the value
            end
        else
            t[i] = v -- unknown stat, assuming custom stat
        end
    end

    -- set stats table
    if tainted then
        self.tainted.stats = t
    else
        self.normal.stats = t
    end
end

---internal function to create a new Character table
---@return Character
local function _newCharacter()
    local t = {
        costume = {},
        items = {}
    }
    setmetatable(t, { __index = character })
    return t
end

---@return CharacterSet
---@param Name? string the name of the character
---@param isTainted? boolean is there a tainted variant of this character? (Default is true)
function module.newCharacter(Name, isTainted)
    local t = {}
    t.normal = _newCharacter()
    t.tainted = _newCharacter()
    t.hasTainted = isTainted or true
    if Name then
        t.normal.name = Name
        t.tainted.name = Name
    end
    setmetatable(t, { __index = CharacterSet })
    table.insert(_characters, t)
    return t
end

---@return Stats
function module.newStatTable()
    return {}
end

---@return AllCharacters
function module.build()
    return _characters
end

return module
