--[[ This entity represents a single soldier who exists in armies and on maps.
The entity can take actions and may be destroyed.
]]

local TableUtility = require ("utility/tableUtility")
local uuid = require("libraries/uuid")

local Squaddie={}
Squaddie.__index = Squaddie

function Squaddie:new(args)
  local newSquaddie = {}
  setmetatable(newSquaddie, Squaddie)
  newSquaddie.id = uuid()
  newSquaddie.name = args.displayName or "No name"

  return newSquaddie
end

function Squaddie:isSameSquaddie(otherSquaddie)
  return self.id == otherSquaddie.id
end

-- mapPresence
function Squaddie:setMapPresence(mapPresence)
  self.mapPresence = mapPresence
end

function Squaddie:hasOneTravelMethod(methods)
  return self.mapPresence:hasOneTravelMethod(methods)
end

function Squaddie:isTurnReady()
  return self.mapPresence:isTurnReady()
end

function Squaddie:chooseToWait()
  return self.mapPresence:chooseToWait()
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

-- affiliation
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

function Squaddie:hasOneOfTheseAffiliations(matchingAffiliations)
  return TableUtility:contains(matchingAffiliations, self:getAffilation())
end

function Squaddie:isPlayerOrAlly()
  return self:hasOneOfTheseAffiliations({"player", "ally"})
end

function Squaddie:isEnemy()
  return self:hasOneOfTheseAffiliations({"enemy"})
end

-- healthStatus
function Squaddie:setHealthStatus(healthStatus)
  self.healthStatus = healthStatus
end

function Squaddie:currentHealth()
  return self.healthStatus:currentHealth()
end

function Squaddie:maxHealth()
  return self.healthStatus:maxHealth()
end

function Squaddie:isAlive()
  return self.healthStatus:isAlive()
end

function Squaddie:addHealth(hitPoints)
  return self.healthStatus:addHealth(hitPoints)
end

function Squaddie:setHealthToMax()
  return self.healthStatus:setHealthToMax()
end

function Squaddie:loseHealth(hitPoints)
  return self.healthStatus:loseHealth(hitPoints)
end

function Squaddie:isDead()
  return self.healthStatus:isDead()
end

function Squaddie:instakill()
  return self.healthStatus:instakill()
end

return Squaddie
