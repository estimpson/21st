begin transaction
go

select
	*
from
	dbo.bill_of_material_ec bome
where
	bome.part = 'WPP231-28'

declare
	@PartNumber varchar(25) = 'R208003'
,	@MachineCode varchar(10) = '2'
,	@PrimaryMachine varchar(10) = '5'

declare
	@silp table
(	TopPartCode varchar(25)
,	Hierarchy varchar(500)
,	BOMLevel int
,	Sequence int
,	InLineTemp int
)

select
	*
from
	dbo.part_machine pm
where
	pm.part = @PartNumber

insert
	@silp
(	TopPartCode
,	Hierarchy
,	BOMLevel
,	Sequence
,	InLineTemp
)
select
	silp.TopPartCode
,	silp.Hierarchy
,	silp.BOMLevel
,	silp.Sequence
,	silp.InLineTemp
from
	dbo.Scheduling_InLineProcessNew silp
where
	silp.TopPartCode = @PartNumber
	and	silp.MachineCode = @MachineCode

if	@@ROWCOUNT = 0 begin
	insert
		@silp
	(	TopPartCode
	,	Hierarchy
	,	BOMLevel
	,	Sequence
	,	InLineTemp
	)
	select
		silp.TopPartCode
	,	silp.Hierarchy
	,	silp.BOMLevel
	,	silp.Sequence
	,	silp.InLineTemp
	from
		dbo.Scheduling_InLineProcessNew silp
	where
		silp.TopPartCode = @PartNumber
		and	silp.MachineCode = @PrimaryMachine
end

select
	*
from
	@silp s

declare
	@WorkOrderNumber varchar(50) = 'WO_0000040287'
,	@WorkOrderDetailLine int = 1

select
	wod.WorkOrderNumber
,	wod.Line
,	Line = row_number() over (partition by wod.WorkOrderNumber order by xr.Sequence)
,	Status =
		case
			when silp2.InLineTemp = 1 then dbo.udf_StatusValue('dbo.WorkOrderDetailBillOfMaterials', 'Temporary WIP')
			else dbo.udf_StatusValue('dbo.WorkOrderDetailBillOfMaterials', 'Used')
		end
,	Type = dbo.udf_TypeValue('dbo.WorkOrderDetailBillOfMaterials', 'Material')
,	ChildPart = xr.ChildPart
,	ChildPartSequence = xr.Sequence
,	ChildPartBOMLevel = xr.BOMLevel
,	BillOfMaterialID = xr.BOMID
,	Suffix = null
,	QtyPer = null
,	xr.XQty
,	xr.XScrap
from
	FT.XRt xr
	join @silp silp
		on silp.TopPartCode = xr.TopPart
		and xr.Hierarchy like silp.Hierarchy + '/%'
		and xr.BOMLevel = silp.BOMLevel + 1
	left join @silp silp2
		 on silp2.TopPartCode = xr.TopPart
		 and silp2.Sequence = xr.Sequence
	join dbo.WorkOrderDetails wod
		on wod.PartCode = xr.TopPart
where
	WorkOrderNumber = @WorkOrderNumber
	and	Line = @WorkOrderDetailLine
order by
	wod.WorkOrderNumber
,	wod.Line
,	xr.Sequence
go

rollback
go
