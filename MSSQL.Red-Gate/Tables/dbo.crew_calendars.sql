CREATE TABLE [dbo].[crew_calendars]
(
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calendar_date] [datetime] NOT NULL,
[calendar_date_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shift_worked] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_hours] [decimal] (18, 6) NULL,
[scheduled_pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[additional_hours_pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[additional_hours_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crew_calendars] ADD CONSTRAINT [pk_crew_calendars] PRIMARY KEY CLUSTERED  ([crew], [calendar_date], [calendar_date_id]) ON [PRIMARY]
GO
