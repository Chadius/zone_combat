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
local cricketBat
local superCricketBat
local controllingCricketBat
local trashbag
local trashbag2
local spillJunk
local victim
local zombie
local zombie2
local zombieBite

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
    distancePerTurn = 1,
    actions = {
      descriptions = {
        {
          name = "Cricket Bat",
          effects ={
            default={
              damage = 4,
              target = {"opponent"}
            }
          },
        },
        {
          name = "Super Cricket Bat",
          effects = {
            default = {
              instakill = true,
              target = { "opponent" }
            }
          }
        },
      }
    }
  })
  cricketBat = shawn:getActionByName("Cricket Bat")
  superCricketBat = shawn:getActionByName("Super Cricket Bat")
  -- TODO controllingCricketBat = shawn:getActionByName("Controlling Cricket Bat")

  trashbag = SquaddieFactory:buildNewSquaddie({
    displayName = "Trashbag",
    affiliation = "other",
    distancePerTurn = 1,
    actions = {
      descriptions = {
        {
          name = "Spill Junk",
          effects = {
            default = {
              damage = 1,
              target = { "opponent" }
            }
          }
        }
      }
    }
  })
  spillJunk = trashbag:getActionByName("Spill Junk")

  trashbag2 = SquaddieFactory:buildNewSquaddie({
    displayName = "Trashbag2",
    affiliation = "other",
    distancePerTurn = 1,
    actions = {
      objects = {spillJunk}
    }
  })

  victim = SquaddieFactory:buildNewSquaddie({
    displayName = "Victim",
    affiliation = "ally",
    distancePerTurn = 1
  })

  zombie = SquaddieFactory:buildNewSquaddie({
    displayName = "Zombie",
    affiliation = "enemy",
    distancePerTurn = 1,
    actions = {
      descriptions = {
        {
          name = "Zombie Bite",
          effects = {
            {
              damage = 3,
              target = { "opponent" }
            }
          }
        }
      }
    }
  })
  zombieBite = zombie:getActionByName("Zombie Bite")

  zombie2 = SquaddieFactory:buildNewSquaddie({
    displayName = "Zombie2",
    affiliation = "enemy",
    distancePerTurn = 1
  })
  zombie2:addAction(zombieBite)
end

function testCannotAttackSelf()
  map:addSquaddie(shawn, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, cricketBat, shawn, map))
  assert_equal("Cannot target self with this power", ActionResolver:getReasonCannotAttackWithPower(shawn, cricketBat, shawn, map))
end

function testCanAttackEnemy()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(shawn, cricketBat, zombie, map))
  assert_equal(nil, ActionResolver:getReasonCannotAttackWithPower(shawn, cricketBat, zombie, map))
end

function testCannotAttackAlly()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(victim, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, cricketBat, victim, map))
  assert_equal("Cannot target friend with this power", ActionResolver:getReasonCannotAttackWithPower(shawn, cricketBat, victim, map))
end

function testCannotAttackOffMapTarget()
  map:addSquaddie(shawn, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, cricketBat, zombie, map))
  assert_equal("Target is off map", ActionResolver:getReasonCannotAttackWithPower(shawn, cricketBat, zombie, map))
end

function testCannotAttackOffMapActor()
  map:addSquaddie(zombie, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, cricketBat, zombie, map))
  assert_equal("Actor is off map", ActionResolver:getReasonCannotAttackWithPower(shawn, cricketBat, zombie, map))
end

function testCannotAttackOutOfRange()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, secondAvenue)
  assert_false(ActionResolver:canAttackWithPower(shawn, cricketBat, zombie, map))
  assert_equal("Target is out of range", ActionResolver:getReasonCannotAttackWithPower(shawn, cricketBat, zombie, map))
end

function testCannotAttackDead()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)
  zombie:instakill()
  assert_true(zombie:isDead())
  assert_false(ActionResolver:canAttackWithPower(shawn, cricketBat, zombie, map))
  assert_equal("Target is already dead", ActionResolver:getReasonCannotAttackWithPower(shawn, cricketBat, zombie, map))
