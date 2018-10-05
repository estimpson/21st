CREATE TABLE [dbo].[InventoryControl_CycleCountHeaders]
(
[CycleCountNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Inventory__Cycle__62C64559] DEFAULT ('0'),
[Status] [int] NOT NULL CONSTRAINT [DF__Inventory__Statu__63BA6992] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__InventoryC__Type__64AE8DCB] DEFAULT ((0)),
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountBeginDT] [datetime] NULL,
[CountEndDT] [datetime] NULL,
[ExpectedCount] [int] NULL,
[FoundCount] [int] NULL,
[RecoveredCount] [int] NULL,
[QtyAdjustedCount] [int] NULL,
[LocationChangedCount] [int] NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__Inventory__RowCr__65A2B204] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Inventory__RowCr__6696D63D] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__Inventory__RowMo__678AFA76] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Inventory__RowMo__687F1EAF] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trInventoryControl_CycleCountHeaders_i] on [dbo].[InventoryControl_CycleCountHeaders] for insert
as
set nocount on
set ansi_warnings off
declare
	@Result int

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

--- <Tran Required=No AutoCreate=No TranDTParm=No>
declare
	@TranDT datetime
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

--- <Body>
declare
	newRows cursor for
select
	i.RowID
from
	inserted i
where
	i.CycleCountNumber = '0'

open
	newRows

while
	1 = 1 begin
	
	declare
		@newRowID int
	
	fetch
		newRows
	into
		@newRowID
	
	if	@@FETCH_STATUS != 0 begin
		break
	end
	
	declare
		@NextNumber varchar(50)

	--- <Call>	
	set	@CallProcName = 'FT.usp_NextNumberInSequnce'
	execute
		@ProcReturn = FT.usp_NextNumberInSequnce
		@KeyName = 'dbo.InventoryControl_CycleCountHeaders.CycleCountNumber'
	,	@NextNumber = @NextNumber out
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		rollback tran @ProcName
		return
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		rollback tran @ProcName
		return
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return
	end
	--- </Call>

	--- <Update rows="1">
	set	@TableName = 'dbo.InventoryControl_CycleCountHeaders'

	update
		l
	set
		CycleCountNumber = @NextNumber
	from
		dbo.InventoryControl_CycleCountHeaders l
	where
		l.RowID = @newRowID

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
		RAISERROR ('Error updating into %s in procedure %s.  Rows Updated: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Update>
	--- </Body>
end

close
	newRows
deallocate
	newRows
GO
ALTER TABLE [dbo].[InventoryControl_CycleCountHeaders] ADD CONSTRAINT [PK__InventoryControl__61D22120] PRIMARY KEY NONCLUSTERED  ([RowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_InventoryControl_CycleCountHeaders] ON [dbo].[InventoryControl_CycleCountHeaders] ([CountEndDT], [Description], [RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InventoryControl_CycleCountHeaders] ADD CONSTRAINT [UQ__InventoryControl__60DDFCE7] UNIQUE CLUSTERED  ([CycleCountNumber]) ON [PRIMARY]
GO
