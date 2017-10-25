CREATE TABLE [dbo].[time_card_calendars]
(
[time_card_calendar] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[time_card_calendars] ADD CONSTRAINT [pk_time_card_calendars] PRIMARY KEY CLUSTERED  ([time_card_calendar]) ON [PRIMARY]
GO
