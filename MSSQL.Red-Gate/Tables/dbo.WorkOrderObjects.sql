CREATE TABLE [dbo].[WorkOrderObjects]
(
[Serial] [int] NULL,
[WorkOrderNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkOrderDetailLine] [float] NOT NULL CONSTRAINT [DF__WorkOrder__WorkO__67A0090F] DEFAULT ((0)),
[Status] [int] NOT NULL CONSTRAINT [DF__WorkOrder__Statu__68942D48] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__WorkOrderO__Type__69885181] DEFAULT ((0)),
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackageType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperatorCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Quantity] [numeric] (20, 6) NOT NULL,
[LotNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompletionDT] [datetime] NULL,
[BackflushNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UndoBackflushNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowCr__6C64BE2C] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowCr__6D58E265] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowMo__6E4D069E] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowMo__6F412AD7] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderObjects] ADD CONSTRAINT [PK__WorkOrderObjects__65B7C09D] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderObjects] ADD CONSTRAINT [UQ__WorkOrderObjects__66ABE4D6] UNIQUE NONCLUSTERED  ([Serial]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderObjects] ADD CONSTRAINT [FK__WorkOrder__UndoB__6B7099F3] FOREIGN KEY ([UndoBackflushNumber]) REFERENCES [dbo].[BackflushHeaders] ([BackflushNumber])
GO
ALTER TABLE [dbo].[WorkOrderObjects] ADD CONSTRAINT [FK__WorkOrder__Backf__6A7C75BA] FOREIGN KEY ([BackflushNumber]) REFERENCES [dbo].[BackflushHeaders] ([BackflushNumber])
GO
ALTER TABLE [dbo].[WorkOrderObjects] ADD CONSTRAINT [FK__WorkOrderObjects__70354F10] FOREIGN KEY ([WorkOrderNumber], [WorkOrderDetailLine]) REFERENCES [dbo].[WorkOrderDetails] ([WorkOrderNumber], [Line])
GO
