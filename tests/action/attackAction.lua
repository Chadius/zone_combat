lunit = require ("libraries/unitTesting/lunitx")
local Action = require("action/action")
local SquaddieFactory = require ("squaddie/squaddieFactory")
local TableUtility = require ("utility/tableUtility")

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

function test_get_name()
  local newAction = Action:new({
    name = "Head rub"
  })
  assert_equal("Head rub", newAction:getName())
end

function test_no_name_makes_error()
  local bad_func = function()
    return Action:new({})
  end

  assert_error("action must have a name", bad_func)
end

function test_get_damage()
  local newAction = Action:new({
    name = "Slappywag",
    damage = 5
  })
  assert_equal(5, newAction:getDamage())
end

-- Test you can give an Action to a Squaddie
function test_squaddie_has_action()
  local hero = SquaddieFactory:buildNewSquaddie({
    displayName = "hero",
    affiliation = "player",
    actions = {
      {
        name = "Fist of Justice",
        damage = 5
      }
    }
  })

  local actions = hero:getActions()
  assert_equal(1, TableUtility:size(actions))
  actualAction = actions[1]
  assert_equal("Fist of Justice", actualAction:getName())
  assert_equal(5, actualAction:getDamage())
end

-- Test you can target unfriendly affiliations with the Action

-- Test you create an ActionResult after acting
-- Test you can see the damage from the ActionResult

-- Test that once the zone is under control, you get the extra benefits of Zone Control.