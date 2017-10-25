CREATE TABLE [dbo].[time_card_calendar_schedule]
(
[time_card_calendar] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calendar_date] [datetime] NOT NULL,
[calendar_date_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calendar_year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_hours] [decimal] (18, 6) NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[additional_hours_pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[additional_hours_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_time] [datetime] NULL,
[end_time] [datetime] NULL,
[pieces_paid] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[time_card_calendar_schedule] ADD CONSTRAINT [pk_time_card_calendar_schedule] PRIMARY KEY CLUSTERED  ([time_card_calendar], [calendar_date], [calendar_date_id]) ON [PRIMARY]
GO
