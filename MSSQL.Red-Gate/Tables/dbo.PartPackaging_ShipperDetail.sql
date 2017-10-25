CREATE TABLE [dbo].[PartPackaging_ShipperDetail]
(
[ShipperID] [int] NULL,
[ShipperPart] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackagingCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__PartPacka__Statu__6D98D987] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__PartPackag__Type__6E8CFDC0] DEFAULT ((0)),
[PackDisabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__6F8121F9] DEFAULT ((0)),
[PackEnabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackE__70754632] DEFAULT ((0)),
[PackDefault] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__71696A6B] DEFAULT ((0)),
[PackWarn] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackW__725D8EA4] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowCr__7351B2DD] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowCr__7445D716] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowMo__7539FB4F] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowMo__762E1F88] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_ShipperDetail] ADD CONSTRAINT [PK__PartPackaging_Sh__69C848A3] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_ShipperDetail] ADD CONSTRAINT [UQ__PartPackaging_Sh__6ABC6CDC] UNIQUE NONCLUSTERED  ([ShipperID], [PartCode], [PackagingCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_ShipperDetail] ADD CONSTRAINT [FK__PartPacka__Packa__6CA4B54E] FOREIGN KEY ([PackagingCode]) REFERENCES [dbo].[package_materials] ([code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_ShipperDetail] ADD CONSTRAINT [FK__PartPacka__PartC__6BB09115] FOREIGN KEY ([PartCode]) REFERENCES [dbo].[part] ([part]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_ShipperDetail] ADD CONSTRAINT [FK__PartPackaging_Sh__772243C1] FOREIGN KEY ([ShipperID], [ShipperPart]) REFERENCES [dbo].[shipper_detail] ([shipper], [part]) ON DELETE CASCADE ON UPDATE CASCADE
GO
