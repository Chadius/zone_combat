lunit = require "libraries/unitTesting/lunitx"
local ArrayTable = require ("utility/arrayTable")

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

--append()
--clone()
--contains()
--containsKey()
--count()
--deepClone()
--each()
--empty()
--equivalent()
--equivalentSet()
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