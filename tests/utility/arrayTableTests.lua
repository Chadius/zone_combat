lunit = require "libraries/unitTesting/lunitx"
local ArrayTable = require ("utility/arrayTable")
local TableUtility = require ("utility/tableUtility")

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local startOfAlphabetTable
local startOfAlphabet
local numbersTable
local numbers
local isEven
local isPositive
local isNegative

function setup()
  startOfAlphabetTable = {"a","b","c"}
  startOfAlphabet = ArrayTable:new(startOfAlphabetTable)

  numbersTable = {1,2,3,4,5}
  numbers = ArrayTable:new(numbersTable)

  isEven = function(val) return(val % 2 == 0) end
  isPositive = function(val) return(val > 0) end
  isNegative = function(val) return(val < 0) end
end

function testSize()
  assert_equal(3, startOfAlphabet:size())
end

function testAt()
  assert_equal("a", startOfAlphabet:at(1))
  assert_equal("a", startOfAlphabet[1])
  assert_equal(nil, startOfAlphabet:at(5))
end

function testAll()
  assert_true(numbers:all(isPositive))
  assert_false(numbers:all(isEven))
end

function testAny()
  assert_true(numbers:any(isEven))
  assert_false(numbers:any(isNegative))
end

function testGetContents()
  local numberContents = {1,2,3,4,5}
  local notNumberContents = {1,2,3}
  assert_true(
    TableUtility:equivalent(
        numbers:getContents(),
        numberContents
    )
  )
  assert_false(
    TableUtility:equivalent(
        numbers:getContents(),
        notNumberContents
    )
  )

  assert_true(
    TableUtility:equivalent(
        numbers:items(),
        numberContents
    )
  )
  assert_false(
    TableUtility:equivalent(
        numbers:items(),
        notNumberContents
    )
  )

  assert_true(
    TableUtility:equivalent(
        numbers:contents(),
        numberContents
    )
  )
  assert_false(
      TableUtility:equivalent(
          numbers:contents(),
          notNumberContents
      )
  )
end

function testEquivalent()
  assert_true(numbers:equivalent(numbers))
  assert_true(numbers:isEquivalent(numbers))

  local sameItemsAsNumbers = ArrayTable:new({1,2,3,4,5})
  assert_true(numbers:equivalent(sameItemsAsNumbers))

  local differentItemsAsNumbers = ArrayTable:new({1,2,3,4,6})
  assert_false(numbers:equivalent(differentItemsAsNumbers))
end

function testEquivalentSet()
  assert_true(numbers:equivalentSet(numbers))
  assert_true(numbers:isEquivalentSet(numbers))

  local numbersInDifferentOrder = ArrayTable:new({1,3,5,2,4})
  assert_true(numbers:equivalentSet(numbersInDifferentOrder))

  local extraNumberAdded = ArrayTable:new({1,2,3,4,5,6})
  assert_false(numbers:equivalentSet(extraNumberAdded))
end

function testClone()
  local clonedNumbers = numbers:clone()

  assert_equal(numbers:size(), clonedNumbers:size() )
  assert_true(numbers:equivalent(clonedNumbers))
  assert_not_equal(numbers, clonedNumbers)
end

function testAppend()
  local doubleAlphabet = startOfAlphabet:append(startOfAlphabet)
  assert_true(
      doubleAlphabet:equivalent(
        ArrayTable:new({"a","b","c", "a","b","c"})
      )
  )

  assert_true(
      startOfAlphabet:equivalent(
          ArrayTable:new({"a","b","c"})
      )
  )

  local numbersAndLetters = numbers:append(startOfAlphabet)
  assert_true(
      numbersAndLetters:equivalent(
          ArrayTable:new({1,2,3,4,5, "a","b","c"})
      )
  )

  local noChangesExpected = startOfAlphabet:append(ArrayTable:new({}))
  assert_true(noChangesExpected:equivalent(startOfAlphabet))

  local alternateCloneMethod = ArrayTable:new({}):append(startOfAlphabet)
  assert_true(alternateCloneMethod:equivalent(startOfAlphabet))
end

function testContains()
  assert_true(startOfAlphabet:contains("c"))
  assert_false(startOfAlphabet:contains("f"))

  assert_true(startOfAlphabet:containsValue("a"))
end

--containsKey()
--count()
--deepClone()
--each()
--empty()
--filter()
--first()
--hasKey()
--isEmpty()
--isOrdered()
--join()
--keyCount()
--keys()
--listcomp()
--map()
--pluck()
--reverse()
--sort()
--sum()
--swap()
--values()