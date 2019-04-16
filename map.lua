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

  if args.zones and args.zones ~= nil then
     for i, zone_info in ipairs(args.zones) do
	newMap:addZone(zone_info)
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

return Map
