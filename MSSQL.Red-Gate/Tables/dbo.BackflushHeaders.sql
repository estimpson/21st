CREATE TABLE [dbo].[BackflushHeaders]
(
[BackflushNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Backflush__Backf__1C5DEA11] DEFAULT ((0)),
[WorkOrderNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkOrderDetailLine] [float] NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__Backflush__Statu__1D520E4A] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__BackflushH__Type__1E463283] DEFAULT ((0)),
[MachineCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToolCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartProduced] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialProduced] [int] NOT NULL,
[QtyProduced] [numeric] (20, 6) NOT NULL,
[TranDT] [datetime] NOT NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__Backflush__RowCr__1F3A56BC] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Backflush__RowCr__202E7AF5] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__Backflush__RowMo__21229F2E] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Backflush__RowMo__2216C367] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create trigger [dbo].[trBackflushHeaders_d] on [dbo].[BackflushHeaders] instead of delete
as
/*	Don't allow deletes.  */
update
	bh
set
	Status = dbo.udf_StatusValue('dbo.BackflushHeaders', 'Deleted')
,	RowModifiedDT = getdate()
,	RowModifiedUser = suser_name()
from
	dbo.BackflushHeaders bh
	join deleted d on
		bh.RowID = d.RowID
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trBackflushHeaders_i] on [dbo].[BackflushHeaders] for insert
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
	@NextNumber varchar(50)

--- <Call>	
set	@CallProcName = 'FT.usp_NextNumberInSequnce'
execute
	@ProcReturn = FT.usp_NextNumberInSequnce
	@KeyName = 'dbo.BackflushHeaders.BackflushNumber'
,	@NextNumber = @NextNumber out
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@Error
if	@Error != 0 begin
	set	@Result = 900501
	RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
	rollback tran
	return
end
if	@ProcReturn != 0 begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	rollback tran
	return
end
if	@ProcResult != 0 begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	rollback tran
	return
end
--- </Call>

--- <Update rows="*">
set	@TableName = 'dbo.BackflushHeaders'

update
	bh
set
	BackflushNumber = @NextNumber
from
	dbo.BackflushHeaders bh
	join inserted i on
		bh.RowID = i.RowID
where
	bh.BackflushNumber = '0'

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran
	return
end
--- </Update>
--- </Body>
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trBackflushHeaders_u] on [dbo].[BackflushHeaders] for update
as
/*	Record modification user and date.  */
if	not update(RowModifiedDT)
	and
		not update(RowModifiedUser) begin
	update
		bh
	set
		RowModifiedDT = getdate()
	,	RowModifiedUser = suser_name()
	from
		dbo.BackflushHeaders bh
		join inserted i on
			bh.RowID = i.RowID
end
GO
ALTER TABLE [dbo].[BackflushHeaders] ADD CONSTRAINT [PK__BackflushHeaders__1A75A19F] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BackflushHeaders] ADD CONSTRAINT [UQ__BackflushHeaders__1B69C5D8] UNIQUE NONCLUSTERED  ([BackflushNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_BackflushHeaders_1] ON [dbo].[BackflushHeaders] ([BackflushNumber]) INCLUDE ([MachineCode], [PartProduced]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BackflushHeaders] ADD CONSTRAINT [FK__BackflushHeaders__230AE7A0] FOREIGN KEY ([WorkOrderNumber], [WorkOrderDetailLine]) REFERENCES [dbo].[WorkOrderDetails] ([WorkOrderNumber], [Line])
GO
