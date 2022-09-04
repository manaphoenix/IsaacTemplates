local CharacterBuilder = {}

-- internal map used to speed up indexing
-- in form:
--[[
    [PlayerTypeID] = {
        pointer : CharacterDescription,
        tainted : boolean,
        set : CharacterSet
    }

    pointer points to the CharacterDescription that the player type is
    and tainted is a boolean that is true if that CharacterDescription is for a tainted variant.
    set is the CharacterSet the CharacterDescription belongs to.
]]
local _CharacterDescriptionMap = {}

---@class AllCharacters
local _characterSets = {}

---returns the CharacterSet that the player is playing
---@param player EntityPlayer the player
---@return CharacterSet | nil
function _characterSets:getCharacterSet(player)
    local ptype = player:GetPlayerType()
    if (not _CharacterDescriptionMap[ptype]) then return nil end

    return _CharacterDescriptionMap[ptype].set
end

---Returns the CharacterDescription of the player (if there is one)
---@param player EntityPlayer the player
---@return CharacterDescription | nil
function _characterSets:getCharacterDescription(player)
    local ptype = player:GetPlayerType()
    if (not _CharacterDescriptionMap[ptype]) then return nil end

    return _CharacterDescriptionMap[ptype].pointer
end

---returns two values, first is if the character is one of these characters, the second is if its the tainted variant
---@param player EntityPlayer the player
---@return boolean, boolean|nil
function _characterSets:isACharacterDescription(player)
    local ptype = player:GetPlayerType()
    if (not _CharacterDescriptionMap[ptype]) then return false, nil end

    return true, _CharacterDescriptionMap[ptype].tainted
end

---@enum HeartEnum
local HeartEnum = {
    SOUL_HEART = 1,
    BLACK_HEART = 2
}

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
---@field criticalMultiplier number how much your damage is multiplied by on a crit (REQUIRES Critical Hit Lib)
---@field criticalChance number how often you get a critical hit (REQUIRES Critical Hit Lib)

---@class CharacterDescription
---@field name string The name of the character
---@field stats Stats The stats of the character
---@field costume table|nil The costume the character should wear
---@field items table The items the character should start with
---@field PocketItem PillEffect|Card the PocketItem the character starts with (Pill or Card)
---@field isPill boolean is the PocketItem a pill?
---@field charge number|boolean the charge level the active item should start at (if the character starts with one)
---@field trinket TrinketType the trinket type the player starts with
---@field soulHeartOnly boolean whether the player is a Soul Heart only character like Bluebaby
---@field blackHeartOnly boolean whether the player is a Black heart only character like Dark Judas
local character = {}

---@class CharacterSet
---@field normal CharacterDescription the normal variant of the character
---@field tainted CharacterDescription the tainted variant of the character
---@field hasTainted boolean whether this set has a tainted variant
local CharacterSet = {}

---@param id string The string id of the costume
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:addCostume(id, tainted)
    if tainted then
        table.insert(self.tainted.costume, id)
    else
        table.insert(self.normal.costume, id)
    end
end

---@param charge number The charge value
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:setCharge(charge, tainted)
    if tainted then
        self.tainted.charge = charge
    else
        self.normal.charge = charge
    end
end

---@param trinket TrinketType The id of the trinket
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:setTrinket(trinket, tainted)
    if tainted then
        self.tainted.trinket = trinket
    else
        self.normal.trinket = trinket
    end
end

---@param id CollectibleType the Id of the collectible
---@param costume? boolean whether to show that collectibles costume (if it has one), defaults to false
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:addItem(id, costume, tainted)
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
function CharacterSet:setPocketItem(id, isPill, tainted)
    if tainted then
        self.tainted.isPill = isPill or false
        self.tainted.PocketItem = id
    else
        self.normal.isPill = isPill or false
        self.normal.PocketItem = id
    end
end

-- internal table of base stats to automatically offset
local _baseTable = {
    Damage = 3.50,
    Speed = 1.00,
    Firedelay = 2.73,
    Range = 6.50,
    Shotspeed = 1.00,
    Luck = 0.00
}

---@param statTable Stats
---@param tainted? boolean whether you are setting the tainted variant, default is false
function CharacterSet:setStats(statTable, tainted)
    -- offset stats by base
    local t = {}
    for i, v in pairs(statTable) do
        if _baseTable[i] then
            local stat = _baseTable[i]
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

---set whether the character is a SoulHeart or BlackHeart only character
---@param Heart HeartEnum
---@param tainted? boolean
function CharacterSet:setHeartType(Heart, tainted)
    if not tainted then
        if Heart == HeartEnum.SOUL_HEART then
            self.normal.soulHeartOnly = true
        elseif Heart == HeartEnum.BLACK_HEART then
            self.normal.blackHeartOnly = true
        end
    else
        if Heart == HeartEnum.SOUL_HEART then
            self.tainted.soulHeartOnly = true
        elseif Heart == HeartEnum.BLACK_HEART then
            self.tainted.blackHeartOnly = true
        end
    end
end

---internal function to create a new Character table
---@return CharacterDescription
local function _newCharacterDescription()
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
function CharacterBuilder.newCharacterSet(Name, isTainted)
    local t = {}
    t.normal = _newCharacterDescription()
    t.tainted = _newCharacterDescription()
    t.hasTainted = isTainted or true
    if Name then
        t.normal.name = Name
        t.tainted.name = Name
    end
    setmetatable(t, { __index = CharacterSet })
    table.insert(_characterSets, t)
    return t
end

---@return Stats
function CharacterBuilder.newStatTable()
    return {}
end

---@return AllCharacters
function CharacterBuilder.build()
    for _, v in ipairs(_characterSets) do
        if type(v) == "table" then
            ---@cast v CharacterSet
            local normalPType = Isaac.GetPlayerTypeByName(v.normal.name)
            _CharacterDescriptionMap[normalPType] = { pointer = v.normal, tainted = false, set = v }
            if v.hasTainted then
                local taintedPType = Isaac.GetPlayerTypeByName(v.tainted.name, true)
                _CharacterDescriptionMap[taintedPType] = { pointer = v.tainted, tainted = true, set = v }
            end
        end
    end

    return _characterSets
end

return CharacterBuilder
