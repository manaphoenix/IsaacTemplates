local RNG = RNG()

-- Luck is the Players Current Luck
-- MinRoll is the Minium percentage needed to hit the chance you want. (aka, if you want it happen 30% of the time, put 30)
-- LuckPerc is how much each 1 Luck is worth in terms of percentage. (aka, if you want 1 luck = +5% chance on top whatever it rolled, put 5)
-- returns true if you *Should* consider the roll successful, and false if not.
local function Roll(Luck, MinRoll, LuckPerc)
  local roll = RNG:RandomInt(100)
  local offset = 100 - (roll + Luck * LuckPerc)
  if offset <= MinRoll then
    return true
  end

  return false
end

local function fact(log, num, max) -- used for the log func, don't use!
  local n = 0
  for i = num, 2, - 1 do
    local form = (log * ((max - i) / max))
    form = form % 1 > 0 and (math.floor(form) + 1) or form
    n = n + form
  end
  return n
end

-- Luck is the Players Current Luck
-- MinRoll is the Minium percentage needed to hit the chance you want. (aka, if you want it happen 30% of the time, put 30)
-- LuckPerc is how much each 1 Luck is worth in terms of percentage. (aka, if you want 1 luck = +5% chance on top whatever it rolled, put 5)
-- Max is the the Max number you want your chance to scale with luck. (aka, if you want your chance to stop scaling after the players get above 20 luck, put 20)
-- returns true if you *Should* consider the roll successful, and false if not.
local function LogRoll(Luck, MinRoll, LuckPerc, Max)
  local roll = RNG:RandomInt(100)
  local offset = 100 - roll
  if (Luck == 1) then
    offset = 100 - (roll + LuckPerc)
  else
    offset = 100 - (roll + fact(LuckPerc, Luck, Max))
  end
  if offset <= MinRoll then
    return true
  end

  return false
end