CREATE TABLE [dbo].[MachineState]
(
[MachineCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__MachineSt__Statu__63256CB5] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__MachineSta__Type__641990EE] DEFAULT ((0)),
[OperatorCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActiveWorkOrderNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActiveWorkOrderDetailSequence] [int] NULL,
[CurrentToolCode] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentPalletSerial] [int] NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__MachineSt__RowCr__650DB527] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MachineSt__RowCr__6601D960] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__MachineSt__RowMo__66F5FD99] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MachineSt__RowMo__67EA21D2] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trMachineState_d] on [dbo].[MachineState] instead of delete
as
/*	Don't allow deletes.  */
update
	ms
set
	Status = dbo.udf_StatusValue('dbo.MachineState', 'Deleted')
,	RowModifiedDT = getdate()
,	RowModifiedUser = suser_name()
from
	dbo.MachineState ms
	join deleted d on
		ms.RowID = d.RowID
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trMachineState_u] on [dbo].[MachineState] for update
as
/*	Record modification user and date.  */
if	not update(RowModifiedDT)
	and
		not update(RowModifiedUser) begin
	update
		ms
	set
		RowModifiedDT = getdate()
	,	RowModifiedUser = suser_name()
	from
		dbo.MachineState ms
		join inserted i on
			ms.RowID = i.RowID
end
GO
ALTER TABLE [dbo].[MachineState] ADD CONSTRAINT [PK__MachineState__613D2443] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MachineState] ADD CONSTRAINT [UQ__MachineState__6231487C] UNIQUE NONCLUSTERED  ([MachineCode]) ON [PRIMARY]
GO
