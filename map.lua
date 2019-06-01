--[[ Maps hold multiple Zones.
--]]

local Zone = require "zone"
local ZoneNeighbor = require "zone_neighbor"
local TableUtility = require "table_utility"

local Map={}
Map.__index = Map

local function AddZoneNeighbor(self, from, to, cost, travelMethods)
  --[[ Create a new zone neighbor and add it to the map's zone information
  ]]
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

  self.mapUnitInfoByID = {}

  return newMap
end

function Map:addZone(zone_info)
  --[[ Add the new zone to the list.
  Args:
    zone_info(table)
      id(string)
      zone(nil or table): If nil, a default zone information table is created.
      neighbors(nil or array): Each array holds a table.
        to(string): Another zone id.
        travelMethods(array): A table of strings, each containing a travel method
  Returns:
    nil
  ]]

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
  Args:
    none
  Returns:
    nil
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
  Args:
    none
  Returns:
    nil
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
  Args:
    none
  Returns:
    nil
  --]]
  for _, zone_info in pairs(self.zone_by_id) do
    print(tostring(zone_info.zone))
    for _, neighbor in pairs(zone_info["neighbors"]) do
      print(tostring(neighbor))
    end
    print("")
  end
end

function Map:addMapUnit(mapUnit, zoneID)
  --[[ Adds a MapUnit to a given zone.
  Args:
    mapUnit.
    zoneID(string): Name of the zone
  Returns:
    nil
  ]]

  -- Check against nil MapUnits.
  if mapUnit == nil then
    error("nil MapUnit cannot be added.")
  end

  -- Make sure the zone exists
  if not self.zone_by_id[zoneID] then
    error("MapUnit " .. mapUnit.name .. " cannot be added because zone " .. zoneID .. " does not exist.")
  end

  -- If the map unit was already added, raise an error
  if self.mapUnitInfoByID[mapUnit.id] then
    error("MapUnit " .. mapUnit.name .. " already exists.")
  end

  -- Give the mapUnit an id if it needs it.
  if mapUnit.id == nil then
    mapUnit.id = self.nextMapUnitID
    self.nextMapUnitID = self.nextMapUnitID + 1
  end

  -- Store in a zone.
  self.mapUnitInfoByID[mapUnit.id] = {
    mapUnit = mapUnit,
    zone = zoneID
  }
end

function Map:getMapUnitsAtLocation(zoneID)
  --[[ Return a table of active MapUnits in a given zone.
  Args:
    zoneID(string): Name of the zone to inspect
  Returns:
    A table array
  ]]

  local mapUnitsByZone = {}
  TableUtility:each(
      self.mapUnitInfoByID,
      function(_, info)
        local localZoneID = info.zone
        if mapUnitsByZone[localZoneID] == nil then mapUnitsByZone[localZoneID] = {} end
        table.insert(mapUnitsByZone[localZoneID], info.mapUnit)
      end
  )
  return mapUnitsByZone[zoneID] or {}
end

function Map:removeMapUnit(mapUnitID)
  --[[ Removes the map unit with the given ID.
  Args:
    mapUnitID(integer): MapUnit.id
  Returns:
    nil
  ]]
  if self.mapUnitInfoByID[mapUnitID]~= nil then
    table.remove(self.mapUnitInfoByID, mapUnitID)
  end
end

