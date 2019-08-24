local ArrayTable = require ("utility/arrayTable")

local Action = {}
Action.__index = Action

function Action:new(args)
  local newAction = {}

  setmetatable(newAction, Action)
  newAction.name = args.name or nil

  newAction.effects = {
    default=ArrayTable:new(),
    inControl=ArrayTable:new()
  }

  if not newAction.name then error("action must have a name") end

  return newAction
end

function Action:getName()
  return self.name
end

function Action:filterByEffectType(effectType, actorIsInControl)
  local effects = self:getDefaultEffects()

  if actorIsInControl == true then
    effects = self:getInControlEffects()
  end

  return effects:filter(
      function(effect)
        return effect:getType() == effectType
      end
  )
end

function Action:getDefaultDamageDealt()
  return self:getTotalDamage(false)
end

function Action:getTotalDamage(actorIsInControl)
  local defaultDamageDealingEffects = self:filterByEffectType(
      "damageDealt",
      actorIsInControl
  )
  if defaultDamageDealingEffects:isEmpty() then
    return nil
  end
  return defaultDamageDealingEffects:sum(
      function(total, effect)
        return total + effect:getDamageDealt()
      end,
      0
  )
end

function Action:getDefaultDamage()
  return self:getDefaultDamageDealt()
end

function Action:hasDefaultEffect(effectType)
  return self:hasEffect(effectType, false)
end

function Action:hasInControlEffect(effectType)
  return self:hasEffect(effectType, true)
end

function Action:hasEffect(effectType, actorIsInControl)
  local effects = self:filterByEffectType(effectType, actorIsInControl)
  return effects:size() > 0
end

function Action:getEffects(actorIsInControl)
  if actorIsInControl then
    return self:getInControlEffects()
  end
  return self:getDefaultEffects()
end

function Action:getDefaultEffects()
  return self.effects.default:clone()
end

function Action:getInControlEffects()
  if self.effects.inControl:isEmpty() then
    return self:getDefaultEffects()
  end

  return self.effects.inControl:clone()
end

return Action
