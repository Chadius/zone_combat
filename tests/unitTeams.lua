lunit = require "libraries/unitTesting/lunitx"
local MapUnit = require "map/mapUnit"

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

local hero
local sidekick
local villain
local citizen
local trashbag

function setup()
  hero = MapUnit:new({
    displayName = "hero",
    affiliation = "player"
  })

  sidekick = MapUnit:new({
    displayName = "sidekick",
    affiliation = "player"
  })

  villain = MapUnit:new({
    displayName = "villain",
    affiliation = "enemy"
  })

  citizen = MapUnit:new({
    displayName = "citizen",
    affiliation = "ally"
  })

  trashbag = MapUnit:new({
    displayName = "trashbag",
    affiliation = "other"
  })
end

-- hero identifies itself on the player affiliation
-- If you make a MapUnit on an unknown affiliation, it raises an error
-- hero considers player and ally units to be friends
-- hero doesn't consider villain a friend
-- villain doesn't consider trashbag a friend

-- units on the playerTeam know the name of their team