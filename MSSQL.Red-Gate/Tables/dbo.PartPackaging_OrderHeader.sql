CREATE TABLE [dbo].[PartPackaging_OrderHeader]
(
[OrderNo] [numeric] (8, 0) NULL,
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackagingCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__PartPacka__Statu__500876A0] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__PartPackag__Type__50FC9AD9] DEFAULT ((0)),
[PackDisabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__51F0BF12] DEFAULT ((0)),
[PackEnabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackE__52E4E34B] DEFAULT ((0)),
[PackDefault] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__53D90784] DEFAULT ((0)),
[PackWarn] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackW__54CD2BBD] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowCr__55C14FF6] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowCr__56B5742F] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowMo__57A99868] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowMo__589DBCA1] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_OrderHeader] ADD CONSTRAINT [PK__PartPackaging_Or__4B43C183] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_OrderHeader] ADD CONSTRAINT [UQ__PartPackaging_Or__4C37E5BC] UNIQUE NONCLUSTERED  ([OrderNo], [PartCode], [PackagingCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_OrderHeader] ADD CONSTRAINT [FK__PartPacka__Order__4D2C09F5] FOREIGN KEY ([OrderNo]) REFERENCES [dbo].[order_header] ([order_no]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_OrderHeader] ADD CONSTRAINT [FK__PartPacka__Packa__4F145267] FOREIGN KEY ([PackagingCode]) REFERENCES [dbo].[package_materials] ([code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_OrderHeader] ADD CONSTRAINT [FK__PartPacka__PartC__4E202E2E] FOREIGN KEY ([PartCode]) REFERENCES [dbo].[part] ([part]) ON DELETE CASCADE ON UPDATE CASCADE
GO
