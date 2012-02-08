alter procedure custom.usp_InventoryValuation
	@InventoryDate datetime = null
as 

select
	object.PartCode
,	object.StdQty
,	object.UnitMeasure
,	object.StdQty * pi.unit_weight
,	part_standard.cost
,	part_standard.price
,	object.ObjectSerial
,	plant = upper(coalesce(location.plant,'PLANT 1'))
,	part.name
,	part.cross_ref
,	part.class
,	part.type
,	Best1PiecePrice.Price as price1
from
	(	select
			*
		from
			dbo.udf_GetInventory_FromDT (@InventoryDate)
	) object
	left outer join location
		on object.LocationCode = location.code
	join part_standard
		on object.PartCode = part_standard.part
	join part
		on object.PartCode = part.part
	join dbo.part_inventory pi
		on pi.part = object.PartCode
	left join REPORT_Best1PiecePrice Best1PiecePrice
		on object.PartCode = Best1PiecePrice.Part
where
	object.LocationCode != 'PRE-OBJECT'
go

