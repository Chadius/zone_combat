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
local rob
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

  rob = Squaddie:new({
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
  assert_false(ActionResolver:CanAttackWithPower(shawn, shawn, map))
end
-- testCannotAttackAlly
-- testCanAttackEnemy
-- testCannotAttackOutOfRange
