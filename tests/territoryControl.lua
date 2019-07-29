lunit = require "libraries/unitTesting/lunitx"
local Map = require ("map/map")
local MoveSquaddieOnMapService = require ("combatLogic/MoveSquaddieOnMapService")
local Squaddie = require "squaddie/squaddie"
local TableUtility = require ("utility/tableUtility")
local TerritoryControlCalculator = require "combatLogic/territoryControlCalculator"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local map
local townSquare
local firstStreet
local thirdStreet

local hero
local sidekick
local villain
local henchman
local mayor
local trashcan

function setup()
  map = Map:new({
    id = "lights district",
    zones = {
      {
        id="town square",
        links={
          { to="3rd street" },
          { to="1st street" },
        }
      },
      {
        id="1st street",
        links={
          { to="town square" }
        }
      },
      {
        id="3rd street",
        links={
          { to="town square" }
        }
      },
    }
  })

  firstStreet = map:getZoneByID("1st street")
  townSquare = map:getZoneByID("town square")
  thirdStreet= map:getZoneByID("3rd street")

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

  trashcan = Squaddie:new({
    displayName = "trashcan",
    affiliation = "other"
  })

end

function teardown()
end

function assertPlayerAndAllyAffiliation(affiliations)
  assert_true(
      TableUtility:equivalent(
          { "player", "ally" },
          affiliations
      )
  )
end

function assertEnemyAffiliation(affiliations)
  assert_true(
      TableUtility:equivalent(
          { "enemy" },
          affiliations
      )
  )
end

function assertNoAffiliation(affiliations)
  assert_true(TableUtility:isEmpty(affiliations))
end


function testEmptyZoneHasNoControl()
  assertNoAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end

function testLonePlayerSquaddieCanControl()
  map:addSquaddie(hero, townSquare)
  assertPlayerAndAllyAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end

function testLoneEnemySquaddieCanControl()
  map:addSquaddie(villain, townSquare)
  assertEnemyAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end

function testMajorityControls()
  map:addSquaddie(hero, townSquare)
  map:addSquaddie(villain, townSquare)
  map:addSquaddie(henchman, townSquare)
  assertEnemyAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end

function testNoMajorityMeansNoControl()
  map:addSquaddie(hero, townSquare)
  map:addSquaddie(sidekick, townSquare)
  map:addSquaddie(villain, townSquare)
  map:addSquaddie(henchman, townSquare)

  assertNoAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end

function testAllyContributesToPlayerTeam()
  map:addSquaddie(mayor, townSquare)

  assertPlayerAndAllyAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end

function testOtherCannotControl()
  map:addSquaddie(trashcan, townSquare)

  assertNoAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end

function testControlDoesNotEffectOtherZones()
  map:addSquaddie(hero, townSquare)
  assertNoAffiliation(TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, firstStreet))
  assertNoAffiliation(TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, thirdStreet))
end

function testMapCanUpdateAllZonesWithTheirControl()
  map:addSquaddie(hero, townSquare)
  TerritoryControlCalculator:updateAllZoneControl(map)
  assertPlayerAndAllyAffiliation(
      map:getControllingAffiliationsForZone(townSquare)
  )
  assert_true(
    TableUtility:contains(
      map:getControllingAffiliationsForZone(townSquare),
      hero:getAffilation()
    )
  )
end

function testControlSticksWhenLeavingZones()
  map:addSquaddie(hero, townSquare)
  TerritoryControlCalculator:updateAllZoneControl(map)
  assertPlayerAndAllyAffiliation(
      map:getControllingAffiliationsForZone(townSquare)
  )

  MoveSquaddieOnMapService:moveSquaddieAndSpendTurn(map, hero, firstStreet)
  TerritoryControlCalculator:updateAllZoneControl(map)
  assertPlayerAndAllyAffiliation(
      map:getControllingAffiliationsForZone(townSquare)
  )
end

function testAllyCannotControlStateIfAllAlliesAreDead()
  map:addSquaddie(sidekick, townSquare)
  sidekick:instakill()
  assertNoAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end

function testAllyCannotControlStateIfAllAlliesAreDead()
  map:addSquaddie(mayor, townSquare)
  TerritoryControlCalculator:updateAllZoneControl(map)
  assertPlayerAndAllyAffiliation(
      map:getControllingAffiliationsForZone(townSquare)
  )

  mayor:instakill()
  TerritoryControlCalculator:updateAllZoneControl(map)
  assertNoAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end

function testLeavingContestedZoneChangesControl()
  map:addSquaddie(hero, townSquare)
  map:addSquaddie(sidekick, townSquare)
  map:addSquaddie(villain, townSquare)
  map:addSquaddie(henchman, townSquare)
  TerritoryControlCalculator:updateAllZoneControl(map)
  assertNoAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )

  MoveSquaddieOnMapService:moveSquaddieAndSpendTurn(map, hero, firstStreet)
  TerritoryControlCalculator:updateAllZoneControl(map)
  assertEnemyAffiliation(
      TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, townSquare)
  )
end
