lunit = require "libraries/unitTesting/lunitx"
local TableUtility = require ("utility/tableUtility")

if _VERSION >= 'Lua 5.2' then
    _ENV = lunit.module('enhanced','seeall')
else
    module( "enhanced", package.seeall, lunit.testcase )
end

local children
local sandwich
local numbers
local numbers2
local numbers3

local is_even = function(_, value)
  return value % 2 == 0
end

local has_even_age = function (_, v)
  return v.age % 2 == 0
end

function setup()
  children = {
    billi = { age=5, color="red" },
    sydney = { age=8, color="blue" },
    alex = { age=2, color="orange" }
  }

  sandwich = {
    top="bread",
    middle="peanut butter",
    bottom="bread",
  }

  numbers = {1,2,3,4,5}
  numbers2 = {1,2,3,4,5,6,7,-7}
  numbers3 = {1,2,5}
end

function teardown()
end

function test_size()
  -- Make sure you can return the number of keys
  assert_equal(3, TableUtility:size(sandwich))
  assert_equal(2, TableUtility:size({1,2}))
end

function test_map()
  -- Test the map function to show it transforms the list.
  local getStringLength = function(_, str)
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

  local square_value = function(_, value) return value* value end
  local squared = TableUtility:map(numbers, square_value)
  assert_true(TableUtility:equivalent({1,4,9,16,25}, squared))

  local numberDict = {
    top = 1,
    middle = 5,
    bottom = 10,
  }

  local squaredDict = TableUtility:map(numberDict, square_value)
  assert_true(TableUtility:equivalent({top=1, middle=25, bottom=100}, squaredDict))
end

function test_filter()
  -- Test the filter function to show it can split the list.
  local onlyEvenLength = function(_, str)
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

  local onlyEvenNumbers = TableUtility:filter(numbers, is_even)
  assert_true(TableUtility:equivalent({2,4}, onlyEvenNumbers))

  local even_aged_children = TableUtility:filter(
    children,
    has_even_age
  )
  assert_true(TableUtility:equivalent(
      {
        sydney = {
          age=8,
          color="blue"
        },
        alex = {
          age=2,
          color="orange"
        }
      },
      even_aged_children
    )
  )
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

  local favorite_colors = TableUtility:pluck(children, "color")
  assert_true(TableUtility:equivalent({billi="red", sydney="blue", alex="orange"}, favorite_colors))
end

function test_accumulate()
  -- Test you can sum numbers and strings in a list.
  local sum = TableUtility:sum(numbers2)
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

  local addToSum = function(_, val)
    sum = sum + val
  end
  TableUtility:each(numbers2, addToSum)
  assert_equal(21, sum)

  local totalAge = 0
  local addToAge = function(_, val)
    totalAge = totalAge + val.age
  end
  TableUtility:each(children, addToAge)
  assert_equal(15, totalAge)
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
    function (_, v)
      return v["letter"]
    end,
    function (_, v)
      return v["index"] % 2 == 0
    end
  )

  assert_equal(3, TableUtility:size(even_indexed_letters))
  assert_equal("B", even_indexed_letters[1])
  assert_equal("D", even_indexed_letters[2])
  assert_equal("F", even_indexed_letters[3])
  local even_aged_children = TableUtility:listcomp(
    children,
    function (k)
      return k
    end,
    has_even_age
  )
  assert_true(TableUtility:equivalent({sydney = "sydney", alex = "alex"}, even_aged_children))
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

  assert_true(TableUtility:all({0,2,4,6}, is_even))
  assert_false(TableUtility:all({0,2,4,7}, is_even))

  local positiveDict = {
    top = 20,
    middle = 16,
    bottom = 30,
  }
  local negativeDict = {
    top = 20,
    middle = 15,
    bottom = 30,
  }
  assert_true(TableUtility:all(positiveDict, is_even))
  assert_false(TableUtility:all(negativeDict, is_even))
end

function test_any()
  local positive = {true, true, false}
  local negative = {false, false, false}

  assert_true(TableUtility:any(positive))
  assert_false(TableUtility:any(negative))

  assert_true(TableUtility:any({0,2,4,6}, is_even))
  assert_false(TableUtility:any({1,3,5,7}, is_even))

  local positiveDict = {
    top = 20,
    middle = 15,
    bottom = -1,
  }
  local negativeDict = {
    top = 1,
    middle = 15,
    bottom = 3,
  }
  assert_true(TableUtility:any(positiveDict, is_even))
  assert_false(TableUtility:any(negativeDict, is_even))
