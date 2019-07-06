lunit = require "libraries/unitTesting/lunitx"
local Map = require ("map/map")
local Squaddie= require "squaddie/squaddie"
local MoveSquaddieOnMapService = require "combatLogic/MoveSquaddieOnMapService"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local map = {}
local trail1
local trail2
local trail3
local pond
local bunny

function setup()
  --[[Set up a forest glade, with a pond surrounded by 3 trails.
  You can walk between the trails, swim across the pond,
  of fly directly from the start to the end.
  ]]
  map = Map:new({
    id = "forest glade",
    zones = {
      {
        id="trail1",
        links={
          { to="trail2" },
          {
            to="trail3",
            travelMethods={"fly"}
          },
          {
            to="pond",
            travelMethods={"swim"}
          },
        }
      },
      {
        id="trail2",
        links={
          { to="trail3" }
        }
      },
      {
        id="trail3",
        links={
          {
            to="pond",
            travelMethods={"swim"}
          }
        }
      },
      { id="pond" }
    }
  })

  bunny = Squaddie:new({
    displayName = "bunny",
    distancePerTurn = 2
  })

  trail1 = map:getZoneByID("trail1")
  trail2 = map:getZoneByID("trail2")
  trail3 = map:getZoneByID("trail3")
  pond = map:getZoneByID("pond")
end

function teardown()
end

function testSquaddieOnMapHasTurn()
  -- Units have turns and can report on what they want to do this turn.
  map:addSquaddie(bunny, "trail1")

  -- Map Unit's turn is ready
  assert_true(bunny:isTurnReady())

  -- Map Unit can still move
  assert_true(bunny:hasTurnPartAvailable("move"))

  -- Map Unit's current phase is movement
  assert_equal("move", bunny:currentTurnPart())
end

function testTurnIsOver()
  -- Turn knows when it's over
  map:addSquaddie(bunny, "trail1")
  assert_true(bunny:isTurnReady())
  assert_true(bunny:hasTurnPartAvailable("move"))

  MoveSquaddieOnMapService:moveSquaddieAndSpendTurn(map, bunny, trail3)
  assert_false(bunny:hasTurnPartAvailable("move"))
  assert_false(bunny:isTurnReady())
end

function testCannotMoveTwiceInOneTurn()
  -- Units cannot move twice per turn
  map:addSquaddie(bunny, "trail1")
  MoveSquaddieOnMapService:moveSquaddieAndSpendTurn(map, bunny, trail2)
  assert_false(MoveSquaddieOnMapService:canSquaddieMoveToAdjacentZone(map, bunny, pond))
  assert_error_match(
      "Looking for an error because the bunny does not have a move action.",
    ": squaddie does not have a move action available.",
      function()
        MoveSquaddieOnMapService:moveSquaddieAndSpendTurn(map, bunny, trail3)
      end
  )

  -- Bunny is still in trail2
  local trail2_units = map:getSquaddiesInZone("trail2")
  assert_equal(1, #trail2_units)
  assert_equal(bunny, trail2_units[1])
end

function testResetUnitTurn()
  -- Turns can be reset
  map:addSquaddie(bunny, "trail1")
  MoveSquaddieOnMapService:moveSquaddieAndSpendTurn(map, bunny, trail2)
  bunny:startNewTurn()

  -- With a new turn, Bunny can move to trail3
  MoveSquaddieOnMapService:moveSquaddieAndSpendTurn(map, bunny, trail3)

  local trail3_units = map:getSquaddiesInZone("trail3")
  assert_equal(1, #trail3_units)
  assert_equal(bunny, trail3_units[1])
end

