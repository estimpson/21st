CREATE TABLE [dbo].[navigation_group_options]
(
[navigation_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tablet] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_option_read_only] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[navigation_group_options] ADD CONSTRAINT [pk_navigation_group_options] PRIMARY KEY CLUSTERED  ([navigation_group], [tablet], [option_description]) ON [PRIMARY]
GO
