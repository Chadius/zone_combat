lunit = require "libraries/unitTesting/lunitx"
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

function test_size()
  -- Make sure you can return the number of keys
  local tab = {
    top="bread",
    middle="peanut butter",
    bottom="bread",
  }

  assert_equal(3, TableUtility:size(tab))
end

function test_map()
  -- Test the map function to show it transforms the list.
end

function test_filter()
  -- Test the filter function to show it can split the list.
end

function test_pluck()
  -- Test the ability to select values based on a certain key from the table.
end

function test_accumulate()
  -- Test you can sum numbers and strings in a list.
end

function test_list_comprehension()
  -- Cloning Python list comprehension to filter and map items in a list.
end
