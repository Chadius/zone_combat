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
local henchman
local mayor
local citizen
local trashbag
local moneybag

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

  henchman = MapUnit:new({
    displayName = "henchman",
    affiliation = "enemy"
  })

  mayor = MapUnit:new({
    displayName = "mayor",
    affiliation = "ally"
  })

  citizen = MapUnit:new({
    displayName = "citizen",
    affiliation = "ally"
  })

  trashbag = MapUnit:new({
    displayName = "trashbag",
    affiliation = "other"
  })

  moneybag = MapUnit:new({
    displayName = "moneybag",
    affiliation = "other"
  })
end

-- hero identifies itself on the player affiliation
-- If you make a MapUnit on an unknown affiliation, it raises an error

-- hero considers other players and allies friends
-- hero doesn't consider villain or moneybag a friend
-- hero considers hero a friend

-- villain doesn't consider trashbag a friend
-- villain considers henchman a friend
-- villain doesn't consider mayor a friend

-- trashbag doesn't consider anyone a friend, not even moneybag

-- units on the playerTeam know the name of their team