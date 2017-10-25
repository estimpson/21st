CREATE TABLE [dbo].[navigation_tablet_options]
(
[tablet] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_order] [smallint] NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[installed_module] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[standard] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[navigation_tablet_options] ADD CONSTRAINT [pk_navigation_tablet_options] PRIMARY KEY CLUSTERED  ([tablet], [option_description]) ON [PRIMARY]
GO
