lunit = require "libraries/unitTesting/lunitx"
local MapFactory = require ("map/mapFactory")
local Squaddie = require ("squaddie/squaddie")
local TableUtility = require ("utility/tableUtility")

if _VERSION >= 'Lua 5.2' then
    _ENV = lunit.module('enhanced','seeall')
else
    module( "enhanced", package.seeall, lunit.testcase )
end

function setup()
end

function teardown()
end

function test_map()
  -- Try to make a map with a single zone.
  local map = MapFactory:buildNewMap({
    id = "test map",
    zones = {
      {
        id="test_zone",
        links={}
      }
    }
  })

  assert_equal("test map", map.id)
  assert_equal(1, #TableUtility:keys(map.zone_by_id))
  assert_not_equal(nil, map.zone_by_id["test_zone"])
end

function test_map_no_id_makes_error()
  -- Try to make a map with no ID, expect an error
  local make_bad_map = function()
    MapFactory:buildNewMap({
      zones = {
        {
          id="test_zone",
          links={}
        }
      }
    })
  end

  assert_error_match("test_map_no_id_makes_error", "Map needs an id", make_bad_map)
end

function test_map_no_zone_id_makes_error()
  -- Make a map with 1 zone without an ID, expect an error
  local make_bad_map = function()
    map = MapFactory:buildNewMap({
      id = "test map",
      zones = {
        {
          links={}
        }
      }
    })
  end

  assert_error_match("test_map_no_id_makes_error", "Zone needs an id", make_bad_map)
end

local function sub_assert_map(map)
  -- Helper function that does the same assertion for the next few tests.
  assert_equal("test map", map.id)
  assert_equal(2, #TableUtility:keys(map.zone_by_id))

  -- peanut_street has a link, jelly_avenue
  assert_not_equal(nil, map.zone_by_id["peanut_street"])
  assert_equal(1, TableUtility:keyCount(map.zone_by_id["peanut_street"].links))
  assert_true(map.zone_by_id["peanut_street"]:haslinkWithDestination("jelly_avenue"))
  assert_false(map.zone_by_id["peanut_street"]:haslinkWithDestination("peanut_street"))

  assert_not_equal(nil, map.zone_by_id["jelly_avenue"])
  assert_equal(1, TableUtility:keyCount(map.zone_by_id["jelly_avenue"].links))
  assert_true(map.zone_by_id["jelly_avenue"]:haslinkWithDestination("peanut_street"))
  assert_false(map.zone_by_id["jelly_avenue"]:haslinkWithDestination("jelly_avenue"))
end

function test_map_connected_zones()
  -- Make a map with 2 zones and links connecting them
  local map = MapFactory:buildNewMap({
    id = "test map",
    zones = {
      {
        id="peanut_street",
        links={
          {
            to="jelly_avenue"
          }
        }
      },
      {
        id="jelly_avenue",
        links={
          {
            to="peanut_street"
          }
        }
      }
    }
  })

  sub_assert_map(map)
end

function test_map_connected_zones_bidirectional()
  -- Make a map with 2 zones and 1 bidirectional link connecting them
  local map = MapFactory:buildNewMap({
    id = "test map",
    zones = {
      {
        id="peanut_street",
        links={
          {
            to="jelly_avenue",
            bidirectional=true,
          }
        }
      },
      {
        id="jelly_avenue",
      }
    }
  })

  -- The bidirectional flag should make a jelly_avenue -> peanut_street link, so this map is the same as the previous test.
  sub_assert_map(map)
end

local function assert_no_links(map)
  -- Asserts the map has a zone with no links.
  assert_equal("test map", map.id)
  assert_equal(1, #TableUtility:keys(map.zone_by_id))
  assert_not_equal(nil, map.zone_by_id["test_zone"])
  assert_equal(0, TableUtility:keyCount(map.zone_by_id["test_zone"].links))
end

function test_map_no_circular_link()
  -- Make a map with 1 zone and 1 link pointing to itself, there should be no link
  local map = MapFactory:buildNewMap({
    id = "test map",
    zones = {
      {
        id="test_zone",
        links={
          {
            to="test_zone"
          }
        }
      }
    }
  })

  assert_no_links(map)
end

function test_map_link_points_to_zone()
  local make_bad_map = function()
    MapFactory:buildNewMap({
      id = "test map",
      zones = {
        {
          id="test_zone",
          links={
            {
              to="nowheresville"
            }
          }
        }
      }
    })
  end

  assert_error(
      "Do not make zone links that point to nonexistent zones",
      make_bad_map
  )
end

function testFilterSquaddiesByAffiliation()
  local hero = Squaddie:new({
    displayName = "hero",
    affiliation = "player"
  })

  local sidekick = Squaddie:new({
    displayName = "sidekick",
    affiliation = "player"
  })

  local villain = Squaddie:new({
    displayName = "villain",
    affiliation = "enemy"
  })

  local trashbag = Squaddie:new({
    displayName = "trashbag",
    affiliation = "other"
  })

  local moneybag = Squaddie:new({
    displayName = "moneybag",
    affiliation = "other"
  })

  local map = MapFactory:buildNewMap({
    id = "test map",
    zones = {
      {
        id="test_zone",
        links={}
      }
    }
  })

  local test_zone = map:getZoneByID("test_zone")

  map:addSquaddie(hero, test_zone)
  map:addSquaddie(sidekick, test_zone)
  map:addSquaddie(villain, test_zone)
  map:addSquaddie(trashbag, test_zone)
  map:addSquaddie(moneybag, test_zone)
  trashbag:instakill()

  local getIDFromSquaddies = function(squaddieList)
    return TableUtility:map(
        squaddieList,
        function (_, squaddie, _)
          return squaddie.id
        end
    )
  end

  local playerSquaddies
  local playerSquaddieIDs
  playerSquaddies = map:getSquaddiesByAffiliation("player")
  playerSquaddieIDs = getIDFromSquaddies(playerSquaddies)

  assert_equal(2, TableUtility:count(playerSquaddies))
  assert_equal(2, TableUtility:count(playerSquaddieIDs))
  assert_true( TableUtility:equivalentSet({hero.id, sidekick.id}, playerSquaddieIDs))

  local enemySquaddies
  local enemySquaddieIDs
  enemySquaddies = map:getSquaddiesByAffiliation("enemy")
  enemySquaddieIDs = getIDFromSquaddies(enemySquaddies)
  assert_equal(1, TableUtility:count(enemySquaddies))
  assert_equal(1, TableUtility:count(enemySquaddieIDs))
  assert_true( TableUtility:equivalentSet({villain.id}, enemySquaddieIDs))

  local allySquaddies
  local allySquaddieIDs
  allySquaddies = map:getSquaddiesByAffiliation("ally")
  allySquaddieIDs = getIDFromSquaddies(allySquaddies)
  assert_equal(0, TableUtility:count(allySquaddies))
  assert_equal(0, TableUtility:count(allySquaddieIDs))

  local otherSquaddies
  local otherSquaddieIDs
  otherSquaddies = map:getSquaddiesByAffiliation("other")
  otherSquaddieIDs = getIDFromSquaddies(otherSquaddies)
  assert_equal(2, TableUtility:count(otherSquaddies))
  assert_equal(2, TableUtility:count(otherSquaddieIDs))
  assert_true( TableUtility:equivalentSet({trashbag.id, moneybag.id}, otherSquaddieIDs))
end
