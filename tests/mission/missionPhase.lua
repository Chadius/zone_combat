lunit = require "libraries/unitTesting/lunitx"
local MapFactory = require ("map/mapFactory")
local SquaddieFactory = require ("squaddie/squaddieFactory")
local MissionPhaseService = require "combatLogic/MissionPhaseService"
local MissionPhaseTracker = require "mission/missionPhaseTracker"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

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
  map = MapFactory:buildNewMap({
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

  hero = SquaddieFactory:buildNewSquaddie({
    displayName = "hero",
    affiliation = "player"
  })

  sidekick = SquaddieFactory:buildNewSquaddie({
    displayName = "sidekick",
    affiliation = "player"
  })

  villain = SquaddieFactory:buildNewSquaddie({
    displayName = "villain",
    affiliation = "enemy"
  })

  henchman = SquaddieFactory:buildNewSquaddie({
    displayName = "henchman",
    affiliation = "enemy"
  })

  mayor = SquaddieFactory:buildNewSquaddie({
    displayName = "mayor",
    affiliation = "ally"
  })

  citizen = SquaddieFactory:buildNewSquaddie({
    displayName = "citizen",
    affiliation = "ally"
  })

  trashbag = SquaddieFactory:buildNewSquaddie({
    displayName = "trashbag",
    affiliation = "other"
  })

  moneybag = SquaddieFactory:buildNewSquaddie({
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
  map:addSquaddie(mayor, firstAvenue)
  local phaseTracker = MissionPhaseTracker:new({ affiliation = "player", subphase = "finish"})

  local newTracker = MissionPhaseService:finishPhaseEnds(phaseTracker, map)
  local currentPhase = MissionPhaseService:getCurrentPhase(newTracker, map)

  assert_equal("ally" , currentPhase:getAffiliation())
  assert_equal("start" , currentPhase:getSubphase())
  assert_equal("allystart" , currentPhase:getPhase())
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

function testAllyPhasesSkippedIfNoAlliesInMap()
  map:addSquaddie(hero, firstAvenue)
  map:addSquaddie(villain, firstAvenue)
  local phaseTracker = MissionPhaseTracker:new({ affiliation = "player", subphase = "finish"})

  local newTracker = MissionPhaseService:finishPhaseEnds(phaseTracker, map)
  local currentPhase = MissionPhaseService:getCurrentPhase(newTracker, map)

  assert_equal("enemy" , currentPhase:getAffiliation())
  assert_equal("start" , currentPhase:getSubphase())
  assert_equal("enemystart" , currentPhase:getPhase())
end

function testAllyPhaseSkippedIfAllAlliesKilled()
  map:addSquaddie(hero, firstAvenue)
  map:addSquaddie(mayor, firstAvenue)
  map:addSquaddie(villain, firstAvenue)
  local phaseTracker = MissionPhaseTracker:new({ affiliation = "player", subphase = "finish"})
  mayor:instakill()

  local newTracker = MissionPhaseService:finishPhaseEnds(phaseTracker, map)
  local currentPhase = MissionPhaseService:getCurrentPhase(newTracker, map)

  assert_equal("enemy" , currentPhase:getAffiliation())
  assert_equal("start" , currentPhase:getSubphase())
  assert_equal("enemystart" , currentPhase:getPhase())
end

function testSpawningAllyMisMissionMeansAllyPhaseWillOccur()
  map:addSquaddie(hero, firstAvenue)
  map:addSquaddie(villain, firstAvenue)
  local phaseTracker = MissionPhaseTracker:new({ affiliation = "player", subphase = "finish"})

  map:addSquaddie(mayor, firstAvenue)
  local newTracker = MissionPhaseService:finishPhaseEnds(phaseTracker, map)
  local currentPhase = MissionPhaseService:getCurrentPhase(newTracker, map)

  assert_equal("ally" , currentPhase:getAffiliation())
  assert_equal("start" , currentPhase:getSubphase())
  assert_equal("allystart" , currentPhase:getPhase())
end