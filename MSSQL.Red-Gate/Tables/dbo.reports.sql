CREATE TABLE [dbo].[reports]
(
[report_id] [int] NOT NULL,
[report_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[reports] ADD CONSTRAINT [pk_reports] PRIMARY KEY CLUSTERED  ([report_id]) ON [PRIMARY]
GO
