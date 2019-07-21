lunit = require "libraries/unitTesting/lunitx"
local Map = require ("map/map")
local Squaddie = require "squaddie/squaddie"
local MissionPhaseService = require "combatLogic/MissionPhaseService"
local MissionPhaseTracker = require "mission/missionPhaseTracker"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

--[[ TODO NOTE
MissionPhaseService

testPlayerEndPhaseAfterAllPlayersFinishTurn

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

function testPlayerPhaseStartFirst()
  map:addSquaddie(hero, firstAvenue)
  local currentPhase = MissionPhaseService:getCurrentPhase(missionPhaseTracker, map)
  assert_equal("player" , currentPhase:getAffiliation())
  assert_equal("start" , currentPhase:getSubphase())
  assert_equal("playerstart" , currentPhase:getPhase())
end

function testPlayerPhaseContinueAfterStartEnds()
  map:addSquaddie(hero, firstAvenue)
  local newTracker = MissionPhaseService:startPhaseEnds(missionPhaseTracker, map)
  local currentPhase = MissionPhaseService:getCurrentPhase(newTracker, map)
  assert_equal("player" , currentPhase:getAffiliation())
  assert_equal("continue" , currentPhase:getSubphase())
  assert_equal("playercontinue" , currentPhase:getPhase())
end

function testPlayerPhaseEndAfterContinueEnds()
  map:addSquaddie(hero, firstAvenue)
  local continueTracker = MissionPhaseService:startPhaseEnds(missionPhaseTracker, map)
  local newTracker = MissionPhaseService:continuePhaseEnds(continueTracker, map)
  local currentPhase = MissionPhaseService:getCurrentPhase(newTracker, map)
  assert_equal("player" , currentPhase:getAffiliation())
  assert_equal("finish" , currentPhase:getSubphase())
  assert_equal("playerfinish" , currentPhase:getPhase())
end

function testAssertIfSubphaseDoesNotExist()
  assert_error(
      "bogus is not a subphase",
    function()
        MissionPhaseTracker:new({ affiliation = "player", subphase = "bogus" })
      end
  )
end

function testAssertIfAffiliationDoesNotExist()
  assert_error(
      "bogus is not an affiliation",
      function()
        MissionPhaseTracker:new({ affiliation = "bogus", subphase = "start" })
      end
  )
end

function testChangeAffiliationAfterFinishSubphase()
  map:addSquaddie(hero, firstAvenue)
  map:addSquaddie(villain, firstAvenue)
  local phaseTracker = MissionPhaseTracker:new({ affiliation = "player", subphase = "finish"})

  local newTracker = MissionPhaseService:finishPhaseEnds(phaseTracker, map)
  local currentPhase = MissionPhaseService:getCurrentPhase(newTracker, map)

  assert_equal("enemy" , currentPhase:getAffiliation())
  assert_equal("start" , currentPhase:getSubphase())
  assert_equal("enemystart" , currentPhase:getPhase())
end

function testErrorRaisedIfNoTeamsExist()
  local phaseTracker = MissionPhaseTracker:new({ affiliation = "player", subphase = "finish"})

  assert_error(
      "No living squaddies on this map.",
      function()
        MissionPhaseService:finishPhaseEnds(phaseTracker, map)
      end
  )
end