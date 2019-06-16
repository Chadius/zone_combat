--[[ Maps hold multiple Zones.
--]]

local Zone = require "zone"
local ZoneNeighbor = require "zone_neighbor"
local TableUtility = require "tableUtility"

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

  -- Set an id to track SquaddieOnMaps.
  newMap.nextsquaddieOnMapID = 1

  self.SquaddieOnMapInfoByID = {}

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

function Map:addSquaddieOnMap(SquaddieOnMap, zoneID)
  --[[ Adds a SquaddieOnMap to a given zone.
  Args:
    SquaddieOnMap.
    zoneID(string): Name of the zone
  Returns:
    nil
  ]]

  -- Check against nil SquaddieOnMaps.
  if SquaddieOnMap == nil then
    error("nil SquaddieOnMap cannot be added.")
  end

  -- Make sure the zone exists
  self:assertZoneExists(zoneID, "Map:addSquaddieOnMap")

  -- If the map unit was already added, raise an error
  if self:isSquaddieOnMap(SquaddieOnMap.id) then
    error("Map:addSquaddieOnMap: " .. SquaddieOnMap.name .. " already exists.")
  end

  -- Give the SquaddieOnMap an id if it needs it.
  if SquaddieOnMap.id == nil then
    SquaddieOnMap.id = self.nextsquaddieOnMapID
    self.nextsquaddieOnMapID = self.nextsquaddieOnMapID + 1
  end

  -- Store in a zone.
  self.SquaddieOnMapInfoByID[SquaddieOnMap.id] = {
    SquaddieOnMap = SquaddieOnMap,
    zone = zoneID
  }
end

function Map:getSquaddieOnMapsAtLocation(zoneID)
  --[[ Return a table of active SquaddieOnMaps in a given zone.
  Args:
    zoneID(string): Name of the zone to inspect
  Returns:
    A table array
  ]]

  local SquaddieOnMapsByZone = {}
  TableUtility:each(
      self.SquaddieOnMapInfoByID,
      function(_, info)
        local localZoneID = info.zone
        if SquaddieOnMapsByZone[localZoneID] == nil then SquaddieOnMapsByZone[localZoneID] = {} end
        table.insert(SquaddieOnMapsByZone[localZoneID], info.SquaddieOnMap)
      end
  )
  return SquaddieOnMapsByZone[zoneID] or {}
end

function Map:removeSquaddieOnMap(squaddieOnMapID)
  --[[ Removes the map unit with the given ID.
  Args:
    squaddieOnMapID(integer): SquaddieOnMap.id
  Returns:
    nil
  ]]
  if self.SquaddieOnMapInfoByID[squaddieOnMapID]~= nil then
    table.remove(self.SquaddieOnMapInfoByID, squaddieOnMapID)
  end
end

function Map:canSquaddieOnMapMoveToAdjacentZone(squaddieOnMapID, desiredZoneID)
  --[[ Indicate if the map unit can move to the nearby zone from its current location.
  Args:
    squaddieOnMapID(integer): SquaddieOnMap.id
    desiredZoneID(string): Name of the zone
  Returns:
    true if the desired zone can be reached, false otherwise.
  ]]

  self:assertSquaddieIsOnMap(squaddieOnMapID, "Map:canSquaddieOnMapMoveToAdjacentZone")
  self:assertZoneExists(desiredZoneID, "Map:canSquaddieOnMapMoveToAdjacentZone")

  local SquaddieOnMap = self.SquaddieOnMapInfoByID[squaddieOnMapID].SquaddieOnMap

  -- Visited: start empty
  local visitedZones = {}

  -- Working list starts with the SquaddieOnMap's current zone and 0 move
  local workingZones = { { zoneID=self.SquaddieOnMapInfoByID[squaddieOnMapID].zone, distance=0 }}
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
        local SquaddieOnMapHasTravelMethod = SquaddieOnMap:hasOneTravelMethod(
          zoneNeighborInfo.travelMethods
        )
        local withinSquaddieOnMapMovement = thisZoneInfo.distance + 1 <= SquaddieOnMap.distancePerTurn
        -- Add the neighbor if the unit can reach and hasn't visited it already
        if notVisitedYet and SquaddieOnMapHasTravelMethod and withinSquaddieOnMapMovement then
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

