lunit = require "libraries/unitTesting/lunitx"
local Map = require "map"
local TableUtility = require "table_utility"

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
  local map = Map:new({
    id = "test map",
    zones = {
      {
        id="test_zone",
        neighbors={}
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
    local map = Map:new({
      zones = {
        {
          id="test_zone",
          neighbors={}
        }
      }
    })
  end

  assert_error_match("test_map_no_id_makes_error", "Map needs an id", make_bad_map)
end

-- Make a map with 1 zone without an ID, expect an error
-- Make a map with 2 zones and 1 neighbor connecting them
-- Make a map with 1 zones and 1 neighbor pointing to itself, there should be no neighbor
-- Make a map with 1 zone and 1 neighbor to nowhere
