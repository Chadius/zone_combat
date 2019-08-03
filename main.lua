--[[
Text-Based Turn Based Strategy game

Zones: Everyone in the same Zone can interact.
They are 1D strips, vertically aligned.

Zone 1: Sw  Ji  Se  Mn
Zone 2: Gu1 Gu2 Gu3 Gu4

My graphical displays took too much time and effort to start, so we're going to use a text display.

Movement lets you move between Zones unless an enemy is in the way. It's kind of like American football.
--]]

local MapFactory = require ("map/mapFactory")

function main()
  print("Zone combat, baby!")

  local map = MapFactory:buildNewMap({
    id = "DA MAP",
    zones = {
      {
        id="A",
        links={{
          to="B",
          bidirectional=true,
        }}
      },
      {
         id="B",
         links={
           {
             to="B",
           },
           {
             to="C",
             bidirectional=true,
           },
         }
      }
    }
  })

  while(keyboard_input ~= "q") do
    print("Type q to quit.")
    keyboard_input = io.read()
    print("You typed in " .. keyboard_input)

    if keyboard_input == "p" then
      print("Printing Zone list:")
      for index, z in ipairs(map.zones) do
        print (string.format("#%d %s", index, tostring(z)))
      end
    end

    if keyboard_input == "n" then
      print("Printing Zone links:")
      map:describeZones()
    end

  end
  print("quitting.")
end

main()
