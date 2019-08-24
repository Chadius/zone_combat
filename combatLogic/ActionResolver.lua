local ActionResult = require("action/actionResult")

local ActionResolver = {}

function ActionResolver:canAttackWithPower(actor, action, target, map)
  return ActionResolver:getReasonCannotAttackWithPower(actor, action, target, map) == nil
end

function ActionResolver:getReasonCannotAttackWithPower(actor, action, target, map)
  if actor:hasAction(action) == false then
    return "User does not have power"
  end

  if target:isDead() then
    return "Target is already dead"
  end

  if not map:isSquaddieOnMap(target.id) then
    return "Target is off map"
  end

  if not map:isSquaddieOnMap(actor.id) then
    return "Actor is off map"
  end

  if actor:isFriendUnit(target) then
    if actor:isSameSquaddie(target) then
      return "Cannot target self with this power"
    else
      return "Cannot target friend with this power"
    end
  end

  local actorCurrentZone = map:getSquaddieCurrentZone(actor)
  local targetCurrentZone = map:getSquaddieCurrentZone(target)
  if actorCurrentZone:isSameZone(targetCurrentZone) ~= true then
    return "Target is out of range"
  end
  return nil
end

function ActionResolver:useActionOnTarget(actor, action, target, map)
  actor:turnPartCompleted("act")

  local result = ActionResult:new()
  local actorIsInControl = map:squaddieIsInControl(actor)
  local actionEffects = action:getEffects(actorIsInControl)
  actionEffects:each(
      function(effect)
        if effect:getType() == "damageDealt" then
          local rawDamage = effect:getDamageDealt()
          target:loseHealth(rawDamage)
          result:actorAttackedTarget(actor, action, target, rawDamage)
        elseif effect:getType() == "instakill" then
          target:instakill()
          result:actorInstakilledTarget(actor, action, target)
        end
      end
  )
  return result
end

return ActionResolver
