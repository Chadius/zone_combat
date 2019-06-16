--[[ Squaddie's presence on a given map.
]]
local TableUtility = require "tableUtility"

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
  self.turnParts["move"] = true

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
  newSquaddieOnMap.distancePerTurn = args.distancePerTurn or 1
  newSquaddieOnMap.turnParts = {}
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

function SquaddieOnMap:isTurnReady()
  --[[ Checks the SquaddieOnMap to see if it is ready to take its turn.
  Args:
    None
  Returns:
    A boolean
  ]]
  return self.turnParts["move"]
end

function SquaddieOnMap:assertHasTurnPartAvailable(partName, nameOfCaller)
  if not self:hasTurnPartAvailable(partName) then
    error(nameOfCaller .. ": squaddie does not have a " .. partName .. " action available.")
  end
end

function SquaddieOnMap:hasTurnPartAvailable(partName)
  --[[ Checks to see if a part of a turn has completed.
  Args:
    partName(string): The name of the turn part (example: "move")
  Returns:
    A boolean (or nil if the partName isn't one of the turn parts.)
  ]]
  return self.turnParts[partName]
end

function SquaddieOnMap:turnPartCompleted(partName)
  --[[ Note that part of a unit's turn has completed.
  Args:
    partName(string): The name of the turn part (example: "move")
  Returns:
    nil
    Throws an error if the partName doesn't match an expected turn part.
  ]]
  if self.turnParts[partName] == nil then
    error("SquaddieOnMap:TurnPartCompleted can't complete " .. partName .. " because it does not exist.")
  end
  self.turnParts[partName] = false
end

function SquaddieOnMap:currentTurnPart()
  --[[ Returns a string explaining which part of the turn is next for this unit.
  Args:
    None
  Returns:
    A string.
  ]]
  return "move"
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

function SquaddieOnMap:startNewTurn()
  --[[ Resets the unit's turn as if it was the start of a new phase.
    Args:
      nil
    Returns:
      nil
  ]]
  startNewSquaddieOnMapTurn(self)
end

return SquaddieOnMap
