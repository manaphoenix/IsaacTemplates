local includes = {}

function includes:Init(mod)
  -- do your inits here
  include("Items/Exodus"):Init(mod)
  include("Items/HermesBoots"):Init(mod)
end

return includes