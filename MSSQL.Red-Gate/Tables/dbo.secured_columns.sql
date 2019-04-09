CREATE TABLE [dbo].[secured_columns]
(
[secured_column_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[security_enabled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[secured_column_start] [smallint] NULL,
[secured_column_length] [smallint] NULL,
[installed_module] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[net_secured_column] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[secured_columns] ADD CONSTRAINT [pk_secured_columns] PRIMARY KEY CLUSTERED  ([secured_column_name]) ON [PRIMARY]
GO
