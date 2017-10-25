
alter table dbo.edi_setups add EDIShipToID varchar(25) null
alter table dbo.edi_setups add ProcessEDI int null
alter table dbo.edi_setups add TransitDays int null
alter table dbo.edi_setups add EDIOffsetDays int null
alter table dbo.edi_setups add PlanningReleasesFlag char(1) null default ('A')
alter table dbo.edi_setups add ReferenceAccum varchar(10) null
alter table dbo.edi_setups add AdjustmentAccum varchar(10) null
alter table dbo.edi_setups add CheckCustomerPOFirm int null
alter table dbo.edi_setups add PlanningReleaseHorizonDaysBack int null
alter table dbo.edi_setups add ShipScheduleHorizonDaysBack int null
alter table dbo.edi_setups add ProcessShipSchedule int null
alter table dbo.edi_setups add ProcessPlanningRelease int null
