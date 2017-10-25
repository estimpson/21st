CREATE TABLE [dbo].[secured_column_group_roles]
(
[secured_column_group_id] [uniqueidentifier] NOT NULL,
[role_id] [uniqueidentifier] NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[secured_column_group_roles] ADD CONSTRAINT [pk_secured_column_group_roles] PRIMARY KEY CLUSTERED  ([secured_column_group_id], [role_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[secured_column_group_roles] ADD CONSTRAINT [FK_secured_column_group_roles_roles] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([role_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[secured_column_group_roles] ADD CONSTRAINT [FK_secured_column_group_roles_secured_column_groups] FOREIGN KEY ([secured_column_group_id]) REFERENCES [dbo].[secured_column_groups] ([secured_column_group_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
