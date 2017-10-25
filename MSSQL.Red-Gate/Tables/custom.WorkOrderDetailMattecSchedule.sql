CREATE TABLE [custom].[WorkOrderDetailMattecSchedule]
(
[WorkOrderNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkOrderDetailLine] [float] NOT NULL CONSTRAINT [DF__WorkOrder__WorkO__745AE5AF] DEFAULT ((0)),
[MattecJobNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyMattec] [numeric] (20, 6) NULL,
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowCr__754F09E8] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowCr__76432E21] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowMo__7737525A] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowMo__782B7693] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [custom].[WorkOrderDetailMattecSchedule] ADD CONSTRAINT [PK__WorkOrderDetailM__7366C176] PRIMARY KEY CLUSTERED  ([WorkOrderNumber], [WorkOrderDetailLine]) ON [PRIMARY]
GO
ALTER TABLE [custom].[WorkOrderDetailMattecSchedule] ADD CONSTRAINT [FK__WorkOrderDetailM__791F9ACC] FOREIGN KEY ([WorkOrderNumber], [WorkOrderDetailLine]) REFERENCES [dbo].[WorkOrderDetails] ([WorkOrderNumber], [Line]) ON DELETE CASCADE ON UPDATE CASCADE
GO
