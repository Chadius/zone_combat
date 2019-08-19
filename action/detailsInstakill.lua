local DetailsInstakill = {}
DetailsInstakill.__index = DetailsInstakill

function DetailsInstakill:new()
  local newDetailsInstakill = {}
  setmetatable(newDetailsInstakill, DetailsInstakill)

  newDetailsInstakill.isInstakill = true

  return newDetailsInstakill
end

function DetailsInstakill:getType()
  return "instakill"
end

function DetailsInstakill:getDetails()
  return self:targetWasInstakilled()
end

function DetailsInstakill:targetWasInstakilled()
  return self.isInstakill
end

return DetailsInstakill
