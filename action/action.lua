local TableUtility = require ("utility/tableUtility")

local Action = {}
Action.__index = Action

function Action:new(args)
  local newAction = {}

  setmetatable(newAction, Action)
  newAction.name = args.name or nil

  newAction.effects = {
    default={}
  }

  -- TODO Remove this
  newAction.damageDealt = args.damage or args.damageDealt or 0
  newAction.instakill = args.instakill or false

  if not newAction.name then error("action must have a name") end

  return newAction
end

function Action:getName()
  return self.name
end

-- TODO Add default effects getters
function Action:getDamage()
  local defaultDamageDealingEffect = TableUtility:first(
      self.effects.default,
      function(_, effect)
        return effect:getType() == "damageDealt"
      end
  )

  if defaultDamageDealingEffect then
    return defaultDamageDealingEffect:getDamageDealt()
  end
  return nil
end

function Action:isInstakill()
  return self.instakill
end

function Action:addDefaultAction(newAction)
  table.insert(newAction.defaultEffects, newAction)
end

return Action
