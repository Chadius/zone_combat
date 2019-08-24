local EffectInstakills = {}
EffectInstakills.__index = EffectInstakills

function EffectInstakills:new(args)
  local newEffectInstakills = {}
  setmetatable(newEffectInstakills, EffectInstakills)

  newEffectInstakills.instakill = true

  return newEffectInstakills
end

function EffectInstakills:isInstakill()
  return true
end

function EffectInstakills:getType()
  return "instakill"
end

return EffectInstakills
