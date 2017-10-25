
/*
Create procedure Fx.dbo.usp_InventoryControl_CycleCount_HandleScanInput
*/

--use Fx
--go

if	objectproperty(object_id('dbo.usp_InventoryControl_CycleCount_HandleScanInput'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_InventoryControl_CycleCount_HandleScanInput
end
go

create procedure dbo.usp_InventoryControl_CycleCount_HandleScanInput
	@User varchar(10)
,	@CycleCountNumber varchar(50)
,	@Serial int
,	@Location varchar(10)
,	@Quantity numeric(20,6)
,	@Debug int = 0
,	@ActionTakenMessage varchar(8000) out
,	@ActionTaken integer out
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
declare @RECOVER_OBJECT int; set @RECOVER_OBJECT						= 0x01  --  1
declare @ADD_OBJECT int; set @ADD_OBJECT								= 0x02  --  2
declare @CHANGE_ORIGINAL_QUANTITY int; set @CHANGE_ORIGINAL_QUANTITY	= 0x04  --  4
declare @SET_CORRECTED_QUANTITY int; set @SET_CORRECTED_QUANTITY		= 0x08  --  8
declare @RESET_CORRECTED_QUANTITY int; set @RESET_CORRECTED_QUANTITY	= 0x10  -- 16
declare @CHANGE_ORIGINAL_LOCATION int; set @CHANGE_ORIGINAL_LOCATION	= 0x20  -- 32
declare @SET_CORRECTED_LOCATION int; set @SET_CORRECTED_LOCATION		= 0x40  -- 64
declare @RESET_CORRECTED_LOCATION int; set @RESET_CORRECTED_LOCATION	= 0x80  --128
declare @MARK_AS_FOUND int; set @MARK_AS_FOUND							= 0x100 --256

set @ActionTaken = 0
set @ActionTakenMessage = 'Serial: ' + convert(varchar, @Serial) + '. CC: ' + @CycleCountNumber + '. '
	
if not exists
	(	select
			o.serial
		from
			object o
		where
			o.serial = @Serial)
	and not exists
    (	select
    		*
    	from
    		dbo.InventoryControl_CycleCountObjects iccco
		where
			@Serial = iccco.Serial
			and @CycleCountNumber = iccco.CycleCountNumber
    ) begin
	-- Object was not found in the system, so recover it.
	--- <Call>	
	set	@CallProcName = 'dbo.usp_InventoryControl_CycleCount_RecoverObject'
	execute
		@ProcReturn = dbo.usp_InventoryControl_CycleCount_RecoverObject
		@User = @User
	,	@CycleCountNumber = @CycleCountNumber
	,	@Serial = @Serial
	,	@Quantity = @Quantity
	,	@Location = @Location
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900503
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		end
		rollback tran @ProcName
		return
			@Result
	end
	--- </Call>

	set @ActionTaken = @ActionTaken | @RECOVER_OBJECT
	set @ActionTakenMessage = @ActionTakenMessage + 'Object was recovered.'
	
	if	@TranCount = 0 begin
		commit tran @ProcName
	end
	
	set @Result = 0
	return
		@Result
end


declare
	@OriginalQuantity numeric(20,6)
,	@CorrectedQuantity numeric(20,6)
,	@ObjectQuantity numeric(20,6)
,	@OriginalLocation varchar(10)
,	@CorrectedLocation varchar(10)
,	@ObjectLocation varchar(10)
select
	@OriginalQuantity = iccco.OriginalQuantity
,	@CorrectedQuantity = iccco.CorrectedQuantity
,	@ObjectQuantity = o.std_quantity
,	@OriginalLocation = iccco.OriginalLocation
,	@CorrectedLocation = iccco.CorrectedLocation
,	@ObjectLocation = o.location
from
	dbo.object o
	left join dbo.InventoryControl_CycleCountObjects iccco
		on iccco.serial = o.Serial
		and iccco.CycleCountNumber = @CycleCountNumber
where
	o.serial = @Serial


if (@OriginalQuantity is null and @OriginalLocation is null) begin
	-- Object exists in object table, but not in this cycle count, so add to current cycle count.
	--- <Call>	
	set	@CallProcName = 'dbo.usp_InventoryControl_CycleCount_AddObject'
	execute
		@ProcReturn = dbo.usp_InventoryControl_CycleCount_AddObject
		@User = @User
	,	@CycleCountNumber = @CycleCountNumber
	,	@Serial = @Serial
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900504
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900505
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900506
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	--- </Call>
		
	set @ActionTaken = @ActionTaken | @ADD_OBJECT -- object will be marked
	set @ActionTakenMessage = @ActionTakenMessage + 'Object added. '
end



if (@OriginalQuantity != @ObjectQuantity) begin
	--- update OriginalQuantity
	set @OriginalQuantity = @ObjectQuantity

	set @TableName = 'dbo.InventoryControl_CycleCountObjects'
	update
		iccco
	set
		iccco.OriginalQuantity = @ObjectQuantity
	from
		dbo.InventoryControl_CycleCountObjects iccco
	where
		iccco.CycleCountNumber = @CycleCountNumber
		and iccco.Serial = @Serial

	select
		@Error = @@Error,
		@RowCount = @@Rowcount

	if	@Error != 0 begin
		set	@Result = 900507
		RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if  @RowCount != 1 begin
		set @Result = 900508
		RAISERROR ('Expected one row updated in table %s in procedure %s.  Rows updated: %d', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Update>

	set @ActionTaken = @ActionTaken | @CHANGE_ORIGINAL_QUANTITY
	set @ActionTakenMessage = @ActionTakenMessage + 'Updated original quantity. '
end
if (@OriginalQuantity != @Quantity) begin 
	-- Object was entered with a different quantity, so correct it.
	--- <Call>	
	set	@CallProcName = 'dbo.usp_InventoryControl_CycleCount_CorrectQuantity'
	execute
		@ProcReturn = dbo.usp_InventoryControl_CycleCount_CorrectQuantity
		@User = @User
	,	@CycleCountNumber = @CycleCountNumber
	,	@NewQuantity = @Quantity
	,	@Serial = @Serial
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900509
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900510
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900511
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	--- </Call>
	
	set @ActionTaken = @ActionTaken | @SET_CORRECTED_QUANTITY -- object will NOT be marked
	set @ActionTakenMessage = @ActionTakenMessage + 'Updated corrected quantity. '
end
else begin --(@OriginalQuantity = @Quantity)
	--- update CorrectQuantity to null if it is not null
	if (@CorrectedQuantity is not null) begin
		--- <Update>	
		set @TableName = 'dbo.InventoryControl_CycleCountObjects'
		update
			iccco
		set
			iccco.CorrectedQuantity = null
		from
			dbo.InventoryControl_CycleCountObjects iccco
		where
			iccco.CycleCountNumber = @CycleCountNumber
			and iccco.Serial = @Serial

		select
			@Error = @@Error,
			@RowCount = @@Rowcount

		if	@Error != 0 begin
			set	@Result = 900512
			RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
			rollback tran @ProcName
			return
		end
		if  @RowCount != 1 begin
			set @Result = 900513
			RAISERROR ('Expected one row updated in table %s in procedure %s.  Rows updated: %d', 16, 1, @TableName, @ProcName, @RowCount)
			rollback tran @ProcName
			return
		end
		--- </Update>

		set @ActionTaken = @ActionTaken | @RESET_CORRECTED_QUANTITY -- object will be marked
		set @ActionTakenMessage = @ActionTakenMessage + 'Cleared corrected quantity. '
	end
end


if (@OriginalLocation != @ObjectLocation) begin
	--- update OriginalLocation
	set @OriginalLocation = @ObjectLocation

	--- <Update>
	set @TableName = 'dbo.InventoryControl_CycleCountObjects'
	update
		iccco
	set
		iccco.CorrectedLocation = @ObjectLocation
	from
		dbo.InventoryControl_CycleCountObjects iccco
	where
		iccco.CycleCountNumber = @CycleCountNumber
		and iccco.Serial = @Serial

	select
		@Error = @@Error,
		@RowCount = @@Rowcount

	if	@Error != 0 begin
		set	@Result = 900514
		RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if  @RowCount != 1 begin
		set @Result = 900515
		RAISERROR ('Expected one row updated in table %s in procedure %s.  Rows updated: %d', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Update>

	set @ActionTaken = @ActionTaken | @CHANGE_ORIGINAL_LOCATION
	set @ActionTakenMessage = @ActionTakenMessage + 'Updated original location. '
end
if (@OriginalLocation != @Location) begin 
	-- Object was entered with a different location, so correct it.	
	--- <Call>
	set	@CallProcName = 'dbo.usp_InventoryControl_CycleCount_CorrectLocation'
	execute
		@ProcReturn = dbo.usp_InventoryControl_CycleCount_CorrectLocation
		@User = @User
	,	@CycleCountNumber = @CycleCountNumber
	,	@NewLocation = @Location
	,	@Serial = @Serial
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900516
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900517
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900518
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	--- </Call>
		
	set @ActionTaken = @ActionTaken | @SET_CORRECTED_LOCATION -- object will NOT be marked
	set @ActionTakenMessage = @ActionTakenMessage + 'Updated corrected location. '
end
else begin --(@OriginalLocation = @Location)
	--- update CorrectedLocation to null if it is not null
	if (@CorrectedLocation is not null) begin
		--- <Update>
		set @TableName = 'dbo.InventoryControl_CycleCountObjects'
		update
			iccco
		set
			iccco.CorrectedLocation = null
		from
			dbo.InventoryControl_CycleCountObjects iccco
		where
			iccco.CycleCountNumber = @CycleCountNumber
			and iccco.Serial = @Serial

		select
			@Error = @@Error,
			@RowCount = @@Rowcount

		if	@Error != 0 begin
			set	@Result = 900519
			RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
			rollback tran @ProcName
			return
		end
		if  @RowCount != 1 begin
			set @Result = 900520
			RAISERROR ('Expected one row updated in table %s in procedure %s.  Rows updated: %d', 16, 1, @TableName, @ProcName, @RowCount)
			rollback tran @ProcName
			return
		end
		--- </Update>
		set @ActionTaken = @ActionTaken | @RESET_CORRECTED_LOCATION -- object will be marked
		set @ActionTakenMessage = @ActionTakenMessage + 'Cleared corrected location. '
	end
end



--	Call mark object when we haven't changed the corrected quantity and we haven't changed the corrected location.
--if (@ActionTaken & @SET_CORRECTED_QUANTITY = 0 and @ActionTaken & @SET_CORRECTED_LOCATION = 0) begin
if (@ActionTaken & ( @SET_CORRECTED_QUANTITY | @SET_CORRECTED_LOCATION ) = 0) begin
	--- <Call>
	set	@CallProcName = 'dbo.usp_InventoryControl_CycleCount_MarkObject' 
	execute
		@ProcReturn = dbo.usp_InventoryControl_CycleCount_MarkObject
		@User = @User
	,	@CycleCountNumber = @CycleCountNumber
	,	@NewStatus = 1 -- found
	,	@Serial = @Serial
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900521
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900522
		if (@Debug = 1) begin
			RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900523
		if (@Debug = 1) begin	
			RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		end
		rollback tran @ProcName
		return	@Result
	end
	--- </Call>

	set @ActionTaken = @ActionTaken | @MARK_AS_FOUND
	set @ActionTakenMessage = @ActionTakenMessage + 'Marked as found. '
end

-- Insert actions taken into the cycle count logging table
--- <Insert>
insert FT.CycleCountRFLogging
(
	ProcName
,	ActionTaken
,	ActionTakenMessage
)
values
(
	@ProcName
,	@ActionTaken
,	@ActionTakenMessage
)
--- </Insert> 
--- </Body>

--- <Tran AutoClose=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
--- </Tran>

---	<Return>
--	Trim trailing space from message.
set	@ActionTakenMessage = rtrim(@ActionTakenMessage)

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
	@User varchar(10)
,	@CycleCountNumber varchar(50)
,	@Serial int = null

set	@User = 'mon'
set	@CycleCountNumber = '0'
set	@Serial = '0'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_InventoryControl_CycleCount_CorrectLocation
	@User = @User
,	@CycleCountNumber = @CycleCountNumber
,	@Serial = @Serial
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

