local TableUtility = require ("utility/tableUtility")
local ArrayTable = require ("utility/arrayTable")

local HashTable = {}
HashTable.__index = function(table, key)
  if rawget(HashTable, key) ~= nil then
    return rawget(HashTable, key)
  end

  return table.container[key]
end

function HashTable:new(args)
  local newHashTable = {}
  setmetatable(newHashTable, HashTable)

  newHashTable.container = {}
  for key, value in pairs(args) do
    newHashTable.container[key] = value
  end

  return newHashTable
end

function HashTable:size()
  return TableUtility:size(self.container)
end

function HashTable:at(index)
  return self.container[index]
end

function HashTable:all(predicate)
  return TableUtility:all(self.container, predicate)
end

function HashTable:any(predicate)
  return TableUtility:any(self.container, predicate)
end

function HashTable:clone()
  return HashTable:new(
      self:getContents()
  )
end

function HashTable:containsKey(keyToFind)
  return TableUtility:containsKey(self:getContents(), keyToFind)
end

function HashTable:hasKey(keyToFind)
  return self:containsKey(keyToFind)
end

function HashTable:containsValue(valueToFind)
  return TableUtility:contains(self:getContents(), valueToFind)
end

function HashTable:count(predicate)
  return TableUtility:count(
      self:getContents(), predicate
  )
end

function HashTable:deepClone()
  return HashTable:new(
      TableUtility:deepClone(
          self:getContents()
      )
  )
end

function HashTable:each(action)
  TableUtility:each(
      self:getContents(),
      action
 )
end

function HashTable:empty()
  return TableUtility:empty(self:getContents())
end

function HashTable:isEmpty()
  return self:empty()
end

function HashTable:equivalentSet(other)
  return TableUtility:equivalentSet(
      self:getContents(),
      other:getContents()
  )
end

function HashTable:isEquivalentSet(other)
  return self:equivalentSet(other)
end

function HashTable:filter(predicate)
  return HashTable:new(
      TableUtility:filter(
          self:getContents(),
          predicate
      )
  )
end

function HashTable:getContents()
  return TableUtility:clone(self.container)
end

function HashTable:items()
  return self:getContents()
end

function HashTable:contents()
  return self:getContents()
end

function HashTable:map(action)
  return HashTable:new(
      TableUtility:map(
          self:getContents(),
          action
      )
  )
end

function HashTable:insert(key, value)
  if key == nil then
    return
  end
  self.container[key] = value
end

function HashTable:pluck(key_to_pluck)
  return HashTable:new(
    TableUtility:pluck(self:getContents(), key_to_pluck)
  )
end

function HashTable:sum(accumulator, startingValue)
  return TableUtility:sum(
      self:getContents(),
      accumulator,
      startingValue
  )
end

function HashTable:keys()
  return ArrayTable:new(
      TableUtility:keys(
          self:getContents()
      )
  )
end

function HashTable:getKeys()
  return self:keys()
end

function HashTable:values()
  return ArrayTable:new(
      TableUtility:values(
          self:getContents()
      )
  )
end

function HashTable:getValues()
  return self:values()
end

function HashTable:toArrayTable()
  return ArrayTable:new(
      TableUtility:toOrderedTable(
          self:getContents()
      )
  )
end

function HashTable:update(other)
  return HashTable:new(
      TableUtility:update(
          self:getContents(),
          other:getContents()
      )
  )
end

return HashTable
