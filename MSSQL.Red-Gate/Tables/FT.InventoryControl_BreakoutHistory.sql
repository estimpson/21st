CREATE TABLE [FT].[InventoryControl_BreakoutHistory]
(
[AuditTrailFromRowID] [int] NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__Inventory__Statu__384D21B7] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__InventoryC__Type__394145F0] DEFAULT ((0)),
[TranDT] [datetime] NULL,
[SerialFrom] [int] NULL,
[SerialTo] [int] NULL,
[Quantity] [numeric] (20, 6) NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__Inventory__RowCr__3A356A29] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Inventory__RowCr__3B298E62] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__Inventory__RowMo__3C1DB29B] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Inventory__RowMo__3D11D6D4] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [FT].[tr_InventoryControl_BreakoutHistory_uRowModified] on [FT].[InventoryControl_BreakoutHistory] after update
as
declare
	@TranDT datetime
,	@Result int

set xact_abort off
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

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. FT.usp_Test
--- </Error Handling>

begin try
	--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
	declare
		@TranCount smallint

	set	@TranCount = @@TranCount
	set	@TranDT = coalesce(@TranDT, GetDate())
	save tran @ProcName
	--- </Tran>

	---	<ArgumentValidation>

	---	</ArgumentValidation>
	
	--- <Body>
	if	not update(RowModifiedDT) begin
		--- <Update rows="*">
		set	@TableName = 'FT.InventoryControl_BreakoutHistory'
		
		update
			icbh
		set	RowModifiedDT = getdate()
		,	RowModifiedUser = suser_name()
		from
			FT.InventoryControl_BreakoutHistory icbh
			join inserted i
				on i.RowID = icbh.RowID
		
		select
			@Error = @@Error,
			@RowCount = @@Rowcount
		
		if	@Error != 0 begin
			set	@Result = 999999
			RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
			rollback tran @ProcName
			return
		end
		--- </Update>
		
		--- </Body>
	end
end try
begin catch
	declare
		@errorName int
	,	@errorSeverity int
	,	@errorState int
	,	@errorLine int
	,	@errorProcedures sysname
	,	@errorMessage nvarchar(2048)
	,	@xact_state int
	
	select
		@errorName = error_number()
	,	@errorSeverity = error_severity()
	,	@errorState = error_state ()
	,	@errorLine = error_line()
	,	@errorProcedures = error_procedure()
	,	@errorMessage = error_message()
	,	@xact_state = xact_state()

	if	xact_state() = -1 begin
		print 'Error number: ' + convert(varchar, @errorName)
		print 'Error severity: ' + convert(varchar, @errorSeverity)
		print 'Error state: ' + convert(varchar, @errorState)
		print 'Error line: ' + convert(varchar, @errorLine)
		print 'Error procedure: ' + @errorProcedures
		print 'Error message: ' + @errorMessage
		print 'xact_state: ' + convert(varchar, @xact_state)
		
		rollback transaction
	end
	else begin
		/*	Capture any errors in SP Logging. */
		rollback tran @ProcName
	end
end catch

---	<Return>
set	@Result = 0
return
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

begin transaction Test
go

insert
	FT.InventoryControl_BreakoutHistory
...

update
	...
from
	FT.InventoryControl_BreakoutHistory
...

delete
	...
from
	FT.InventoryControl_BreakoutHistory
...
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
ALTER TABLE [FT].[InventoryControl_BreakoutHistory] ADD CONSTRAINT [PK__Inventor__FFEE74514694453B] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [FT].[InventoryControl_BreakoutHistory] ADD CONSTRAINT [UQ__Inventor__1C793010CB365401] UNIQUE NONCLUSTERED  ([AuditTrailFromRowID]) ON [PRIMARY]
GO
