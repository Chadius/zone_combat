local EffectDealsDamage = {}
EffectDealsDamage.__index = EffectDealsDamage

function EffectDealsDamage:new(args)
  local newEffectDealsDamage = {}
  setmetatable(newEffectDealsDamage, EffectDealsDamage)

  newEffectDealsDamage.damageDealt = args.damageDealt or args.damage

  return newEffectDealsDamage
end

function EffectDealsDamage:getDamageDealt()
  return self.damageDealt
end

function EffectDealsDamage:getType()
  return "damageDealt"
end

function EffectDealsDamage:clone()
  return EffectDealsDamage:new({damageDealt = self:getDamageDealt()})
end

return EffectDealsDamage
