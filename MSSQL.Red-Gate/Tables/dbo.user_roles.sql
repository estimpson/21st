CREATE TABLE [dbo].[user_roles]
(
[user_id] [uniqueidentifier] NOT NULL,
[role_id] [uniqueidentifier] NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_roles] ADD CONSTRAINT [pk_user_roles] PRIMARY KEY CLUSTERED  ([user_id], [role_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_roles] ADD CONSTRAINT [FK_user_roles_roles] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([role_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
