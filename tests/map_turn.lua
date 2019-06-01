lunit = require "libraries/unitTesting/lunitx"
local Map = require "map"
local MapUnit = require "map/mapUnit"
local TableUtility = require "table_utility"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local map = {}
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
        neighbors={
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
        neighbors={
          { to="trail3" }
        }
      },
      {
        id="trail3",
        neighbors={
          {
            to="pond",
            travelMethods={"swim"}
          }
        }
      },
      { id="pond" }
    }
  })

  bunny = MapUnit:new({
    displayName = "bunny",
    distancePerTurn = 2
  })
end

function teardown()
end

function testMapUnitHasTurn()
  -- Units have turns and can report on what they want to do this turn.
  map:addMapUnit(bunny, "trail1")

  -- Map Unit's turn is ready
  assert_true(bunny:isTurnReady())

  -- Map Unit can still move
  assert_true(bunny:hasTurnPartAvailable("move"))

  -- Map Unit's current phase is movement
  assert_equal("move", bunny:currentTurnPart())
end

function testTurnRemembersLastMove()
  -- Turn can leave a record of what it did
  map:addMapUnit(bunny, "trail1")

  assert_true(TableUtility:equivalent(
      {},
      bunny:getLastTurnMovement()
  ))

  map:mapUnitMoves(bunny.id, "trail3")

  assert_true(TableUtility:equivalent(
      {"trail1", "trail3"},
      bunny:getLastTurnMovement()
  ))
end

function testTurnIsOver()
  -- Turn knows when it's over
  map:addMapUnit(bunny, "trail1")
  assert_true(bunny:isTurnReady())
  assert_true(bunny:hasTurnPartAvailable("move"))

  map:mapUnitMoves(bunny.id, "trail3")
  assert_false(bunny:hasTurnPartAvailable("move"))
  assert_false(bunny:isTurnReady())
end

function testCannotMoveTwiceInOneTurn()
  -- Units cannot move twice per turn
  map:addMapUnit(bunny, "trail1")
  map:mapUnitMoves(bunny.id, "trail2")
  assert_false(map:canMapUnitMoveToAdjacentZone(bunny.id, "pond"))
  assert_error_match(
      "Unit doesn't have a move action, trying to move should have thrown an error.",
      "MapUnit bunny does not have a move action and cannot reach zone trail3 this turn.",
      function()
        map:mapUnitMoves(bunny.id, "trail3")
      end
  )

  -- Bunny is still in trail2
  local trail2_units = map:getMapUnitsAtLocation("trail2")
  assert_equal(1, #trail2_units)
  assert_equal(bunny, trail2_units[1])
end

function testResetUnitTurn()
  -- Turns can be reset
  map:addMapUnit(bunny, "trail1")
  map:mapUnitMoves(bunny.id, "trail2")
  map:resetMapUnitTurn(bunny.id)

  -- With a new turn, Bunny can move to trail3
  map:mapUnitMoves(bunny.id, "trail3")

  local trail3_units = map:getMapUnitsAtLocation("trail3")
  assert_equal(1, #trail3_units)
  assert_equal(bunny, trail3_units[1])
end

