local handler = {}
local callbacks = {}

handler.mod = false

function handler:AddCallback(Callback, Delegate, Filter)
  if (callbacks[Callback]) then
    table.insert(callbacks[Callback], {Delegate, Filter})
    return
  end
  callbacks[Callback] = {
    {Delegate, Filter}
  }
end

function handler:GetCallbacks()
  return callbacks
end

function handler:AddCallbacks(CallBacks)
  for i, v in pairs(CallBacks) do
    if (callbacks[i]) then
      table.insert(callbacks[Callback], v)
    else
      callbacks[i] = {v}
    end
  end
end

function handler:Init()
  for i,v in pairs(callbacks) do
    for _,c in ipairs(v) do
      handler.mod:AddCallback(i, c[1][1], c[1][2])
    end
  end
end

return handler
