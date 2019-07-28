local TableUtility = require ("utility/tableUtility")

local TerritoryControlCalculator={}

function TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, zone)
  local squaddiesInZone = map:getSquaddiesInZone(zone)

  local goodGuyCount = TableUtility:count(
    squaddiesInZone,
    function (_, squaddie, _)
      if squaddie:isPlayerOrAlly() and squaddie:isAlive() then
        return true
      end
      return false
    end
  )

  local badGuyCount = TableUtility:count(
      squaddiesInZone,
      function (_, squaddie, _)
        if squaddie:isEnemy() and squaddie:isAlive() then
          return true
        end
        return false
      end
  )

  if goodGuyCount > badGuyCount then
    return {"player", "ally"}
  elseif badGuyCount > goodGuyCount then
    return {"enemy"}
  end

  return {}
end

function TerritoryControlCalculator:updateAllZoneControl(map)
  local zoneids = map:getAllZoneIDs()

  TableUtility:each(
      zoneids,
      function(_, zoneid, _)
        local zone = map:getZoneByID(zoneid)
        local currentControllingAffiliations = TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, zone)
        local recordedControllingAffiliations = map:getControllingAffiliationsForZone(zone)

        local updateAffiliation = false
        if TableUtility:isEmpty(currentControllingAffiliations) then
          if TableUtility:all(
              recordedControllingAffiliations,
              function(_, affiliation)
                local squaddiesMatchingAffiliation = map:getSquaddiesByAffiliation(affiliation)
                local livingSquaddies = TableUtility:filter(
                    squaddiesMatchingAffiliation,
                    function(_, squaddie)
                      return squaddie:isAlive()
                    end
                )
                return TableUtility:isEmpty(livingSquaddies)
              end
          ) then
            updateAffiliation = true
          end
        else
          updateAffiliation = true
        end

        if updateAffiliation == false then
          return
        end

        map:updateControllingAffiliationsForZone(zone, currentControllingAffiliations)
      end
  )
end

return TerritoryControlCalculator