local TableUtility = require ("utility/tableUtility")

local SquaddieAction = {}
SquaddieAction.__index = SquaddieAction

function SquaddieAction:new(args)
  local newSquaddieAction = {}
  newSquaddieAction.actionsByName = {}
  setmetatable(newSquaddieAction, SquaddieAction)

  return newSquaddieAction
end

function SquaddieAction:addAction(action)
  self.actionsByName[action:getName()] = action
end

function SquaddieAction:getAllActions()
  return TableUtility:keys(self.actionsByName)
end

return SquaddieAction
