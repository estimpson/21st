
/*
Create procedure tempdb.dbo.usp_GetJobInvAlloc
*/

use tempdb
go

if	objectproperty(object_id('dbo.usp_GetJobInvAlloc'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_GetJobInvAlloc
end
go

create procedure dbo.usp_GetJobInvAlloc
	@TranDT datetime = null out
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
if	objectproperty(object_id('tempdb.dbo.InventoryAlloc'), 'IsTable') is not null begin
	drop table tempdb..InventoryAlloc
end

create table
	tempdb..InventoryAlloc
(	RowID int not null IDENTITY(1, 1) primary key
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
	tempdb..InventoryAlloc
(	Serial
,	Part
,	Suffix
,	AllocDT
,	QtyAvailable
)
select
	Serial
,	Part
,	Suffix = null
,	AllocDT
,	QtyAvailable
from
	(
select
	Serial = o.serial
,	Part = o.part
,	AllocDT = o.last_date
,	QtyAvailable = o.std_quantity
,	RowNumber = row_number() over(partition by o.part order by o.last_date)
from
	fx21st.dbo.object o
where
	part in
	(	select
			xr.ChildPart
		from
			tempdb..XRt xr
	)
	and status = 'A'
	) o
where
	o.RowNumber <= 2
order by
	o.Part
,	o.AllocDT

update
	ia
set
	Concurrence = (select count(*) from tempdb..InventoryAlloc iaP where iaP.Serial = ia.Serial)
from
	tempdb..InventoryAlloc ia

update
	ia
set
	PriorAccum = coalesce((select sum(QtyAvailable / Concurrence) from tempdb..InventoryAlloc iaP where iaP.Part = ia.Part and iap.RowID < ia.RowID and coalesce(iaP.Suffix, -1) = coalesce(ia.Suffix, -1)), 0)
from
	tempdb..InventoryAlloc ia
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
	@ProcReturn = fx21st.dbo.usp_GetJobInvAlloc
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
