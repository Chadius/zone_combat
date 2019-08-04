lunit = require "libraries/unitTesting/lunitx"
local MapFactory = require ("map/mapFactory")
local SquaddieFactory = require ("squaddie/squaddieFactory")
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
local trashbag
local trashbag2
local victim
local zombie
local zombie2

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

  shawn = SquaddieFactory:buildNewSquaddie({
    displayName = "Shawn",
    affiliation = "player",
    distancePerTurn = 1
  })

  trashbag = SquaddieFactory:buildNewSquaddie({
    displayName = "Trashbag",
    affiliation = "other",
    distancePerTurn = 1
  })

  trashbag2 = SquaddieFactory:buildNewSquaddie({
    displayName = "Trashbag2",
    affiliation = "other",
    distancePerTurn = 1
  })

  victim = SquaddieFactory:buildNewSquaddie({
    displayName = "Victim",
    affiliation = "ally",
    distancePerTurn = 1
  })

  zombie = SquaddieFactory:buildNewSquaddie({
    displayName = "Zombie",
    affiliation = "enemy",
    distancePerTurn = 1
  })

  zombie2 = SquaddieFactory:buildNewSquaddie({
    displayName = "Zombie2",
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
  assert_equal("Cannot target friend with this power", ActionResolver:getReasonCannotAttackWithPower(shawn, victim, map))
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

function testEnemyCanAttackPlayer()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(zombie, shawn, map))
end

function testEnemyCanAttackAlly()
  map:addSquaddie(zombie, firstAvenue)
  map:addSquaddie(victim, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(zombie, victim, map))
end

function testEnemyCanAttackOther()
  map:addSquaddie(zombie, firstAvenue)
  map:addSquaddie(trashbag, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(zombie, trashbag, map))
end

function testEnemyCannotAttackEnemy()
  map:addSquaddie(zombie, firstAvenue)
  map:addSquaddie(zombie2, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(zombie, zombie2, map))
  assert_equal("Cannot target friend with this power", ActionResolver:getReasonCannotAttackWithPower(zombie, zombie2, map))
end

function testOtherCanAttackPlayer()
  map:addSquaddie(trashbag, firstAvenue)
  map:addSquaddie(shawn, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(trashbag, shawn, map))
end

function testOtherCanAttackAlly()
  map:addSquaddie(trashbag, firstAvenue)
  map:addSquaddie(victim, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(trashbag, victim, map))
end

function testOtherCanAttackOther()
  map:addSquaddie(trashbag, firstAvenue)
  map:addSquaddie(trashbag2, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(trashbag, trashbag2, map))
end

function testOtherCanAttackEnemy()
  map:addSquaddie(trashbag, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(trashbag, zombie, map))
end

function testCanKillTarget()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)
  assert_equal(zombie:currentHealth(), zombie:maxHealth())
  ActionResolver:usePowerOnTarget(shawn, zombie)
  assert_true(zombie:currentHealth() < zombie:maxHealth())
  assert_false(shawn:hasTurnPartAvailable("act"))
end