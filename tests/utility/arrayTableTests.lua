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
local children

function setup()
  startOfAlphabetTable = {"a","b","c"}
  startOfAlphabet = ArrayTable:new(startOfAlphabetTable)

  numbersTable = {6,7,8,9,10}
  numbers = ArrayTable:new(numbersTable)

  isEven = function(val) return(val % 2 == 0) end
  isPositive = function(val) return(val > 0) end
  isNegative = function(val) return(val < 0) end

  children = ArrayTable:new({
    { name="billi", age=5, color="red" },
    { name="sydney", age=8, color="blue" },
    { name="alex", age=2, color="orange" }
  })
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
  local numberContents = {6,7,8,9,10}
  local notNumberContents = {5,7,8}
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

  local sameItemsAsNumbers = ArrayTable:new({6,7,8,9,10})
  assert_true(numbers:equivalent(sameItemsAsNumbers))

  local differentItemsAsNumbers = ArrayTable:new({6,7,8,9,1})
  assert_false(numbers:equivalent(differentItemsAsNumbers))
end

function testEquivalentSet()
  assert_true(numbers:equivalentSet(numbers))
  assert_true(numbers:isEquivalentSet(numbers))

  local numbersInDifferentOrder = ArrayTable:new(7,9,8,10,6)
  assert_true(numbers:equivalentSet(numbersInDifferentOrder))

  local extraNumberAdded = ArrayTable:new({5,6,7,8,9,10})
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
          ArrayTable:new({6,7,8,9,10, "a","b","c"})
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

function testContainsKey()
  assert_true(startOfAlphabet:containsKey(3))
  assert_false(startOfAlphabet:containsKey(6))
  assert_false(startOfAlphabet:containsKey("a"))
end

function testCount()
  assert_equal(5, numbers:count())
  assert_equal(3, numbers:count(isEven))
  assert_equal(0, numbers:count(isNegative))
end

function testDeepClone()
  local clonedChildren = children:deepClone()

  assert_not_equal(children, clonedChildren)
  assert_not_equal(children[1], clonedChildren[1])
  assert_equal(children[1]["age"], clonedChildren[1]["age"])
  assert_true(children:equivalent(clonedChildren))
end

function testInsert()
  numbers:insert(1)
  assert_true(
      numbers:equivalent(ArrayTable:new({6,7,8,9,10,1}))
  )

  numbers:insert(nil)
  assert_true(
      numbers:equivalent(ArrayTable:new({6,7,8,9,10,1}))
  )
end

function testEach()
  local doubledValues = {}
  local doubleAndAdd = function (x)
    table.insert(doubledValues, x * 2)
  end

  numbers:each(doubleAndAdd)
  assert_true(
      TableUtility:equivalent(
          doubledValues,
          {12,14,16,18,20}
      )
  )
end

function testEmpty()
  local emptyArray = ArrayTable:new({})
  assert_true(emptyArray:empty())
  assert_true(emptyArray:isEmpty())
  assert_false(startOfAlphabet:empty())
end

function testFilter()
  local evenNumbersOnly = numbers:filter(isEven)
  assert_true(
      evenNumbersOnly:equivalent(
          ArrayTable:new({6,8,10})
      )
  )
  assert_not_equal(numbers, evenNumbersOnly)
  assert_true(
      numbers:filter(isNegative):isEmpty()
  )
end

function testNewArrayTableWithoutBracket()
  local noBracketAlphabet = ArrayTable:new("a", "b", "c")
  assert_false(noBracketAlphabet:empty())
  assert_true(startOfAlphabet:equivalent(noBracketAlphabet))
end

function testFirst()
  assert_equal(
      6,
      numbers:first(isEven)
  )
  assert_equal(
      nil,
      numbers:first(isNegative)
  )
end

--hasKey()
--isEmpty()
--isOrdered()
--join()
--keyCount()
--keys()
--listcomp()

function testMap()
  local doubleNumber = function(x)return 2 * x end
  local expectedArray = ArrayTable:new({12,14,16,18,20})
  local actualArray = numbers:map(doubleNumber)
  assert_true(expectedArray:equivalent(actualArray))
end

--pluck()
--reverse()
--sort()
--sum()
--swap()
--values()