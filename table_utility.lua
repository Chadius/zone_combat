--[[ Utility library to add functional programming for Tables, and reduce for loops in general.

These functions work on all tables:
all()
any()
clone()
each()
equaivalentSet()
filter()
keyCount()
keys()
listcomp()
map()
pluck()
size()
sum()

These functions only work on indexed tables (keys are integers starting with 1, table is ordered)
equaivalent()
first()
join()
reverse()
sort()
swap()

These functions only work on Associative Tables (keys are arbitraty, table is unordered)
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
  for key, value in pairs(source) do
     table.insert(result, key)
  end

  return result
end

function TableUtility:keyCount(source)
  --[[ Returns the number of keys in this indexed table.
  Args:
    source(table)
    
  Returns:
    A number.
  ]]

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
  local plucker = function(key, value, list)
    return value[key_to_pluck]
  end

  return TableUtility:map(source, plucker)
end

function TableUtility:sum(source, accumulator, start_value)
  --[[ Accumulate value based on each value in the source table.
    Args:
      source(table)
      accumulator(function, optional): Signature(sum, value). The accumulator will 
        transofrm the value as necessary and apply to the sum.
        The default function is numeric addition.
      start_value(object, optional, default=""): Start value to begin adding/
        Default is 0.
  ]]
  accumulator = accumulator or nil
  local sum = start_value
  if not accumulator then
    sum = 0
  end

  for key, value in ipairs(source) do
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

  local is_truthy = function(key, value, source)
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

  local is_truthy = function(key, value, source)
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

  local equivalentComp = function (key, value, source)
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

local function partition(source, low, high, comparison)
  --[[ Helper function for quicksort() that paritions the table.
  Assuming source[high] is the pivot, rearrange the table
  so all values less than the pivot are closer to low,
  and all values greater than the pivot are closer to high.
  The pivot will be moved to its final, sorted location.

  Args:
    source(table): The table has ordered indexed keys. This will be modified.
    low(integer): Index of the start of the subtable to partition.
    high(integer): Index of the end of the subtable to partition.
    comparison(function): Function takes two parameters.
      If the first parameter is less than the other, returns -1.
      Otherwise return something besides -1.
  Returns:
    The sorted index of the pivot.
  ]]

  -- The pivot value is the last item on the table.
  local pivot_value = source[high]

  -- Track the pivot's final index, starting at low.
  local sorted_pivot_index = low

  -- Look at each element from the low index to high, skipping the pivot.
  for index=low, high - 1 do
    -- If the element is less than the pivot, then
    if comparison(source[index], pivot_value) < 0 then
      -- Swap this element with the pivot's final index.
      TableUtility:swap(source, index, sorted_pivot_index)
      -- Increment the pivot's final index, since we know it isn't here.
      sorted_pivot_index = sorted_pivot_index + 1
    end
  end

  -- Swap the pivot to its final index and return the index.
  TableUtility:swap(source, sorted_pivot_index, high)
  return sorted_pivot_index
end

local function quicksort(source, low, high, comparison)
  --[[ Helper function for sort().
  The table will be modified so source[low] is the smallest value and source[high]
  is the greatest value in the table. The next value in the table is never
  less than the previous.

  Args:
    source(table): The table has ordered indexed keys. This will be modified.
    low(integer): Index of the start of the subtable to partition.
    high(integer): Index of the end of the subtable to partition.
    comparison(function): Function takes two parameters.
      If the first parameter is less than the other, returns -1.
      Otherwise return something besides -1.
  Returns:
    nil
  ]]

  -- If there are no items to sort, stop
  if low >= high then return end

  -- Partition the table and get the pivot's location.
  local pivot_location = partition(source, low, high, comparison)

  -- The pivot has been sorted correctly, so recurse and sort the two subtables.
  quicksort(source, low, pivot_location - 1, comparison)
  quicksort(source, pivot_location + 1, high, comparison)
end

function TableUtility:sort(source, comparison)
  --[[ sort the values in the source table from smallest to greatest, based on a comparison.
  If two items have the same value, the order is arbitrary.

  Args:
    source(table): The table has ordered indexed keys. This will be modified.
    comparison(function): Function takes two parameters.
      If the first parameter is less than the other, returns -1.
      If the first parameter is greater than the other, returns 1.
      Otherwise return 0.
  Returns:
    source, now properly sorted
  ]]

  local defaultComparison = function (a,b)
    if type(a) ~= type(b) then return 0 end

    if a < b then
      return -1
    elseif a > b then
      return 1
    end
    return 0
  end

  comparison = comparison or defaultComparison

  -- Execute QuickSort, starting from the start to the end of the table.
  quicksort(source, 1, #source, comparison)
  
  return source
end

function TableUtility:equivalentSet(left, right, sortComparison)
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
    sortComparison(function, optional): If left and right are numerically indexed tables,
      you can supply a function to help speed this function up. See sort() for an example.
  Returns:
    A boolean.
  ]]

  -- Equivalent tables are the same length.
  if TableUtility:size(left) ~= TableUtility:size(right) then
    return false
  end

  -- Indexed tables don't care about their keys, so we'll have to sort their values before comparing them.
  if #left > 0 then 
    -- Clone the tables, then sort them.
    local leftClone = TableUtility:sort( TableUtility:clone(left), sortComparison )
    local rightClone = TableUtility:sort( TableUtility:clone(right), sortComparison )

    -- Now test the objects are in the same order.
    return TableUtility:equivalent(leftClone, rightClone)
  end
  
  -- Unordered tables use unique keys, so we can compare them directly.
  return TableUtility:equivalent(left, right)
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
  --[[ Creates a string showing the values of the ordered source table and a separator.
  Args:
    source(table): The table has numeric ordered indecies.
    separator(string, optional, default=","): Each value will be separated by this string.
      If there are 0 or 1 values the separator is not used.
  ]]
  separator = separator or ","

  -- If it's empty, return an empty string
  if #source == 0 then return "" end

  -- If there is only 1 item in the array, just return that
  if #source == 1 then return tostring(source[1]) end

  -- Otherwise append the value and separator combo.
  local joinedStr = ""
  for key, value in ipairs(source) do
    joinedStr = joinedStr .. value
    if key < #source then
      joinedStr = joinedStr .. separator
    end
  end
  return joinedStr
end

function TableUtility:first(source, predicate)
  --[[ Finds the first element in the ordered table that passes a predicate function.
  This function stops as soon as one item is tested truthy.

  Args:
    source(table): A table with ordered indecies.
    predicate(function): This function takes the parameters (value).
      It should return true or false.
  Returns:
    An object in the source that satisfies the predicate.
    nil otherwise.
  ]]
  -- Returns the first element that satisfies the predicate.

  for key, value in ipairs(source) do
    if predicate(value) then
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
return TableUtility
