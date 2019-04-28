function cloneTable(source)
   --[[ Returns a copy of the table, using shallow copies.
   --]]

   local newTable = {}

   for i, item in ipairs(source) do
      table.insert(newTable, item)
   end

   return newTable
end

local TableUtility = {}
function TableUtility:keys(source)
  -- [[ Returns an indexed table where the values are the keys of source.
  -- ]]

  local result = {}
  for key, value in pairs(source) do
     table.insert(result, key)
  end

  return result
end

function TableUtility:keyCount(source)
  -- [[ Returns the number of keys in this indexed table.
  -- ]]

  local count = 0
  for key, value in pairs(source) do
     count = count + 1
  end

  return count
end

function TableUtility:size(source)
  -- Alias for keyCount
  return TableUtility:keyCount(source)
end

function TableUtility:map(source, map_func)
  -- Return a new table, generated by applying func to each value in the source.

  local result = {}

  for key, value in ipairs(source) do
    local mapped_value = map_func(key, value, source)
    table.insert(result, mapped_value)
  end

  return result
end

function TableUtility:filter(source, filter_func)
  -- [[ Return a new table. Call filter_func on each item in the source
  --]] and keep only those that return truthy values.

  local result = {}

  for key, value in ipairs(source) do
    local filter_value = filter_func(key, value, source)
    if filter_value then
      table.insert(result, value)
    end
  end

  return result
end

function TableUtility:pluck(source, key_to_pluck)
  --[[ Return a table of values extracted from the source, based on the key.
  ]]
  local plucker = function(key, value, list)
    return value[key_to_pluck]
  end

  return TableUtility:map(source, plucker)
end

return TableUtility
