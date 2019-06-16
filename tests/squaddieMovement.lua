lunit = require "libraries/unitTesting/lunitx"
local Map = require "map"
local SquaddieOnMap = require "squaddie/squaddieOnMap"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local map = {}
local human
local bunny
local turtle
local bird
local stone

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

  human = SquaddieOnMap:new({
    displayName = "human"
  })

  bunny = SquaddieOnMap:new({
    displayName = "bunny",
    distancePerTurn = 2
  })

  turtle = SquaddieOnMap:new({
    displayName = "turtle",
    travelMethods = {"foot", "swim"}
  })

  bird = SquaddieOnMap:new({
    displayName = "bird",
    travelMethods = {"foot", "fly"}
  })

  stone = SquaddieOnMap:new({
    displayName = "stone",
    travelMethods = {"none"}
  })
end

function teardown()
end

function test_place_unit_on_map()
  --[[ You can create units with given movement types.
  ]]

  -- Human has a name, but no id since it's not on the map.
  assert_equal("human", human.name)
  assert_equal(nil, human.id)

  -- Place human on the map, map knows its location
  map:addSquaddie(human, "trail1")

  trail1_units = map:getSquaddiesInZone("trail1")
  assert_equal(1, #trail1_units)
  assert_equal(human, trail1_units[1])
end

function test_one_SquaddieOnMap_location()
  -- Can't place the same unit on the map at two places at once
  map:addSquaddie(human, "trail1")
  local bad_unit_add = function()
    map:addSquaddie(human, "trail2")
  end

  assert_error_match(
      "Added human to trail2 without error. That's bad.",
      "Map:addSquaddie: human already exists.",
      bad_unit_add
  )
  local trail1_units = map:getSquaddiesInZone("trail1")
  assert_equal(1, #trail1_units)
  assert_equal(human, trail1_units[1])
end

function testNonexistentZoneAdd()
  -- Can't put the unit in a zone that doesn't exist
  local bad_unit_add = function()
    map:addSquaddie(human, "bogus")
  end

  assert_error_match(
      "Added human to trail that doesn't exist without error. That's bad.",
      " Map:addSquaddie: zone does not exist: bogus",
      bad_unit_add
  )
end

function testremoveSquaddie()
  -- Can remove units from zones
  map:addSquaddie(human, "trail1")

  local trail1_units = map:getSquaddiesInZone("trail1")
  assert_equal(1, #trail1_units)
  assert_equal(human, trail1_units[1])

  map:removeSquaddie(human.id)

  trail1_units = map:getSquaddiesInZone("trail1")
  assert_equal(0, #trail1_units)
end

function testSquaddieOnMapIDIsConstant()
  -- Unit ID should not change if it's moved to another zone
  map:addSquaddie(human, "trail1")
  local originalID = human.id

  map:removeSquaddie(human.id)
  assert_equal(originalID, human.id)

  map:addSquaddie(human, "trail2")
  assert_equal(originalID, human.id)
end

function testHumanPositiveTravel()
  -- Human can move from trail1 to trail2 to trail3
  map:addSquaddie(human, "trail1")
  assert_true(map:canSquaddieMoveToAdjacentZone(human.id, "trail2"))
  map:moveSquaddieAndSpendTurn(human.id, "trail2")
  local trail2_units = map:getSquaddiesInZone("trail2")
  assert_equal(1, #trail2_units)
  assert_equal(human, trail2_units[1])
  assert_true(map:canSquaddieMoveToAdjacentZone(human.id, "trail3"))

  map:resetSquaddieTurn(human.id)
  map:moveSquaddieAndSpendTurn(human.id, "trail3")
  local trail3_units = map:getSquaddiesInZone("trail3")
  assert_equal(1, #trail3_units)
  assert_equal(human, trail3_units[1])
end

function testIllegalInquiries()
  -- Can't call SquaddieOnMap movement functions with nonexistent zones or SquaddieOnMap names
  local bad_unit_add = function()
    map:addSquaddie(nil, "trail1")
  end

  assert_error_match(
      "Added nil to Map as a SquaddieOnMap. That's bad.",
      "nil squaddie cannot be added.",
      bad_unit_add
  )

  map:addSquaddie(human, "trail1")
  local bad_unit_move = function()
    map:moveSquaddieAndSpendTurn(human.id, "bogus")
  end

  assert_error_match(
      "Moved the unit to the middle of nowhere. That's bad.",
      " Map:moveSquaddieAndSpendTurn: zone does not exist: bogus",
      bad_unit_move
  )
end

function testSquaddieOnMapKnowsTravelMethods()
  assert_true(human:hasOneTravelMethod("foot"))
  assert_true(human:hasOneTravelMethod({"foot", "swim", "fly"}))
  assert_false(human:hasOneTravelMethod({"swim", "fly"}))
end

function testFootlockedMovementLimits()
  map:addSquaddie(human, "trail1")

  -- Human can't move from trail1 to trail3 directly
  assert_false(map:canSquaddieMoveToAdjacentZone(human.id, "trail3"))
  assert_error_match(
      "Unit should not be able to move that far. That's bad.",
      "squaddie human cannot reach zone trail3 in a single move.",
      function()
        map:moveSquaddieAndSpendTurn(human.id, "trail3")
      end
  )

  -- Human can't move from trail1 to pond
  assert_false(map:canSquaddieMoveToAdjacentZone(human.id, "pond"))
  assert_error_match(
      "Unit should not be able to move that far. That's bad.",
      "squaddie human cannot reach zone pond in a single move.",
      function()
        map:moveSquaddieAndSpendTurn(human.id, "pond")
      end
  )
end

function testFootMovementIncreasedCanReachFurther()
  map:addSquaddie(bunny, "trail1")

  -- bunny has more movement than a human
  assert_true(bunny.distancePerTurn > human.distancePerTurn)

  -- bunny can move from trail1 to trail3 directly
  assert_true(map:canSquaddieMoveToAdjacentZone(bunny.id, "trail3"))
  map:moveSquaddieAndSpendTurn(bunny.id, "trail3")
  local trail3_units = map:getSquaddiesInZone("trail3")
  assert_equal(1, #trail3_units)
  assert_equal(bunny, trail3_units[1])

  map:resetSquaddieTurn(bunny.id)
  map:placeSquaddieInZone(bunny.id, "trail1")

  -- Bunny can't move from trail3 to pond
  assert_false(map:canSquaddieMoveToAdjacentZone(bunny.id, "pond"))
  assert_error_match(
    "Unit should not be able to move that far. That's bad.",
    "squaddie bunny cannot reach zone pond in a single move.",
    function()
      map:moveSquaddieAndSpendTurn(bunny.id, "pond")
    end
  )
end

function testMovemethods()
  -- Turtles can walk to trail2 and swim to the pond but they aren't fast enough to get to trail3
  map:addSquaddie(turtle, "trail1")
  assert_true(map:canSquaddieMoveToAdjacentZone(turtle.id, "trail2"))
  assert_true(map:canSquaddieMoveToAdjacentZone(turtle.id, "pond"))
  assert_false(map:canSquaddieMoveToAdjacentZone(turtle.id, "trail3"))

  -- Birds can fly to trail2 and trail3 but they can't land in the pond
  map:addSquaddie(bird, "trail1")
  assert_true(map:canSquaddieMoveToAdjacentZone(bird.id, "trail2"))
  assert_false(map:canSquaddieMoveToAdjacentZone(bird.id, "pond"))
  assert_true(map:canSquaddieMoveToAdjacentZone(bird.id, "trail3"))

  -- Stones can't move at all
  map:addSquaddie(stone, "trail1")
  assert_false(map:canSquaddieMoveToAdjacentZone(stone.id, "trail2"))
  assert_false(map:canSquaddieMoveToAdjacentZone(stone.id, "pond"))
  assert_false(map:canSquaddieMoveToAdjacentZone(stone.id, "trail3"))
end
