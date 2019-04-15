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
 Make Zone Objects
 Objects can print
 Zones have IDs
 Zones have neighbors
--]]

local Zone = require "zone"

function main()
   print("Zone combat, baby!")

   while(keyboard_input ~= "q") do
      print("Type q to quit.")
      keyboard_input = io.read()
      print("You typed in " .. keyboard_input)

	  if keyboard_input == "p" then
		 print("Printing Zone list:")
		 print("Zone 1")
		 print("Zone 2")
		 print("Zone 3")
		 print("Zone 4")
		 print("Zone 5")
	  end
   end
   print("quitting.")
end

main()
