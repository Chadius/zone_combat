--[[
Text-Based Turn Based Strategy game

Zones: Everyone in the same Zone can interact.
They are 1D strips, vertically aligned.

Zone 1: Sw  Ji  Se  Mn
Zone 2: Gu1 Gu2 Gu3 Gu4

My graphical displays took too much time and effort to start, so we're going to use a text display.

Movement lets you move between Zones unless an enemy is in the way. It's kind of like American football.

TODO LIST:
ZONES
 Print list of zones
 Make Zone Objects
 Objects can print
 Zones have IDs
 Zones have neighbors
--]]

function main()
   print("HI. Type in something and we'll mirror it.")

   while(b ~= "q") do
      print("Type q to quit.")
      b = io.read()
      print("You typed in " .. b)
   end
   print("quitting.")
end

main()
