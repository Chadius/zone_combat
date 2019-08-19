local TableUtility = require("utility/TableUtility")
local DetailsDamage = require("action/detailsDamage")
local DetailsInstakill = require("action/detailsInstakill")

local ActionResult = {}
ActionResult.__index = ActionResult

function ActionResult:new()
  local newActionResult = {}
  newActionResult.action = nil
  newActionResult.actor = nil
  newActionResult.target = nil
  setmetatable(newActionResult, ActionResult)
  newActionResult.details = {}

  return newActionResult
end

function ActionResult:setActorActionTarget(actor, action, target)
  self.actor = actor
  self.action = action
  self.target = target
end

function ActionResult:actorAttackedTarget(actor, action, target, damageDealt)
  self:setActorActionTarget(actor, action, target)

  local damageResult = DetailsDamage:new({damageDealt = damageDealt})
  table.insert(self.details, damageResult)
end

function ActionResult:actorInstakilledTarget(actor, action, target)
  self:setActorActionTarget(actor, action, target)

  local instakillResult = DetailsInstakill:new()
  table.insert(self.details, instakillResult)
end

function ActionResult:getActor()
  return self.actor
end

function ActionResult:getAction()
  return self.action
end

function ActionResult:getTarget()
  return self.target
end

function ActionResult:getDamageDealt()
  return self:getFirstDetailOfType("damage")
end

function ActionResult:targetWasInstakilled()
  return self:getFirstDetailOfType("instakill")
end

function ActionResult:getFirstDetailOfType(detailType)
  local firstDetail = TableUtility:first(
      self.details,
      function(_, detail)
        return detail.getType() == detailType
      end
  )

  if firstDetail ~= nil then
    return firstDetail:getDetails()
  end

  return nil
end

return ActionResult
