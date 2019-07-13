local TableUtility = require ("utility/tableUtility")

local MissionPhaseTracker = {}
MissionPhaseTracker.__index = MissionPhaseTracker

MissionPhaseTracker.AffiliationOrder = {
  "player",
  "ally",
  "enemy",
  "other",
}

MissionPhaseTracker.SubphaseOrder = {
  "start",
  "continue",
  "end",
}

function MissionPhaseTracker:new(args)
  local newMissionPhaseTracker = {}
  setmetatable(newMissionPhaseTracker, MissionPhaseTracker)

  newMissionPhaseTracker.currentAffiliation = MissionPhaseTracker.AffiliationOrder[1]
  if args and TableUtility:contains(args.affiliation, MissionPhaseTracker.AffiliationOrder) then
    newMissionPhaseTracker.currentAffiliation = args.affiliation
  end

  newMissionPhaseTracker.currentSubphase = MissionPhaseTracker.SubphaseOrder[1]
  if args and TableUtility:contains(args.subphase, MissionPhaseTcurrentSubphaseOrder) then
    newMissionPhaseTracker.currentSubphase = args.subphase
  end

  return newMissionPhaseTracker
end

function MissionPhaseTracker:clone()
  local otherTracker = MissionPhaseTracker:new({
    currentAffiliation = self.currentAffiliation,
    currentSubphase = self.currentSubphase
  })
  return otherTracker
end

function MissionPhaseTracker:getPhase()
  local upperAffiliation = self.currentAffiliation:gsub("^%l", string.upper)
  local upperSubphase = self.currentSubphase:gsub("^%l", string.upper)
  return upperAffiliation .. "Phase" .. upperSubphase
end

return MissionPhaseTracker
