local SquaddieHealthAndDeath = require ("squaddie/squaddieHealthAndDeath")
local SquaddieOnMap = require ("squaddie/squaddieOnMap")
local Squaddie = require ("squaddie/squaddie")
local TableUtility = require ("utility/tableUtility")

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
  local newSquaddie = Squaddie:new(args)
  newSquaddie:setMapPresence(SquaddieOnMap:new(args))
  newSquaddie:setHealthStatus(SquaddieHealthAndDeath:new(args))

  setAffiliation(newSquaddie, args.affiliation or "other")

  return newSquaddie
end

return SquaddieFactory
