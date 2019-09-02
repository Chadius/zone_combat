--[[ Utility library to add functional programming for Tables, and reduce for loops in general.

These functions work on all tables. If the table is an array the order will be respected:
all()
any()
clone()
contains()
containsKey()
count()
deepClone()
each()
empty()
equivalentSet()
filter()
hasKey()
isEmpty()
isOrdered()
keys()
listcomp()
map()
pluck()
size()
sum()
update()
values()

These functions only work on arrays (ordered tables whose keys are integers starting with 1, isOrdered returns true)
append()
equivalent()
first()
join()
reverse()
swap()

These functions only work on dictionaries (a table where keys are unordered)
toOrderedTable()
]]

local TableUtility = {}
function TableUtility:getIterator(source)
  --[[ Return the correct iterator for the given source.

  Args:
    source(table)

  Returns:
    A function.
  ]]
  local iterator = pairs
  if #source > 0 then iterator = ipairs end
  return iterator
end
function TableUtility:keys(source)
  --[[ Return a table containing the keys from source.
  Args:
    source(table)

  Returns:
    indexed table. Each value represents a key from source. Order is arbitrary.
  ]]

  local result = {}
  for key, _ in pairs(source) do
     table.insert(result, key)
  end

  return result
end

function TableUtility:keyCount(source, filter_func)
  local count = 0
  local tableToCount = source

  if filter_func ~= nil then
    tableToCount = TableUtility:filter(source, filter_func)
  end

  for _, _ in pairs(tableToCount) do
     count = count + 1
  end

  return count
end

function TableUtility:size(source, filter_func)
  return TableUtility:keyCount(source, filter_func)
end

function TableUtility:count(source, filter_func)
  return TableUtility:keyCount(source, filter_func)
end

function TableUtility:map(source, map_func)
  --[[ Apply some task to each item in the source table, creating a new table in the process.
  Args:
    source(table): If this is an indexed table, the order of the mapped table is preserved.
    map_func(function): Should accept the parameters (key, value, source).
      The function will get each key/value pair in the source, as well as a copy of the source.
      The function's return value will be added to the new table, using the same key.

  Returns:
    A new table.
  ]]

  local result = {}
  local iterator = TableUtility:getIterator(source)

  for key, value in iterator(source) do
    local mapped_value = map_func(key, value, source)
    result[key] = mapped_value
  end

  return result
end

function TableUtility:filter(source, filter_func)
  --[[ Return a new table containing key/value pairs that passed a test.
  Args:
    source(table): If this is an indexed table, the order of the mapped table is preserved.
    filter_func(function): Should accept the parameters (key, value, source).
      The function will get each key/value pair in the source, as well as a copy of the source.
      If the function returns a truthy value, the key/value pair will be added to the new table.

  Returns:
    A new table.
  ]]

  local result = {}
  local iterator = TableUtility:getIterator(source)
  for key, value in iterator(source) do
    local filter_value = filter_func(key, value, source)
    if filter_value then
      if iterator == ipairs then
        table.insert(result, value)
      else
        result[key] = value
      end
    end
  end

  return result
end

function TableUtility:pluck(source, key_to_pluck)
  --[[ Return a new table containing only the subkey/value pairs from each value in the source.
  Args:
    source(table): If this is an indexed table, the order of the mapped table is preserved.
      Each value is assumed to be an unordered table.
    key_to_pluck(object): The desired key to extract.
  Returns:
    A new table.
  ]]
  --[[ Return a table of values extracted from the source, based on the key.
  ]]
  local plucker = function(_, value)
    return value[key_to_pluck]
  end

  return TableUtility:map(source, plucker)
end

function TableUtility:sum(source, accumulator, start_value)
  --[[ Accumulate value based on each value in the source table.
    Args:
      source(table)
      accumulator(function, optional): Signature(sum, value). The accumulator will
        transform the value as necessary and apply to the sum.
        The default function is numeric addition.
      start_value(object, optional, default=""): Start value to begin adding/
        Default is 0.
  ]]
  accumulator = accumulator or nil
  local sum = start_value
  if not accumulator then
    sum = 0
  end

  local iterator = TableUtility:getIterator(source)
  for _, value in iterator(source) do
    if accumulator then
      sum = accumulator(sum, value)
    else
      sum = sum + value
    end
  end

  return sum
