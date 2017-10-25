CREATE TABLE [dbo].[roles]
(
[role_id] [uniqueidentifier] NOT NULL,
[role_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[roles] ADD CONSTRAINT [pk_roles] PRIMARY KEY CLUSTERED  ([role_id]) ON [PRIMARY]
GO
