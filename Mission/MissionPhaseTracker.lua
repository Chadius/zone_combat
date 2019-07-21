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
  "finish",
}

function MissionPhaseTracker:new(args)
  local newMissionPhaseTracker = {}
  setmetatable(newMissionPhaseTracker, MissionPhaseTracker)

  newMissionPhaseTracker.currentAffiliation = MissionPhaseTracker.AffiliationOrder[1]
  if args and args.affiliation then
    MissionPhaseTracker:AssertAffiliation(args.affiliation)
    newMissionPhaseTracker.currentAffiliation = args.affiliation
  end

  newMissionPhaseTracker.currentSubphase = MissionPhaseTracker.SubphaseOrder[1]
  if args and args.subphase then
    MissionPhaseTracker:AssertSubphase(args.subphase)
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

function MissionPhaseTracker:getAffiliation()
  return self.currentAffiliation
end

function MissionPhaseTracker:getSubphase()
  return self.currentSubphase
end

function MissionPhaseTracker:getPhase()
  local upperAffiliation = self:getAffiliation()
  local upperSubphase = self:getSubphase()
  return upperAffiliation .. upperSubphase
end

function MissionPhaseTracker:setSubphase(newSubphase)
  MissionPhaseTracker:AssertSubphase(newSubphase)
  local newMissionPhaseTracker = self:clone()
  if TableUtility:contains(MissionPhaseTracker.SubphaseOrder, newSubphase) then
    newMissionPhaseTracker.currentSubphase = newSubphase
  end
  return newMissionPhaseTracker
end

function MissionPhaseTracker:AssertAffiliation(newAffiliation)
  if not TableUtility:contains(MissionPhaseTracker.AffiliationOrder, newAffiliation) then
    error(newAffiliation .. " is not a affiliation")
  end
end

function MissionPhaseTracker:AssertSubphase(newSubphase)
  if not TableUtility:contains(MissionPhaseTracker.SubphaseOrder, newSubphase) then
    error(newSubphase .. " is not a subphase")
  end
end

return MissionPhaseTracker
