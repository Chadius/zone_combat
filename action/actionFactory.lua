local Action = require ("action/action")
local EffectDealsDamage = require ("action/effectDealsDamage")
local EffectInstakills = require ("action/effectInstakills")
local TableUtility = require ("utility/tableUtility")

local ActionFactory = {}

function ActionFactory:buildNewAction(args)
  local newAction = Action:new(args)

  if args.effects and args.effects.default then
    TableUtility:each(
        args.effects.default,
        function(_, effectArgs)
          if effectArgs.damage or effectArgs.dealsDamage then
            table.insert(
                newAction.effects.default,
                EffectDealsDamage:new(effectArgs)
            )
          end

          if effectArgs.instakill or effectArgs.isInstakill then
            table.insert(
                newAction.effects.default,
                EffectInstakills:new(effectArgs)
            )
          end
        end
    )
  end

  return newAction
end

return ActionFactory
