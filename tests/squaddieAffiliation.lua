lunit = require "libraries/unitTesting/lunitx"
local Squaddie = require "squaddie/squaddie"
local TableUtility = require ("utility/tableUtility")

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

function testHeroIdentifyAffiliation ()
  -- hero identifies itself on the player affiliation
  assert_equal("player", hero:getAffilation())
  -- If you make a SquaddieOnMap on an unknown affiliation, it raises an error
  local badAffiliation = function()
    Squaddie:new({
      displayName = "badAffiliation",
      affiliation = "bogus"
    })
  end

  assert_error_match(
      "Made a SquaddieOnMap with a bad affiliation. That's bad.",
      "Affiliation bogus does not exist. Valid affiliations are player, ally, enemy, other",
      badAffiliation
  )
end

function testPlayerFriends()
  -- hero considers other players and allies friends
  assert_true(hero:isFriendUnit(sidekick))
  assert_true(hero:isFriendUnit(mayor))
  -- hero doesn't consider villain or moneybag a friend
  assert_false(hero:isFriendUnit(villain))
  assert_false(hero:isFriendUnit(moneybag))
  -- hero considers hero a friend
  assert_true(hero:isFriendUnit(hero))
end

function testVillainFriends()
  -- villain doesn't consider trashbag a friend
  assert_false(villain:isFriendUnit(trashbag))
  -- villain considers henchman a friend
  assert_true(villain:isFriendUnit(henchman))
  -- villain doesn't consider mayor a friend
  assert_false(villain:isFriendUnit(mayor))
end

function testOtherFriends()
  -- trashbag doesn't consider anyone a friend, not even moneybag
  assert_false(trashbag:isFriendUnit(hero))
  assert_false(trashbag:isFriendUnit(sidekick))
  assert_false(trashbag:isFriendUnit(villain))
  assert_false(trashbag:isFriendUnit(henchman))
  assert_false(trashbag:isFriendUnit(mayor))
  assert_false(trashbag:isFriendUnit(citizen))
  assert_false(trashbag:isFriendUnit(moneybag))

  -- But trashbag considers itself a friend
  assert_true(trashbag:isFriendUnit(trashbag))
end

function testAllyFriends()
  assert_true(mayor:isFriendUnit(mayor))
  assert_true(mayor:isFriendUnit(citizen))

  assert_true(mayor:isFriendUnit(hero))
  assert_true(mayor:isFriendUnit(sidekick))

  assert_false(mayor:isFriendUnit(villain))
  assert_false(mayor:isFriendUnit(henchman))

  assert_false(mayor:isFriendUnit(trashbag))
  assert_false(mayor:isFriendUnit(moneybag))
end

function testAffiliationOrder()
  assert_true(
      TableUtility:equivalent(
          Squaddie:getAffilationOrder("player"),
          {
            "player",
            "ally",
            "enemy",
            "other"
          }
      )
  )

  print (TableUtility:join(Squaddie:getAffilationOrder("ally")))
end