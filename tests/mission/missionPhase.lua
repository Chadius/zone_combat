lunit = require "libraries/unitTesting/lunitx"
local Map = require ("map/map")
local Squaddie = require "squaddie/squaddie"
local MissionPhaseService = require "combatLogic/MissionPhaseService"
local MissionPhaseTracker = require "mission/MissionPhaseTracker"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

--[[ TODO NOTE
MissionPhaseService

testPlayerPhaseFirst
testPlayerEndPhaseAfterAllPlayersFinishTurn

testAllyPhaseAfterPlayerEndUpkeepFinish

testAllyPhasesSkippedIfNoAlliesInMap

testAllyPhaseSkippedIfAllAlliesKilled

testSpawningAllyMisMissionMeansAllyPhaseWillOccur
]]

local missionPhaseTracker
local map
local firstAvenue
local secondAvenue

local hero
local sidekick
local villain
local henchman
local mayor
local citizen
local trashbag
local moneybag

function setup()
  map = Map:new({
    id = "downtown",
    zones = {
      {
        id = "firstAvenue",
        links = {
          { to = "secondAvenue" }
        }
      },
      {
        id = "secondAvenue",
        links = {
          { to = "firstAvenue" }
        }
      }
    }
  })
  firstAvenue = map:getZoneByID("firstAvenue")
  secondAvenue = map:getZoneByID("secondAvenue")

  -- TODO
  missionPhaseTracker = MissionPhaseTracker:new()

  hero = Squaddie:new({
    displayName = "hero",
    affiliation = "player"
  })

  sidekick = Squaddie:new({
    displayName = "sidekick",
    affiliation = "player"
  })

  villain = Squaddie:new({
    displayName = "villain",
    affiliation = "enemy"
  })

  henchman = Squaddie:new({
    displayName = "henchman",
    affiliation = "enemy"
  })

  mayor = Squaddie:new({
    displayName = "mayor",
    affiliation = "ally"
  })

  citizen = Squaddie:new({
    displayName = "citizen",
    affiliation = "ally"
  })

  trashbag = Squaddie:new({
    displayName = "trashbag",
    affiliation = "other"
  })

  moneybag = Squaddie:new({
    displayName = "moneybag",
    affiliation = "other"
  })
end

function testPlayerPhaseFirst()
  local currentPhase = MissionPhaseService:getCurrentPhase(missionPhaseTracker, map)
  assert_equal("PlayerPhaseStart" , currentPhase:getPhase())
end