CREATE TABLE [dbo].[PartPackaging_ShipTo]
(
[ShipToCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackagingCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__PartPacka__Statu__40C63310] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__PartPackag__Type__41BA5749] DEFAULT ((0)),
[PackDisabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__42AE7B82] DEFAULT ((0)),
[PackEnabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackE__43A29FBB] DEFAULT ((0)),
[PackDefault] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__4496C3F4] DEFAULT ((0)),
[PackWarn] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackW__458AE82D] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowCr__467F0C66] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowCr__4773309F] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowMo__486754D8] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowMo__495B7911] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_ShipTo] ADD CONSTRAINT [PK__PartPackaging_Sh__3C017DF3] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_ShipTo] ADD CONSTRAINT [UQ__PartPackaging_Sh__3CF5A22C] UNIQUE NONCLUSTERED  ([ShipToCode], [PartCode], [PackagingCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_ShipTo] ADD CONSTRAINT [FK__PartPacka__ShipT__3DE9C665] FOREIGN KEY ([ShipToCode]) REFERENCES [dbo].[destination] ([destination]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_ShipTo] ADD CONSTRAINT [FK__PartPacka__Packa__3FD20ED7] FOREIGN KEY ([PackagingCode]) REFERENCES [dbo].[package_materials] ([code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_ShipTo] ADD CONSTRAINT [FK__PartPacka__PartC__3EDDEA9E] FOREIGN KEY ([PartCode]) REFERENCES [dbo].[part] ([part]) ON DELETE CASCADE ON UPDATE CASCADE
GO
