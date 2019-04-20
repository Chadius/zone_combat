--[[Zone neighbors link two zones together.
--]]

local TableUtility = require "table_utility"

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

function ZoneNeighbor:__tostring()
   local allTravelMethods = ""
   for i, method in ipairs(self.travelMethods) do
      allTravelMethods = allTravelMethods .. method .. ", "
   end
   return string.format("%s to %s. Cost %d, Methods %s", self.fromZoneID, self.toZoneID, self.moveCost, allTravelMethods)
end

return ZoneNeighbor
