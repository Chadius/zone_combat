local TableUtility = require ("utility/tableUtility")

local SquaddieHealthAndDeath = {}
SquaddieHealthAndDeath.__index = SquaddieHealthAndDeath

function SquaddieHealthAndDeath:new(args)
  local newSquaddieHealthAndDeath = {}
  setmetatable(newSquaddieHealthAndDeath, SquaddieHealthAndDeath)

  newSquaddieHealthAndDeath.maxHP = args.maxHealth or 5
  newSquaddieHealthAndDeath.currentHP = args.currentHealth or newSquaddieHealthAndDeath.maxHP

  return newSquaddieHealthAndDeath
end

function SquaddieHealthAndDeath:currentHealth()
    return self.currentHP
end

function SquaddieHealthAndDeath:maxHealth()
  return self.maxHP
end

function SquaddieHealthAndDeath:isAlive()
  return (self:currentHealth() > 0)
end

function SquaddieHealthAndDeath:addHealth(hitPoints)
  self.currentHP = TableUtility:min({self.currentHP + hitPoints, self:maxHealth()})
end

function SquaddieHealthAndDeath:setHealthToMax()
  self:addHealth(self:maxHealth())
end

function SquaddieHealthAndDeath:loseHealth(hitPoints)
  self.currentHP = TableUtility:max({self.currentHP - hitPoints, 0})
end

function SquaddieHealthAndDeath:isDead()
  return (self:currentHealth() <= 0)
end

return SquaddieHealthAndDeath
