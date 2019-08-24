--[[ Maps hold multiple Zones.
--]]
local ZoneControlRecord = require("map/ZoneControlRecord")
local TableUtility = require ("utility/tableUtility")

local Map={}
Map.__index = Map

function Map:new(args)
  --[[ Create a new Map.
  --]]
  local newMap = {}
  setmetatable(newMap,Map)
  newMap.id = args.id

  newMap.zone_by_id = {}
  newMap.zone_affiliation_control_by_zoneid = {}
  newMap.squaddieInfoByID = {}

  if newMap.id == nil then
    error("Map needs an id")
  end

  newMap:checkInvariants()
  return newMap
end

function Map:checkInvariants()
  -- Delete any invalid links.
  self:VerifyZoneLink()
end

function Map:addZone(newZone)
  self.zone_by_id[newZone.id] = newZone
  self.zone_affiliation_control_by_zoneid[newZone.id] = ZoneControlRecord:new()
  self:checkInvariants()
end

function Map:connectTwoZonesWithLink(fromZone, toZone, movementCost, travelMethods)
  local modifiedZone = fromZone:addLink(
      toZone.id,
      movementCost,
      travelMethods
  )
  self.zone_by_id[fromZone.id] = modifiedZone
end

function Map:VerifyZoneLink()
  --[[ Deletes all invalid Zone links
  Args:
    none
  Returns:
    nil
  ]]
  for key, zone in pairs(self.zone_by_id) do
    local verifiedZone = zone:filterInvalidZones()
    self.zone_by_id[key] = verifiedZone
  end
end

function Map:__tostring()
   return string.format("Map ID: %s", self.id)
end

function Map:addSquaddie(squaddie, zone)
  -- Check against nil squaddies.
  if squaddie == nil then
    error("nil squaddie cannot be added.")
  end

  -- If the map unit was already added, raise an error
  if self:isSquaddieOnMap(squaddie.id) then
    error("Map:addSquaddie: " .. squaddie.name .. " already exists.")
  end

  -- Store in a zone.
  self.squaddieInfoByID[squaddie.id] = {
    squaddie = squaddie,
    zone = zone.id
  }

  self:checkInvariants()
end

function Map:getSquaddiesInZone(zone)
  local squaddiesByZone = {}
  TableUtility:each(
      self.squaddieInfoByID,
      function(_, info)
        local localZoneID = info.zone
        if squaddiesByZone[localZoneID] == nil then squaddiesByZone[localZoneID] = {} end
        table.insert(squaddiesByZone[localZoneID], info.squaddie)
      end
  )
  return squaddiesByZone[zone.id] or {}
end

function Map:removeSquaddie(squaddieID)
  --[[ Removes the map unit with the given ID.
  Args:
    squaddieID(integer): squaddie.id
  Returns:
    nil
  ]]
  if self:isSquaddieOnMap(squaddieID) then
    self.squaddieInfoByID[squaddieID] = nil
  end

  self:checkInvariants()
end

function Map:isSquaddieOnMap(squaddieID)
  return self.squaddieInfoByID[squaddieID] ~= nil
end

function Map:assertSquaddieIsOnMap(squaddieID, nameOfCaller)
  if not self:isSquaddieOnMap(squaddieID) then
    error(nameOfCaller .. ": squaddie not found: " .. squaddieID )
  end
end

function Map:doesZoneExist(zoneID)
  return self.zone_by_id[zoneID]
end

function Map:assertZoneExists(zoneID, nameOfCaller)
  if not self:doesZoneExist(zoneID) then
    error(nameOfCaller .. ": zone does not exist: " .. zoneID)
  end
end

function Map:changeSquaddieZone(squaddie, zone)
  self.squaddieInfoByID[squaddie.id].zone = zone.id
  self:checkInvariants()
end

function Map:getSquaddieByID(squaddieID)
  self:assertSquaddieIsOnMap(squaddieID, "Map:getSquaddieByID")
  return self.squaddieInfoByID[squaddieID].squaddie
end

function Map:getZoneByID(zoneID)
  self:assertZoneExists(zoneID, "Map:getZoneByID")
  return self.zone_by_id[zoneID]
end

function Map:getAllZoneIDs()
  return TableUtility:keys(self.zone_by_id)
end

function Map:getSquaddieCurrentZone(squaddie)
  return self:getZoneByID( self.squaddieInfoByID[squaddie.id].zone )
end

function Map:getSquaddiesByAffiliation(affiliation)
  return TableUtility:listcomp(
    self.squaddieInfoByID,
    function (_, squaddieInfo, _)
      return squaddieInfo.squaddie
    end,
    function (_, squaddieInfo, _)
      local squaddie = squaddieInfo.squaddie
      return squaddie:hasOneOfTheseAffiliations({affiliation})
    end
  )
end

function Map:updateControllingAffiliationsForZone(zone, newAffiliations)
  self:assertZoneExists(zone.id, "Map:updateControllingAffiliationsForZone")
  local newZoneControlRecord = self.zone_affiliation_control_by_zoneid[zone.id]:cloneWithNewAffiliationsInControl(newAffiliations)
  self.zone_affiliation_control_by_zoneid[zone.id] = newZoneControlRecord
end

function Map:getControllingAffiliationsForZone(zone)
  self:assertZoneExists(zone.id, "Map:getControllingAffiliationsForZone")
  local zoneToObserve = self.zone_affiliation_control_by_zoneid[zone.id]
  return zoneToObserve:getAffiliationsInControl()
end

function Map:squaddieIsInControl(squaddie)
  if self:isSquaddieOnMap(squaddie:getId()) ~= true then
    return false
  end

  local squaddieCurrentZone = self:getSquaddieCurrentZone(squaddie)
  local controllingAffilliations = self:getControllingAffiliationsForZone(squaddieCurrentZone)
  return TableUtility:contains(
      controllingAffilliations,
      squaddie:getAffiliation()
  )
end

return Map
