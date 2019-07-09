-- local CLASSNAME = require ("")

local ActionResolver = {}

function ActionResolver:CanAttackWithPower(actor, target, map)
  return false
end

return ActionResolver
