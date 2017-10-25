CREATE TABLE [dbo].[option_group_roles]
(
[option_group_id] [uniqueidentifier] NOT NULL,
[role_id] [uniqueidentifier] NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[option_group_roles] ADD CONSTRAINT [pk_option_group_roles] PRIMARY KEY CLUSTERED  ([option_group_id], [role_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[option_group_roles] ADD CONSTRAINT [FK_option_group_roles_option_groups] FOREIGN KEY ([option_group_id]) REFERENCES [dbo].[option_groups] ([option_group_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[option_group_roles] ADD CONSTRAINT [FK_option_group_roles_roles] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([role_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
