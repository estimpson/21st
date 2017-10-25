CREATE TABLE [dbo].[preferences_standard]
(
[preference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_changeable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[version] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[validate_style] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[validate_object] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[installed_module] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value_standard] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[preferences_standard] ADD CONSTRAINT [pk_preferences_standard] PRIMARY KEY CLUSTERED  ([preference]) ON [PRIMARY]
GO
