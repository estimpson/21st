SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_ReceivingDock_ReceiveObject_againstReceiverObject]
	@User varchar (5)
,	@ReceiverObjectID int
,	@TranDT datetime = null out
,	@Result int = null out
as
set nocount on
set ansi_warnings off
set	@Result = 999999

--- <Error Handling>
declare
	@CallProcName sysname,
	@TableName sysname,
	@ProcName sysname,
	@ProcReturn int,
	@ProcResult int,
	@Error int,
	@RowCount int

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
--		ReceiverObjectID is valid and not received.
if	(	select
			Status
		from
			dbo.ReceiverObjects ro
		where
			ReceiverObjectID = @ReceiverObjectID) != dbo.udf_StatusValue ('ReceiverObjects', 'New') begin
    
	RAISERROR ('Error encountered in %s.  Validation: ReceiverObjectID %d is already received.', 16, 1, @ProcName, @ReceiverObjectID)
	rollback tran @ProcName
	return @Result
end

--	ReceiverObjectID has valid Receiver rows.
if	not exists
		(	select
				*
			from
				dbo.ReceiverObjects ro
				join dbo.ReceiverLines rl
					on ro.ReceiverLineID = rl.ReceiverLineID
				join dbo.ReceiverHeaders rh
					on rl.ReceiverID = rh.ReceiverID
			where
				ro.ReceiverObjectID = @ReceiverObjectID
				and ro.Status = dbo.udf_StatusValue('ReceiverObjects', 'New')

		) begin
	
	RAISERROR ('Error encountered in %s.  Invalid ReceiverObjectID %d.', 16, 1, @ProcName, @ReceiverObjectID)
	rollback tran @ProcName
	return @Result
end      
---	</ArgumentValidation>

--- <Body>

declare
	@ReceiverType int
,	@PONumber int
,	@POLineNo int
,	@PartCode varchar(25)
,	@PODueDT datetime
,	@PORowID int
,	@PackageType varchar(20)
,	@QtyObject numeric(20, 6)
,	@NewObjects int
,	@Shipper varchar(20)
,	@LotNumber varchar(20)
,	@Location varchar(10)
,	@UserDefinedStatus varchar(30)
,	@SerialNumber int
,	@ReceiverNumber varchar(50)
,	@ShipFrom varchar(10)
,	@IntercompanyReceipt bit
,	@TransferReceipt bit
,	@Note varchar(max)

select
	@ReceiverType = rh.Type
,	@PONumber = rl.PONumber
,	@POLineNo = rl.POLineNo
,	@PartCode = rl.PartCode
,	@PODueDT = rl.POLineDueDate
,	@PORowID =
		(	select
				min(pd.row_id)
			from
				dbo.po_detail pd
			where
				pd.po_number = rl.PONumber
				and pd.part_number = rl.PartCode
				and pd.date_due = rl.POLineDueDate
				and pd.status = 'A'
		)
,	@NewObjects = 1
,	@Shipper = rh.ConfirmedSID
,	@LotNumber = ro.Lot
,	@SerialNumber = ro.Serial
,	@PackageType = ro.PackageType
,	@QtyObject = ro.QtyObject
,	@Location = ro.Location
,	@UserDefinedStatus = ro.UserDefinedStatus
,	@ReceiverNumber = rh.ReceiverNumber
,	@ShipFrom = rh.ShipFrom
,	@Note = ro.Note
,	@IntercompanyReceipt = case when rl.PONumber > 0 and ro.Serial > 0 then 1 else 0 end
,	@TransferReceipt = case when rl.PONumber is null and ro.Serial > 0 then 1 else 0 end
from
	dbo.ReceiverObjects ro
	join dbo.ReceiverLines rl
		on ro.ReceiverLineID = rl.ReceiverLineID
	join dbo.ReceiverHeaders rh
		on rl.ReceiverID = rh.ReceiverID
where
	ro.ReceiverObjectID = @ReceiverObjectID
	and ro.Status = dbo.udf_StatusValue('ReceiverObjects', 'New')

if	@@RowCount != 1 begin

	RAISERROR ('Error encountered in %s.  Validation: ReceiverObjectID %d not found or invalid.', 16, 1, @ProcName, @ReceiverObjectID)
	rollback tran @ProcName
	return @Result
end
if	coalesce(@Shipper, '') !> '' begin

	RAISERROR ('Error encountered in %s.  Validation: Vendor ShipperID has not been entered yet.  Update Receiver Header and try again.', 16, 1, @ProcName, @ReceiverObjectID)
	rollback tran @ProcName
	return @Result
end

