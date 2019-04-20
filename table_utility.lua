function cloneTable(source)
   --[[ Returns a copy of the table, using shallow copies.
   --]]

   local newTable = {}

   for i, item in ipairs(source) do
      table.insert(newTable, item)
   end

   return newTable
end
