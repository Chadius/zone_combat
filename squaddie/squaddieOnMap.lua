--[[ Squaddie's presence on a given map.
]]
local TableUtility = require "tableUtility"
local MapTurn = require "squaddie/mapTurn"

local SquaddieOnMap={}
SquaddieOnMap.__index = SquaddieOnMap

SquaddieOnMap.definedTravelMethods = {
  "none",
  "foot",
  "swim",
  "fly",
  "shadow",
}

local function startNewSquaddieOnMapTurn(self)
  --[[ Resets the unit's turn as if it was the start of a new phase.
    Args:
      nil
    Returns:
      nil
  ]]

  -- Clear history
  self.recordForLastTurn = {
    movement={}
  }
end

function SquaddieOnMap:new(args)
  local newSquaddieOnMap = {}
  setmetatable(newSquaddieOnMap,SquaddieOnMap)
  newSquaddieOnMap.id = nil
  newSquaddieOnMap.name = args.displayName or "No name"

  -- travelMethods must match one of the definedTravelMethods.
  newSquaddieOnMap.travelMethods = {}
  if args.travelMethods then
    newSquaddieOnMap.travelMethods = TableUtility:filter(
      args.travelMethods,
        function(_, possibleMethod)
        return TableUtility:contains( SquaddieOnMap.definedTravelMethods, possibleMethod)
      end
    )
  else
    -- By default the Map Unit can travel on foot.
    newSquaddieOnMap.travelMethods = {"foot"}
  end

  newSquaddieOnMap.mapTurn = MapTurn:new({
    turnParts = args.turnParts
  })

  newSquaddieOnMap.distancePerTurn = args.distancePerTurn or 1
  newSquaddieOnMap.recordForLastTurn = {}

  startNewSquaddieOnMapTurn(newSquaddieOnMap)

  return newSquaddieOnMap
end

function SquaddieOnMap:hasOneTravelMethod(methods)
  --[[ Sees if this SquaddieOnMap has at least one of the given travel methods.
  Args:
    methods(string OR table)
      (string): The method to check for.
      (table): An array of strings, each string representing a method to look for.
  Returns:
    Return true if the SquaddieOnMap has any of the methods.
    Return false otherwise.
  ]]
  if type(methods) == "table" then
    return TableUtility:any(
      methods,
      function( _, thisMethod)
        return TableUtility:contains(self.travelMethods, thisMethod)
      end
    )
  end

  return TableUtility:contains(self.travelMethods, methods)
end

function SquaddieOnMap:getLastTurnMovement()
  --[[ Returns the record of the unit's movement last turn.
  Args:
    None
  Returns:
    An array of strings
  ]]
  return self.recordForLastTurn.movement
end

function SquaddieOnMap:recordMovement(fromZoneID, toZoneID)
  --[[ Note the unit's movement from one zone to the next.
  Args:
    fromZoneID(string): The name of the starting zone.
    toZoneID(string): The name of the ending zone.
  Returns:
      nil
  ]]
  table.insert(
    self.recordForLastTurn.movement,
    fromZoneID
  )
  table.insert(
      self.recordForLastTurn.movement,
      toZoneID
  )
end

function SquaddieOnMap:hasTurnPartAvailable(partName)
  return self.mapTurn:hasTurnPartAvailable(partName)
end

function SquaddieOnMap:turnPartCompleted(partName)
  local newMapTurn = self.mapTurn:turnPartCompleted(partName)
  self.mapTurn = newMapTurn
end

function SquaddieOnMap:currentTurnPart()
  return self.mapTurn:currentTurnPart()
end

function SquaddieOnMap:startNewTurn()
  local newMapTurn = self.mapTurn:startNewTurn()
  self.mapTurn = newMapTurn
  startNewSquaddieOnMapTurn(self)
end

function SquaddieOnMap:isTurnReady()
  return self.mapTurn:isTurnReady()
end

function SquaddieOnMap:assertHasTurnPartAvailable(partName, nameOfCaller)
  if not self.mapTurn:hasTurnPartAvailable(partName) then
    error(nameOfCaller .. ": squaddie does not have a " .. partName .. " action available.")
  end
end

return SquaddieOnMap
