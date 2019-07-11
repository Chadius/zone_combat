lunit = require "libraries/unitTesting/lunitx"
local Map = require ("map/map")
local Squaddie= require "squaddie/squaddie"
local ActionResolver = require "combatLogic/ActionResolver"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local map = {}
local firstAvenue
local secondAvenue
local shawn
local victim
local zombie

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

  shawn = Squaddie:new({
    displayName = "Shawn",
    affiliation = "player",
    distancePerTurn = 1
  })

  victim = Squaddie:new({
    displayName = "Rob",
    affiliation = "ally",
    distancePerTurn = 1
  })

  zombie = Squaddie:new({
    displayName = "Zombie",
    affiliation = "enemy",
    distancePerTurn = 1
  })
end

function testCannotAttackSelf()
  map:addSquaddie(shawn, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, shawn, map))
  assert_equal("Cannot target self with this power", ActionResolver:getReasonCannotAttackWithPower(shawn, shawn, map))
end

function testCanAttackEnemy()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(shawn, zombie, map))
  assert_equal(nil, ActionResolver:getReasonCannotAttackWithPower(shawn, zombie, map))
end

function testCannotAttackAlly()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(victim, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, victim, map))
  assert_equal("Cannot target ally with this power", ActionResolver:getReasonCannotAttackWithPower(shawn, victim, map))
end

function testCannotAttackOffMapTarget()
  map:addSquaddie(shawn, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, zombie, map))
  assert_equal("Target is off map", ActionResolver:getReasonCannotAttackWithPower(shawn, zombie, map))
end

function testCannotAttackOffMapActor()
  map:addSquaddie(zombie, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, zombie, map))
  assert_equal("Actor is off map", ActionResolver:getReasonCannotAttackWithPower(shawn, zombie, map))
end

function testCannotAttackOutOfRange()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, secondAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, zombie, map))
  assert_equal("Target is out of range", ActionResolver:getReasonCannotAttackWithPower(shawn, zombie, map))
end

function testCannotAttackDead()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)
  zombie:instakill()
  assert_true(zombie:isDead())
  assert_false(ActionResolver:canAttackWithPower(shawn, zombie, map))
  assert_equal("Target is already dead", ActionResolver:getReasonCannotAttackWithPower(shawn, zombie, map))
end

-- testEnemyCanAttackPlayer
-- testEnemyCanAttackAlly
-- testEnemyCanAttackOther
-- testEnemyCannotAttackEnemy

-- testOtherCanAttackPlayer
-- testOtherCanAttackAlly
-- testOtherCanAttackOther
-- testOtherCanAttackEnemy
