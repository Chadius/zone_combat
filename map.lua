--[[ Maps hold multiple Zones.
--]]

local Zone = require "zone"
local ZoneNeighbor = require "zone_neighbor"
local TableUtility = require "table_utility"

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

  newMap.zone_by_id = {}

  if newMap.id == nil then
     error("Map needs an id")
  end

  if args.zones and args.zones ~= nil then
     for _, zone_info in ipairs(args.zones) do
	      newMap:addZone(zone_info)
     end
  end

  -- Delete any non existant zones and invalid neighbors.
  newMap:VerifyZone()
  newMap:VerifyZoneNeighbor()

  -- Set an id to track MapUnits.
  newMap.nextMapUnitID = 1

  self.mapUnitsByID = {}

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

  if self.zone_by_id[newZone.id]["zone"] == nil then
    self.zone_by_id[newZone.id]["zone"] = newZone
  end

  -- If there are zone neighbors
  for _, neighbor_info in ipairs(zone_info.neighbors or {}) do
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

    -- If the neighbor is bidirectional, add a neighbor with reversed direction.
    if neighbor_info.bidirectional then
      AddZoneNeighbor(
        self,
        neighbor_info.to,
        newZone.id,
        neighbor_info.cost,
        neighbor_info.travelMethods
      )
    end
  end
end

function Map:VerifyZone()
  --[[ Deletes all invalid Zones
  ]]

  -- Delete any zones without a zone object
  for zone_id, zone_info in pairs(self.zone_by_id) do
    if zone_info.zone == nil then
      self.zone_by_id[zone_id] = nil
    end
  end
end

function Map:VerifyZoneNeighbor()
  --[[ Deletes all invalid Zone Neighbors
  ]]
  for _, zone_info in pairs(self.zone_by_id) do
    for to, neighbor_info in pairs(zone_info.neighbors) do
      local delete_neighbor = false
      -- If the to points to nowhere, mark to delete
      if self.zone_by_id[neighbor_info.toZoneID] == nil then
        delete_neighbor = true
      end

      -- If the from and to to the same ID, mark to delete
      if neighbor_info.toZoneID == neighbor_info.fromZoneID then
        delete_neighbor = true
      end

      -- If marked to delete, remove this neighbor
      if delete_neighbor then
        zone_info.neighbors[to] = nil
      end
    end
  end
end

function Map:__tostring()
   return string.format("Map ID: %s", self.id)
end

function Map:describeZones()
  --[[ Returns a list of strings to describe all of the zones.
  --]]
  for _, zone_info in pairs(self.zone_by_id) do
    print(tostring(zone_info.zone))
    for _, neighbor in pairs(zone_info["neighbors"]) do
      print(tostring(neighbor))
    end
    print("")
  end
end

-- should be zone id, not zone name
function Map:addMapUnit(mapUnit, zoneName)
  --[[ Adds a MapUnit to a given zone.
  ]]

  -- Make sure the zone exists
  if not self.zone_by_id[zoneName] then
    error("MapUnit " .. mapUnit.name .. " cannot be added because zone " .. zoneName .. " does not exist.")
  end

  -- If the map unit was already added, raise an error
  if self.mapUnitsByID[mapUnit.id] then
    error("MapUnit " .. mapUnit.name .. " already exists.")
  end

  -- Give the mapUnit an id if it needs it.
  if mapUnit.id == nil then
    mapUnit.id = self.nextMapUnitID
    self.nextMapUnitID = self.nextMapUnitID + 1
  end

  -- Store in a zone.
  self.mapUnitsByID[mapUnit.id] = {
    mapUnit = mapUnit,
    zone = zoneName
  }
end

function Map:getMapUnitsAtLocation(zoneName)
  --[[ Return a table of active MapUnits in a given zone.
  ]]

  local mapUnitsByZone = {}
  TableUtility:each(
      self.mapUnitsByID,
      function(_, info)
        local zoneID = info.zone
        if mapUnitsByZone[zoneID] == nil then mapUnitsByZone[zoneID] = {} end
        table.insert(mapUnitsByZone[zoneID], info.mapUnit)
      end
  )
  return mapUnitsByZone[zoneName] or {}
end

function Map:removeMapUnit(mapUnitID)
  --[[ Removes the map unit with the given ID.
  ]]
  if self.mapUnitsByID[mapUnitID]~= nil then
    table.remove(self.mapUnitsByID, mapUnitID)
  end
end

function Map:canMapUnitMoveToAdjacentZone(mapUnitID, nextZoneName)
  --[[ Indicate if the map unit can move to the nearby zone from its current location.
  ]]
  return true
end

function Map:mapUnitMoves(mapUnitID, nextZoneName)
  --[[ Change the map unit's location to the next zone.
  ]]

  -- Make sure the map unit actually exists
  if not self.mapUnitsByID[mapUnitID] then
    error("Map:mapUnitMoves no MapUnit named " .. mapUnitID .. " found.")
  end

  -- Change the zone the unit is in.
  self.mapUnitsByID[mapUnitID]["zone"] = nextZoneName
end

return Map
