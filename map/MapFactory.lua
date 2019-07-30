local Map = require ("map/map")
local TableUtility = require ("utility/tableUtility")

local MapFactory = {}
MapFactory.__index = MapFactory

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
        function(_, zone, _)
          newMap:addZone(zone)
        end
    )

    TableUtility:each(
        args.zones,
        function(_, zone, _)
          newMap:addZoneLinks(zone)
        end
    )
  end

  newMap:checkInvariants()
  return newMap
end

return MapFactory
