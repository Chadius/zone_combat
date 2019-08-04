local SquaddieHealthAndDeath = require ("squaddie/squaddieHealthAndDeath")
local SquaddieOnMap = require ("squaddie/squaddieOnMap")
local Squaddie = require ("squaddie/squaddie")
local TableUtility = require ("utility/tableUtility")
local uuid = require("libraries/uuid")

local SquaddieFactory = {}
SquaddieFactory.__index = SquaddieFactory

local function setAffiliation(newSquaddie, affiliation)
  if not TableUtility:contains(SquaddieFactory.definedAffiliations, affiliation) then
    error("Affiliation "
        .. affiliation
        .. " does not exist. Valid affiliations are "
        .. TableUtility:join(
        SquaddieFactory.definedAffiliations,
        ", "
    )
    )
  else
    newSquaddie.affiliation = affiliation
  end
end

SquaddieFactory.definedAffiliations = {
  "player",
  "ally",
  "enemy",
  "other",
}

function SquaddieFactory:buildNewSquaddie(args)
  local newSquaddie = {}
  setmetatable(newSquaddie, Squaddie)
  newSquaddie.id = uuid()
  newSquaddie.name = args.displayName or "No name"

  newSquaddie.mapPresence = SquaddieOnMap:new(args)
  newSquaddie.healthStatus = SquaddieHealthAndDeath:new(args)

  setAffiliation(newSquaddie, args.affiliation or "other")

  return newSquaddie
end

return SquaddieFactory
