--[[ Maps hold multiple Zones.
--]]

local Zone = require ("map/zone")
local ZoneControlRecord = require("map/ZoneControlRecord")
local TableUtility = require ("utility/tableUtility")

local Map={}
Map.__index = Map

local function AddZoneLink(self, from, to, cost, travelMethods)
  --[[ Create a new zone link and add it to the map's zone information
  ]]
  -- Add to this zone
  local newZone = self.zone_by_id[from]:addlink(to, cost, travelMethods)
  self.zone_by_id[from] = newZone
end

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

  if args.zones and args.zones ~= nil then
    -- Add the zones
    TableUtility:each(
        args.zones,
        function(_, zone, _)
          newMap:addZone(zone)
        end
    )

    TableUtility:each(
        args.zones,
        function(_, zone, _)
          newMap:addZoneLinks(zone)
        end
    )
  end

  newMap:checkInvariants()
  return newMap
end

function Map:checkInvariants()
  -- Delete any invalid links.
  self:VerifyZoneLink()
end

function Map:addZone(zone_info)
  --[[ Add the new zone to the list.
  Args:
    zone_info(table)
      id(string)
      zone(nil or table): If nil, a default zone information table is created.
      links(nil or array): Each array holds a table.
        to(string): Another zone id.
        travelMethods(array): A table of strings, each containing a travel method
  Returns:
    nil
  ]]

  -- Create a new zone from the info
  local zone_id = zone_info.id

  if not zone_info.id then
    error("Zone needs an id")
  end

  local newZone = Zone:new({
    id=zone_id
  })

  -- Add the zone to the info.
  self.zone_by_id[newZone.id] = newZone
  
  self.zone_affiliation_control_by_zoneid[newZone.id] = ZoneControlRecord:new()
end

function Map:addZoneLinks(zone)
  --[[ All zones have been added. Time to add links.
  ]]

  for _, link_info in ipairs(zone.links or {}) do
    if self.zone_by_id[link_info.to] == nil then
      error("Map:addZoneLinks: Zone " .. link_info.to .. " does not exist")
    end

    AddZoneLink(
      self,
      zone.id,
      link_info.to,
      link_info.cost,
      link_info.travelMethods
    )

    -- If the link is bidirectional, add a link with reversed direction.
    if link_info.bidirectional then
      AddZoneLink(
        self,
        link_info.to,
        zone.id,
        link_info.cost,
        link_info.travelMethods
      )
    end
  end
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
end

function Map:isSquaddieOnMap(squaddieID)
  return self.squaddieInfoByID[squaddieID]
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

return Map
