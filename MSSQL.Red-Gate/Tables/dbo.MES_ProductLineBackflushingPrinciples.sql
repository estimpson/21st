CREATE TABLE [dbo].[MES_ProductLineBackflushingPrinciples]
(
[ProductLine] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__MES_Produ__Statu__4B03CA61] DEFAULT ((0)),
[BackflushingPrinciple] [int] NOT NULL CONSTRAINT [DF__MES_Produ__Backf__4BF7EE9A] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__MES_Produ__RowCr__4CEC12D3] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MES_Produ__RowCr__4DE0370C] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__MES_Produ__RowMo__4ED45B45] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MES_Produ__RowMo__4FC87F7E] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_ProductLineBackflushingPrinciples] ADD CONSTRAINT [PK__MES_ProductLineB__48275DB6] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_ProductLineBackflushingPrinciples] ADD CONSTRAINT [UQ__MES_ProductLineB__491B81EF] UNIQUE NONCLUSTERED  ([ProductLine]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_ProductLineBackflushingPrinciples] ADD CONSTRAINT [FK__MES_Produ__Produ__4A0FA628] FOREIGN KEY ([ProductLine]) REFERENCES [dbo].[product_line] ([id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
