--[[ Value Object that marks the path between 2 Zones.
]]

local TableUtility = require "tableUtility"

local ZoneNeighbor={}
ZoneNeighbor.__index = ZoneNeighbor

function ZoneNeighbor:new(args)
  --[[ Create a new Zone Neighbor.
  --]]
  local newZN = {}
  setmetatable(newZN,ZoneNeighbor)

  newZN.fromZoneID = args.fromZoneID or args.from
  newZN.toZoneID = args.toZoneID or args.to
  newZN.moveCost = args.moveCost or args.movementCost or 1
  newZN.travelMethods = args.travelMethods or {"foot"}

  return newZN
end

function ZoneNeighbor:createBiDirectionalZoneNeighbor()
   --[[ Returns a new zone neighbor with flipped from/to directions.
   --]]
   local newZoneNeighbor = ZoneNeighbor:new({
     fromZoneID = self.toZoneID,
     toZoneID = self.fromZoneID,
     moveCost = self.moveCost,
     travelMethods = TableUtility.cloneTable(self.travelMethods)
   })

   return newZoneNeighbor
end

function ZoneNeighbor:hasValidDestination()
  if self.toZoneID == nil then
    return false
  end

  if self.toZoneID == self.fromZoneID then
    return false
  end

  return true
end

return ZoneNeighbor
