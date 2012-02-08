
if	objectproperty(object_id('dbo.MES_PickList'), 'IsView') = 1 begin
	drop view dbo.MES_PickList
end
go

create view dbo.MES_PickList
as
select
	mjl.MachineCode
,	mjl.WODID
,	mjl.WorkOrderNumber
,	mjl.MattecJobNumber
,	mjl.PartCode
,	ChildPart = wodbom.ChildPart
,	QtyRequiredStandardPack = mjl.StandardPack * wodbom.XQty * wodbom.XScrap
,	QtyRequired = (mjl.QtyRequired - mjl.QtyCompleted) * wodbom.XQty * wodbom.XScrap
,	QtyAvailable = mai.QtyAvailable
,	QtyToPull =
		case
			when (mjl.QtyRequired - mjl.QtyCompleted) * wodbom.XQty * wodbom.XScrap > coalesce(mai.QtyAvailable, 0)
				then (mjl.QtyRequired - mjl.QtyCompleted) * wodbom.XQty * wodbom.XScrap - coalesce(mai.QtyAvailable, 0)
			else 0
		end
,	FIFOLocation = dbo.fn_MES_GetFIFOLocation_forPart(wodbom.ChildPart, 'A', null, null, null, 'N')
,	ProductLine = p.product_line
,	Commodity = p.commodity
,	PartName = p.name
from
	dbo.MES_JobList mjl
	left join dbo.WorkOrderDetailBillOfMaterials wodbom
		on	wodbom.WorkOrderNumber = mjl.WorkOrderNumber
			and wodbom.WorkOrderDetailLine = mjl.WorkOrderDetailLine
			and wodbom.Status >= 0
	left join dbo.part p on
		p.part = wodbom.ChildPart
	left join dbo.MES_AllocatedInventory mai on
		mai.PartCode = wodbom.ChildPart
		and
			mai.AvailableToMachine = mjl.MachineCode
where
	mjl.QtyRequired > mjl.QtyCompleted
go

select
	*
from
	dbo.MES_PickList pl
order by
	WODID

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