function Map:SquaddieOnMapMoves(squaddieOnMapID, nextZoneID, warpUnit)
  --[[ Change the map unit's location to the next zone.
  Args:
    squaddieOnMapID(integer): SquaddieOnMap.id
    nextZoneID(string): Name of the zone
    warpUnit(boolean): If true, ignore movement and method limits, and do not consume the map unit's movement.
  Returns:
    nil
    Throws an error if there is no zone with the given nextZoneID.
    Throws an error if there is no SquaddieOnMap with the given squaddieOnMapID.
    Throws an error if warpUnit is falsy and the SquaddieOnMap cannot reach the next zone.
  ]]

  self:assertSquaddieIsOnMap(squaddieOnMapID, "Map:SquaddieOnMapMoves")
  self:assertZoneExists(nextZoneID, "Map:squaddieOnMapMoves")

  local unitInfo = self.SquaddieOnMapInfoByID[squaddieOnMapID]

  if not warpUnit then
    -- Can the unit still move this turn?
    if not (unitInfo.SquaddieOnMap:hasTurnPartAvailable("move")) then
      error("SquaddieOnMap " .. self.SquaddieOnMapInfoByID[squaddieOnMapID].SquaddieOnMap.name ..  " does not have a move action and cannot reach zone " .. nextZoneID .. " this turn.")
    end
    -- Make sure the unit can actually travel to that zone in a single move
    if not self:canSquaddieOnMapMoveToAdjacentZone(squaddieOnMapID, nextZoneID) then
      error("SquaddieOnMap " .. self.SquaddieOnMapInfoByID[squaddieOnMapID].SquaddieOnMap.name ..  " cannot reach zone " .. nextZoneID .. " in a single move.")
    end
  end

  -- Tell the map unit to remember where it's moving.
  unitInfo.SquaddieOnMap:recordMovement(unitInfo["zone"], nextZoneID)
  if not warpUnit then
    -- Tell the unit it completed its movement
    unitInfo.SquaddieOnMap:turnPartCompleted("move")
  end

  -- Change the zone the unit is in.
  unitInfo["zone"] = nextZoneID
end

function Map:warpSquaddieOnMap(squaddieOnMapID, nextZoneID)
  --[[ Move the Map Unit directly to the nextZoneID.
    This does not spend the Map Unit's resources nor does it take terrain into account.
  Args:
    squaddieOnMapID(integer): SquaddieOnMap.id
    nextZoneID(string): Name of the zone
  Returns:
    nil
  ]]
  return self:SquaddieOnMapMoves(squaddieOnMapID, nextZoneID, true)
end

function Map:resetSquaddieOnMapTurn(squaddieOnMapID)
  --[[ Passthrough function that resets the unit's turn as if it was the start of a new phase.
  Args:
    squaddieOnMapID(integer): SquaddieOnMap.id
  Returns:
    nil
  ]]
  self:assertSquaddieIsOnMap(squaddieOnMapID, "Map:resetSquaddieOnMapTurn")

  -- Tell it a new turn has started
  self.SquaddieOnMapInfoByID[squaddieOnMapID].SquaddieOnMap:startNewTurn()
end

function Map:isSquaddieOnMap(squaddieOnMapID)
  return self.SquaddieOnMapInfoByID[squaddieOnMapID]
end

function Map:assertSquaddieIsOnMap(squaddieOnMapID, nameOfCaller)
  if not self:isSquaddieOnMap(squaddieOnMapID) then
    error(nameOfCaller .. ": SquaddieOnMap not found: " .. squaddieOnMapID )
  end
end

function Map:doesZoneExist(zoneID)
  return self.zone_by_id[zoneID]
end

function Map:assertZoneExists(zoneID, nameOfCaller)
  if not self:doesZoneExist(zoneID) then
    error(nameOfCaller .. ": zone does not exist: " .. zoneID)
  end
end
return Map
