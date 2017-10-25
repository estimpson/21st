CREATE TABLE [dbo].[preferences_site_backup]
(
[preference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_changeable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