end

function TableUtility:each(source, action)
  --[[ Perform an action on each item in the source table.
  Args:
    source(table): If the table responds to the # operator, order of keys is preserved.
    action(function): The function gets 3 parameters: (key, value, source).
  Returns:
    nil
  ]]

  local iterator = TableUtility:getIterator(source)

  for key, value in iterator(source) do
    action(key, value, source)
  end
end

function TableUtility:listcomp(source, postprocess, filter)
  --[[ In Python, a list comprehension filters a list, then processes the results into another list.
  This function mimics the behavior against an array.
  Args:
    source(table): If the table responds to the # operator, order of elements is preserved.
    postprocess(function): Should accept the parameters (key, value, source).
      This is passed to TableUtility:map() as the map_func.
    filter(function): Should accept the parameters (key, value, source).
      This is passed to TableUtility:filter() as the filter_func.

  Returns:
    A table
  ]]

  local filtered_items = TableUtility:filter(source, filter)
  local postprocessed_items = TableUtility:map(filtered_items, postprocess)
  return postprocessed_items
end

function TableUtility:all(source, predicate)
  --[[ Test to see if all of the itmes in the source Table are truthy, based on a predicate.
  This function stops as soon as one item is tested falsy.

  Args:
    source(table): If this is an indexed table, the order of the mapped table is preserved.
    predicate(function, optional): This function takes the parameters (key, value, source).
      It should return true or false.
      The default function tests if the value is truthy.
  Returns:
    A boolean.
  ]]

  local is_truthy = function(_, value)
    if value then
      return true
    else
      return false
    end
  end
  predicate = predicate or is_truthy
  local iterator = TableUtility:getIterator(source)

  for key, value in iterator(source) do
    if not predicate(key, value, source) then
      return false
    end
  end

  return true
end

function TableUtility:any(source, predicate)
  --[[ Test to see if at least one item in the source Table is truthy, based on a predicate.
  This function stops as soon as one item is tested truthy.

  Args:
    source(table): If this is an indexed table, the order of the mapped table is preserved.
    predicate(function, optional): This function takes the parameters (key, value, source).
      It should return true or false.
      The default function tests if the value is truthy.
  Returns:
    A boolean.
  ]]

  local is_truthy = function(_, value)
    if value then
      return true
    else
      return false
    end
  end
  predicate = predicate or is_truthy
  local iterator = TableUtility:getIterator(source)

  for key, value in iterator(source) do
    if predicate(key, value, source) then
      return true
    end
  end

  return false
end

