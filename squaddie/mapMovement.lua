--[[ Information about the Squaddie's movement.
]]

local TableUtility = require "tableUtility"

local MapMovement={}
MapMovement.__index = MapMovement

MapMovement.definedTravelMethods = {
  "none",
  "foot",
  "swim",
  "fly",
  "shadow",
}

function MapMovement:new(args)
  local newMapMovement = {}
  setmetatable(newMapMovement,MapMovement)

  -- travelMethods must match one of the definedTravelMethods.
  newMapMovement.travelMethods = {}
  if args.travelMethods then
    newMapMovement.travelMethods = TableUtility:filter(
        args.travelMethods,
        function(_, possibleMethod)
          return TableUtility:contains( MapMovement.definedTravelMethods, possibleMethod)
        end
    )
  else
    -- By default the Map Unit can travel on foot.
    newMapMovement.travelMethods = {"foot"}
  end
  
  newMapMovement.distancePerTurn = args.distancePerTurn or 1

  return newMapMovement
end

function MapMovement:hasOneTravelMethod(methods)
  --[[ Sees if this MapMovement has at least one of the given travel methods.
  Args:
    methods(string OR table)
      (string): The method to check for.
      (table): An array of strings, each string representing a method to look for.
  Returns:
    Return true if the MapMovement has any of the methods.
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

return MapMovement
