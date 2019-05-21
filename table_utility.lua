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

function TableUtility:sum(source, accumulator, start_value)
  --[[ Return a single value by adding each value in the source table.
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
  --[[ Perform the action on each element in the source.

  The action will be a function that accepts 3 parameters: The key, the value, and the source.
  ]]

  for key, value in ipairs(source) do
    action(key, value, source)
  end
end

function TableUtility:listcomp(source, postprocess, filter)
  --[[ Perform a Python-style list comprehension on the source.
  Filter the source with filter as the function.
  Each item that is true will have Postprocess applied.
  ]]

  local filtered_items = TableUtility:filter(source, filter)
  local postprocessed_items = TableUtility:map(filtered_items, postprocess)
  return postprocessed_items
end

function TableUtility:all(source, predicate)
  --[[ Tests all of the items in the source are truthy.
  Predicate is a function that takes the key, value and source as parameters.
  If not provided, Predicate just checks the values to see if they are truthy.
  ]]

  local is_truthy = function(key, value, source)
    if value then
      return true
    else
      return false
    end
  end
  predicate = predicate or is_truthy

  for key, value in ipairs(source) do
    if not predicate(key, value, source) then
      return false
    end
  end

  return true
end

function TableUtility:any(source, predicate)
  --[[ Tests at least one items in the source is truthy.
  Predicate is a function that takes the key, value and source as parameters.
  If not provided, Predicate just checks the values to see if they are truthy.
  ]]

  local is_truthy = function(key, value, source)
    if value then
      return true
    else
      return false
    end
  end
  predicate = predicate or is_truthy

  for key, value in ipairs(source) do
    if predicate(key, value, source) then
      return true
    end
  end

  return false
end

function TableUtility:equivalent(left, right)
  --[[ Given two tables, return true if they are the same size and the elements are equivalent.
  Order matters.
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
  --[[ Swap the values of source[from] and source[to].
  Modifies the source.
  ]]

  -- If from and to are the same, do nothing
  if from == to then return end

  local swap_space = source[from]

  source[from] = source[to]
  source[to] = swap_space
end

function TableUtility:clone(source)
  --[[ Make a shallow copy of the source table.
  ]]
  return cloneTable(source)
end

local function partition(source, low, high, comparison)
  --[[ Assuming source[high] is the pivot,
  rearrange the table so all values less than the pivot are closer to low,
  and all values greater than the pivot are closer to high.
  The pivot will be in its sorted location.
  
  Return the index of the pivot.
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
  --[[ Sort the source table so every element from low to high is sorted
  from smallest to greatest value.
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
  --[[ Sort the source table from least to greatest value.
  source is modified in place.
  
  comparison function is optional. It accepts 2 objects a and b and returns a number.
  -- If negative, then a is less than b
  -- If positive, then a is greater than b
  -- If zero, then a equals b
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
  --[[ Given two tables, return true if they are the same size and the elements are equivalent.
  Order does not matter.
  ]]

  -- Equivalent tables are the same length.
  if TableUtility:size(left) ~= TableUtility:size(right) then
    return false
  end

  sortComparison = sortComparison or nil

  -- Clone the tables, then sort them.
  local leftClone = TableUtility:sort( TableUtility:clone(left), sortComparison )
  local rightClone = TableUtility:sort( TableUtility:clone(right), sortComparison )

  -- Now test the objects are in the same order.
  return TableUtility:equivalent(leftClone, rightClone)
end

function TableUtility:reverse(source)
  --[[ Returns a copy of the source where the first item is the last item of the source.
  ]]

  local newTable = {}

  for i=#source, 0, -1 do
    table.insert(newTable, source[i])
  end

  return newTable
end

function TableUtility:join(source, separator)
  --[[ Prints the contents of a numeric table, using separator to space multiple elements.
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
  -- Returns the first element that satisfies the predicate.

  for key, value in ipairs(source) do
    if predicate(value) then
      return value
    end
  end

  return nil
end
return TableUtility
