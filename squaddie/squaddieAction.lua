local TableUtility = require ("utility/tableUtility")

local SquaddieAction = {}
SquaddieAction.__index = SquaddieAction

function SquaddieAction:new()
  local newSquaddieAction = {}
  newSquaddieAction.actionsByName = {}
  setmetatable(newSquaddieAction, SquaddieAction)

  return newSquaddieAction
end

function SquaddieAction:addAction(action)
  self.actionsByName[action:getName()] = action
end

function SquaddieAction:getAllActions()
  return TableUtility:values(self.actionsByName)
end

function SquaddieAction:assertActionWithNameExists(name)
  if self.actionsByName[name] == nil then
    error("No action with that name exists: " .. name)
  end
end

function SquaddieAction:getActionByName(name)
  self:assertActionWithNameExists(name)
  return self.actionsByName[name]
end

function SquaddieAction:hasActionByName(name)
  return self.actionsByName[name] ~= nil
end

return SquaddieAction
