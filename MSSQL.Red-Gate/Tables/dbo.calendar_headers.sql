CREATE TABLE [dbo].[calendar_headers]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calendar] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[calendar_headers] ADD CONSTRAINT [pk_calendar_headers] PRIMARY KEY CLUSTERED  ([fiscal_year], [calendar]) ON [PRIMARY]
GO
