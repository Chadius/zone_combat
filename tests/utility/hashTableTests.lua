lunit = require "libraries/unitTesting/lunitx"
local ArrayTable = require ("utility/ArrayTable")
local HashTable = require ("utility/HashTable")
local TableUtility = require ("utility/tableUtility")

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local lettersInTheAlphabetTable
local lettersInTheAlphabet
local storePrices
local isEven
local isPositive
local isNegative
local children
--local storePricesInDifferentOrder

function setup()
  lettersInTheAlphabetTable = {m = 13, n = 14, o = 15}
  lettersInTheAlphabet = HashTable:new(lettersInTheAlphabetTable)

  storePrices = HashTable:new({
    bread = 2,
    peanut_butter = 3,
    jelly = 4
  })
  
  isEven = function(key, val) return(val % 2 == 0) end
  isPositive = function(key, val) return(val > 0) end
  isNegative = function(key, val) return(val < 0) end

  children = HashTable:new({
    billi = { age=5, color="red" },
    sydney = { age=8, color="blue" },
    alex = { age=2, color="orange" }
  })
end

function testSize()
  assert_equal(3, lettersInTheAlphabet:size())
end

function testAt()
  assert_equal(13, lettersInTheAlphabet:at("m"))
  assert_equal(13, lettersInTheAlphabet["m"])
  assert_equal(nil, lettersInTheAlphabet:at("q"))
end

function testAll()
  assert_true(storePrices:all(isPositive))
  assert_false(storePrices:all(isEven))
end

function testAny()
  assert_true(storePrices:any(isEven))
  assert_false(storePrices:any(isNegative))
end

function testGetContents()
  local storeContents = {
    bread = 2,
    peanut_butter = 3,
    jelly = 4
  }
  local notStoreContents = {
    bread = 3,
    peanut_butter = 3,
    jelly = 4,
    cheese = 5
  }
  assert_true(
    TableUtility:equivalent(
        storePrices:getContents(),
        storeContents
    )
  )
  assert_false(
    TableUtility:equivalent(
        storePrices:getContents(),
        notStoreContents
    )
  )

  assert_true(
    TableUtility:equivalent(
        storePrices:items(),
        storeContents
    )
  )
  assert_false(
    TableUtility:equivalent(
        storePrices:items(),
        notStoreContents
    )
  )

  assert_true(
    TableUtility:equivalent(
        storePrices:contents(),
        storeContents
    )
  )
  assert_false(
      TableUtility:equivalent(
          storePrices:contents(),
          notStoreContents
      )
  )
end

function testEquivalentSet()
  assert_true(storePrices:equivalentSet(storePrices))
  assert_true(storePrices:isEquivalentSet(storePrices))

  local rivalStore = HashTable:new({
    bread = 3,
    peanut_butter = 4,
    jelly = 6,
    cheese = 5
  })
  assert_false(storePrices:equivalentSet(rivalStore))
end

function testClone()
  local clonedStorePrices = storePrices:clone()

  assert_equal(storePrices:size(), clonedStorePrices:size() )
  assert_true(storePrices:equivalentSet(clonedStorePrices))
  assert_not_equal(storePrices, clonedStorePrices)
end

function testContainsKey()
  assert_true(lettersInTheAlphabet:containsKey("m"))
  assert_true(lettersInTheAlphabet:hasKey("m"))
  assert_false(lettersInTheAlphabet:containsKey("f"))
end

function testContainsValue()
  assert_true(lettersInTheAlphabet:containsValue(13))
  assert_false(lettersInTheAlphabet:containsValue(1))
end

function testCount()
  assert_equal(3, storePrices:count())
  assert_equal(2, storePrices:count(isEven))
  assert_equal(0, storePrices:count(isNegative))
end

function testDeepClone()
  local clonedChildren = children:deepClone()

  assert_not_equal(children, clonedChildren)
  assert_not_equal(children["alex"], clonedChildren["alex"])
  assert_equal(children["alex"]["age"], clonedChildren["alex"]["age"])
  assert_true(children:equivalentSet(clonedChildren))
end

