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

function ActionResolver:usePowerOnTarget(actor, target)
  actor:turnPartCompleted("act")
  target:instakill()
end

return ActionResolver
