begin transaction TESTING
go

declare
	@CPU int

set	@CPU = @@CPU_BUSY

set nocount on

declare
	@WorkOrderNumber varchar(50)
,	@WorkOrderDetailLine float
,	@QtyRequested numeric(20,6)

set	@WorkOrderNumber = 'WO_0000000131'
set	@WorkOrderDetailLine = 1
set @QtyRequested = 80

declare
	@XRt dbo.MES_XRt

insert
	@XRt
select
	*
from
	dbo.fn_MES_GetJobXRt(@WorkOrderNumber, @WorkOrderDetailLine) fmgjxr

declare
	@InventoryAllocation table
(	RowID int primary key
,	Serial int
,	Part varchar (25)
,	Suffix int
,	AllocDT datetime
,	QtyAvailable float
,	QtyIssue float default 0
,	PriorAccum float
,	Concurrence tinyint
,	unique
	(	Serial
	,	Suffix
	)
)

insert
	@InventoryAllocation
select
	*
from
	dbo.fn_MES_GetJobInventoryAllocation(@XRt) fmgjxr

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
,	QtyUsed float default 0
,	QtyXUsed float default 0
,	QtyNetDefaultUsage float default 0
,	QtyEffective float default 0
,	QtySubUsed float default 0
,	QtyXSubUsed float default 0
,	QtyFinalNet float default 0
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
,	Y4 float default 0
,	Y3 float default 0
,	Y2 float default 0
,	Y1 float default 0
,	Y0 float default 0
,	NF0 float default 0
,	UF1 float default 0
,	XF1 float default 0
,	NF1 float default 0
,	UF2 float default 0
,	XF2 float default 0
,	NF2 float default 0
,	UF3 float default 0
,	XF3 float default 0
,	NF3 float default 0
,	UF4 float default 0
,	XF4 float default 0
,	NF4 float default 0
,	unique (BOMLevel, Hierarchy, RowID)
,	unique (Hierarchy, BOMLevel, RowID)
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

/*	Calculate default usage.*/
update
	nm
set
	QtyDefaultUsage = QtyRequired - QtySubbed
,	N0 = QtyRequired - QtySubbed
,	QtyNetDefaultUsage = QtyRequired - QtySubbed
from
	tempdb..NetMPS nm

declare
	@BOMLevel int
,	@LastBOMLevel int

set	@BOMLevel = 0

select
	@LastBOMLevel = max(BOMLevel)
from
	tempdb..NetMPS nm

