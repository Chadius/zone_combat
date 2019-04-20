--[[ Maps hold multiple Zones.
--]]

local Zone = require "zone"

local Map={}
Map.__index = Map

function Map:new(args)
  --[[ Create a new Map.
  --]]
  local newMap = {}
  setmetatable(newMap,Map)
  newMap.id = args.id
  newMap.zones = {}
  newMap.zone_neighbors = {}

  if args.zones and args.zones ~= nil then
     for i, zone_info in ipairs(args.zones) do
	      newMap:addZone(zone_info)
     end
  end

  if args.zone_neighbors and args.zone_neighbors ~= nil then
     for i, neigh in ipairs(args.zone_neighbors) do
        table.insert(newMap.zone_neighbors, neigh)
     end
  end

  if newMap.id == nil then
     error("Map needs an id")
  end

  return newMap
end

function Map:addZone(zone_info)
   --[[ Add the new zone to the list.
   --]]
   table.insert(self.zones, zone_info)
end

function Map:__tostring()
   return string.format("Map ID: %s", self.id)
end

function Map:describeZones()
  --[[ Returns a list of strings to describe all of the zones.
  --]]
  for i, nei in self.zone_neighbors do
    print(nei)
  end
end

return Map
