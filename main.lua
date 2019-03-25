--[[
Text-Based Turn Based Strategy game

Zones: Everyone in the same Zone can interact.
They are 1D strips, vertically aligned.

Zone 1: Sw  Ji  Se  Mn
Zone 2: Gu1 Gu2 Gu3 Gu4

My graphical displays took too much time and effort to start, so we're going to use a text display.

Movement lets you move between Zones unless an enemy is in the way. It's kind of like American football.

TODO LIST:
Create Text Input Loop
Create Zones
- Zones hold Units
- Print a Zone's contents
Map holds multiple Zones
- Tell Map to print all of the Zones
Units have abbreviations (up to 2 letters)
- Move distance
- Can pass through
- Describe itself
- Check zones for blockades
Add input to move Units
Add Enemy units
- Player can't control them
- Enemy can't skip
- Ask Player unit who they can target
Let Players attack enemies
Check Victory conditions
Enemies can fight back
Check for failure
--]]

function main()
   print("HI")
end

main()
