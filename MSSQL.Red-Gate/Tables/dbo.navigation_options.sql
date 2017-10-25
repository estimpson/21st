CREATE TABLE [dbo].[navigation_options]
(
[option_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[option_parameters] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[option_help_message] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[menu] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[menu_module] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[menu_item_sort_order] [int] NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[standard] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[navigation_options] ADD CONSTRAINT [pk_navigation_options] PRIMARY KEY CLUSTERED  ([option_description]) ON [PRIMARY]
GO
