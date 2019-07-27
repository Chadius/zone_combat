local TableUtility = require ("utility/tableUtility")

local TerritoryControlCalculator={}

function TerritoryControlCalculator:whichAffiliationsHaveTheMajorityInThisZone(map, zone)
  local squaddiesInZone = map:getSquaddiesInZone(zone)

  local goodGuyCount = TableUtility:count(
    squaddiesInZone,
    function (_, squaddie, _)
      return squaddie:isPlayerOrAlly()
    end
  )

  local badGuyCount = TableUtility:count(
      squaddiesInZone,
      function (_, squaddie, _)
        return squaddie:isEnemy()
      end
  )

  if goodGuyCount > badGuyCount then
    return {"player", "ally"}
  elseif badGuyCount > goodGuyCount then
    return {"enemy"}
  end

  return {}
end

return TerritoryControlCalculator