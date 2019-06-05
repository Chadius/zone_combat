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

MapUnit.definedAffiliations = {
  "player",
  "ally",
  "enemy",
  "other",
}

local function startNewMapUnitTurn(self)
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

local function setAffiliation(newMapUnit, affiliation)
  --[[ Set the MapUnit's affiliation.
  Throws an error if an invalid affiliation is passed.
    Args:
      newMapUnit(object)
      affiliation(string) Should be one of the MapUnit.definedAffiliations values.
    Returns:
      nil
  ]]
  if not TableUtility:contains(MapUnit.definedAffiliations, affiliation) then
    error("Affiliation "
        .. affiliation
        .. " does not exist. Valid affiliations are "
        .. TableUtility:join(
        MapUnit.definedAffiliations,
        ", "
    )
    )
  else
    newMapUnit.affiliation = affiliation
  end
end


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
  newMapUnit.turnParts = {}
  newMapUnit.recordForLastTurn = {}

  startNewMapUnitTurn(newMapUnit)
  setAffiliation(newMapUnit, args.affiliation or "other")

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
  --[[ Checks the MapUnit to see if it is ready to take its turn.
  Args:
    None
  Returns:
    A boolean
  ]]
  return self.turnParts["move"]
end

function MapUnit:hasTurnPartAvailable(partName)
  --[[ Checks to see if a part of a turn has completed.
  Args:
    partName(string): The name of the turn part (example: "move")
  Returns:
    A boolean (or nil if the partName isn't one of the turn parts.)
  ]]
  return self.turnParts[partName]
end

function MapUnit:turnPartCompleted(partName)
  --[[ Note that part of a unit's turn has completed.
  Args:
    partName(string): The name of the turn part (example: "move")
  Returns:
    nil
    Throws an error if the partName doesn't match an expected turn part.
  ]]
  if self.turnParts[partName] == nil then
    error("MapUnit:TurnPartCompleted can't complete " .. partName .. " because it does not exist.")
  end
  self.turnParts[partName] = false
end

function MapUnit:currentTurnPart()
  --[[ Returns a string explaining which part of the turn is next for this unit.
  Args:
    None
  Returns:
    A string.
  ]]
  return "move"
end

function MapUnit:getLastTurnMovement()
  --[[ Returns the record of the unit's movement last turn.
  Args:
    None
  Returns:
    An array of strings
  ]]
  return self.recordForLastTurn.movement
end

function MapUnit:recordMovement(fromZoneID, toZoneID)
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

function MapUnit:startNewTurn()
  --[[ Resets the unit's turn as if it was the start of a new phase.
    Args:
      nil
    Returns:
      nil
  ]]
  startNewMapUnitTurn(self)
end

function MapUnit:getAffilation()
  --[[ Returns the MapUnit's affiliation.
  Args:
    nil
  Returns:
    A string
  ]]
  return self.affiliation
end

function MapUnit:isFriendUnit(otherMapUnit)
  --[[ Sees if the other MapUnit is considered friendly.
  Args:
    otherMapUnit(MapUnit)
  Returns:
    boolean
  ]]

  -- A MapUnit is always its own friend.
  if self == otherMapUnit then
    return true
  end

  local friendlyAffiliations = {
    player={"player", "ally"},
    ally={"player", "ally"},
    enemy={"enemy",},
    other={}
  }

  return TableUtility:contains(friendlyAffiliations[self.affiliation], otherMapUnit.affiliation)
end

return MapUnit
