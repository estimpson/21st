CREATE TABLE [FT].[Users]
(
[UserID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Users__UserID__21C1BDAC] DEFAULT (newid()),
[OperatorCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginName] [sys].[sysname] NULL
) ON [PRIMARY]
GO
ALTER TABLE [FT].[Users] ADD CONSTRAINT [PK__Users__20CD9973] PRIMARY KEY CLUSTERED  ([UserID]) ON [PRIMARY]
GO
ALTER TABLE [FT].[Users] ADD CONSTRAINT [FK__Users__OperatorC__22B5E1E5] FOREIGN KEY ([OperatorCode]) REFERENCES [dbo].[employee] ([operator_code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