function testInsert()
  local expectedStorePricesContents = storePrices:getContents()
  expectedStorePricesContents["lettuce"] = 1

  storePrices:insert("lettuce", 1)
  assert_equal(4, storePrices:size())
  assert_true(
      storePrices:equivalentSet(HashTable:new(expectedStorePricesContents))
  )

  storePrices:insert(nil, 1000000)
  assert_true(
      storePrices:equivalentSet(HashTable:new(expectedStorePricesContents))
  )
end

function testEach()
  local doubledPrices = {}
  local doubleAndAdd = function (k, v, source)
    table.insert(doubledPrices, v * 2)
  end

  storePrices:each(doubleAndAdd)
  assert_true(
      TableUtility:equivalentSet(
          doubledPrices,
          {4,6,8}
      )
  )
end

function testEmpty()
  local emptyArray = HashTable:new({})
  assert_true(emptyArray:empty())
  assert_true(emptyArray:isEmpty())
  assert_false(lettersInTheAlphabet:empty())
end

function testFilter()
  local evenStorePricesOnly = storePrices:filter(isEven)
  assert_true(
      evenStorePricesOnly:equivalentSet(
          HashTable:new({
            bread = 2,
            jelly = 4
          })
      )
  )
  assert_not_equal(storePrices, evenStorePricesOnly)
  assert_true(
      storePrices:filter(isNegative):isEmpty()
  )
end

function testMap()
  local doublePrices = function(_, price)
    return 2 * price
  end
  local expectedPrices = HashTable:new({
    bread = 4,
    peanut_butter = 6,
    jelly = 8
  })
  local actualPrices = storePrices:map(doublePrices)
  assert_true(expectedPrices:equivalentSet(actualPrices))
end

function testPluck()
  local justTheColors = children:pluck("color")
  local expectedColors = HashTable:new({
    billi = "red",
    sydney = "blue",
    alex = "orange"
  })

  assert_true(
      expectedColors:equivalentSet(justTheColors)
  )
end

function testSum()
  local addPrice = function (totalCost, price)
    return totalCost + price
  end
  assert_equal(2+3+4, storePrices:sum(addPrice, 0))

  local concat = function(sum, childInfo)
    return sum + childInfo.age
  end
  local totalChildrenAge = children:sum(concat, 0)
  assert_equal(5+8+2, totalChildrenAge)
end

function testGetKeys()
  local expectedChildrenNames = ArrayTable:new({"billi", "alex", "sydney"})
  local actualChildrenNames = children:keys()
  assert_true(
      actualChildrenNames:equivalentSet(expectedChildrenNames)
  )

  actualChildrenNames = children:getKeys()
  assert_true(
      actualChildrenNames:equivalentSet(expectedChildrenNames)
  )
end

function testGetValues()
  local expectedPrices = ArrayTable:new({2,3,4})
  local actualPrices = storePrices:values()
  assert_true(
      actualPrices:equivalentSet(expectedPrices)
  )

  actualPrices = storePrices:getValues()
  assert_true(
      actualPrices:equivalentSet(expectedPrices)
  )
end

function testToArrayTable()
  local expectedPricesArray = ArrayTable:new({
    {bread = 2},
    {peanut_butter = 3},
    {jelly = 4}
  })

  local actualPricesArray = storePrices:toArrayTable()

  assert_true(
      actualPricesArray:equivalentSet(expectedPricesArray)
  )
end

function testUpdate()
  local updateWithSelf = lettersInTheAlphabet:update(lettersInTheAlphabet)
  assert_true(
      updateWithSelf:equivalentSet(lettersInTheAlphabet)
  )

  local storePricesAndLetters = storePrices:update(lettersInTheAlphabet)
  assert_true(
      storePricesAndLetters:equivalentSet(
          HashTable:new({
            m = 13,
            n = 14,
            o = 15,
            bread = 2,
            peanut_butter = 3,
            jelly = 4
          })
      )
  )

  local noChangesExpected = lettersInTheAlphabet:update(HashTable:new({}))
  assert_true(noChangesExpected:equivalentSet(lettersInTheAlphabet))

  local alternateCloneMethod = HashTable:new({}):update(lettersInTheAlphabet)
  assert_true(alternateCloneMethod:equivalentSet(lettersInTheAlphabet))
end

