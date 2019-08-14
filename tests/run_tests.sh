#!/usr/bin/env bash
lua-5.1 ./tests/map.lua && lua-5.1 ./tests/tableUtility.lua && lua-5.1 ./tests/squaddieMovement.lua && \
lua-5.1 ./tests/squaddieTurn.lua && lua-5.1 ./tests/squaddieAffiliation.lua && lua-5.1 ./tests/territoryControl.lua && \
lua-5.1 ./tests/squaddieHealthAndDeath.lua && lua-5.1 ./tests/validAction.lua && lua-5.1 ./tests/mission/missionPhase.lua && \
lua-5.1 ./tests/action/attackAction.lua