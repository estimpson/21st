SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[udf_GetInventory_FromDT]
(	@InventoryDT datetime
)
returns @Objects table
(	ObjectSerial int null
,	PartCode varchar (25) null
,	LastTranDT datetime null
,	LocationCode varchar (10) null
,	LastOperatorCode varchar (10) null
,	ShortStatus char (1) null
,	LongStatus varchar (30) null
,	StdQty numeric (20, 6) null
,	UnitMeasure char (2) null
,	AltQty numeric (20, 6) null
,	AltUnitMeasure char (2) null
,	Lot varchar (20) null
,	PackageType varchar (20) null
,	StagedSID int null
,	ParentSerial numeric (10, 0) null
,	Note varchar (254) null
,	StdCost numeric (20, 6) null
,	StdMaterial numeric (20, 6) null
,	StdLabor numeric (20, 6) null
,	StdBurden numeric (20, 6) null
,	StdOther numeric (20, 6) null
)
as
begin
--- <Body>
	insert
		@Objects
	select
		ObjectSerial = o.serial
	,	PartCode = o.part
	,	LastTranDT = o.last_date
	,	LocationCode = o.location
	,	LastOperatorCode = o.operator
	,	ShortStatus = o.status
	,	LongStatus = o.user_defined_status
	,	StdQty = o.std_quantity
	,	UnitMeasure = pi.standard_unit
	,	AltQty = o.quantity
	,	AltUnitMeasure = o.unit_measure
	,	Lot = o.lot
	,	PackageType = o.package_type
	,	StagedSID = o.shipper
	,	ParentSerial = o.parent_serial
	,	Note = o.note
	,	StdCost = ps.cost_cum
	,	StdMaterial = ps.material_cum
	,	StdLabor = ps.labor_cum
	,	StdBurden = ps.burden_cum
	,	StdOther = ps.other_cum
	from
		dbo.object o
		left join dbo.part_inventory pi
			on pi.part = o.part
		left join dbo.part_standard ps
			on ps.part = o.part
--- </Body>

---	<Return>
	return
end
GO
