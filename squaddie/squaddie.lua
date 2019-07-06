--[[ This entity represents a single soldier who exists in armies and on maps.
The entity can take actions and may be destroyed.
]]

local SquaddieOnMap = require "squaddie/squaddieOnMap"
local TableUtility = require ("utility/tableUtility")
local uuid = require("libraries/uuid")

local Squaddie={}
Squaddie.__index = Squaddie

local function setAffiliation(newSquaddie, affiliation)
  --[[ Set the Squaddie's affiliation.
  Throws an error if an invalid affiliation is passed.
    Args:
      newSquaddie(object)
      affiliation(string) Should be one of the Squaddie.definedAffiliations values.
    Returns:
      nil
  ]]
  if not TableUtility:contains(Squaddie.definedAffiliations, affiliation) then
    error("Affiliation "
        .. affiliation
        .. " does not exist. Valid affiliations are "
        .. TableUtility:join(
        Squaddie.definedAffiliations,
        ", "
    )
    )
  else
    newSquaddie.affiliation = affiliation
  end
end

Squaddie.definedAffiliations = {
  "player",
  "ally",
  "enemy",
  "other",
}

function Squaddie:new(args)
  local newSquaddie = {}
  setmetatable(newSquaddie, Squaddie)
  newSquaddie.id = uuid()
  newSquaddie.name = args.displayName or "No name"

  newSquaddie.mapPresence = SquaddieOnMap:new(args)

  setAffiliation(newSquaddie, args.affiliation or "other")

  return newSquaddie
end

function Squaddie:hasOneTravelMethod(methods)
  return self.mapPresence:hasOneTravelMethod(methods)
end

function Squaddie:isTurnReady()
  return self.mapPresence:isTurnReady()
end

function Squaddie:hasTurnPartAvailable(partName)
  return self.mapPresence:hasTurnPartAvailable(partName)
end

function Squaddie:assertHasTurnPartAvailable(partName, nameOfCaller)
  return self.mapPresence:assertHasTurnPartAvailable(partName, nameOfCaller)
end

function Squaddie:turnPartCompleted(partName)
  return self.mapPresence:turnPartCompleted(partName)
end

function Squaddie:currentTurnPart()
  return self.mapPresence:currentTurnPart()
end

function Squaddie:startNewTurn()
  return self.mapPresence:startNewTurn()
end

function Squaddie:getAffilation()
  --[[ Returns the SquaddieOnMap's affiliation.
  Args:
    nil
  Returns:
    A string
  ]]
  return self.affiliation
end

function Squaddie:isFriendUnit(otherSquaddie)
  --[[ Sees if the other Squaddie is considered friendly.
  Args:
    otherSquaddie(Squaddie)
  Returns:
    boolean
  ]]

  -- A Squaddie is always its own friend.
  if self == otherSquaddie then
    return true
  end

  local friendlyAffiliations = {
    player={"player", "ally"},
    ally={"player", "ally"},
    enemy={"enemy",},
    other={}
  }

  return TableUtility:contains(friendlyAffiliations[self.affiliation], otherSquaddie.affiliation)
end

return Squaddie
