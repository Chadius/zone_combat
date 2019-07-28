local TableUtility = require ("utility/tableUtility")

local ZoneControlRecord = {}
ZoneControlRecord.__index = ZoneControlRecord

function ZoneControlRecord:new(args)
  local newZoneControlRecord = {}
  setmetatable(newZoneControlRecord, ZoneControlRecord)

  newZoneControlRecord.affiliationsInControl = {}
  if args and args.affiliationsInControl then
    newZoneControlRecord.affiliationsInControl = args.affiliationsInControl
  end

  return newZoneControlRecord
end

function ZoneControlRecord:clone()
  local newZoneControlRecord = ZoneControlRecord:new({
    affiliationsInControl = self:getAffiliationsInControl()
  })
  return newZoneControlRecord
end

function ZoneControlRecord:getAffiliationsInControl()
  return TableUtility:clone(self.affiliationsInControl)
end

function ZoneControlRecord:cloneWithNewAffiliationsInControl(newAffiliations)
  local newZoneControlRecord = self:clone()
  newZoneControlRecord.affiliationsInControl = newAffiliations
  return newZoneControlRecord
end

return ZoneControlRecord
