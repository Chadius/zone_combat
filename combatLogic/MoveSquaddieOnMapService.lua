--[[ This service moves Squaddies across Maps.
It is stateless.
]]

local TableUtility = require "tableUtility"

local MoveSquaddieOnMapService={}

function MoveSquaddieOnMapService:canSquaddieMoveToAdjacentZone(map, squaddie, desiredZone)
  local desiredZoneID = desiredZone.id

  -- Visited: start empty
  local visitedZones = {}

  -- Working list starts with the squaddie's current zone and 0 move
  local workingZones = { { zone=map:getSquaddieCurrentZone(squaddie), distance=0 }}

  -- While the working list is not empty
  while TableUtility:size(workingZones) > 0 do
    local thisZoneInfo = table.remove(workingZones, 1)
    local thisZoneID = thisZoneInfo.zone.id
    visitedZones[thisZoneID] = true

    -- If the endpoint is the target zone, return true
    if thisZoneID == desiredZoneID then return true end

    local visitingZone = map:getZoneByID(thisZoneID)

    TableUtility:each(
        visitingZone.neighbors,
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
                  zone = map:getZoneByID(toZoneID),
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

function MoveSquaddieOnMapService:spendSquaddieMoveAction(map, squaddie)
  -- Tell the squaddie it completed its movement
  map:assertSquaddieIsOnMap(squaddie.id, "MoveSquaddieOnMapService:spendSquaddieMoveAction")
  squaddie:turnPartCompleted("move")
end

function MoveSquaddieOnMapService:assertSquaddieCanMoveToZoneThisTurn(map, squaddie, zone)
  -- Can the unit still move this turn?
  squaddie:assertHasTurnPartAvailable("move", "MoveSquaddieOnMapService:assertSquaddieCanMoveToZoneThisTurn with " .. squaddie.id )

  -- Make sure the unit can actually travel to that zone in a single move
  if not MoveSquaddieOnMapService:canSquaddieMoveToAdjacentZone(map, squaddie, zone) then
    error("squaddie " .. squaddie.name ..  " cannot reach zone " .. zone.id .. " in a single move.")
  end
end

function MoveSquaddieOnMapService:moveSquaddieAndSpendTurn(map, squaddie, zone)
  --[[ Squaddie will spend its turn to move to the next zone.
  ]]

  MoveSquaddieOnMapService:assertSquaddieCanMoveToZoneThisTurn(map, squaddie, zone)
  MoveSquaddieOnMapService:spendSquaddieMoveAction(map, squaddie)

  -- Change the zone the unit is in.
  map:changeSquaddieZone(
      squaddie,
      zone
  )
end

function MoveSquaddieOnMapService:placeSquaddieInZone(map, squaddie, nextZone)
  --[[ Move the squaddie to the next zone at no cost.
  ]]
  map:changeSquaddieZone(
      squaddie,
      nextZone
  )
end

return MoveSquaddieOnMapService
