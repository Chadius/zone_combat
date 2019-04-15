local Zone={}
Zone.__index = Zone

function Zone:new()
  --[[ Create a new Zone.
  --]]
  local newZone = {}
  setmetatable(newZone,Zone)

  return newZone
end

return Zone
