CREATE TABLE [dbo].[user_secured_columns]
(
[security_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[secured_column_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[valid_values] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_secured_column_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_secured_columns] ADD CONSTRAINT [pk_user_secured_columns] PRIMARY KEY CLUSTERED  ([security_id], [secured_column_name], [user_secured_column_id]) ON [PRIMARY]
GO
