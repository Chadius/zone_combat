-- local CLASSNAME = require ("")

local MissionPhaseService = {}
MissionPhaseService.__index = MissionPhaseService

function MissionPhaseService:getCurrentPhase(missionPhaseTracker, map)
  return missionPhaseTracker
end

return MissionPhaseService
