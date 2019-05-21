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
  local numbers = {1,2,3,4,5,6,7,-7}
  local sum = TableUtility:sum(numbers)
  assert_equal(21, sum)
  
  local concat = function(arg1, arg2)
    return arg1 .. arg2
  end
  local letters = {"M", "i", "k", "e"}
  local glued = TableUtility:sum(letters, concat, "Hi ")
  assert_equal("Hi Mike", glued)
end

function test_each()
  local sum = 0
  local numbers = {1,2,3,4,5,6,7,-7}
  
  local addToSum = function(key, val, tab)
    sum = sum + val
  end
  TableUtility:sum(numbers, addToSum)
  assert_equal(21, sum)
end

function test_list_comprehension()
  -- Cloning Python list comprehension to filter and map items in a list.
  
  -- Get a list of all even items in the list.
  local alphabet = {
    {
      letter = "A",
      index = 1
    },
    {
      letter = "B",
      index = 2
    },
    {
      letter = "C",
      index = 1
    },
    {
      letter = "D",
      index = 4
    },
    {
      letter = "E",
      index = 1
    },
    {
      letter = "F",
      index = 6
    }    
  }
  
  local even_indexed_letters = TableUtility:listcomp(
    alphabet,
    function (k, v)
      return v["letter"]
    end,
    function (k, v)
      return v["index"] % 2 == 0
    end
  )
  
  assert_equal(3, TableUtility:size(even_indexed_letters))
  assert_equal("B", even_indexed_letters[1])
  assert_equal("D", even_indexed_letters[2])
  assert_equal("F", even_indexed_letters[3])
end

function test_equivalent()
  local a = {1,2,3}
  local b = {1,2,3}
  local reordered_b = {3,2,1}
  local different_length = {1, 2, 3, 4}
  local different_elements = {1, 2, "3"}

  -- Tables are equivalent if they are the same length and the elements are equivalent
  assert_true(TableUtility:equivalent(a, b))
  assert_true(TableUtility:equivalent(b, a))
  
  -- The order counts, so rearranging the elements will not make them equivalent.
  assert_false(TableUtility:equivalent(b, reordered_b))
  
  -- different length tables are not equivalent either.
  assert_false(TableUtility:equivalent(a, different_length))
  
  -- different is not equivalent and does not contain the same elements as a
  assert_false(TableUtility:equivalent(different_elements, a))
  
  -- But b and c do contain the same elements
  --  assert_true(TableUtility:equivalent_unordered(b, c))
  -- assert_false(TableUtility:equivalent_unordered(different, a))
  
  -- Check for nested tables, too.
  local nested_table_a = {{1}}
  local nested_table_b = {{1}}
  assert_true(TableUtility:equivalent(nested_table_a, nested_table_b))
end

function test_all()
  local positive = {true, true, true}
  local negative = {false, true, true}
  
  assert_true(TableUtility:all(positive))
  assert_false(TableUtility:all(negative))
  
  local is_even = function(key, value, source)
    return value % 2 == 0
  end

  assert_true(TableUtility:all({0,2,4,6}, is_even))
  assert_false(TableUtility:all({0,2,4,7}, is_even))
end

function test_any()
  local positive = {true, true, false}
  local negative = {false, false, false}

  assert_true(TableUtility:any(positive))
  assert_false(TableUtility:any(negative))

  local is_even = function(key, value, source)
    return value % 2 == 0
  end

  assert_true(TableUtility:any({0,2,4,6}, is_even))
  assert_false(TableUtility:any({1,3,5,7}, is_even))
end

function test_swap()
  local numbers = {"a",4,3,2,1}
  local expected = {1,4,3,2,"a"}
  TableUtility:swap(numbers, 1, 5)
  assert_true(TableUtility:equivalent(numbers, expected))
end

function test_clone_table()
  local original = {"a",4,3,2,1}
  local clone = TableUtility:clone(original)
  assert_false(original == clone)
  assert_true(TableUtility:equivalent(original, clone))
end

function test_sort_numbers()
  local numbers = {3,4,5,2,1}
  local expected = {1,2,3,4,5}
  TableUtility:sort(numbers)
  assert_true(TableUtility:equivalent(numbers, expected))
end

function test_sort_comparison()
  local numbers = {3,4,5,2,1}
  local expected = {5,4,3,2,1}
  local reverse_compare = function (a,b)
    if a < b then
      return 1
    elseif a > b then
      return -1
    end
    return 0
  end
  TableUtility:sort(numbers, reverse_compare)
  assert_true(TableUtility:equivalent(numbers, expected))
end

function test_equivalent_set()
  local a = {1,2,3}
  local b = {1,2,3}
  local reordered_b = {3,2,1}
  local different_length = {1, 2, 3, 4}
  local different_elements = {1, 2, "3"}

  -- Tables are equivalent sets if they are the same length and they have the same elements
  assert_true(TableUtility:equivalentSet(a, b))
  assert_true(TableUtility:equivalentSet(b, a))

  -- The order does NOT matter, so rearranging the elements doesn't matter.
  assert_true(TableUtility:equivalentSet(b, reordered_b))

  -- different length tables are not equivalent either.
  assert_false(TableUtility:equivalentSet(a, different_length))

  -- different is not equivalent and does not contain the same elements as a
  assert_false(TableUtility:equivalentSet(different_elements, a))

  -- Check for nested tables, too.
  local nested_table_a = {{2}, {1}}
  local nested_table_b = {{1}, {2}}
  local nested_comparison = function(a,b)
    if a[1] < b[1] then
      return -1
    else
      return 1
    end
  end
  assert_true(TableUtility:equivalentSet(nested_table_a, nested_table_b, nested_comparison))
end

function test_reverse()
  local numbers = {1,2,3,4,5}
  local expected = {5,4,3,2,1}
  local reversed = TableUtility:reverse(numbers)
  assert_true(TableUtility:equivalent(reversed, expected))
end