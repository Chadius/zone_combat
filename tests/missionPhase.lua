lunit = require "libraries/unitTesting/lunitx"
local Map = require ("map/map")
local Squaddie= require "squaddie/squaddie"
local ActionResolver = require "combatLogic/ActionResolver"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

--[[ TODO NOTE
Mission has:
- Map
- Player (hero & sidekick)
- Enemy (villain & henchman)
- Ally (mayor & citizen)
- Other (trashbag & trashbag2)

PhaseTracker - Object with state

testPlayerPhaseFirst
testPlayerEndPhaseAfterAllPlayersFinishTurn

testAllyPhaseAfterPlayerEndUpkeepFinish

testAllyPhasesSkippedIfNoAlliesInMap

testAllyPhaseSkippedIfAllAlliesKilled

testSpawningAllyMisMissionMeansAllyPhaseWillOccur
]]

local mission
local map
local firstAvenue
local secondAvenue

local hero
local sidekick
local villain
local henchman
local mayor
local citizen
local trashbag
local moneybag

function setup()
  map = Map:new({
    id = "downtown",
    zones = {
      {
        id = "firstAvenue",
        links = {
          { to = "secondAvenue" }
        }
      },
      {
        id = "secondAvenue",
        links = {
          { to = "firstAvenue" }
        }
      }
    }
  })
  firstAvenue = map:getZoneByID("firstAvenue")
  secondAvenue = map:getZoneByID("secondAvenue")

  -- TODO
  mission = Mission:new(map)

  hero = Squaddie:new({
    displayName = "hero",
    affiliation = "player"
  })

  sidekick = Squaddie:new({
    displayName = "sidekick",
    affiliation = "player"
  })

  villain = Squaddie:new({
    displayName = "villain",
    affiliation = "enemy"
  })

  henchman = Squaddie:new({
    displayName = "henchman",
    affiliation = "enemy"
  })

  mayor = Squaddie:new({
    displayName = "mayor",
    affiliation = "ally"
  })

  citizen = Squaddie:new({
    displayName = "citizen",
    affiliation = "ally"
  })

  trashbag = Squaddie:new({
    displayName = "trashbag",
    affiliation = "other"
  })

  moneybag = Squaddie:new({
    displayName = "moneybag",
    affiliation = "other"
  })
end
