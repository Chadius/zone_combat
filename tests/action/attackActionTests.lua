lunit = require ("libraries/unitTesting/lunitx")
local Action = require("action/action")
local ActionFactory = require("action/actionFactory")
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
  local newAction = ActionFactory:buildNewAction({
    name = "Slappywag",
    effects = {
      default = {
        {
          damage = 5
        }
      }
    }
  })
  assert_equal(5, newAction:getDefaultDamage())
end

function testSquaddieHasAction()
  local hero = SquaddieFactory:buildNewSquaddie({
    displayName = "hero",
    affiliation = "player",
    actions = {
      descriptions = {
        {
          name = "Fist of Justice",
          effects = {
            default = {
              {
                damage = 5
              }
            }
          }
        }
      }
    }
  })

  local actions = hero:getActions()
  assert_equal(1, TableUtility:size(actions))
  actualAction = actions[1]
  assert_equal("Fist of Justice", actualAction:getName())
  assert_equal(5, actualAction:getDefaultDamage())

  local fistAction = hero:getActionByName("Fist of Justice")
  assert_equal("Fist of Justice", fistAction:getName())
  assert_equal(5, fistAction:getDefaultDamage())
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

function testAddActionByObject()
  local newAction = ActionFactory:buildNewAction({
    name = "Fist of Justice",
    effects = {
      default = {
        {
          damage = 5
        }
      }
    }
  })

  local hero = SquaddieFactory:buildNewSquaddie({
    displayName = "hero",
    affiliation = "player",
    actions = {
      objects = {
        newAction
      }
    }
  })

  local fistAction = hero:getActionByName("Fist of Justice")
  assert_equal("Fist of Justice", fistAction:getName())
  assert_equal(5, fistAction:getDefaultDamage())
end

function testInstakillAction()
  local instakillAction = ActionFactory:buildNewAction({
    name = "Nuke from Orbit",
    effects = {
      default = {
        {
          instakill = true
        }
      }
    }
  })

  assert_true(instakillAction:hasDefaultEffect("instakill"))
  assert_equal(nil, instakillAction:getDefaultDamage())
  assert_equal(nil, instakillAction:getDefaultDamageDealt())
end

function testDefaultActionEffects()
  local damageDealingAction = ActionFactory:buildNewAction({
    name = "Fist of Justice",
    effects = {
      default = {
        {
          damage = 5
        }
      }
    }
  })

  local attackEffects = damageDealingAction:getDefaultEffects()
  assert_equal(1, TableUtility:size(attackEffects))
  actualDamageDealingAffect = attackEffects[1]
  assert_equal(5, actualDamageDealingAffect:getDamageDealt())

  local instakillAction = ActionFactory:buildNewAction({
    name = "Nuke from Orbit",
    effects = {
      default = {
        {
          instakill = true
        }
      }
    }
  })
  attackEffects = instakillAction:getDefaultEffects()
  assert_equal(1, TableUtility:size(attackEffects))
  actualInstakillEffect = attackEffects[1]
  assert_true(actualInstakillEffect:isInstakill())
end

function testAttackActionInstakillsWhenInControl()
  local finishingBlow = ActionFactory:buildNewAction({
    name = "Finishing Blow",
    effects = {
      default = {
        {
          damage = 5
        }
      },
      inControl = {
        {
          instakill = true
        }
      }
    }
  })

  attackEffects = finishingBlow:getInControlEffects()
  assert_equal(1, TableUtility:size(attackEffects))
  actualInstakillEffect = attackEffects[1]
  assert_true(actualInstakillEffect:isInstakill())
end