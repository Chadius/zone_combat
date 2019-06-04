--[[ Unit's presence on a given map.
]]
local TableUtility = require "table_utility"

local MapUnit={}
MapUnit.__index = MapUnit

MapUnit.definedTravelMethods = {
  "none",
  "foot",
  "swim",
  "fly",
  "shadow",
}

function MapUnit:new(args)
  local newMapUnit = {}
  setmetatable(newMapUnit,MapUnit)
  newMapUnit.id = nil
  newMapUnit.name = args.displayName or "No name"

  -- travelMethods must match one of the definedTravelMethods.
  newMapUnit.travelMethods = {}
  if args.travelMethods then
    newMapUnit.travelMethods = TableUtility:filter(
      args.travelMethods,
        function(_, possibleMethod)
        return TableUtility:contains( MapUnit.definedTravelMethods, possibleMethod)
      end
    )
  else
    -- By default the Map Unit can travel on foot.
    newMapUnit.travelMethods = {"foot"}
  end
  newMapUnit.distancePerTurn = args.distancePerTurn or 1
  newMapUnit.recordForLastTurn = {
    movement={}
  }
  newMapUnit.turnParts = {
    move = true
  }

  return newMapUnit
end

function MapUnit:hasOneTravelMethod(methods)
  --[[ Sees if this MapUnit has at least one of the given travel methods.
  Args:
    methods(string OR table)
      (string): The method to check for.
      (table): An array of strings, each string representing a method to look for.
  Returns:
    Return true if the MapUnit has any of the methods.
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

function MapUnit:isTurnReady()
  return self.turnParts["move"]
end

function MapUnit:hasTurnPartAvailable(partName)
  return self.turnParts[partName]
end

function MapUnit:turnPartCompleted(partName)
  if not self.turnParts[partName] then
    error("MapUnit:TurnPartCompleted can't complete " .. partName .. " because it does not exist.")
  end
  self.turnParts[partName] = false
end

function MapUnit:currentTurnPart()
  return "move"
end

function MapUnit:getLastTurnMovement()
  return self.recordForLastTurn.movement
end

function MapUnit:recordMovement(fromZoneID, toZoneID)
  table.insert(
    self.recordForLastTurn.movement,
    fromZoneID
  )
  table.insert(
      self.recordForLastTurn.movement,
      toZoneID
  )
end

return MapUnit
