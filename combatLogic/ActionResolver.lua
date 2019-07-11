-- local CLASSNAME = require ("")

local ActionResolver = {}

function ActionResolver:canAttackWithPower(actor, target, map)
  return ActionResolver:getReasonCannotAttackWithPower(actor, target, map) == nil
end

function ActionResolver:getReasonCannotAttackWithPower(actor, target, map)
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
      return "Cannot target ally with this power"
    end
  end

  local actorCurrentZone = map:getSquaddieCurrentZone(actor)
  local targetCurrentZone = map:getSquaddieCurrentZone(target)
  if actorCurrentZone:isSameZone(targetCurrentZone) ~= true then
    return "Target is out of range"
  end
  return nil
end

return ActionResolver