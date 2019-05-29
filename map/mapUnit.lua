--[[ Unit's presence on the map.
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

  newMapUnit.name = args.displayName or "No name"
  newMapUnit.travelMethods = {}
  if args.travelMethods then
    newMapUnit.travelMethods = TableUtility:filter(
        args.travelMethods,
        function(_, possibleMethod)
          return ( MapUnit.definedTravelMethods[possibleMethod] )
        end
    )
  else
    newMapUnit.travelMethods = {"foot"}
  end
  newMapUnit.distancePerTurn = args.distancePerTurn or 1
  newMapUnit.id = nil
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

return MapUnit
