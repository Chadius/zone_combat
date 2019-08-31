local TableUtility = require ("utility/tableUtility")

local ArrayTable = {}
ArrayTable.__index = function(table, key)
  if rawget(ArrayTable, key) ~= nil then
    return rawget(ArrayTable, key)
  end

  return table.container[key]
end

function ArrayTable:new(args)
  local newArrayTable = {}
  setmetatable(newArrayTable, ArrayTable)
  newArrayTable.container = args or {}

  return newArrayTable
end

function ArrayTable:size()
  return TableUtility:size(self.container)
end

function ArrayTable:at(index)
  return self.container[index]
end

function ArrayTable:all(predicate)
  return TableUtility:all(self.container, predicate)
end

function ArrayTable:any(predicate)
  return TableUtility:any(self.container, predicate)
end

function ArrayTable:append(other)
  local appendedContents = TableUtility:append(self:getContents(), other:getContents())
  return ArrayTable:new(appendedContents)
end

function ArrayTable:clone()
  return ArrayTable:new(
      self:getContents()
  )
end

function ArrayTable:contains(valueToFind)
  return TableUtility:contains(self:getContents(), valueToFind)
end

function ArrayTable:containsValue(valueToFind)
  return self:contains(valueToFind)
end

--function ArrayTable:containsKey()
--end

--function ArrayTable:count()
--end

--function ArrayTable:deepClone()
--end

--function ArrayTable:each()
--end

--function ArrayTable:empty()
--end

function ArrayTable:equivalent(other)
  return TableUtility:equivalent(
      self:getContents(),
      other:getContents()
  )
end

function ArrayTable:isEquivalent(other)
  return self:equivalent(other)
end

function ArrayTable:equivalentSet(other)
  return TableUtility:equivalentSet(
      self:getContents(),
      other:getContents()
  )
end

function ArrayTable:isEquivalentSet(other)
  return self:equivalentSet(other)
end

--function ArrayTable:filter()
--end

--function ArrayTable:first()
--end

--function ArrayTable:contains()
--end

function ArrayTable:getContents()
  return TableUtility:clone(self.container)
end

function ArrayTable:items()
  return self:getContents()
end

function ArrayTable:contents()
  return self:getContents()
end

--function ArrayTable:hasKey()
--end

--function ArrayTable:isEmpty()
--end

--function ArrayTable:isOrdered()
--end

--function ArrayTable:join()
--end

--function ArrayTable:keyCount()
--end

--function ArrayTable:keys()
--end

--function ArrayTable:listcomp()
--end

--function ArrayTable:map()
--end

--function ArrayTable:pluck()
--end

--function ArrayTable:reverse()
--end

--function ArrayTable:sort()
--end

--function ArrayTable:sum()
--end

--function ArrayTable:swap()
--end

--function ArrayTable:values()
--end

return ArrayTable
