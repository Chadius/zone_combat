local TableUtility = require ("utility/tableUtility")

local Action = {}
Action.__index = Action

local cloneEffects = function(source)
  local clonedEffects = {}

  TableUtility:each(
      source,
      function(_, effect)
        table.insert(
            clonedEffects,
            effect:clone()
        )
      end
  )

  return clonedEffects
end

function Action:new(args)
  local newAction = {}

  setmetatable(newAction, Action)
  newAction.name = args.name or nil

  newAction.effects = {
    default={},
    inControl={}
  }

  if not newAction.name then error("action must have a name") end

  return newAction
end

function Action:getName()
  return self.name
end

function Action:filterByEffectType(effects, effectType)
  return TableUtility:filter(
      effects,
      function(_, effect)
        return effect:getType() == effectType
      end
  )
end

function Action:getDamageDealt()
  local defaultDamageDealingEffects = self:filterByEffectType(
      self.effects.default,
      "damageDealt"
  )
  if #defaultDamageDealingEffects == 0 then
    return nil
  end

  local damageDealtByEffect = TableUtility:map(
      defaultDamageDealingEffects,
      function(_, effect)
        return effect:getDamageDealt()
      end
  )

  return damageDealtByEffect[1]
end

function Action:getDamage()
  return self:getDamageDealt()
end

function Action:isInstakill()
  local defaultInstakillEffects = self:filterByEffectType(
      self.effects.default,
      "instakill"
  )
  if #defaultInstakillEffects == 0 then
    return false
  end

  local effectInstakills = TableUtility:map(
      defaultInstakillEffects,
      function(_, effect)
        return effect:isInstakill()
      end
  )

  return effectInstakills[1]
end

function Action:getDefaultEffects()
  return cloneEffects(self.effects.default)
end

function Action:getInControlEffects()
  return cloneEffects(self.effects.inControl)
end

return Action
