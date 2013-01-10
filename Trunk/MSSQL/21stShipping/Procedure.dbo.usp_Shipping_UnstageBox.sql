
/*
Create Procedure.Fx.dbo.usp_Shipping_UnstageBox.sql
*/

--use Fx
--go

if	objectproperty(object_id('dbo.usp_Shipping_UnstageBox'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_Shipping_UnstageBox
end
go

create procedure dbo.usp_Shipping_UnstageBox
	@User varchar(5)
,	@Serial int
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
/*	Check if object exists. */
if	not exists
	(	select
			*
		from
			dbo.object o
		where
			o.serial = @Serial
	) begin
	

	set	@Result = 999999
	RAISERROR ('Error encountered in %s.  Object %d is not valid', 16, 1, @ProcName, @Serial)
	rollback tran @ProcName
	return
end

/*	Check if this object is staged. */
declare
	@Shipper int

select
	@Shipper = o.shipper
from
  	dbo.object o
where
  	o.serial = @Serial
  	and o.shipper > 0

if	@Shipper is null begin
  	
  	set	@Result = 100
	rollback tran @ProcName
	return
end

/*	Validate shipper... */
/*		Shipper is open. */
if	(	select
  			s.status
  		from
  			dbo.shipper s
  		where
  			s.id = @Shipper
  	) not in ('O', 'S') begin

	set	@Result = 999999
	RAISERROR ('Error encountered in %s.  Shipper %d is not open', 16, 1, @ProcName, @Serial, @Shipper)
	rollback tran @ProcName
	return
end
--- </Body>

/*		Shipper is not manual invoice. */
if	(	select
  			s.type
  		from
  			dbo.shipper s
  		where
  			s.id = @Shipper
  	) = 'M' begin

	set	@Result = 999999
	RAISERROR ('Error encountered in %s.  Shipper %d is a manual invoice', 16, 1, @ProcName, @Serial, @Shipper)
	rollback tran @ProcName
	return
end

/*	Undo staging...*/
/*		Remove object from shipper and (if on one) pallet. */
--- <Update rows="1">
set	@TableName = 'dbo.object'

update
	o
set
	shipper = null
,	parent_serial = null  
from
	dbo.object o
where
	o.serial = @Serial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error updating %s in procedure %s.  Rows Updated: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Update>

/*	Reconcile shipper. */
--- <Call>	
set	@CallProcName = 'dbo.msp_reconcile_shipper '
execute
	@ProcReturn = dbo.msp_reconcile_shipper 
		@shipper = @Shipper

set	@Error = @@Error
if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
	rollback tran @ProcName
	return	@Result
end
if	@ProcReturn != 0 begin
	set	@Result = 999999
	RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	rollback tran @ProcName
	return	@Result
end
if	@ProcResult != 0 begin
	set	@Result = 999999
	RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	rollback tran @ProcName
	return	@Result
end
--- </Call>

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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_Shipping_StageBox
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

