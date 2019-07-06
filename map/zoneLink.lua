--[[ Value Object that marks the path between 2 Zones.
]]

local TableUtility = require ("utility/tableUtility")

local ZoneLink={}
ZoneLink.__index = ZoneLink

function ZoneLink:new(args)
  --[[ Create a new Zone link.
  --]]
  local newZN = {}
  setmetatable(newZN,ZoneLink)

  newZN.fromZoneID = args.fromZoneID or args.from
  newZN.toZoneID = args.toZoneID or args.to
  newZN.moveCost = args.moveCost or args.movementCost or 1
  newZN.travelMethods = args.travelMethods or {"foot"}

  return newZN
end

function ZoneLink:createBiDirectionalZoneLink()
   --[[ Returns a new zone link with flipped from/to directions.
   --]]
   local newZoneLink = ZoneLink:new({
     fromZoneID = self.toZoneID,
     toZoneID = self.fromZoneID,
     moveCost = self.moveCost,
     travelMethods = TableUtility.cloneTable(self.travelMethods)
   })

   return newZoneLink
end

function ZoneLink:hasValidDestination()
  if self.toZoneID == nil then
    return false
  end

  if self.toZoneID == self.fromZoneID then
    return false
  end

  return true
end

return ZoneLink
