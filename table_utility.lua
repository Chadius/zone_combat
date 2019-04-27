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

return TableUtility
