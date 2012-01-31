
/*
Create procedure tempdb.dbo.usp_GetJobMaterialAlloc
*/

use tempdb
go

if	objectproperty(object_id('dbo.usp_GetJobMaterialAlloc'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_GetJobMaterialAlloc
end
go

create procedure dbo.usp_GetJobMaterialAlloc
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
if	objectproperty(object_id('tempdb.dbo.MaterialAlloc'), 'IsTable') is not null begin
	drop table tempdb..MaterialAlloc
end

create table
	tempdb..MaterialAlloc
(	RowID int not null IDENTITY(1, 1) primary key
,	Part varchar (25)
,	Suffix int
,	QtyAvailable float
,	QtyAssigned float default 0
,	Concurrence tinyint
,	unique
	(	Part
	,	Suffix
	)
)

insert
	tempdb..MaterialAlloc
(	Part
,	Suffix
,	QtyAvailable
,	Concurrence
)
select
	Part = ia.Part
,	Suffix = ia.Suffix
,	QtyAvailable = sum(ia.QtyAvailable / ia.Concurrence)
,	Concurrence = max(ia.Concurrence)
from
	tempdb..InventoryAlloc ia
group by
	ia.Part
,	ia.Suffix
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
	@ProcReturn = fx21st.dbo.usp_GetJobMaterialAlloc
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
