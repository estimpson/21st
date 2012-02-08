
/*
Create procedure tempdb.dbo.usp_GetJobXRt
*/

use tempdb
go

if	objectproperty(object_id('dbo.usp_GetJobXRt'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_GetJobXRt
end
go

create procedure dbo.usp_GetJobXRt
	@WorkOrderNumber varchar(50)
,	@WorkOrderDetailLine float
,	@QtyRequested numeric(20,6)
,	@TranDT datetime = null out
,	@Result integer = null out
as
set nocount on
set ansi_warnings off
set	@Result = 999999

--- <Error Handling>
declare
	@CallProcName sysname,
	@TableName sysname,
	@ProcName sysname,
	@ProcReturn integer,
	@ProcResult integer,
	@Error integer,
	@RowCount integer

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. fx21st.dbo.usp_Test
--- </Error Handling>

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
declare
	@TranCount smallint

set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
else begin
	save tran @ProcName
end
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
if	objectproperty(object_id('tempdb.dbo.XRt'), 'IsTable') is not null begin
	drop table tempdb..XRt
end

create table tempdb..XRt
(	RowID int not null IDENTITY(1, 1) primary key nonclustered
,	Hierarchy varchar(1000) unique clustered
,	TopPart varchar(25)
,	ChildPart varchar(25)
,	BOMID int
,	Sequence tinyint
,	BOMLevel tinyint
,	Suffix int
,	XQty float
,	XScrap float
,	XSuffix float
,	SubForBOMID int
,	SubRate numeric(20,6)
)

insert
	tempdb..XRt
select
	Hierarchy = '/0'
,	TopPart = wod.PartCode
,	ChildPart = wod.PartCode
,	BOMID = null
,	Sequence = 0
,	BOMLevel = 0
,	Suffix = null
,	XQty = 1
,	XScrap = 1
,	XSuffix =  1
,	SubForBOMID = null
,	SubPercentage = null
from
	fx21st.dbo.WorkOrderDetails wod
where
	wod.WorkOrderNumber = @WorkOrderNumber
	and wod.Line = @WorkOrderDetailLine

insert
	tempdb..XRt
select
	Hierarchy = '/0/' + convert(varchar, wodbom.ChildPartSequence)
,	TopPart = wod.PartCode
,	ChildPart = wodbom.ChildPart
,	BOMID = wodbom.RowID
,	Sequence = wodbom.ChildPartSequence --row_number() over (order by wodbom.ChildPartSequence)
,	BOMLevel = wodbom.ChildPartBOMLevel
,	Suffix = wodbom.Suffix
,	XQty = wodbom.XQty
,	XScrap = wodbom.XScrap
,	XSuffix =  1
,	SubForBOMID = wodbom.SubForRowID
,	SubPercentage = wodbom.SubPercentage
from
	fx21st.dbo.WorkOrderDetailBillOfMaterials wodbom
	join fx21st.dbo.WorkOrderDetails wod
		on wod.WorkOrderNumber = @WorkOrderNumber
		and wod.Line = @WorkOrderDetailLine
where
	wodbom.WorkOrderNumber = @WorkOrderNumber
	and wodbom.WorkOrderDetailLine = @WorkOrderDetailLine
	and wodbom.Status >= 0
	and wodbom.ChildPartBOMLevel = 1
order by
	wodbom.ChildPartSequence

insert
	tempdb..XRt
select
	Hierarchy = xr.Hierarchy + '/' + convert(varchar, wodbom.ChildPartSequence)
,	TopPart = wod.PartCode
,	ChildPart = wodbom.ChildPart
,	BOMID = wodbom.RowID
,	Sequence = wodbom.ChildPartSequence --row_number() over (order by wodbom.ChildPartSequence)
,	BOMLevel = wodbom.ChildPartBOMLevel
,	Suffix = wodbom.Suffix
,	XQty = wodbom.XQty
,	XScrap = wodbom.XScrap
,	XSuffix =  1
,	SubForBOMID = wodbom.SubForRowID
,	SubPercentage = wodbom.SubPercentage
from
	fx21st.dbo.WorkOrderDetailBillOfMaterials wodbom
	join fx21st.dbo.WorkOrderDetails wod
		on wod.WorkOrderNumber = @WorkOrderNumber
		and wod.Line = @WorkOrderDetailLine
	join tempdb..XRt xr
		on xr.BOMLevel = wodbom.ChildPartBOMLevel - 1
		and xr.Sequence =
		(	select
				max(xr1.Sequence)
			from
				tempdb..XRt xr1
			where
				xr1.Sequence < wodbom.ChildPartSequence
		)
where
	wodbom.WorkOrderNumber = @WorkOrderNumber
	and wodbom.WorkOrderDetailLine = @WorkOrderDetailLine
	and wodbom.Status >= 0
	and wodbom.ChildPartBOMLevel = 2
order by
	wodbom.ChildPartSequence

insert
	tempdb..XRt
select
	Hierarchy = xr.Hierarchy + '/' + convert(varchar, wodbom.ChildPartSequence)
,	TopPart = wod.PartCode
,	ChildPart = wodbom.ChildPart
,	BOMID = wodbom.RowID
,	Sequence = wodbom.ChildPartSequence --row_number() over (order by wodbom.ChildPartSequence)
,	BOMLevel = wodbom.ChildPartBOMLevel
,	Suffix = wodbom.Suffix
,	XQty = wodbom.XQty
,	XScrap = wodbom.XScrap
,	XSuffix =  1
,	SubForBOMID = wodbom.SubForRowID
,	SubPercentage = wodbom.SubPercentage
from
	fx21st.dbo.WorkOrderDetailBillOfMaterials wodbom
	join fx21st.dbo.WorkOrderDetails wod
		on wod.WorkOrderNumber = @WorkOrderNumber
		and wod.Line = @WorkOrderDetailLine
	join tempdb..XRt xr
		on xr.BOMLevel = wodbom.ChildPartBOMLevel - 1
		and xr.Sequence =
		(	select
				max(xr1.Sequence)
			from
				tempdb..XRt xr1
			where
				xr1.Sequence < wodbom.ChildPartSequence
		)
where
	wodbom.WorkOrderNumber = @WorkOrderNumber
	and wodbom.WorkOrderDetailLine = @WorkOrderDetailLine
	and wodbom.Status >= 0
	and wodbom.ChildPartBOMLevel = 3
order by
	wodbom.ChildPartSequence

insert
	tempdb..XRt
select
	Hierarchy = xr.Hierarchy + '/' + convert(varchar, wodbom.ChildPartSequence)
,	TopPart = wod.PartCode
,	ChildPart = wodbom.ChildPart
,	BOMID = wodbom.RowID
,	Sequence = wodbom.ChildPartSequence --row_number() over (order by wodbom.ChildPartSequence)
,	BOMLevel = wodbom.ChildPartBOMLevel
,	Suffix = wodbom.Suffix
,	XQty = wodbom.XQty
,	XScrap = wodbom.XScrap
,	XSuffix =  1
,	SubForBOMID = wodbom.SubForRowID
,	SubPercentage = wodbom.SubPercentage
from
	fx21st.dbo.WorkOrderDetailBillOfMaterials wodbom
	join fx21st.dbo.WorkOrderDetails wod
		on wod.WorkOrderNumber = @WorkOrderNumber
		and wod.Line = @WorkOrderDetailLine
	join tempdb..XRt xr
		on xr.BOMLevel = wodbom.ChildPartBOMLevel - 1
		and xr.Sequence =
		(	select
				max(xr1.Sequence)
			from
				tempdb..XRt xr1
			where
				xr1.Sequence < wodbom.ChildPartSequence
		)
where
	wodbom.WorkOrderNumber = @WorkOrderNumber
	and wodbom.WorkOrderDetailLine = @WorkOrderDetailLine
	and wodbom.Status >= 0
	and wodbom.ChildPartBOMLevel = 4
order by
	wodbom.ChildPartSequence
/*
insert
	tempdb..XRt
select
	TopPart = wod.PartCode
,	ChildPart = wodbom.ChildPart
,	BOMID = wodbom.RowID
,	Sequence = wodbom.ChildPartSequence --row_number() over (order by wodbom.ChildPartSequence)
,	BOMLevel = wodbom.ChildPartBOMLevel
,	Suffix = wodbom.Suffix
,	XQty = wodbom.XQty
,	XScrap = wodbom.XScrap
,	XSuffix =  1
,	SubForBOMID = wodbom.SubForRowID
,	SubPercentage = wodbom.SubPercentage
from
	fx21st.dbo.WorkOrderDetailBillOfMaterials wodbom
	join fx21st.dbo.WorkOrderDetails wod
		on wodbom.WorkOrderNumber = wod.WorkOrderNumber
		and wodbom.WorkOrderDetailLine = wod.Line
where
	wodbom.WorkOrderNumber = @WorkOrderNumber
	and wodbom.WorkOrderDetailLine = @WorkOrderDetailLine
	and wodbom.Status >= 0
order by
	wodbom.ChildPartSequence

insert
	tempdb..XRt
select
	TopPart = xr1.ChildPart
,	xr2.ChildPart
,	xr2.BOMID
,	Sequence = xr2.Sequence - xr1.Sequence
,	BOMLevel = xr2.BOMLevel - xr1.BOMLevel
,	Suffix = xr2.Suffix
,	XQty = xr2.XQty / xr1.XQty
,	XScrap = xr2.XScrap / xr1.XScrap
,	XSuffix = xr2.XSuffix / xr1.XSuffix
,	SubForBOMID = xr2.SubForBOMID
,	SubRate = xr2.SubRate
from
	tempdb..XRt xr1
	cross join tempdb..XRt xr2
where
	xr2.Sequence > xr1.Sequence
	and xr2.BOMLevel > xr1.BOMLevel
	and xr2.Sequence <
	(	select
			min(xrCheck.Sequence)
		from
			tempdb..XRt xrCheck
		where
			xrCheck.Sequence > xr1.Sequence
			and xrCheck.BOMLevel <= xr1.BOMLevel
	)
*/
--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end

set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries
{

}

Test syntax
{

set statistics io on
set statistics time on
go

declare
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = fx21st.dbo.usp_GetJobXRt
	@Param1 = @Param1
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
go

if	@@trancount > 0 begin
	rollback
end
go

set statistics io off
set statistics time off
go

}

Results {
}
*/
go
