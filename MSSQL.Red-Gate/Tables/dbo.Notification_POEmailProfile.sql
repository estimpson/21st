CREATE TABLE [dbo].[Notification_POEmailProfile]
(
[PONumber] [int] NULL,
[ProfileID] [int] NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__Notificat__Statu__1B1FAD15] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__Notificati__Type__1C13D14E] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__Notificat__RowCr__1D07F587] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Notificat__RowCr__1DFC19C0] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__Notificat__RowMo__1EF03DF9] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Notificat__RowMo__1FE46232] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Notification_POEmailProfile] ADD CONSTRAINT [PK__Notification_POE__174F1C31] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Notification_POEmailProfile] ADD CONSTRAINT [UQ__Notification_POE__1843406A] UNIQUE NONCLUSTERED  ([PONumber], [ProfileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Notification_POEmailProfile] ADD CONSTRAINT [FK__Notificat__Profi__1A2B88DC] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[Notification_EmailProfiles] ([RowID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Notification_POEmailProfile] ADD CONSTRAINT [FK__Notificat__PONum__193764A3] FOREIGN KEY ([PONumber]) REFERENCES [dbo].[po_header] ([po_number]) ON DELETE CASCADE ON UPDATE CASCADE
GO
