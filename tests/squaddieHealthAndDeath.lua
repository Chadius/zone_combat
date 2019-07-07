lunit = require ("libraries/unitTesting/lunitx")
local Squaddie = require ("squaddie/squaddie")

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local citizen
local hero
local injuredCitizen

function setup()
  hero = Squaddie:new({
    displayName = "hero",
    affiliation = "player"
  })

  injuredCitizen = Squaddie:new({
    displayName = "injuredCitizen",
    affiliation = "ally",
    maxHealth = 10,
    currentHealth = 5
  })

  citizen = Squaddie:new({
    displayName = "citizen",
    affiliation = "ally",
    maxHealth = 10
  })
end

function teardown()
end

function testDefaultSquaddiesHaveHealthAndAreAlive()
  assert_true(hero:currentHealth() > 0)
  assert_true(hero:maxHealth() > 0)
  assert_true(hero:isAlive())
end

function testSetHealth()
  assert_equal(10, citizen:maxHealth())
  assert_equal(10, citizen:currentHealth())

  assert_equal(10, injuredCitizen:maxHealth())
  assert_equal(5, injuredCitizen:currentHealth())
end

function testAddHealth()
  injuredCitizen:addHealth(2)
  assert_equal(7, injuredCitizen:currentHealth())

  injuredCitizen:addHealth(5)
  assert_equal(10, injuredCitizen:currentHealth())
end

function testFillHealth()
  injuredCitizen:setHealthToMax()
  assert_equal(10, injuredCitizen:currentHealth())
end

function testLoseHealth()
  injuredCitizen:loseHealth(2)
  assert_equal(3, injuredCitizen:currentHealth())

  injuredCitizen:loseHealth(5)
  assert_equal(0, injuredCitizen:currentHealth())
end

function testIsDead()
  assert_false(injuredCitizen:isDead())
  injuredCitizen:loseHealth(10)
  assert_true(injuredCitizen:isDead())
end