local TableUtility = require ("utility/tableUtility")

local getValuesToAdd = function(arguments)
  if arguments ~= nil then
    if type(arguments[1]) == "table" and #arguments == 1  then
      return arguments[1]
    end
    return arguments
  end
  return {}
end

local ArrayTable = {}
ArrayTable.__index = function(table, key)
  if rawget(ArrayTable, key) ~= nil then
    return rawget(ArrayTable, key)
  end

  return table.container[key]
end

function ArrayTable:new(...)
  local newArrayTable = {}
  setmetatable(newArrayTable, ArrayTable)

  newArrayTable.container = {}
  for _, value in ipairs(getValuesToAdd(arg)) do
    table.insert(newArrayTable.container, value)
  end

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

function ArrayTable:count(predicate)
  return TableUtility:count(
      self:getContents(),
      function (_, value, source)
        if predicate ~= nil then
          return predicate(value, source)
        end
        return true
      end
  )
end

function ArrayTable:deepClone()
  return ArrayTable:new(
      TableUtility:deepClone(
          self:getContents()
      )
  )
end

function ArrayTable:each(action)
  TableUtility:each(
      self:getContents(),
      function (_, value)
        action(value)
      end
 )
end

function ArrayTable:empty()
  return TableUtility:empty(self:getContents())
end

function ArrayTable:isEmpty()
  return self:empty()
end

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

function ArrayTable:filter(predicate)
  return ArrayTable:new(
      TableUtility:filter(
          self:getContents(),
          function (_, value, source)
            return predicate(value, source)
          end
      )
  )
end

function ArrayTable:first(predicate)
  return TableUtility:first(
      self:getContents(),
      function (_, value, source)
        return predicate(value, source)
      end
  )
end

function ArrayTable:getContents()
  return TableUtility:clone(self.container)
end

function ArrayTable:items()
  return self:getContents()
end

function ArrayTable:contents()
  return self:getContents()
end

function ArrayTable:join(separator)
  return TableUtility:join(self:getContents(), separator)
end

function ArrayTable:map(action)
  return ArrayTable:new(
      TableUtility:map(
          self:getContents(),
          function (_, value, source)
            return action(value, source)
          end
      )
  )
end

function ArrayTable:insert(value)
  table.insert(self.container, value)
end

function ArrayTable:pluck(key_to_pluck)
  return ArrayTable:new(
    TableUtility:pluck(self:getContents(), key_to_pluck)
  )
end

function ArrayTable:reverse()
  return ArrayTable:new(
      TableUtility:reverse(self:getContents())
  )
end

function ArrayTable:sort(sort_func)
  local contents = self:getContents()
  if sort_func ~= nil then
    table.sort(contents, sort_func)
  else
    table.sort(contents)
  end

  return ArrayTable:new(contents)
end

function ArrayTable:sum(accumulator, startingValue)
  return TableUtility:sum(
      self:getContents(),
      accumulator,
      startingValue
  )
end

function ArrayTable:swap(key1, key2)
  if key1 < 1 or key1 > self:size() or key2 < 1 or key2 > self:size() then
    error("Out of bounds: cannot swap " .. key1 .. ", " .. key2)
  end

  local contents = self:getContents()
  TableUtility:swap(contents, key1, key2)
  return ArrayTable:new(contents)
end

return ArrayTable
