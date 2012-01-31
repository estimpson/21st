begin transaction TESTING
go

set nocount on

declare
	@WorkOrderNumber varchar(50)
,	@WorkOrderDetailLine float
,	@QtyRequested numeric(20,6)

set	@WorkOrderNumber = 'WO_0000000131'
set	@WorkOrderDetailLine = 1
set @QtyRequested = 80

execute
	tempdb.dbo.usp_GetJobXRt
	@WorkOrderNumber
,	@WorkOrderDetailLine
,	@QtyRequested

execute
	tempdb.dbo.usp_GetJobInvAlloc

execute
	tempdb.dbo.usp_GetJobMaterialAlloc

if	objectproperty(object_id('tempdb.dbo.NetMPS'), 'IsTable') is not null begin
	drop table tempdb..NetMPS
end

create table
	tempdb..NetMPS
(	RowID int not null IDENTITY(1, 1) primary key
,	Hierarchy varchar(1000)
,	Suffix int
,	Part varchar(25)
,	Sequence int
,	BOMLevel int
,	XQty float
,	XScrap float
,	XSuffix float
,	SubRate float
,	Children int
,	Leaf bit
,	QtyAvailable float default 0
,	QtyRequired float default 0
,	QtySub float default 0
,	QtySubbed float default 0
,	QtyDefaultUsage float default 0
,	N0 float default 0
,	U1 float default 0
,	X1 float default 0
,	N1 float default 0
,	U2 float default 0
,	X2 float default 0
,	N2 float default 0
,	U3 float default 0
,	X3 float default 0
,	N3 float default 0
,	U4 float default 0
,	X4 float default 0
,	N4 float default 0
)

insert
	tempdb..NetMPS
(	Hierarchy
,	Suffix
,	Part
,	Sequence
,	BOMLevel
,	XQty
,	XScrap
,	XSuffix
,	SubRate
,	Children
,	Leaf
,	QtyAvailable
,	QtyRequired
,	QtySub
)
select
	Hierarchy = xr.Hierarchy
,	Suffix = xr.Suffix
,	Part = xr.ChildPart
,	Sequence = xr.Sequence
,	BOMLevel = xr.BOMLevel
,	XQty = xr.XQty
,	XScrap = xr.XScrap
,	XSuffix = xr.XSuffix
,	SubRate = xr.SubRate
,	Children = (select count(*) from tempdb..XRt xr1 where xr1.Hierarchy like xr.Hierarchy + '%' and xr1.BOMLevel > xr.BOMLevel)
,	Leaf =
		case
			when (select count(*) from tempdb..XRt xr1 where xr1.Hierarchy like xr.Hierarchy + '%' and xr1.BOMLevel > xr.BOMLevel) = 0 then 1
			else 0
		end
,	QtyAvailable = coalesce(ma.QtyAvailable / ma.Concurrence, 0) --Weight for dups in BOM
,	QtyRequired = @QtyRequested * xr.XQty * xr.XScrap * xr.XSuffix
,	QtySub = @QtyRequested * xr.XQty * xr.XScrap * xr.XSuffix* xr.SubRate
from
	tempdb..XRt xr
	left join tempdb..MaterialAlloc ma
		on xr.ChildPart = ma.Part
		and coalesce(xr.Suffix, -1) = coalesce(ma.Suffix, -1)
order by
	xr.Sequence

update
	nm
set
	QtySubbed = coalesce((select sum(QtySub / XQty / XScrap / XSuffix) from tempdb..NetMPS nm1 where nm1.Hierarchy like nm.Hierarchy + '%' and nm1.BOMLevel = nm.BOMLevel + 1) * XQty * XScrap * XSuffix, 0)
from
	tempdb..NetMPS nm

update
	nm
set
	QtyDefaultUsage = QtyRequired - QtySubbed
,	N0 = QtyRequired - QtySubbed
from
	tempdb..NetMPS nm

update
	nm
set
	U1 = coalesce(case when N0 > QtyAvailable then QtyAvailable else N0 end, 0)
,	QtyAvailable = QtyAvailable - coalesce(case when N0 > QtyAvailable then QtyAvailable else N0 end, 0)
from
	tempdb..NetMPS nm
where
	BOMLevel = 1

update
	nm
