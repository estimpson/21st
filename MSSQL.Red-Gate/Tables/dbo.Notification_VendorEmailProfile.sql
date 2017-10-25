CREATE TABLE [dbo].[Notification_VendorEmailProfile]
(
[VendorCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileID] [int] NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__Notificat__Statu__080CD8A1] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__Notificati__Type__0900FCDA] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__Notificat__RowCr__09F52113] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Notificat__RowCr__0AE9454C] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__Notificat__RowMo__0BDD6985] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Notificat__RowMo__0CD18DBE] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Notification_VendorEmailProfile] ADD CONSTRAINT [PK__Notification_Ven__043C47BD] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Notification_VendorEmailProfile] ADD CONSTRAINT [UQ__Notification_Ven__05306BF6] UNIQUE NONCLUSTERED  ([VendorCode], [ProfileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Notification_VendorEmailProfile] ADD CONSTRAINT [FK__Notificat__Profi__21CCAAA4] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[Notification_EmailProfiles] ([RowID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Notification_VendorEmailProfile] ADD CONSTRAINT [FK__Notificat__Vendo__0718B468] FOREIGN KEY ([VendorCode]) REFERENCES [dbo].[vendor] ([code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