function TableUtility:equivalent(left, right)
  --[[ Given two numerically indexed tables, return true if:
  -- left and right are the same size
  -- left and right have the same keys
  -- For any given key, left[key] is equivalent to right[key].
  ---- Both values are the same type.
  ---- Tables are recursed to make sure they are equivalent.
  ---- Other object types use the == operator.

  Args:
    left(table): Must be numerically indexed (The # operator works on them)
    right(table): Must be numerically indexed (The # operator works on them)
  Returns:
    A boolean.
  ]]

  -- Equivalent tables are the same length.
  if TableUtility:size(left) ~= TableUtility:size(right) then
    return false
  end

  local equivalentComp = function (key, value)
    -- Get the target value
    local target_value = right[key]

    -- Make sure the values are the same type
    if type(value) ~= type(target_value) then return false end

    -- If they are tables, recurse
    if type(value) == 'table' then
      return TableUtility:equivalent(value, target_value)
    else
      return value == right[key]
    end
  end

  local matching = TableUtility:map(left, equivalentComp)
  return TableUtility:all(matching)
end

function TableUtility:swap(source, from, to)
  --[[ Swap the values of source[from] and source[to]. Modifies the source.
  Args:
    source(table): Table should have ordered keys.
    from(integer > 0): Index to start the swap from.
    to(integer > 0): Index to swap with.
  Returns:
    nil
  ]]

  -- If from and to are the same, do nothing
  if from == to then return end

  local swap_space = source[from]

  source[from] = source[to]
  source[to] = swap_space
end

function TableUtility:clone(source)
  --[[ Makes a shallow copy of the source table.

  Args:
    source(table): If this is an indexed table, the clone's order of the mapped table is preserved.
  Returns:
    A table.
  ]]

  local newTable = {}
  local iterator = TableUtility:getIterator(source)
  for key, value in iterator(source) do
    newTable[key] = value
  end

  return newTable
end

function TableUtility:deepClone(source)
  --[[ Makes a deep copy of the source table.

  Args:
    source(table): If this is an indexed table, the clone's order of the mapped table is preserved.
  Returns:
    A table.
  ]]

  local newTable = {}
  local iterator = TableUtility:getIterator(source)
  for key, value in iterator(source) do
    if type(value) == "table" then
      newTable[key] = TableUtility:deepClone(value)
    else
      newTable[key] = value
    end
  end

  return newTable
end

function TableUtility:equivalentSet(left, right)
  --[[ Given two tables, return true if:
  -- left and right are the same size
  -- left and right have the same keys

  -- For any given key, the value of left[key] can be found in right.
  ---- Both values are the same type.
  ---- Tables are recursed to make sure they are equivalent.
  ---- Other object types use the == operator.
  Notice that order doesn't matter.

  Args:
    left(table)
    right(table)
  Returns:
    A boolean.
  ]]

  -- Equivalent tables are the same length.
  if TableUtility:size(left) ~= TableUtility:size(right) then
    return false
  end

  -- Track all of the right keys that are accounted for
  local right_keys_marked = {}
  TableUtility:each(right, function(key) right_keys_marked[key] = false end)

  -- For each key in left
  for _, leftValue in pairs(left) do
    -- If all right keys have been marked before the left keys were examined, return false.
    if TableUtility:all(right_keys_marked, function(_, value) return value == true end) then
      return false
    end

    for rightKey, _ in pairs(right_keys_marked) do
      -- Only look in unmarked right keys
      if not right_keys_marked[rightKey] then
        local rightValue = right[rightKey]
        local equalValue = false
        --- If the left value and right value have different types, continue to the next right key
        if type(leftValue) == type(rightValue) then
          -- If they are tables, recurse
          if type(leftValue) == 'table' then
            equalValue = TableUtility:equivalentSet(leftValue, rightValue)
          else
            equalValue = (leftValue == rightValue)
          end
        end

        --- If they are equal, mark the right key.
        if equalValue then
          right_keys_marked[rightKey] = true
        end
      end
    end
  end

  -- See if there are any unmarked right keys. If so, return false
  if TableUtility:any(right_keys_marked, function(_, value) return value == false end) then
    return false
  end
  return true
end

function TableUtility:reverse(source)
  --[[ Creates a copy of the source table where the indecies are in the opposite order.
  Args:
    source(table): Table must have integer indecies starting from 1.
  Returns:
    A new table.
  ]]

  local newTable = {}

  for i=#source, 0, -1 do
    table.insert(newTable, source[i])
  end

  return newTable
end

function TableUtility:join(source, separator)
  --[[ Creates a string showing the values of the source table and a separator.
  If the source has ordered keys, the keys are not shown.
  Otherwise the key/value pairs are shown as key:value
  Args:
    source(table)
    separator(string, optional, default=","): Each value will be separated by this string.
      If there are 0 or 1 values the separator is not used.
  Return:
    A string.
  ]]
  separator = separator or ","

  -- If it's empty, return an empty string
  if TableUtility:size(source) == 0 then return "" end

  local iterator = TableUtility:getIterator(source)

  local joinedStr = ""
  local toString = function (value)
    if type(value) == "boolean" then
      if value then
        return "true"
      else
        return "false"
      end
    end
    return value
  end

  if iterator == ipairs then
    -- If there is only 1 item in the array, just return that
    if #source == 1 then return tostring(source[1]) end

    -- Otherwise append the value and separator combo.
    for key, value in ipairs(source) do
      local valueStr = toString(value)
      joinedStr = joinedStr .. valueStr
      if key < #source then
        joinedStr = joinedStr .. separator
      end
    end
    return joinedStr
  end

  local first_pair = true
  for key, value in pairs(source) do
    if not first_pair then
      joinedStr = joinedStr .. separator
    end
    joinedStr = joinedStr .. toString(key) .. ":" .. toString(value)
    first_pair = false
  end
  return joinedStr
end

function TableUtility:first(source, predicate)
  --[[ Finds the first element in the ordered table that passes a predicate function.
  This function stops as soon as one item is tested truthy.

  Args:
    source(table): A table with ordered indecies.
    predicate(function): This function takes the parameters (key, value, source).
      It should return true or false.
  Returns:
    An object in the source that satisfies the predicate.
    nil otherwise.
  ]]
  -- Returns the first element that satisfies the predicate.

  for key, value in ipairs(source) do
    if predicate(key, value, source) then
      return value
    end
  end

  return nil
end
function TableUtility:toOrderedTable(source)
  --[[ Unfolds an unordered table. Each key: value pair becomes an item in a new ordered list.
  Args:
    source(table)
  Returns:
    A new table.
  ]]

  -- If the table is already ordered, return the table
  if #source > 0 then return source end

  local orderedTable = {}
  for key, value in pairs(source) do
    local newPair = {}
    newPair[key] = value
    table.insert(orderedTable, newPair)
  end
  return orderedTable
end

function TableUtility:contains(source, target)
  --[[ Sees if one of the values equals the target.
  Args:
    source(table)
    target(object)
  Returns:
    A boolean.
  ]]
  return TableUtility:any(
      source,
      function(_, value)
        -- Make sure the values are the same type
        if type(value) ~= type(target) then return false end

        -- If they are tables, use equivalent to test.
        if type(value) == 'table' then
          return TableUtility:equivalent(value, target)
        else
          return value == target
        end
      end
  )
end

function TableUtility:empty(source)
  --[[ Returns true if the source table is empty.
  Args:
    source(table)
  Returns:
    boolean
  ]]
  return TableUtility:size(source) <= 0
end

function TableUtility:isEmpty(source)
  return TableUtility:empty(source)
end

function TableUtility:max(source, comparison)
  local currentMax

  TableUtility:each(
      source,
      function(_, currentValue, _)
        if currentMax == nil then
          currentMax = currentValue
          return
        end

        local isGreater = false
        if comparison == nil then
          isGreater = (currentValue > currentMax)
        else
          isGreater = comparison(currentMax, currentValue)
        end

        if isGreater then
          currentMax = currentValue
        end
      end
  )

  return currentMax
end

function TableUtility:min(source, comparison)
  local currentMin

  TableUtility:each(
      source,
      function(_, currentValue, _)
        if currentMin == nil then
          currentMin = currentValue
          return
        end

        local isLessThan = false
        if comparison == nil then
          isLessThan = (currentValue < currentMin)
        else
          isLessThan = comparison(currentValue, currentMin)
        end

        if isLessThan then
          currentMin = currentValue
        end
      end
  )

  return currentMin
end

function TableUtility:keyOf(source, targetValue)
  local iterator = TableUtility:getIterator(source)

  for key, value in iterator(source) do
    if value == targetValue then
      return key
    end
  end

  return nil
end

function TableUtility:values(source)
  local result = {}
  for _, value in pairs(source) do
    table.insert(result, value)
  end

  return result
end

function TableUtility:hasKey(source, desiredKey)
  return TableUtility:any(
      source,
      function(sourceKey)
        return sourceKey == desiredKey
      end
  )
end

function TableUtility:containsKey(source, desiredKey)
  return TableUtility:hasKey(source, desiredKey)
end

function TableUtility:append(firstTable, ...)
  if TableUtility:isOrdered(firstTable) ~= true then
    error("First argument must be an ordered table (numerical index)")
  end

  local copiedTable = {}

  local addToCopiedTable = function(_, tableToAppend)
    if TableUtility:isOrdered(tableToAppend) then
      TableUtility:each(
          tableToAppend,
          function(_, value)
            table.insert(copiedTable, value)
          end
      )
    else
      table.insert(copiedTable, tableToAppend)
    end
  end

  addToCopiedTable(_, firstTable)

  TableUtility:each(
      arg,
      addToCopiedTable
  )

  return copiedTable
end

function TableUtility:isOrdered(source)
  return TableUtility:empty(source) == true or TableUtility:getIterator(source) == ipairs
end

function TableUtility:update(firstTable, ...)
  local combinedTable = {}

  local setKeyValuePairs = function(_, newTable)
    for key, value in pairs(newTable) do
      combinedTable[key] = value
    end
  end

  setKeyValuePairs(_, firstTable)
  TableUtility:each(
      arg,
      setKeyValuePairs
  )

  return combinedTable
end

return TableUtility
