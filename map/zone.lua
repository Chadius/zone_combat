--[[ Entity holds Squaddies on a Map.
--]]

local TableUtility = require "tableUtility"
local ZoneNeighbor = require "map/zoneNeighbor"

local Zone={}
Zone.__index = Zone

function Zone:new(args)
  --[[ Create a new Zone.
  --]]
  local newZone = {}
  setmetatable(newZone,Zone)
  newZone.id = args.id

  if newZone.id == nil then
    error("Zone needs an id")
  end

  if args.neighbors then
    newZone.neighbors = TableUtility:clone(args.neighbors)
  else
    newZone.neighbors = {}
  end

  return newZone
end

function Zone:__tostring()
  return string.format("Zone ID: %s", self.id)
end

function Zone:clone()
  return Zone:new({
    id = self.id,
    neighbors = self.neighbors
  })
end

function Zone:addNeighbor(toZoneID, movementCost, travelMethods)
  local newNeighbor = ZoneNeighbor:new({
    from = self.id,
    to = toZoneID,
    cost = movementCost,
    travelMethods = travelMethods,
  })

  local newZone = self:clone()
  table.insert(newZone.neighbors, newNeighbor)
  return newZone
end

function Zone:filterInvalidZones()
  local newZone = self:clone()

  newZone.neighbors = TableUtility:filter(
      newZone.neighbors,
      function (_, neighbor, _)
        return neighbor:hasValidDestination()
      end
  )

  return newZone
end

function Zone:hasNeighborWithDestination(toZoneID)
  return TableUtility:any(
      self.neighbors,
      function (_, neighbor, _)
        return neighbor.toZoneID == toZoneID
      end
  )
end

return Zone
