
/*
Create procedure fx21st.dbo.usp_MES_CorrectObjectQty
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_CorrectObjectQty'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_CorrectObjectQty
end
go

create procedure dbo.usp_MES_CorrectObjectQty
	@Operator varchar(5)
,	@WODID int = null
,	@Serial int
,	@ObjectQty numeric (20,6)
,	@ShortageReason varchar(255)
,	@TranDT datetime out
,	@Result integer out


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
declare 
	@AdjustmentQty numeric(20,6)


set @AdjustmentQty = 
(	select
		qty = @ObjectQty - o.quantity
	from
		dbo.object o
	where
		o.serial = @Serial
)

/* Record excess or shortage if necessary */
if (@AdjustmentQty < 0) begin

	set @AdjustmentQty = abs(@AdjustmentQty)
	--- <Call>	
	set	@CallProcName = 'dbo.usp_MES_NewShortageQty'
	execute
		@ProcReturn = dbo.usp_MES_NewShortageQty
		@Operator = @Operator
	,	@WODID = null
	,	@Serial = @Serial
	,	@QtyShort = @AdjustmentQty
	,	@ShortageReason = ''
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
else if (@AdjustmentQty > 0) begin
--- <Call>	
	set	@CallProcName = 'dbo.usp_MES_NewExcessQty'
	execute
		@ProcReturn = dbo.usp_MES_NewExcessQty
		@Operator = @Operator
	,	@WODID = null
	,	@Serial = @Serial
	,	@QtyExcess = @AdjustmentQty
	,	@ExcessReason = ''
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
--- </Body>

/*	Print label.*/
--- <Insert rows="1">
set	@TableName = 'dbo.print_queue'

insert
	dbo.print_queue
(	printed
,	type
,	copies
,	serial_number
,	label_format
,	server_name
)
select
	printed = 0
,	type = 'W'
,	copies = 1
,	serial_number = @Serial
,	label_format = 'SMART_LABEL'
,	server_name = 'LBLSRV'

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

--- <CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
--- </CloseTran Required=Yes AutoCreate=Yes>

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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_CorrectObjectQty
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
