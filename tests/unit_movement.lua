lunit = require "libraries/unitTesting/lunitx"

if _VERSION >= 'Lua 5.2' then
    _ENV = lunit.module('enhanced','seeall')
else
    module( "enhanced", package.seeall, lunit.testcase )
end

local map = {}

function setup()
    --[[Set up a forest glade, with a pond surrounded by 3 trails.
    You can walk between the trails, swim across the pond,
    of fly directly from the start to the end.
    ]]
    map = Map:new({
        id = "forest glade",
        zones = {
            {
                id="trail1",
                neighbors={
                    { to="trail2" },
                    {
                        to="trail3",
                        travelMethods={"fly"}
                    },
                    {
                        to="pond",
                        travelMethods={"swim"}
                    },
                }
            },
            {
                id="trail2",
                neighbors={
                    { to="trail3" }
                }
            },
            {
                id="trail3",
                neighbors={
                    {
                        to="pond",
                        travelMethods={"swim"}
                    }
                }
            },
            { id="pond" }
        }
    })
end

function teardown()
end

