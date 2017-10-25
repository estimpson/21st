CREATE TABLE [dbo].[user_sessions]
(
[session_id] [uniqueidentifier] NOT NULL,
[user_id] [uniqueidentifier] NULL,
[expiration_date] [datetime] NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_sessions] ADD CONSTRAINT [pk_user_sessions] PRIMARY KEY CLUSTERED  ([session_id]) ON [PRIMARY]
GO
