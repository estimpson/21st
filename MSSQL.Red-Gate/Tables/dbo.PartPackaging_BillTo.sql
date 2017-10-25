CREATE TABLE [dbo].[PartPackaging_BillTo]
(
[BillToCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackagingCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__PartPacka__Statu__3183EF80] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__PartPackag__Type__327813B9] DEFAULT ((0)),
[PackDisabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__336C37F2] DEFAULT ((0)),
[PackEnabled] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackE__34605C2B] DEFAULT ((0)),
[PackDefault] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackD__35548064] DEFAULT ((0)),
[PackWarn] [tinyint] NULL CONSTRAINT [DF__PartPacka__PackW__3648A49D] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowCr__373CC8D6] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowCr__3830ED0F] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__PartPacka__RowMo__39251148] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__PartPacka__RowMo__3A193581] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_BillTo] ADD CONSTRAINT [PK__PartPackaging_Bi__2CBF3A63] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_BillTo] ADD CONSTRAINT [UQ__PartPackaging_Bi__2DB35E9C] UNIQUE NONCLUSTERED  ([BillToCode], [PartCode], [PackagingCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPackaging_BillTo] ADD CONSTRAINT [FK__PartPacka__BillT__2EA782D5] FOREIGN KEY ([BillToCode]) REFERENCES [dbo].[customer] ([customer]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_BillTo] ADD CONSTRAINT [FK__PartPacka__Packa__308FCB47] FOREIGN KEY ([PackagingCode]) REFERENCES [dbo].[package_materials] ([code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[PartPackaging_BillTo] ADD CONSTRAINT [FK__PartPacka__PartC__2F9BA70E] FOREIGN KEY ([PartCode]) REFERENCES [dbo].[part] ([part]) ON DELETE CASCADE ON UPDATE CASCADE
GO
