--[[ Maps hold multiple Zones.
--]]

local Zone = require "map/zone"
local TableUtility = require "tableUtility"

local Map={}
Map.__index = Map

local function AddZoneNeighbor(self, from, to, cost, travelMethods)
  --[[ Create a new zone neighbor and add it to the map's zone information
  ]]
  -- Add to this zone
  local newZone = self.zone_by_id[from]:addNeighbor(to, cost, travelMethods)
  self.zone_by_id[from] = newZone
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
          newMap:addZoneNeighbors(zone)
        end
    )
  end

  -- Delete any invalid neighbors.
  newMap:VerifyZoneNeighbor()

  self.squaddieInfoByID = {}

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
  self.zone_by_id[newZone.id] = newZone
end

function Map:addZoneNeighbors(zone)
  --[[ All zones have been added. Time to add neighbors.
  ]]

  for _, neighbor_info in ipairs(zone.neighbors or {}) do
    if self.zone_by_id[neighbor_info.to] == nil then
      error("Map:addZoneNeighbors: Zone " .. neighbor_info.to .. " does not exist")
    end

    AddZoneNeighbor(
      self,
      zone.id,
      neighbor_info.to,
      neighbor_info.cost,
      neighbor_info.travelMethods
    )

    -- If the neighbor is bidirectional, add a neighbor with reversed direction.
    if neighbor_info.bidirectional then
      AddZoneNeighbor(
        self,
        neighbor_info.to,
        zone.id,
        neighbor_info.cost,
        neighbor_info.travelMethods
      )
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
  for key, zone in pairs(self.zone_by_id) do
    local verifiedZone = zone:filterInvalidZones()
    self.zone_by_id[key] = verifiedZone
  end
end

function Map:__tostring()
   return string.format("Map ID: %s", self.id)
end

function Map:addSquaddie(squaddie, zoneID)
  --[[ Adds a squaddie to a given zone.
  Args:
    squaddie.
    zoneID(string): Name of the zone
  Returns:
    nil
  ]]

  -- Check against nil squaddies.
  if squaddie == nil then
    error("nil squaddie cannot be added.")
  end

  -- Make sure the zone exists
  self:assertZoneExists(zoneID, "Map:addSquaddie")

  -- If the map unit was already added, raise an error
  if self:isSquaddieOnMap(squaddie.id) then
    error("Map:addSquaddie: " .. squaddie.name .. " already exists.")
  end

  -- Store in a zone.
  self.squaddieInfoByID[squaddie.id] = {
    squaddie = squaddie,
    zone = zoneID
  }
end

function Map:getSquaddiesInZone(zoneID)
  --[[ Return a table of active squaddies in a given zone.
  Args:
    zoneID(string): Name of the zone to inspect
  Returns:
    A table array
  ]]

  local squaddiesByZone = {}
  TableUtility:each(
      self.squaddieInfoByID,
      function(_, info)
        local localZoneID = info.zone
        if squaddiesByZone[localZoneID] == nil then squaddiesByZone[localZoneID] = {} end
        table.insert(squaddiesByZone[localZoneID], info.squaddie)
      end
  )
  return squaddiesByZone[zoneID] or {}
end

function Map:removeSquaddie(squaddieID)
  --[[ Removes the map unit with the given ID.
  Args:
    squaddieID(integer): squaddie.id
  Returns:
    nil
  ]]
  if self:isSquaddieOnMap(squaddieID) then
    self.squaddieInfoByID[squaddieID] = nil
  end
end

