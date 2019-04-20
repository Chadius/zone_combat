--[[Zone neighbors link two zones together.
--]]

local TableUtility = require "table_utility"

local ZoneNeighbor={}
ZoneNeighbor.__index = ZoneNeighbor

function ZoneNeighbor:new(args)
  --[[ Create a new Zone Neighbor.
  --]]
  local newZN = {}
  setmetatable(newZoneNeighbor,ZoneNeighbor)

  newZN.fromZoneID = args.fromZoneID
  newZN.toZoneID = args.toZoneID
  newZN.moveCost = args.moveCost or 1
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
   return string.format("%s to %s. Cost %d, Methods %s", self.fromZoneID, self.toZoneID, self.moveCost)
end

return ZoneNeighbor