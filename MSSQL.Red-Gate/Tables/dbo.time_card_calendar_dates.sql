CREATE TABLE [dbo].[time_card_calendar_dates]
(
[time_card_calendar] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calendar_date] [datetime] NOT NULL,
[calendar_year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[override_employee_defaults] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[time_card_calendar_dates] ADD CONSTRAINT [pk_time_card_calendar_dates] PRIMARY KEY CLUSTERED  ([time_card_calendar], [calendar_date]) ON [PRIMARY]
GO
