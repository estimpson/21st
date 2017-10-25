CREATE TABLE [dbo].[WorkOrderDetails]
(
[WorkOrderNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Line] [float] NOT NULL CONSTRAINT [DF__WorkOrderD__Line__554161B2] DEFAULT ((0)),
[Status] [int] NOT NULL CONSTRAINT [DF__WorkOrder__Statu__563585EB] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__WorkOrderD__Type__5729AA24] DEFAULT ((0)),
[ProcessCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TopPartCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence] [int] NULL,
[DueDT] [datetime] NULL,
[QtyRequired] [numeric] (20, 6) NOT NULL,
[QtyLabelled] [numeric] (20, 6) NOT NULL CONSTRAINT [DF__WorkOrder__QtyLa__581DCE5D] DEFAULT ((0)),
[QtyCompleted] [numeric] (20, 6) NOT NULL CONSTRAINT [DF__WorkOrder__QtyCo__5911F296] DEFAULT ((0)),
[QtyDefect] [numeric] (20, 6) NOT NULL CONSTRAINT [DF__WorkOrder__QtyDe__5A0616CF] DEFAULT ((0)),
[QtyRework] [numeric] (20, 6) NOT NULL CONSTRAINT [DF__WorkOrder__QtyRe__5AFA3B08] DEFAULT ((0)),
[SetupHours] [numeric] (20, 6) NOT NULL CONSTRAINT [DF__WorkOrder__Setup__5BEE5F41] DEFAULT ((0)),
[PartsPerHour] [numeric] (20, 6) NOT NULL,
[PartsPerCycle] [numeric] (20, 6) NOT NULL CONSTRAINT [DF__WorkOrder__Parts__5CE2837A] DEFAULT ((1)),
[CycleSeconds] [numeric] (20, 6) NOT NULL,
[StartDT] [datetime] NULL,
[EndDT] [datetime] NULL,
[ShipperID] [int] NULL,
[SalesOrderNumber] [int] NULL,
[DestinationCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowCr__5DD6A7B3] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowCr__5ECACBEC] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowMo__5FBEF025] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowMo__60B3145E] DEFAULT (suser_name())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create trigger [dbo].[trWorkOrderDetails_d] on [dbo].[WorkOrderDetails] instead of delete
as
/*	Don't allow deletes.  */
update
	dbo.WorkOrderDetails
set
	Status = dbo.udf_StatusValue('dbo.WorkOrderDetails', 'Deleted')
,	RowModifiedDT = getdate()
,	RowModifiedUser = suser_name()
from
	dbo.WorkOrderHeaders woh
	join deleted d on
		woh.RowID = d.RowID
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trWorkOrderDetails_u] on [dbo].[WorkOrderDetails] for update
as
/*	Record modification user and date.  */
if	not update(RowModifiedDT)
	and
		not update(RowModifiedUser) begin
	update
		dbo.WorkOrderDetails
	set
		RowModifiedDT = getdate()
	,	RowModifiedUser = suser_name()
	from
		dbo.WorkOrderDetails wod
		join inserted i on
			wod.RowID = i.RowID
end
GO
ALTER TABLE [dbo].[WorkOrderDetails] ADD CONSTRAINT [PK__WorkOrderDetails__5264F507] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderDetails] ADD CONSTRAINT [UQ__WorkOrderDetails__53591940] UNIQUE NONCLUSTERED  ([WorkOrderNumber], [Line]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderDetails] ADD CONSTRAINT [FK__WorkOrder__WorkO__544D3D79] FOREIGN KEY ([WorkOrderNumber]) REFERENCES [dbo].[WorkOrderHeaders] ([WorkOrderNumber])
GO
