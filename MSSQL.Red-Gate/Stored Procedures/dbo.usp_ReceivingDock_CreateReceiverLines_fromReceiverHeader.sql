SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_ReceivingDock_CreateReceiverLines_fromReceiverHeader]
(	@ReceiverID int,
	@Result int output)
as
set ansi_warnings off
set nocount on
set	@Result = 999999

--- <ErrorHandling>
declare
	@CallProcName sysname,
	@TableName sysname,
	@ProcName sysname,
	@ProcReturn integer,
	@ProcResult integer,
	@Error integer,
	@RowCount integer

set	@ProcName = user_name(objectproperty (@@procid, 'OwnerId')) + '.' + object_name (@@procid)  -- e.g. dbo.usp_Test
--- </ErrorHandling>

--- <Tran required=Yes autoCreate=Yes>
declare
	@TranCount smallint
set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
save tran @ProcName
--- </Tran>

--	Create receiver lines for Purchase Orders:
if	dbo.udf_TypeName('ReceiverHeaders', dbo.udf_ReceiverHeader_Type(@ReceiverID)) = 'Purchase Order' begin

	--- <Call>	
	set	@CallProcName = 'dbo.usp_ReceivingDock_CreateReceiverLines_fromPOReceiverHeader'
	execute
		@ProcReturn = dbo.usp_ReceivingDock_CreateReceiverLines_fromPOReceiverHeader
		@ReceiverID = @ReceiverID,
		@Result = @ProcResult out
	
	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	--- </Call>
end
else if dbo.udf_TypeName('ReceiverHeaders', dbo.udf_ReceiverHeader_Type(@ReceiverID)) = 'Outside Process' begin

	--- <Call>	
	set	@CallProcName = 'dbo.usp_ReceivingDock_CreateReceiverLines_fromOutPReceiverHeader'
	execute
		@ProcReturn = dbo.usp_ReceivingDock_CreateReceiverLines_fromOutPReceiverHeader
		@ReceiverID = @ReceiverID,
		@Result = @ProcResult out
	
	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	--- </Call>
end
else if dbo.udf_TypeName('ReceiverHeaders', dbo.udf_ReceiverHeader_Type(@ReceiverID)) = 'RMA' begin

	--- <Call>	
	set	@CallProcName = 'dbo.usp_ReceivingDock_CreateReceiverLines_fromRMAReceiverHeader'
	execute
		@ProcReturn = dbo.usp_ReceivingDock_CreateReceiverLines_fromRMAReceiverHeader
		@ReceiverID = @ReceiverID,
		@Result = @ProcResult out
	
	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	--- </Call>
end
else if dbo.udf_TypeName('ReceiverHeaders', dbo.udf_ReceiverHeader_Type(@ReceiverID)) = 'Plant Transfer' begin

	--- <Call>	
	set	@CallProcName = 'dbo.usp_ReceivingDock_CreateReceiverLines_fromPlantTReceiverHeader'
	execute
		@ProcReturn = dbo.usp_ReceivingDock_CreateReceiverLines_fromPlantTReceiverHeader
		@ReceiverID = @ReceiverID,
		@Result = @ProcResult out
	
	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	--- </Call>
end

--- <CloseTran required=Yes autoCreate=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
--- </CloseTran>

---	<Return success=True>
set	@Result = 0
return	@Result
--- </Return>
GO
