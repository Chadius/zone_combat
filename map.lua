--[[ Maps hold multiple Zones.
--]]

local Zone = require "zone"
local ZoneNeighbor = require "zone_neighbor"

local Map={}
Map.__index = Map

local function AddZoneNeighbor(self, from, to, cost, travelMethods)
  --- Set the other info
  local newNeighbor = ZoneNeighbor:new({
    from = from,
    to = to,
    cost = cost,
    travelMethods = travelMethods,
  })

  -- Add to this zone
  if self.zone_by_id[from] == nil then
    self.zone_by_id[from] = {
      zone=nil,
      neighbors={},
    }
  end
  self.zone_by_id[from]["neighbors"][to] = newNeighbor
end

function Map:new(args)
  --[[ Create a new Map.
  --]]
  local newMap = {}
  setmetatable(newMap,Map)
  newMap.id = args.id
  newMap.zones = {}
  newMap.zone_neighbors = {}

  newMap.zone_by_id = {}

  if newMap.id == nil then
     error("Map needs an id")
  end

  if args.zones and args.zones ~= nil then
     for i, zone_info in ipairs(args.zones) do
	      newMap:addZone(zone_info)
     end
  end

  return newMap
end

function Map:addZone(zone_info)
   --[[ Add the new zone to the list.
   --]]

   -- Create a new zone from the info
   local zone_id = zone_info.id

   if not zone_info.id then
     error("Zone needs an id")
   end

   local newZone = Zone:new({
     id=zone_id
   })

   -- Add the zone to the info.
   if self.zone_by_id[newZone.id] == nil then
     self.zone_by_id[newZone.id] = {
       zone=newZone,
       neighbors={},
     }
   end

   -- If there are zone neighbors
   for index, neighbor_info in ipairs(zone_info.neighbors or {}) do

     -- Create a new neighbor.
     --- This zone is the from point
     --- Set the other info
     AddZoneNeighbor(
      self,
      newZone.id,
      neighbor_info.to,
      neighbor_info.cost,
      neighbor_info.travelMethods
    )
   end
end

function Map:__tostring()
   return string.format("Map ID: %s", self.id)
end

function Map:describeZones()
  --[[ Returns a list of strings to describe all of the zones.
  --]]
  for zone_id, zone_info in pairs(self.zone_by_id) do
    print(tostring(zone_info.zone))
    for to_zone_id, neighbor in pairs(zone_info["neighbors"]) do
      print(tostring(neighbor))
    end
    print("")
  end
end

return Map
