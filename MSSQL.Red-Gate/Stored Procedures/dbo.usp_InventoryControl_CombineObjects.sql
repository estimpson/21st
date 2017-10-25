SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_InventoryControl_CombineObjects]
	@Operator varchar(5)
,	@ObjectList varchar(max)
,	@CombineSerial integer out
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

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. dbo.usp_Test
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
/*	Get the list of serials to be combined. */
declare
	@CombineSerials table
(	Serial int primary key
)
insert
	@CombineSerials
(	Serial
)
select
	o.serial
from
	dbo.object o
where
	o.serial in
	(	select
			convert(int, rtrim(fsstr.Value))
		from
			dbo.fn_SplitStringToRows(@ObjectList, ',') fsstr
		where
			convert(int, rtrim(fsstr.Value)) > 0
	)
order by
	o.serial

/*	Figure out which serial will be the master. */
declare
	@toSerial int

select top 1
	@toSerial = cs.Serial
from
	@CombineSerials cs
order by
	cs.Serial

declare
	combineSerials cursor local for
select
	cs.Serial
from
	@CombineSerials cs
where
	cs.Serial != @toSerial
order by
	cs.Serial

open
	combineSerials

while
	1 = 1 begin

	declare
		@fromSerial int

	fetch
		combineSerials
	into
		@fromSerial

	if	@@FETCH_STATUS != 0 begin
		break
	end

	/*	Do combine. */
	--- <Call>	
	set	@CallProcName = 'dbo.usp_InventoryControl_Combine'
	execute
		@ProcReturn = dbo.usp_InventoryControl_Combine
		    @Operator = @Operator
		,   @FromSerial = @fromSerial
		,   @ToSerial = @toSerial
		,	@TranDT = @TranDT out
		,	@Result = @ProcResult out
	
	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return	@Result
	end
	--- </Call>
end

close
	combineSerials
deallocate
	combineSerials

set	@CombineSerial = @toSerial
--- </Body>

---	<CloseTran AutoCommit=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
---	</CloseTran AutoCommit=Yes>

---	<Return>
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
	@Operator varchar(5) = 'EES'
,	@ObjectList varchar(max) = '1478101, 1478102, 1478103'
,	@CombineSerial integer

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_InventoryControl_CombineObjects
	@Operator = @Operator
,	@ObjectList = @ObjectList
,	@CombineSerial = @CombineSerial out
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @CombineSerial, @TranDT, @ProcResult
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
GO
