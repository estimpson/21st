CREATE TABLE [dbo].[navigation_groups]
(
[navigation_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[navigation_groups] ADD CONSTRAINT [pk_navigation_groups] PRIMARY KEY CLUSTERED  ([navigation_group]) ON [PRIMARY]
GO
