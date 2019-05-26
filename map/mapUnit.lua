--[[ Unit's presence on the map.
]]

local MapUnit={}
MapUnit.__index = MapUnit

function MapUnit:new(args)
  local newMapUnit = {}
  setmetatable(newMapUnit,MapUnit)

  newMapUnit.name = args.displayName or "No name"
  newMapUnit.id = nil
  return newMapUnit
end

return MapUnit
