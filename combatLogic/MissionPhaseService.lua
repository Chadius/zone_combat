local Squaddie = require ("squaddie/squaddie")

local MissionPhaseService = {}
MissionPhaseService.__index = MissionPhaseService

function MissionPhaseService:getCurrentPhase(missionPhaseTracker, map)
  return missionPhaseTracker
end

function MissionPhaseService:startPhaseEnds(missionPhaseTracker, map)
  if missionPhaseTracker:getSubphase() ~= "start" then
    error("Subphase is not start.")
  end

  return missionPhaseTracker:setSubphase("continue")
end

function MissionPhaseService:continuePhaseEnds(missionPhaseTracker, map)
  if missionPhaseTracker:getSubphase() ~= "continue" then
    error("Subphase is not continue.")
  end

  return missionPhaseTracker:setSubphase("finish")
end

function MissionPhaseService:finishPhaseEnds(missionPhaseTracker, map)
  if missionPhaseTracker:getSubphase() ~= "finish" then
    error("Subphase is not finish.")
  end

  -- Ask Squaddie for a list of affiliations, in order, starting with the Mission Phase's affil
  -- For each affil in the table
  -- Ask the map for all of the squaddies of the affiliation who are alive
  -- If any are alive, set the next phase to that affiliation and set the subphase to start

  local maxAffiliationsToCheck = TableUtility:count(Squaddie.definedAffiliations)
  for i=1, maxAffiliationsToCheck do
    -- TODO
  end

  -- TODO throw an error. We checked all affiliations and none of them have living squaddies.
  return missionPhaseTracker:setSubphase("finish")
end

return MissionPhaseService