set
	X1 =  coalesce
	(	(	select
				sum(nmX.U1 / nmX.XQty / nmX.XScrap / nmX.XSuffix)
			from
				tempdb..NetMPS nmX
			where
				nm.Hierarchy like nmX.Hierarchy + '%'
				and nmX.BOMLevel < nm.BOMLevel
		) * nm.XQty * nm.XScrap * nm.XSuffix
	,	0
	)
from
	tempdb..NetMPS nm

update
	nm
set
	N1 = N0 - U1 - X1
from
	tempdb..NetMPS nm

update
	nm
set
	U2 = coalesce(case when N1 > QtyAvailable then QtyAvailable else N1 end, 0)
,	QtyAvailable = QtyAvailable - coalesce(case when N1 > QtyAvailable then QtyAvailable else N1 end, 0)
from
	tempdb..NetMPS nm
where
	BOMLevel = 2

update
	nm
set
	X2 =  coalesce
	(	(	select
				sum(nmX.U2 / nmX.XQty / nmX.XScrap / nmX.XSuffix)
			from
				tempdb..NetMPS nmX
			where
				nm.Hierarchy like nmX.Hierarchy + '%'
				and nmX.BOMLevel < nm.BOMLevel
		) * nm.XQty * nm.XScrap * nm.XSuffix
	,	0
	)
from
	tempdb..NetMPS nm

update
	nm
set
	N2 = N1 - U2 - X2
from
	tempdb..NetMPS nm

update
	nm
set
	U3 = coalesce(case when N2 > QtyAvailable then QtyAvailable else N2 end, 0)
,	QtyAvailable = QtyAvailable - coalesce(case when N2 > QtyAvailable then QtyAvailable else N2 end, 0)
from
	tempdb..NetMPS nm
where
	BOMLevel = 3

update
	nm
set
	X3 =  coalesce
	(	(	select
				sum(nmX.U3 / nmX.XQty / nmX.XScrap / nmX.XSuffix)
			from
				tempdb..NetMPS nmX
			where
				nm.Hierarchy like nmX.Hierarchy + '%'
				and nmX.BOMLevel < nm.BOMLevel
		) * nm.XQty * nm.XScrap * nm.XSuffix
	,	0
	)
from
	tempdb..NetMPS nm

update
	nm
set
	N3 = N2 - U3 - X3
from
	tempdb..NetMPS nm

update
	nm
set
	U4 = coalesce(case when N3 > QtyAvailable then QtyAvailable else N3 end, 0)
,	QtyAvailable = QtyAvailable - coalesce(case when N3 > QtyAvailable then QtyAvailable else N3 end, 0)
from
	tempdb..NetMPS nm
where
	BOMLevel = 4

update
	nm
set
	X4 =  coalesce
	(	(	select
				sum(nmX.U4 / nmX.XQty / nmX.XScrap / nmX.XSuffix)
			from
				tempdb..NetMPS nmX
			where
				nm.Hierarchy like nmX.Hierarchy + '%'
				and nmX.BOMLevel < nm.BOMLevel
		) * nm.XQty * nm.XScrap * nm.XSuffix
	,	0
	)
from
	tempdb..NetMPS nm

update
	nm
set
	N4 = N3 - U4 - X4
from
	tempdb..NetMPS nm

update
	ia
set
	QtyIssue =
		case
			when nmIssues.QtyIssue > ia.PriorAccum + ia.QtyAvailable then ia.QtyAvailable
			when nmIssues.QtyIssue > ia.PriorAccum then nmIssues.QtyIssue - ia.PriorAccum
			else 0
		end
from
	tempdb..InventoryAlloc ia
	join
	(	select
			nm.Part
		,	nm.Sequence
		,	nm.Suffix
		,	QtyIssue = sum(U1 + U2 + U3 + U4)
		from
			tempdb..NetMPS nm
		where
			U1 + U2 + U3 + U4 > 0
		group by
			nm.Part
		,	nm.Sequence
		,	nm.Suffix
	) nmIssues
		on nmIssues.Part = ia.Part
		and coalesce(nmIssues.Suffix, -1) = coalesce(ia.Suffix, -1)

select
	*
from
	tempdb..NetMPS nm

select
	*
from
	tempdb..InventoryAlloc
go

if	@@TRANCOUNT > 0 rollback
go
