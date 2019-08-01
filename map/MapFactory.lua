local Map = require ("map/map")
local TableUtility = require ("utility/tableUtility")
local Zone = require ("map/zone")

local MapFactory = {}
MapFactory.__index = MapFactory

local function createNewZoneAndAddToTheMap(zone_info, map)
  if not zone_info.id then
    error("Zone needs an id")
  end

  local zone_id = zone_info.id

  local newZone = Zone:new({
    id=zone_id
  })

  map:addZone(newZone)
end

local function createZoneLinkAndAddToTheMap(fromZoneId, link_specifications, map)
  map:assertZoneExists(fromZoneId, "createZoneLinkAndAddToTheMap - from")
  map:assertZoneExists(link_specifications.to, "createZoneLinkAndAddToTheMap - from")

  local fromZone = map:getZoneByID(fromZoneId)
  local toZone = map:getZoneByID(link_specifications.to)

  local movementCost = link_specifications.cost
  local travelMethods = link_specifications.travelMethods

  map:connectTwoZonesWithLink(fromZone, toZone, movementCost, travelMethods)

  if link_specifications.bidirectional then
    map:connectTwoZonesWithLink(toZone, fromZone, movementCost, travelMethods)
  end
end

function MapFactory:buildNewMap(args)
  if not (args.mapId or args.id) then
    error("Map needs an id")
  end

  local newMapId = args.mapId or args.id
  local newMap = Map:new({id = newMapId})

  if args.zones and args.zones ~= nil then
    -- Add the zones
    TableUtility:each(
        args.zones,
        function(_, zone_specifications, _)
          createNewZoneAndAddToTheMap(zone_specifications, newMap)
        end
    )

    TableUtility:each(
        args.zones,
        function(_, zone_specifications, _)
          TableUtility:each(
              zone_specifications.links or {},
              function(_, link_specifications, _)
                createZoneLinkAndAddToTheMap(zone_specifications.id, link_specifications, newMap)
              end
          )
        end
    )
  end

  newMap:checkInvariants()
  return newMap
end

return MapFactory