function Map:canMapUnitMoveToAdjacentZone(mapUnitID, desiredZoneID)
  --[[ Indicate if the map unit can move to the nearby zone from its current location.
  Args:
    mapUnitID(integer): MapUnit.id
    desiredZoneID(string): Name of the zone
  Returns:
    true if the desired zone can be reached, false otherwise.
  ]]

  -- Make sure the map unit and zone exist
  if not self.mapUnitInfoByID[mapUnitID] then
    error("Map:canMapUnitMoveToAdjacentZone no MapUnit named " .. mapUnitID .. " found.")
  end

  if not self.zone_by_id[desiredZoneID] then
    error("MapUnit " .. self.mapUnitInfoByID[mapUnitID].mapUnit.name ..  " cannot check for movement because zone " .. desiredZoneID .. " does not exist.")
  end
  local mapUnit = self.mapUnitInfoByID[mapUnitID].mapUnit

  -- Visited: start empty
  local visitedZones = {}

  -- Working list starts with the mapUnit's current zone and 0 move
  local workingZones = { { zoneID=self.mapUnitInfoByID[mapUnitID].zone, distance=0 }}
  -- While the working list is not empty
  while TableUtility:size(workingZones) > 0 do
    local thisZoneInfo = table.remove(workingZones, 1)
    local thisZoneID = thisZoneInfo.zoneID
    visitedZones[thisZoneID] = true

    -- If the endpoint is the target zone, return true
    if thisZoneID == desiredZoneID then return true end

    TableUtility:each(
      self.zone_by_id[thisZoneID].neighbors,
      function(toZoneID, zoneNeighborInfo)
        local notVisitedYet = visitedZones[toZoneID] ~= true
        local mapUnitHasTravelMethod = mapUnit:hasOneTravelMethod(
          zoneNeighborInfo.travelMethods
        )
        local withinMapUnitMovement = thisZoneInfo.distance + 1 <= mapUnit.distancePerTurn
        -- Add the neighbor if the unit can reach and hasn't visited it already
        if notVisitedYet and mapUnitHasTravelMethod and withinMapUnitMovement then
          table.insert(
            workingZones,
            {
              zoneID = toZoneID,
              distance = thisZoneInfo.distance + 1
            }
          )
        end
      end
    )
    end

  -- Destination is unreachable, return false
  return false
end

function Map:mapUnitMoves(mapUnitID, nextZoneID, warpUnit)
  --[[ Change the map unit's location to the next zone.
  Args:
    mapUnitID(integer): MapUnit.id
    nextZoneID(string): Name of the zone
    warpUnit(boolean): If true, ignore movement and method limits, and do not consume the map unit's movement.
  Returns:
    nil
  ]]

  -- Make sure the map unit actually exists
  if not self.mapUnitInfoByID[mapUnitID] then
    error("Map:mapUnitMoves no MapUnit named " .. mapUnitID .. " found.")
  end

  -- Make sure the target zone exists
  if not self.zone_by_id[nextZoneID] then
    error("MapUnit " .. self.mapUnitInfoByID[mapUnitID].mapUnit.name ..  " cannot be moved because zone " .. nextZoneID .. " does not exist.")
  end

  local unitInfo = self.mapUnitInfoByID[mapUnitID]

  if not warpUnit then
    -- Can the unit still move this turn?
    if not (unitInfo.mapUnit:hasTurnPartAvailable("move")) then
      error("MapUnit " .. self.mapUnitInfoByID[mapUnitID].mapUnit.name ..  " does not have a move action and cannot reach zone " .. nextZoneID .. " this turn.")
    end
    -- Make sure the unit can actually travel to that zone in a single move
    if not self:canMapUnitMoveToAdjacentZone(mapUnitID, nextZoneID) then
      error("MapUnit " .. self.mapUnitInfoByID[mapUnitID].mapUnit.name ..  " cannot reach zone " .. nextZoneID .. " in a single move.")
    end
  end

  -- Tell the map unit to remember where it's moving.
  unitInfo.mapUnit:recordMovement(unitInfo["zone"], nextZoneID)
  if not warpUnit then
    -- Tell the unit it completed its movement
    unitInfo.mapUnit:turnPartCompleted("move")
  end

  -- Change the zone the unit is in.
  unitInfo["zone"] = nextZoneID
end

function Map:warpMapUnit(mapUnitID, nextZoneID)
  --[[ Move the Map Unit directly to the nextZoneID.
    This does not spend the Map Unit's resources nor does it take terrain into account.
  Args:
    mapUnitID(integer): MapUnit.id
    nextZoneID(string): Name of the zone
  Returns:
    nil
  ]]
  return self:mapUnitMoves(mapUnitID, nextZoneID, true)
end

function Map:resetMapUnitTurn(mapUnitID)
  -- Get Map Unit
  if not self.mapUnitInfoByID[mapUnitID] then
    error("Map:resetMapUnitTurn no MapUnit named " .. mapUnitID .. " found.")
  end

  -- Tell it a new turn has started
  self.mapUnitInfoByID[mapUnitID].mapUnit:startNewTurn()
end
return Map
