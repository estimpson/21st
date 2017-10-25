CREATE TABLE [dbo].[preferences_user]
(
[preference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[security_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preference_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[preferences_user] ADD CONSTRAINT [pk_preferences_user] PRIMARY KEY CLUSTERED  ([preference], [security_id]) ON [PRIMARY]
GO