end

function test_swap()
  local swapNumbers = {"a",4,3,2,1}
  local expected = {1,4,3,2,"a"}
  TableUtility:swap(swapNumbers, 1, 5)
  assert_true(TableUtility:equivalent(swapNumbers, expected))
end

function test_clone_table()
  local original = {"a",4,3,2,1}
  local clone = TableUtility:clone(original)
  assert_false(original == clone)
  assert_true(TableUtility:equivalent(original, clone))
  local cloned_children = TableUtility:clone(children)
  assert_false(children == cloned_children)
  assert_true(TableUtility:equivalent(children, cloned_children))
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
  local more_kids = TableUtility:clone(children)
  assert_false(children == more_kids)
  assert_true(TableUtility:equivalentSet(children, more_kids))
end

function test_reverse()
  local expected = {5,4,3,2,1}
  local reversed = TableUtility:reverse(numbers)
  assert_true(TableUtility:equivalent(reversed, expected))
end

function test_join()
  local contents = TableUtility:join(numbers, ",")
  assert_equal("1,2,3,4,5", contents)

  local short_contents = TableUtility:join({1}, ",")
  assert_equal("1", short_contents)

  assert_equal("", TableUtility:join({}, ","))

  local unordered_table_join = TableUtility:join({a=1, b=2}, ",")
  assert_true(unordered_table_join == "a:1,b:2" or unordered_table_join == "b:2,a:1")
end

function test_first()
  local isMoreThanTen = function(_, a) return a > 10 end
  local firstEven = TableUtility:first(numbers, is_even)
  assert_equal(2, firstEven)
  local firstMoreThanTen = TableUtility:first(numbers, isMoreThanTen)
  assert_equal(nil, firstMoreThanTen)
end

function test_keys()
  local index_keys = TableUtility:keys(numbers3)
  assert_true(TableUtility:equivalentSet({1,2,3}, index_keys))

  local tab_keys = TableUtility:keys(sandwich)
  assert_true(TableUtility:equivalentSet({"top","middle","bottom"}, tab_keys))
end
function test_toorderedlist()
  local ordered_numbers = TableUtility:toOrderedTable(numbers3)
  assert_equal(numbers3, ordered_numbers)

  local expected = {
    {
      billi = { age=5, color="red" }
    },
    {
      sydney = { age=8, color="blue" }
    },
    {
      alex = { age=2, color="orange" }
    }
  }
  local sort_by_name = function(a, b)
    local a_keys = TableUtility:keys(a)
    local b_keys = TableUtility:keys(b)
    if a_keys[1] < b_keys[1] then return true end
    return false
  end
  local ordered_kids = TableUtility:toOrderedTable(expected)
  assert_true(TableUtility:equivalentSet(expected, ordered_kids, sort_by_name))
end
function testContains()
  assert_true(TableUtility:contains(numbers, 3))
  assert_false(TableUtility:contains(numbers, 8))

  assert_true(TableUtility:contains(sandwich, "bread"))
  assert_false(TableUtility:contains(sandwich, "pickles"))
end
function testEmpty()
  assert_false(TableUtility:empty(sandwich))
  assert_false(TableUtility:empty(numbers))

  assert_true(TableUtility:empty({}))
end
function testDeepCopy()
  local cloned_children = TableUtility:deepClone(children)
  assert_false(children == cloned_children)
  assert_true(TableUtility:equivalent(children, cloned_children))
  assert_false(children.sydney == cloned_children.sydney)
  assert_true(TableUtility:equivalent(children.sydney, cloned_children.sydney))

  local cloned_sandwich = TableUtility:deepClone(sandwich)
  assert_true(TableUtility:equivalent(sandwich, cloned_sandwich))

  local cloned_numbers = TableUtility:deepClone(numbers)
  assert_true(TableUtility:equivalent(numbers, cloned_numbers))
end

function testSizeFilter()
  assert_equal(2, TableUtility:size(numbers, is_even))
  assert_equal(2, TableUtility:count(numbers, is_even))
end