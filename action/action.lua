local Action = {}
Action.__index = Action

function Action:new(args)
  local newAction = {}

  setmetatable(newAction, Action)
  newAction.name = args.name or nil
  newAction.damageDealt = args.damage or args.damageDealt or 0
  newAction.instakill = args.instakill or false

  if not newAction.name then error("action must have a name") end

  return newAction
end

function Action:getName()
  return self.name
end

function Action:getDamage()
  return self.damageDealt
end

function Action:isInstakill()
  return self.instakill
end

return Action
