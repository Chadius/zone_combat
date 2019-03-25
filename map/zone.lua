--[[All units in the same Zone occupy the same general area. There is no concept of cover or facing in a given zone.
--]]

local Zone={}
Zone.__index = Zone

function Zone:new()
  --[[ Create a new Zone to contain Units.
  --]]
  local newZone = {}
  setmetatable(newZone,Zone)

  return newZone
end

return Zone
