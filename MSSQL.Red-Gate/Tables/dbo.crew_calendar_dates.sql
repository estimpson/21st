CREATE TABLE [dbo].[crew_calendar_dates]
(
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calendar_date] [datetime] NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crew_calendar_dates] ADD CONSTRAINT [pk_crew_calendar_dates] PRIMARY KEY CLUSTERED  ([crew], [calendar_date]) ON [PRIMARY]
GO
