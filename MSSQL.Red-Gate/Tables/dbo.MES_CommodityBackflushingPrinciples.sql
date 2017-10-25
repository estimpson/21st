CREATE TABLE [dbo].[MES_CommodityBackflushingPrinciples]
(
[Commodity] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__MES_Commo__Statu__417A6027] DEFAULT ((0)),
[BackflushingPrinciple] [int] NOT NULL CONSTRAINT [DF__MES_Commo__Backf__426E8460] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__MES_Commo__RowCr__4362A899] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MES_Commo__RowCr__4456CCD2] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__MES_Commo__RowMo__454AF10B] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MES_Commo__RowMo__463F1544] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_CommodityBackflushingPrinciples] ADD CONSTRAINT [PK__MES_CommodityBac__3E9DF37C] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_CommodityBackflushingPrinciples] ADD CONSTRAINT [UQ__MES_CommodityBac__3F9217B5] UNIQUE NONCLUSTERED  ([Commodity]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_CommodityBackflushingPrinciples] ADD CONSTRAINT [FK__MES_Commo__Commo__40863BEE] FOREIGN KEY ([Commodity]) REFERENCES [dbo].[commodity] ([id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
