local Action = require ("action/action")
local EffectDealsDamage = require ("action/effectDealsDamage")
local EffectInstakills = require ("action/effectInstakills")
local ArrayTable = require ("utility/arrayTable")

local ActionFactory = {}

local createEffectFromDescription = function(effectDescription)
  if effectDescription.damage or effectDescription.dealsDamage then
    return EffectDealsDamage:new(effectDescription)
  end

  if effectDescription.instakill or effectDescription.isInstakill then
    return EffectInstakills:new(effectDescription)
  end

  return nil
end

local scanEffectDescriptionsAndAddEffects = function(effectDescriptions, effectList)
  ArrayTable:new(effectDescriptions)
  :map(
      function(effectDescription)
        return createEffectFromDescription(effectDescription)
      end
  )
  :filter(
      function(newEffect)
        return newEffect ~= nil
      end
  )
  :each(
      function(effect)
        effectList:insert(effect)
      end
  )
end

function ActionFactory:buildNewAction(args)
  local newAction = Action:new(args)

  if args.effects and args.effects.default then
    scanEffectDescriptionsAndAddEffects(
        args.effects.default,
        newAction.effects.default
    )
  end

  if args.effects and args.effects.inControl then
    scanEffectDescriptionsAndAddEffects(
        args.effects.inControl,
        newAction.effects.inControl
    )
  end

  return newAction
end

return ActionFactory