/*	Perform receipt depending on type. */
if	@ReceiverType in (1, 3, 4) begin --Purchase Order, Outside Processing, Transfer
	--- <Call>	
	set	@CallProcName = 'dbo.usp_ReceivingDock_ReceiveObject_Inventory'
	execute
		@ProcReturn = dbo.usp_ReceivingDock_ReceiveObject_Inventory
			@User = @User
		,	@PONumber = @PONumber
		,	@PartCode = @PartCode
		,	@PODueDT = @PODueDT
		,	@PORowID = @PORowID
		,	@PackageType = @PackageType
		,	@PerBoxQty = @QtyObject
		,	@NewObjects = 1
		,	@Shipper = @Shipper
		,	@LotNumber = @LotNumber
		,	@Location = @Location
		,	@UserDefinedStatus = @UserDefinedStatus
		,	@IntercompanyReceipt = @IntercompanyReceipt
		,	@TransferReceipt = @TransferReceipt
		,	@SerialNumber = @SerialNumber out
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

	--- <Call>
	set	@CallProcName = 'dbo.usp_Purchasing_AddReceipt'
	execute
		@ProcReturn = dbo.usp_Purchasing_AddReceipt 
			@User = @User
		,	@PONumber = @PONumber
		,	@PartCode = @PartCode
		,	@PODueDT = @PODueDT
		,	@PORowID = @PORowID
		,	@QtyReceived = @QtyObject
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
else if
	@ReceiverType = 2 begin --RMA
	--- <Call>	
	set	@CallProcName = 'dbo.usp_ReceivingDock_ReceiveRMAObjects'
	execute @ProcReturn = dbo.usp_ReceivingDock_ReceiveRMAObjects 
		@User = @User
	,	@RMA_ID = @PONumber
	,	@RMA_LineID = @POLineNo
	,	@RMA_Reason = @Note
	,	@PartCode = @PartCode
	,	@PackageType = @PackageType
	,	@PerBoxQty = @QtyObject
	,	@NewObjects = @NewObjects
	,	@Shipper = @Shipper
	,	@LotNumber = @LotNumber
	,	@Location = @Location
	,	@UserDefinedStatus = @UserDefinedStatus
	,	@SerialNumber = @SerialNumber out
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

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

/*	Update ReceiverObjects. */
--- <Update>
set	@TableName = 'dbo.ReceiverObjects'

update
	dbo.ReceiverObjects
set	
	Status = 1 --(select dbo.udf_StatusValue('ReceiverObjects', 'Received'))
,	Serial = @SerialNumber
,	ReceiveDT = @TranDT
where
	ReceiverObjectID = @ReceiverObjectID

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
--- </Update>

/*	Update ReceiverLine. */
--- <Update>
set	@TableName = 'dbo.ReceiverLines'

update
	dbo.ReceiverLines
set	
	Status =
		case RemainingBoxes
			when 1 then 4 --(select dbo.udf_StatusValue('ReceiverLines', 'Received'))
			else rl.Status
		end
,	ReceiptDT =
		case RemainingBoxes
			when 1 then @TranDT
			else ReceiptDT
		end
,	RemainingBoxes = RemainingBoxes - 1
from
	dbo.ReceiverLines rl
	join dbo.ReceiverObjects ro
		on rl.ReceiverLineID = ro.ReceiverLineID
where
	ro.ReceiverObjectID = @ReceiverObjectID

select
	@Error = @@Error
,	@RowCount = @@Rowcount


if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
--- </Update>

/*	Update ReceiverHeader. */
--- <Update>
set	@TableName = 'dbo.ReceiverHeader'

update
	dbo.ReceiverHeaders
set	
	Status =
		case
			when coalesce(ReceiverLines.RemainingBoxes, 0) = 0 then 4 --(select dbo.udf_StatusValue('ReceiverHeaders', 'Received'))
			when rh.Status < 3 --(select dbo.udf_StatusValue('ReceiverHeaders', 'Arrived'))
				then 3 --(select dbo.udf_StatusValue('ReceiverHeaders', 'Arrived'))
			else rh.Status
		end
,	ReceiveDT =
		case
			when coalesce(ReceiverLines.RemainingBoxes, 0) = 0 then @TranDT
			else rh.ReceiveDT
		end
from
	dbo.ReceiverHeaders rh
	join
		(	select
				ReceiverID = rl.ReceiverID
			,	RemainingBoxes = sum(RemainingBoxes)
			from
				dbo.ReceiverLines rl
				join dbo.ReceiverObjects ro
					on rl.ReceiverLineID = ro.ReceiverLineID
			where
				ro.ReceiverObjectID = @ReceiverObjectID
			group by
				rl.ReceiverID
			) ReceiverLines
		on rh.ReceiverID = ReceiverLines.ReceiverID

