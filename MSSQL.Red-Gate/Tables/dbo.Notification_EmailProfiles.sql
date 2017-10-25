CREATE TABLE [dbo].[Notification_EmailProfiles]
(
[Status] [int] NOT NULL CONSTRAINT [DF__Notificat__Statu__0FADFA69] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__Notificati__Type__10A21EA2] DEFAULT ((0)),
[EmailTo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailCC] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailReplyTo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailSubject] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailBody] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAttachmentNames] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailFrom] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__Notificat__RowCr__119642DB] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Notificat__RowCr__128A6714] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__Notificat__RowMo__137E8B4D] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Notificat__RowMo__1472AF86] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Notification_EmailProfiles] ADD CONSTRAINT [PK__Notification_Ema__0EB9D630] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
