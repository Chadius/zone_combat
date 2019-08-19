local DetailsDamage = {}
DetailsDamage.__index = DetailsDamage

function DetailsDamage:new(args)
  local newDetailsDamage = {}
  setmetatable(newDetailsDamage, DetailsDamage)

  newDetailsDamage.damageDealt = args.damageDealt

  return newDetailsDamage
end

function DetailsDamage:getType()
  return "damage"
end

function DetailsDamage:getDetails()
  return self:getDamageDealt()
end

function DetailsDamage:getDamageDealt()
  return self.damageDealt
end

return DetailsDamage
