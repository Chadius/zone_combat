local Squaddie = require ("squaddie/squaddie")
local TableUtility = require ("utility/tableUtility")

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

  local currentAffiliationOrder = missionPhaseTracker:getAffiliationsInOrder(missionPhaseTracker:getAffiliation())
  local nextAffiliation = currentAffiliationOrder[2]
  local nextAffiliationOrder = missionPhaseTracker:getAffiliationsInOrder(nextAffiliation)

  for _, affiliation in ipairs(nextAffiliationOrder) do
    local squaddiesWithAffiliation = map:getSquaddiesByAffiliation(affiliation)
    local livingSquaddies = TableUtility:filter(
        squaddiesWithAffiliation,
        function(_, squaddie, _)
          return squaddie:isAlive()
        end
    )
    if TableUtility:count(livingSquaddies) > 0 then
      local missionPhaseTrackerNewAffiliation = missionPhaseTracker:setAffiliation(affiliation)
      return missionPhaseTrackerNewAffiliation:setSubphase("start")
    end
  end

  error("No living squaddies on this map.")
end

return MissionPhaseService
