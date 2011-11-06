
if	objectproperty(object_id('dbo.MES_PickList'), 'IsView') = 1 begin
	drop view dbo.MES_PickList
end
go

create view dbo.MES_PickList
as
select
	cs.MachineCode
,	cs.WODID
,	cs.PartCode
,	ChildPart = wodbom.ChildPart
,	QtyRequired = (cs.QtyRequired - cs.QtyCompleted) * wodbom.XQty
,	QtyAvailable = alloc.QtyAvailable
,	QtyToPull =
		case
			when (cs.QtyRequired - cs.QtyCompleted) * wodbom.XQty > coalesce(alloc.QtyAvailable, 0)
				then (cs.QtyRequired - cs.QtyCompleted) * wodbom.XQty - coalesce(alloc.QtyAvailable, 0)
			else 0
		end
,	FIFOLocation = dbo.fn_MES_GetFIFOLocation_forPart(wodbom.ChildPart, 'A', null, null, null, 'N')
,	ProductLine = p.product_line
,	Commodity = p.commodity
,	PartName = p.name
from
	(	select
	 		cs.MachineCode
		,	cs.WODID
		,	cs.WorkOrderNumber
		,	cs.WorkOrderDetailLine
		,	cs.PartCode
		,	QtyRequired = cs.QtyLabelled
		,	cs.QtyCompleted
	 	from
	 		dbo.MES_CurrentSchedules cs
	 	group by
	 		cs.MachineCode
		,	cs.WODID
		,	cs.WorkOrderNumber
		,	cs.WorkOrderDetailLine
		,	cs.PartCode
		,	cs.QtyLabelled
		,	cs.QtyCompleted
	) cs
	left join dbo.WorkOrderDetailBillOfMaterials wodbom
	on
		wodbom.WorkOrderNumber = cs.WorkOrderNumber
		and wodbom.WorkOrderDetailLine = cs.WorkOrderDetailLine
	left join dbo.part p on
		p.part = wodbom.ChildPart
	left join
	(	select
	 		Part = o.part
	 	,	Machine = o.location
	 	,	QtyAvailable = sum(o.std_quantity)
	 	from
	 		dbo.object o
	 	where
	 		o.status = 'A'
	 	group by
	 		o.part
	 	,	o.location
	) alloc on
		alloc.Part = wodbom.ChildPart
		and
			alloc.Machine = cs.MachineCode
where
	cs.QtyRequired > cs.QtyCompleted
go

select
	MachineCode
,	WODID
,	PartCode
,	ChildPart
,	QtyRequired
,	QtyAvailable
,	QtyToPull
,	FIFOLocation
,	ProductLine
,	Commodity
,	PartName
from
	dbo.MES_PickList pl
order by
	Commodity

/*
insert
	dbo.group_technology
(	id
,	notes
,	source_type
)
values
(	'EEA Warehouse'
,	'Material warehouse in Florence, AL'
,	null
)

update
	dbo.location
set
	group_no = 'EEA Warehouse'
where
	code like 'ALA%'
*/
