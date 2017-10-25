CREATE TABLE [dbo].[nav_tab_opt_changes]
(
[nav_tab_opt_changes_identity] [int] NOT NULL IDENTITY(1, 1),
[option_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[old_tablet] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[new_tablet] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[nav_tab_opt_changes] ADD CONSTRAINT [pk_nav_tab_opt_changes] PRIMARY KEY CLUSTERED  ([nav_tab_opt_changes_identity]) ON [PRIMARY]
GO
