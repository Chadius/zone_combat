lunit = require "libraries/unitTesting/lunitx"
local Map = require "map"
local MapUnit = require "map/mapUnit"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local map = {}
local human

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

  human = MapUnit:new({
    displayName = "human"
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
  map:addMapUnit(human, "trail1")

  trail1_units = map:getMapUnitsAtLocation("trail1")
  assert_equal(1, #trail1_units)
  assert_equal(human, trail1_units[1])
end

function test_one_mapunit_location()
  -- Can't place the same unit on the map at two places at once
  map:addMapUnit(human, "trail1")
  local bad_unit_add = function()
    map:addMapUnit(human, "trail2")
  end

  assert_error_match(
      "Added human to trail2 without error. That's bad.",
      "MapUnit human already exists.",
      bad_unit_add
  )
  local trail1_units = map:getMapUnitsAtLocation("trail1")
  assert_equal(1, #trail1_units)
  assert_equal(human, trail1_units[1])
end

function testNonexistentZoneAdd()
  -- Can't put the unit in a zone that doesn't exist
  local bad_unit_add = function()
    map:addMapUnit(human, "bogus")
  end

  assert_error_match(
      "Added human to trail that doesn't exist without error. That's bad.",
      "MapUnit human cannot be added because zone bogus does not exist.",
      bad_unit_add
  )
end

function testRemoveMapUnit()
  -- Can remove units from zones
  map:addMapUnit(human, "trail1")

  local trail1_units = map:getMapUnitsAtLocation("trail1")
  assert_equal(1, #trail1_units)
  assert_equal(human, trail1_units[1])

  map:removeMapUnit(human.id)

  trail1_units = map:getMapUnitsAtLocation("trail1")
  assert_equal(0, #trail1_units)
end

function testMapUnitIDIsConstant()
  -- Unit ID should not change if it's moved to another zone
  map:addMapUnit(human, "trail1")
  local originalID = human.id

  map:removeMapUnit(human.id)
  assert_equal(originalID, human.id)

  map:addMapUnit(human, "trail2")
  assert_equal(originalID, human.id)
end