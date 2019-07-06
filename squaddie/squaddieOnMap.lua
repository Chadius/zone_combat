--[[ Squaddie's presence on a given map.
]]
local TableUtility = require ("utility/tableUtility")
local MapTurn = require "squaddie/mapTurn"
local MapMovement = require "squaddie/mapMovement"

local SquaddieOnMap={}
SquaddieOnMap.__index = SquaddieOnMap

function SquaddieOnMap:new(args)
  local newSquaddieOnMap = {}
  setmetatable(newSquaddieOnMap,SquaddieOnMap)
  newSquaddieOnMap.id = nil
  newSquaddieOnMap.name = args.displayName or "No name"

  newSquaddieOnMap.mapMovement = MapMovement:new(args)

  newSquaddieOnMap.mapTurn = MapTurn:new({
    turnParts = args.turnParts
  })

  return newSquaddieOnMap
end

function SquaddieOnMap:hasOneTravelMethod(methods)
  return self.mapMovement:hasOneTravelMethod(methods)
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
end

function SquaddieOnMap:isTurnReady()
  return self.mapTurn:isTurnReady()
end

function SquaddieOnMap:assertHasTurnPartAvailable(partName, nameOfCaller)
  if not self.mapTurn:hasTurnPartAvailable(partName) then
    error(nameOfCaller .. ": squaddie does not have a " .. partName .. " action available.")
  end
end

function SquaddieOnMap:getDistancePerTurn()
  return self.mapMovement.distancePerTurn
end

return SquaddieOnMap