select
	@Error = @@Error
,	@RowCount = @@Rowcount


if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
--- </Update>

/*	Special processing for Outside Process. */
if	@ReceiverType = 3 --(select dbo.udf_TypeValue('ReceiverHeaders', 'Outside Process'))
	begin
	
/*	Backflush materials for outside process. */
/*		Create back flush header.  */
	--- <Insert rows="1">
	set	@TableName = 'dbo.BackflushHeaders'
	
	insert
		dbo.BackflushHeaders
	(	TranDT
	,	WorkOrderNumber
	,	WorkOrderDetailLine
	,	MachineCode
	,	PartProduced
	,	SerialProduced
	,	QtyProduced
	)
	select
		@TranDT
	,	WorkOrderNumber = null
	,	WorkOrderDetailLine = null
	,	MachineCode = @ShipFrom
	,	PartCode = @PartCode
	,	SerialProduced = @SerialNumber
	,	QtyProduced = @QtyObject

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

	declare
		@NewBackflushNumber varchar(50)

	set	@NewBackflushNumber =
		(	select
	 			bh.BackflushNumber
	 		from
	 			dbo.BackflushHeaders bh
	 		where
	 			bh.RowID = scope_identity()
		 )
	
	/*	Perform back flush.  */
	--- <Call>	
	set	@CallProcName = 'dbo.usp_ReceivingDock_Backflush'
	
	execute @ProcReturn = dbo.usp_ReceivingDock_Backflush
		@Operator = @User
	,	@BackflushNumber = @NewBackflushNumber
	,	@ReceiverObjectID = @ReceiverObjectID
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

	set @Error = @@Error
	if @ProcResult != 0 
		begin
			set @Result = 999999
			raiserror ('An error result was returned from the procedure %s', 16, 1, 'ProdControl_BackFlush')
			rollback tran @ProcName
			return	@Result
		end
	if @ProcReturn != 0 
		begin
			set @Result = 999999
			raiserror ('An error was returned from the procedure %s', 16, 1, 'ProdControl_BackFlush')
			rollback tran @ProcName
			return	@Result
		end
	if @Error != 0 
		begin
			set @Result = 999999
			raiserror ('An error occurred during the execution of the procedure %s', 16, 1, 'ProdControl_BackFlush')
			rollback tran @ProcName
			return	@Result
		end
	--- </Call>
end

/*	If material has been delivered to an outside processor, autocreate PO line. */
if	exists
	(	select
			*
		from
			dbo.ReceiverHeaders rh
				join dbo.ReceiverLines rl
						join dbo.ReceiverObjects ro
							on rl.ReceiverLineID = ro.ReceiverLineID
							and ro.ReceiverObjectID = @ReceiverObjectID
					on rh.ReceiverID = rl.ReceiverID
			join dbo.OutsideProcessing_BlanketPOs opbpo
				on opbpo.InPartCode = ro.PartCode
	) begin
	
	--- <Call>
	declare
		@vendorShipTo varchar(20)
	,	@rawPartCode varchar(25)
	,	@rawPartStandardQty numeric(20,6)
	
	select
		@vendorShipTo = rh.Plant
	,	@rawPartCode = ro.PartCode
	,	@rawPartStandardQty = ro.QtyObject
	from
		dbo.ReceiverHeaders rh
			join dbo.ReceiverLines rl
					join dbo.ReceiverObjects ro
						on rl.ReceiverLineID = ro.ReceiverLineID
						and ro.ReceiverObjectID = @ReceiverObjectID
				on rh.ReceiverID = rl.ReceiverID
		join dbo.OutsideProcessing_BlanketPOs opbpo
			on opbpo.InPartCode = ro.PartCode
	
	set	@CallProcName = 'dbo.usp_OutsideProcessing_AutocreateFirmPOLineItem'
	execute
		@ProcReturn = dbo.usp_OutsideProcessing_AutocreateFirmPOLineItem
		@User = @User
	,	@VendorShipFrom = @vendorShipTo
	,	@RawPartCode = @rawPartCode
	,	@RawPartStandardQty = @rawPartStandardQty
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
	@User varchar (5) = 'EES'
,	@ReceiverObjectID int = 34925

set	@User = 'EES'

begin transaction Test

declare
	@ProcReturn int
,	@TranDT datetime
,	@ProcResult int
,	@Error int

execute
	@ProcReturn = dbo.usp_ReceivingDock_ReceiveObject_againstReceiverObject
	@User = @User
,	@ReceiverObjectID = @ReceiverObjectID
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

select
	*
from
	dbo.ReceiverObjects ro
where
	ro.ReceiverObjectID = @ReceiverObjectID
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