function Map:canSquaddieMoveToAdjacentZone(squaddieID, desiredZoneID)
  --[[ Indicate if the map unit can move to the nearby zone from its current location.
  Args:
    squaddieID(integer): squaddie.id
    desiredZoneID(string): Name of the zone
  Returns:
    true if the desired zone can be reached, false otherwise.
  ]]

  self:assertSquaddieIsOnMap(squaddieID, "Map:canSquaddieMoveToAdjacentZone")
  self:assertZoneExists(desiredZoneID, "Map:canSquaddieMoveToAdjacentZone")

  local squaddie = self.squaddieInfoByID[squaddieID].squaddie

  -- Visited: start empty
  local visitedZones = {}

  -- Working list starts with the squaddie's current zone and 0 move
  local workingZones = { { zoneID=self.squaddieInfoByID[squaddieID].zone, distance=0 }}
  -- While the working list is not empty
  while TableUtility:size(workingZones) > 0 do
    local thisZoneInfo = table.remove(workingZones, 1)
    local thisZoneID = thisZoneInfo.zoneID
    visitedZones[thisZoneID] = true

    -- If the endpoint is the target zone, return true
    if thisZoneID == desiredZoneID then return true end

    TableUtility:each(
      self.zone_by_id[thisZoneID].neighbors,
      function(_, zoneNeighborInfo)
        local toZoneID = zoneNeighborInfo.toZoneID
        local notVisitedYet = visitedZones[toZoneID] ~= true
        local squaddieHasTravelMethod = squaddie:hasOneTravelMethod(
          zoneNeighborInfo.travelMethods
        )
        local withinSquaddieMovement = thisZoneInfo.distance + 1 <= squaddie.mapPresence:getDistancePerTurn()
        -- Add the neighbor if the unit can reach and hasn't visited it already
        if notVisitedYet and squaddieHasTravelMethod and withinSquaddieMovement then
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

function Map:spendSquaddieMoveAction(squaddieID)
  -- Tell the squaddie it completed its movement
  self:assertSquaddieIsOnMap(squaddieID, "Map:spendSquaddieMoveAction")
  local squaddie = self.squaddieInfoByID[squaddieID]
  squaddie.squaddie:turnPartCompleted("move")
end

function Map:assertSquaddieCanMoveToZoneThisTurn(squaddieID, destinationZoneID)
  self:assertSquaddieIsOnMap(squaddieID, "Map:moveSquaddieAndSpendTurn")
  self:assertZoneExists(destinationZoneID, "Map:moveSquaddieAndSpendTurn")

  local unitInfo = self.squaddieInfoByID[squaddieID]

  -- Can the unit still move this turn?
  unitInfo.squaddie:assertHasTurnPartAvailable("move", "Map:moveSquaddieAndSpendTurn with " .. unitInfo.squaddie.name )

  -- Make sure the unit can actually travel to that zone in a single move
  if not self:canSquaddieMoveToAdjacentZone(squaddieID, destinationZoneID) then
    error("squaddie " .. unitInfo.squaddie.name ..  " cannot reach zone " .. destinationZoneID .. " in a single move.")
  end
end

function Map:moveSquaddieAndSpendTurn(squaddieID, nextZoneID)
  --[[ Squaddie will spend its turn to move to the next zone.
  Args:
    squaddieID(integer): squaddie.id
    nextZoneID(string): Name of the zone
  Returns:
    nil
  ]]

  self:assertSquaddieIsOnMap(squaddieID, "Map:moveSquaddieAndSpendTurn")
  self:assertZoneExists(nextZoneID, "Map:moveSquaddieAndSpendTurn")

  local unitInfo = self.squaddieInfoByID[squaddieID]

  self:assertSquaddieCanMoveToZoneThisTurn(squaddieID, nextZoneID)
  self:spendSquaddieMoveAction(squaddieID)

  -- Change the zone the unit is in.
  unitInfo["zone"] = nextZoneID
end

function Map:placeSquaddieInZone(squaddieID, nextZoneID)
  --[[ Move the squaddie to the next zone at no cost.
  Args:
    squaddieID(integer): squaddie.id
    nextZoneID(string): Name of the zone
  Returns:
    nil
  ]]

  self:assertSquaddieIsOnMap(squaddieID, "Map:moveSquaddieAndSpendTurn")
  self:assertZoneExists(nextZoneID, "Map:moveSquaddieAndSpendTurn")

  local unitInfo = self.squaddieInfoByID[squaddieID]

  -- Change the zone the unit is in.
  unitInfo["zone"] = nextZoneID
end

function Map:resetSquaddieTurn(squaddieID)
  --[[ Pass through function that resets the unit's turn as if it was the start of a new phase.
  Args:
    squaddieID(integer): squaddie.id
  Returns:
    nil
  ]]
  self:assertSquaddieIsOnMap(squaddieID, "Map:resetSquaddieTurn")

  -- Tell it a new turn has started
  self.squaddieInfoByID[squaddieID].squaddie:startNewTurn()
end

function Map:isSquaddieOnMap(squaddieID)
  return self.squaddieInfoByID[squaddieID]
end

function Map:assertSquaddieIsOnMap(squaddieID, nameOfCaller)
  if not self:isSquaddieOnMap(squaddieID) then
    error(nameOfCaller .. ": squaddie not found: " .. squaddieID )
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
