--[[ Entity holds Squaddies on a Map.
--]]

local TableUtility = require ("utility/tableUtility")
local ZoneLink = require "map/zoneLink"

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

  if args.links then
    newZone.links = TableUtility:clone(args.links)
  else
    newZone.links = {}
  end

  return newZone
end

function Zone:isSameZone(otherZone)
  return self.id == otherZone.id
end

function Zone:__tostring()
  return string.format("Zone ID: %s", self.id)
end

function Zone:clone()
  return Zone:new({
    id = self.id,
    links = self.links
  })
end

function Zone:addLink(toZoneID, movementCost, travelMethods)
  local newLink = ZoneLink:new({
    from = self.id,
    to = toZoneID,
    cost = movementCost,
    travelMethods = travelMethods,
  })

  local newZone = self:clone()
  table.insert(newZone.links, newLink)
  return newZone
end

function Zone:filterInvalidZones()
  local newZone = self:clone()

  newZone.links = TableUtility:filter(
      newZone.links,
      function (_, link, _)
        return link:hasValidDestination()
      end
  )

  return newZone
end

function Zone:haslinkWithDestination(toZoneID)
  return TableUtility:any(
      self.links,
      function (_, link, _)
        return link.toZoneID == toZoneID
      end
  )
end

return Zone
