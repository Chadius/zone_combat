local Action = require ("action/action")
local EffectDealsDamage = require ("action/effectDealsDamage")
local TableUtility = require ("utility/tableUtility")

local ActionFactory = {}

function ActionFactory:buildNewAction(args)
  local newAction = Action:new(args)

  if args.effects and args.effects.default then
    TableUtility:each(
        args.effects.default,
        function(_, effectArgs)
          local newEffect = nil
          if effectArgs.damage then
            newEffect = EffectDealsDamage:new(effectArgs)
          end

          if newEffect then
            table.insert(newAction.effects.default, newEffect)
          end
        end
    )
  end

  return newAction
end

return ActionFactory