while
	@BOMLevel <= @LastBOMLevel begin

	update
		nm
	set
		QtyUsed = coalesce(case when QtyNetDefaultUsage > QtyAvailable then QtyAvailable else QtyNetDefaultUsage end, 0)
	from
		tempdb..NetMPS nm
	where
		BOMLevel = @BOMLevel
	
	update
		nm
	set
		QtyAvailable = QtyAvailable - QtyUsed
	from
		tempdb..NetMPS nm
	where
		BOMLevel = @BOMLevel
	
	update
		nm
	set
		QtyXUsed =  coalesce
		(	(	select
					sum(nmX.QtyUsed / nmX.XQty / nmX.XScrap / nmX.XSuffix)
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
	where
		BOMLevel = @BOMLevel + 1
	
	update
		nm
	set
		QtyNetDefaultUsage = QtyDefaultUsage - QtyUsed - QtyXUsed
	from
		tempdb..NetMPS nm

	set	@BOMLevel = @BOMLevel + 1
end

/*	Using quantity assigned during default usage, calculate effective quantity. */
while
	@BOMLevel >= 0 begin
	
	update
		nm
	set
		QtyEffective = QtyUsed + coalesce
		(	(	select
					min(nmY.QtyEffective / nmY.XQty / nmY.XScrap / nmY.XSuffix)
				from
					tempdb..NetMPS nmY
				where
					nmY.Hierarchy like nm.Hierarchy + '%'
					and nmY.BOMLevel = nm.BOMLevel + 1
			) * nm.XQty * nm.XScrap * nm.XSuffix
		,	0
		)
	from
		tempdb..NetMPS nm
	where
		BOMLevel = @BOMLevel

	set	@BOMLevel = @BOMLevel - 1
end

update
	nm
set
	QtyFinalNet = QtyRequired - QtyEffective
from
	tempdb..NetMPS nm

/*	Assign usage from net of effective quantity. */
while
	@BOMLevel <= @LastBOMLevel begin

	update
		nm
	set
		QtySubUsed = coalesce(case when QtyFinalNet > QtyAvailable then QtyAvailable else QtyFinalNet end, 0)
	,	QtyAvailable = QtyAvailable - coalesce(case when QtyFinalNet > QtyAvailable then QtyAvailable else QtyFinalNet end, 0)
	from
		tempdb..NetMPS nm
	where
		BOMLevel = @BOMLevel
	
	update
		nm
	set
		QtyXSubUsed =  coalesce
		(	(	select
					sum(nmX.QtySubUsed / nmX.XQty / nmX.XScrap / nmX.XSuffix)
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
	where
		BOMLevel = @BOMLevel + 1
	
	update
		nm
	set
		QtyFinalNet = QtyRequired - QtyEffective - QtyXUsed - QtySubUsed - QtyXSubUsed
	from
		tempdb..NetMPS nm

	set	@BOMLevel = @BOMLevel + 1
end

/*	Calculate issues. */
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
		,	QtyIssue = sum(QtyUsed + QtySubUsed)
		from
			tempdb..NetMPS nm
		where
			QtyUsed + QtySubUsed > 0
		group by
			nm.Part
		,	nm.Sequence
		,	nm.Suffix
	) nmIssues
		on nmIssues.Part = ia.Part
		and coalesce(nmIssues.Suffix, -1) = coalesce(ia.Suffix, -1)

--select
--	*
--from
--	tempdb..NetMPS nm

--select
--	*
--from
--	tempdb..InventoryAlloc

select
	@@CPU_BUSY - @CPU
go

if	@@TRANCOUNT > 0 rollback
go

/*

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

/*	Assign Qty BOM Level 4 */
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
	X4 = coalesce
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

/*	Rollup buildable quantity. */
update
	nm
set
	Y4 = U4
from
	tempdb..NetMPS nm

update
	nm
set
	Y3 = U3 + coalesce
	(	(	select
				min(nmY.Y4 / nmY.XQty / nmY.XScrap / nmY.XSuffix)
			from
				tempdb..NetMPS nmY
			where
				nmY.Hierarchy like nm.Hierarchy + '%'
				and nmY.BOMLevel = nm.BOMLevel + 1
		) * nm.XQty * nm.XScrap * nm.XSuffix
	,	0
	)
from
	tempdb..NetMPS nm

update
	nm
set
	Y2 = U2 + coalesce
	(	(	select
				min(nmY.Y3 / nmY.XQty / nmY.XScrap / nmY.XSuffix)
			from
				tempdb..NetMPS nmY
			where
				nmY.Hierarchy like nm.Hierarchy + '%'
				and nmY.BOMLevel = nm.BOMLevel + 1
		) * nm.XQty * nm.XScrap * nm.XSuffix
	,	0
	)
from
	tempdb..NetMPS nm

update
	nm
set
	Y1 = U1 + coalesce
	(	(	select
				min(nmY.Y2 / nmY.XQty / nmY.XScrap / nmY.XSuffix)
			from
				tempdb..NetMPS nmY
			where
				nmY.Hierarchy like nm.Hierarchy + '%'
				and nmY.BOMLevel = nm.BOMLevel + 1
		) * nm.XQty * nm.XScrap * nm.XSuffix
	,	0
	)
from
	tempdb..NetMPS nm

update
	nm
set
	Y0 = coalesce
	(	(	select
				min(nmY.Y1 / nmY.XQty / nmY.XScrap / nmY.XSuffix)
			from
				tempdb..NetMPS nmY
			where
				nmY.Hierarchy like nm.Hierarchy + '%'
				and nmY.BOMLevel = nm.BOMLevel + 1
		) * nm.XQty * nm.XScrap * nm.XSuffix
	,	0
	)
from
	tempdb..NetMPS nm

/*	Calculate net after primary usage. */
update
	nm
set
	NF0 = QtyRequired - Y4 - Y3 - Y2 - Y1 - Y0 - X4 - X3 - X2 - X1
from
	tempdb..NetMPS nm

/*	Apply inventory using available of substitutes. */
/*		BOMLevel 1 */
update
	nm
set
	UF1 = coalesce(case when NF0 > QtyAvailable then QtyAvailable else NF0 end, 0)
,	QtyAvailable = QtyAvailable - coalesce(case when NF0 > QtyAvailable then QtyAvailable else NF0 end, 0)
from
	tempdb..NetMPS nm
where
	BOMLevel = 1

update
	nm
set
	XF1 = coalesce
	(	(	select
				sum(nmX.UF1 / nmX.XQty / nmX.XScrap / nmX.XSuffix)
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
	NF1 = NF0 - UF1 - XF1
from
	tempdb..NetMPS nm

/*		BOMLevel 2 */
update
	nm
set
	UF2 = coalesce(case when NF1 > QtyAvailable then QtyAvailable else NF1 end, 0)
,	QtyAvailable = QtyAvailable - coalesce(case when NF1 > QtyAvailable then QtyAvailable else NF1 end, 0)
from
	tempdb..NetMPS nm
where
	BOMLevel = 2

update
	nm
set
	XF2 = coalesce
	(	(	select
				sum(nmX.UF2 / nmX.XQty / nmX.XScrap / nmX.XSuffix)
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
	NF2 = NF1 - UF2 - XF2
from
	tempdb..NetMPS nm

/*		BOMLevel 3 */
update
	nm
set
	UF3 = coalesce(case when NF2 > QtyAvailable then QtyAvailable else NF2 end, 0)
,	QtyAvailable = QtyAvailable - coalesce(case when NF2 > QtyAvailable then QtyAvailable else NF2 end, 0)
from
	tempdb..NetMPS nm
where
	BOMLevel = 3

update
	nm
set
	XF3 = coalesce
	(	(	select
				sum(nmX.UF3 / nmX.XQty / nmX.XScrap / nmX.XSuffix)
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
	NF3 = NF2 - UF3 - XF3
from
	tempdb..NetMPS nm

/*		BOMLevel 4 */
update
	nm
set
	UF4 = coalesce(case when NF3 > QtyAvailable then QtyAvailable else NF3 end, 0)
,	QtyAvailable = QtyAvailable - coalesce(case when NF3 > QtyAvailable then QtyAvailable else NF3 end, 0)
from
	tempdb..NetMPS nm
where
	BOMLevel = 4

update
	nm
set
	XF4 = coalesce
	(	(	select
				sum(nmX.UF4 / nmX.XQty / nmX.XScrap / nmX.XSuffix)
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
	NF4 = NF3 - UF4 - XF4
from
	tempdb..NetMPS nm
*/
