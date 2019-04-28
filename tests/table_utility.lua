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
  local getStringLength = function(index, str, list)
    return string.len(str)
  end

  local tab = {
    "I",
    "am",
    "a",
    "cat",
  }

  local map_table = TableUtility:map(tab, getStringLength)

  assert_equal(4, TableUtility:size(map_table))
  assert_equal(1, map_table[1])
  assert_equal(2, map_table[2])
  assert_equal(1, map_table[3])
  assert_equal(3, map_table[4])
end

function test_filter()
  -- Test the filter function to show it can split the list.
  local onlyEvenLength = function(index, str, list)
    local str_len = string.len(str)
    if str_len % 2 == 0 then
      return true
    end
    return false
  end

  local tab = {
    "I",
    "am",
    "a",
    "cat",
  }

  local map_table = TableUtility:filter(tab, onlyEvenLength)

  assert_equal(1, TableUtility:size(map_table))
  assert_equal("am", map_table[1])
end

function test_pluck()
  -- Test the ability to select values based on a certain key from the table.
  local tab = {
    {
      name="Larry",
      dunks=10,
      retired=true,
    },
    {
      name="Michael",
      dunks=50,
      retired=true,
    },
    {
      name="LeBron",
      dunks=30,
      retired=false,
    },
  }

  local just_names = TableUtility:pluck(tab, "name")
  assert_equal(3, TableUtility:size(just_names))
  assert_equal("Larry", just_names[1])
  assert_equal("Michael", just_names[2])
  assert_equal("LeBron", just_names[3])

  local just_dunks = TableUtility:pluck(tab, "dunks")
  assert_equal(3, TableUtility:size(just_dunks))
  assert_equal(10, just_dunks[1])
  assert_equal(50, just_dunks[2])
  assert_equal(30, just_dunks[3])

  local just_retired = TableUtility:pluck(tab, "retired")
  assert_equal(3, TableUtility:size(just_retired))
  assert_equal(true, just_retired[1])
  assert_equal(true, just_retired[2])
  assert_equal(false, just_retired[3])

  local just_bogus = TableUtility:pluck(tab, "bogus")
  assert_equal(0, TableUtility:size(just_bogus))
end

function test_accumulate()
  -- Test you can sum numbers and strings in a list.
end

function test_list_comprehension()
  -- Cloning Python list comprehension to filter and map items in a list.
end
