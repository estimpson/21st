CREATE TABLE [custom].[WorkOrderDetailBOMVerification]
(
[WorkOrderNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkOrderDetailLine] [float] NOT NULL CONSTRAINT [DF__WorkOrder__WorkO__70DF5A86] DEFAULT ((0)),
[Notes] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperatorCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowCr__71D37EBF] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowCr__72C7A2F8] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowMo__73BBC731] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowMo__74AFEB6A] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [custom].[WorkOrderDetailBOMVerification] ADD CONSTRAINT [PK__WorkOrderDetailB__6FEB364D] PRIMARY KEY CLUSTERED  ([WorkOrderNumber], [WorkOrderDetailLine]) ON [PRIMARY]
GO
ALTER TABLE [custom].[WorkOrderDetailBOMVerification] ADD CONSTRAINT [FK__WorkOrderDetailB__75A40FA3] FOREIGN KEY ([WorkOrderNumber], [WorkOrderDetailLine]) REFERENCES [dbo].[WorkOrderDetails] ([WorkOrderNumber], [Line]) ON DELETE CASCADE ON UPDATE CASCADE
GO
