--[[ Maps hold multiple Zones.
--]]

local Zone = require "zone"

local Map={}
Map.__index = Map

function Map:new(args)
  --[[ Create a new Map.
  --]]
  local newMap = {}
  setmetatable(newMap,Map)
  newMap.id = args.id

  -- TODO
  newMap.zones = (args.zones and args.zones ~= "") and args.zones or {}

  if newMap.id == nil then
	 error("Map needs an id")
  end

  return newMap
end

function Map:__tostring()
   return string.format("Map ID: %s", self.id)
end

return Map
