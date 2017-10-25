SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[InventoryControl_Objects]
as
select
	Serial = o.serial
,	Part = o.part
,	Quantity = o.quantity
,	Unit = o.unit_measure
,	StdQuantity = o.std_quantity
,	StdUnit = pInv.standard_unit
,	Location = o.location
,	Plant = o.plant
,	Status = o.status
,	UserDefinedStatus = o.user_defined_status
,	PackageType = nullif(o.package_type, '')
,	PalletSerial = o.parent_serial
,	Operator = o.operator
,	Lot = o.lot
,	LastDT = o.last_date
,	Weight = o.weight
,	TareWeight = o.tare_weight
,	Shipper = o.shipper
,	PONumber = o.po_number
,	Customer = o.customer
,	Destination = o.destination
,	Origin = o.origin
,	Note = o.note
,	ObjectType = o.type
,	Field1 = o.field1
,	Field2 = o.field2
,	Custom1 = o.custom1
,	Custom2 = o.custom2
,	Custom3 = o.custom3
,	Custom4 = o.custom4
,	Custom5 = o.custom5
,	EngineeringLevel = o.engineering_level
,	LicensePlate = o.LicensePlate
from
	dbo.object o
	left join dbo.part_inventory pInv
		on pInv.part = o.part
where
	o.user_defined_status != 'PRESTOCK'
	and o.location != 'PRE-OBJECT'
GO
