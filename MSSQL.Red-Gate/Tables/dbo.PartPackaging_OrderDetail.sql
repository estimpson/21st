CREATE TABLE [dbo].[PartPackaging_OrderDetail]
(
[ReleaseID] [int] NULL,
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackagingCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__PartPacka__Statu__5F4ABA30] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__PartPackag__Type__603EDE69] DEFAULT ((0)),
[PackDisabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__613302A2] DEFAULT ((0)),
[PackEnabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackE__622726DB] DEFAULT ((0)),
[PackDefault] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__631B4B14] DEFAULT ((0)),
[PackWarn] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackW__640F6F4D] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowCr__65039386] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowCr__65F7B7BF] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowMo__66EBDBF8] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowMo__67E00031] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_OrderDetail] ADD CONSTRAINT [PK__PartPackaging_Or__5A860513] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_OrderDetail] ADD CONSTRAINT [UQ__PartPackaging_Or__5B7A294C] UNIQUE NONCLUSTERED  ([ReleaseID], [PartCode], [PackagingCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_OrderDetail] ADD CONSTRAINT [FK__PartPacka__Relea__5C6E4D85] FOREIGN KEY ([ReleaseID]) REFERENCES [dbo].[order_detail] ([id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_OrderDetail] ADD CONSTRAINT [FK__PartPacka__Packa__5E5695F7] FOREIGN KEY ([PackagingCode]) REFERENCES [dbo].[package_materials] ([code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_OrderDetail] ADD CONSTRAINT [FK__PartPacka__PartC__5D6271BE] FOREIGN KEY ([PartCode]) REFERENCES [dbo].[part] ([part]) ON DELETE CASCADE ON UPDATE CASCADE
GO