end

function testEnemyCanAttackPlayer()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(zombie, zombieBite, shawn, map))
end

function testEnemyCanAttackAlly()
  map:addSquaddie(zombie, firstAvenue)
  map:addSquaddie(victim, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(zombie, zombieBite, victim, map))
end

function testEnemyCanAttackOther()
  map:addSquaddie(zombie, firstAvenue)
  map:addSquaddie(trashbag, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(zombie, zombieBite, trashbag, map))
end

function testEnemyCannotAttackEnemy()
  map:addSquaddie(zombie, firstAvenue)
  map:addSquaddie(zombie2, firstAvenue)
  assert_false(ActionResolver:canAttackWithPower(zombie, zombieBite, zombie2, map))
  assert_equal("Cannot target friend with this power", ActionResolver:getReasonCannotAttackWithPower(zombie, zombieBite, zombie2, map))
end

function testOtherCanAttackPlayer()
  map:addSquaddie(trashbag, firstAvenue)
  map:addSquaddie(shawn, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(trashbag, spillJunk, shawn, map))
end

function testOtherCanAttackAlly()
  map:addSquaddie(trashbag, firstAvenue)
  map:addSquaddie(victim, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(trashbag, spillJunk, victim, map))
end

function testOtherCanAttackOther()
  map:addSquaddie(trashbag, firstAvenue)
  map:addSquaddie(trashbag2, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(trashbag2, spillJunk, trashbag, map))
end

function testOtherCanAttackEnemy()
  map:addSquaddie(trashbag, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)
  assert_true(ActionResolver:canAttackWithPower(trashbag, spillJunk, zombie, map))
end

function testCanInstakillTargetWithAction()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)

  assert_equal(zombie:currentHealth(), zombie:maxHealth())
  assert_true(superCricketBat:isInstakill())
  ActionResolver:useActionOnTarget(shawn, superCricketBat, zombie)
  assert_true(zombie:currentHealth() < zombie:maxHealth())
  assert_false(shawn:hasTurnPartAvailable("act"))
  assert_true(zombie:isDead())
end

function testCannotUseActionItDoesNotOwn()
    map:addSquaddie(shawn, firstAvenue)
    map:addSquaddie(zombie, firstAvenue)
    assert_false(ActionResolver:canAttackWithPower(shawn, spillJunk, zombie, map))
    assert_equal("User does not have power", ActionResolver:getReasonCannotAttackWithPower(shawn, spillJunk, zombie, map))
end

function testCanDamageTargetWithAction()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)

  assert_equal(zombie:currentHealth(), zombie:maxHealth())
  assert_false(cricketBat:isInstakill())
  assert_true(cricketBat:getDamage() < zombie:maxHealth())

  ActionResolver:useActionOnTarget(shawn, cricketBat, zombie)
  assert_equal(
      cricketBat:getDamage(),
      zombie:maxHealth() - zombie:currentHealth()
  )

  assert_false(shawn:hasTurnPartAvailable("act"))
  assert_false(zombie:isDead())
end

function testActionResults()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)

  local actionResult = ActionResolver:useActionOnTarget(shawn, cricketBat, zombie)
  assert_equal(shawn, actionResult:getActor())
  assert_equal(cricketBat, actionResult:getAction())
  assert_equal(zombie, actionResult:getTarget())
  assert_equal(cricketBat:getDamage(), actionResult:getDamageDealt())
end

function testInstakillActionResults()
  map:addSquaddie(shawn, firstAvenue)
  map:addSquaddie(zombie, firstAvenue)

  local actionResult = ActionResolver:useActionOnTarget(shawn, superCricketBat, zombie)
  assert_equal(shawn, actionResult:getActor())
  assert_equal(superCricketBat, actionResult:getAction())
  assert_equal(zombie, actionResult:getTarget())
  assert_true(actionResult:targetWasInstakilled())
end
