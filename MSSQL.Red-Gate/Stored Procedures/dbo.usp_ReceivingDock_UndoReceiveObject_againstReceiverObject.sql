SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_ReceivingDock_UndoReceiveObject_againstReceiverObject]
(	@User varchar (5),
	@ReceiverObjectID int,
	@TranDT datetime out,
	@Result integer out)
as
/*
Example:
Initial queries {
select
	*
from
	dbo.ReceiverObjects ro
}

Test syntax {
begin transaction ReceiveObject
go

declare
	@User varchar (5),
	@ReceiverObjectID int,
	@TranDT datetime

set	@User = '01956'
set	@ReceiverObjectID = 16006

declare
	@SerialNumber int

select
	@SerialNumber = Serial
from
	dbo.ReceiverObjects ro
where
	ReceiverObjectID = @ReceiverObjectID

declare
	@ProcReturn integer,
	@ProcResult integer,
	@Error integer

execute	@ProcReturn = dbo.usp_ReceivingDock_UndoReceiveObject_againstReceiverObject
	@User = @User,
	@ReceiverObjectID = @ReceiverObjectID,
	@TranDT = @TranDT out,
	@Result = @ProcResult out

set	@Error = @@error

select	@ProcReturn, @ProcResult

select
	*
from
	dbo.ReceiverObjects ro
	left join dbo.object o on
		o.serial = ro.Serial
where
	ro.ReceiverObjectID = @ReceiverObjectID

select
	*
from
	dbo.audit_trail at
where
	at.serial = @SerialNumber
go

rollback
go

}

Results {
See below...
}
*/
set nocount on
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
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

declare
	@PONumber integer,
	@POLineNo integer,
	@PartCode varchar(25),
	@SerialNumber integer

--	Argument Validation:
--		ReceiverObjectID is valid and not received.
if
	(	select
			Status
		from
			dbo.ReceiverObjects ro
		where
			ReceiverObjectID = @ReceiverObjectID) != dbo.udf_StatusValue ('ReceiverObjects', 'Received') begin
	set	@Result = 1000007
	RAISERROR ('Error encountered in %s.  Validation: ReceiverObjectID %d is not yet received.', 16, 1, @ProcName, @ReceiverObjectID)
	rollback tran @ProcName
	return @Result
end

select
	@PONumber = rl.PONumber
,	@POLineNo = rl.POLineNo
,	@PartCode = rl.PartCode
,	@SerialNumber = ro.Serial
from
	dbo.ReceiverObjects ro
	join dbo.ReceiverLines rl on ro.ReceiverLineID = rl.ReceiverLineID
	join dbo.ReceiverHeaders rh on rl.ReceiverID = rh.ReceiverID
where
	ro.ReceiverObjectID = @ReceiverObjectID

if
	@@RowCount != 1 begin
	set	@Result = 1000008
	RAISERROR ('Error encountered in %s.  Validation: ReceiverObjectID %d not found or invalid.', 16, 1, @ProcName, @ReceiverObjectID)
	rollback tran @ProcName
	return @Result
end

--- <Call>	
set	@CallProcName = 'dbo.usp_ReceivingDock_UndoReceiveObjects'
execute
	@ProcReturn = dbo.usp_ReceivingDock_UndoReceiveObjects
	@User = @User,
	@PONumber = @PONumber,
	@POLineNo = @POLineNo,
	@PartCode = @PartCode,
	@SerialNumber = @SerialNumber,
	@TranDT = @TranDT out,
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

--		D.	Update ReceiverObjects.
--- <Update>
set	@TableName = 'dbo.ReceiverObjects'

update
	dbo.ReceiverObjects
set
	Status = dbo.udf_StatusValue ('ReceiverObjects', 'New'),
	Serial = null,
	ReceiveDT = null
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

--		E.	Update ReceiverLine.
--- <Update>
set	@TableName = 'dbo.ReceiverLines'

update
	dbo.ReceiverLines
set
	Status = dbo.udf_StatusValue ('ReceiverLines', 'New'),
	ReceiptDT = null,
	RemainingBoxes = RemainingBoxes + 1
from
	dbo.ReceiverLines rl
	join dbo.ReceiverObjects ro on
		rl.ReceiverLineID = ro.ReceiverLineID
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

--<CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit transaction @ProcName
end
--</CloseTran Required=Yes AutoCreate=Yes>

--	IV.	Return.
set	@Result = 0
return @Result
GO
