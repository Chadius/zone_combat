--[[ Map Turn shows the state for a Squaddie.
]]
local TableUtility = require "tableUtility"

local SquaddieMapTurn={}
SquaddieMapTurn.__index = SquaddieMapTurn

local function clone(source)
  local newSquaddieMapTurn = SquaddieMapTurn:new({
    turnParts = TableUtility:clone(source.turnParts)
  })

  return newSquaddieMapTurn
end

local function initializeForNewMapTurn(self)
  --[[ Returns a new MapTurn with all actions available.
    Args:
      nil
    Returns:
      nil
  ]]

  self.turnParts["move"] = true
  return self
end

function SquaddieMapTurn:new(args)
  local newSquaddieMapTurn = {}
  setmetatable(newSquaddieMapTurn,SquaddieMapTurn)
  newSquaddieMapTurn.turnParts = args.turnParts or {}

  if not args.turnParts then
    newSquaddieMapTurn = initializeForNewMapTurn(newSquaddieMapTurn)
  end

  return newSquaddieMapTurn
end

function SquaddieMapTurn:isTurnReady()
  --[[ Checks the SquaddieMapTurn to see if it is ready to take its turn.
  Args:
    None
  Returns:
    A boolean
  ]]
  return self.turnParts["move"]
end

function SquaddieMapTurn:hasTurnPartAvailable(partName)
  --[[ Checks to see if a part of a turn has completed.
  Args:
    partName(string): The name of the turn part (example: "move")
  Returns:
    A boolean (or nil if the partName isn't one of the turn parts.)
  ]]
  return self.turnParts[partName]
end

function SquaddieMapTurn:currentTurnPart()
  --[[ Returns a string explaining which part of the turn is next for this unit.
  Args:
    None
  Returns:
    A string.
  ]]
  return "move"
end

function SquaddieMapTurn:turnPartCompleted(partName)
  --[[ Returns a copy of this MapTurn, but part of turn has been completed.
  Args:
    partName(string): The name of the turn part (example: "move")
  Returns:
    nil
    Throws an error if the partName doesn't match an expected turn part.
  ]]
  if self.turnParts[partName] == nil then
    error("SquaddieMapTurn:TurnPartCompleted can't complete " .. partName .. " because it does not exist.")
  end
  local duplicate = clone(self)
  duplicate.turnParts[partName] = false
  return duplicate
end

function SquaddieMapTurn:startNewTurn()
  --[[ Returns a new MapTurn with all actions available.
    Args:
      nil
    Returns:
      nil
  ]]
  local duplicate = clone(self)
  return initializeForNewMapTurn(duplicate)
end

return SquaddieMapTurn
