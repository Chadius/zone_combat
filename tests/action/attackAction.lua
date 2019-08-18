lunit = require ("libraries/unitTesting/lunitx")
local Action = require("action/action")
local SquaddieFactory = require ("squaddie/squaddieFactory")
local TableUtility = require ("utility/tableUtility")

if _VERSION >= 'Lua 5.2' then
  _ENV = lunit.module('enhanced','seeall')
else
  module( "enhanced", package.seeall, lunit.testcase )
end

function testGetName()
  local newAction = Action:new({
    name = "Head rub"
  })
  assert_equal("Head rub", newAction:getName())
end

function testNoNameMakesError()
  local bad_func = function()
    return Action:new({})
  end

  assert_error("action must have a name", bad_func)
end

function testGetDamage()
  local newAction = Action:new({
    name = "Slappywag",
    damage = 5
  })
  assert_equal(5, newAction:getDamage())
end

function testSquaddieHasAction()
  local hero = SquaddieFactory:buildNewSquaddie({
    displayName = "hero",
    affiliation = "player",
    actions = {
      descriptions = {
        {
          name = "Fist of Justice",
          damage = 5
        }
      }
    }
  })

  local actions = hero:getActions()
  assert_equal(1, TableUtility:size(actions))
  actualAction = actions[1]
  assert_equal("Fist of Justice", actualAction:getName())
  assert_equal(5, actualAction:getDamage())

  local fistAction = hero:getActionByName("Fist of Justice")
  assert_equal("Fist of Justice", fistAction:getName())
  assert_equal(5, fistAction:getDamage())
end

function testRaiseErrorIfActionNameDoesNotExist()
  local hero = SquaddieFactory:buildNewSquaddie({
    displayName = "hero",
    affiliation = "player"
  })

  local bad_func = function()
    hero:getActionByName("Fist of Justice")
  end

  assert_error(
      "No action with that name exists: Fist of Justice",
      bad_func
  )
end

-- Test you create an ActionResult after acting
-- Test you can see the damage from the ActionResult

-- Test that once the zone is under control, you get the extra benefits of Zone Control.