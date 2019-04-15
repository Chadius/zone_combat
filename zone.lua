local Zone={}
Zone.__index = Zone

function Zone:new(args)
  --[[ Create a new Zone.
  --]]
  local newZone = {}
  setmetatable(newZone,Zone)
  newZone.id = args.id

  if newZone.id == nil then
	 error("Zone needs an id")
  end

  return newZone
end

return Zone
