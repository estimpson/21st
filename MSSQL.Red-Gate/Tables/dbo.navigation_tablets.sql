CREATE TABLE [dbo].[navigation_tablets]
(
[tablet] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tablet_title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[standard] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[navigation_tablets] ADD CONSTRAINT [pk_navigation_tablets] PRIMARY KEY CLUSTERED  ([tablet]) ON [PRIMARY]
GO
