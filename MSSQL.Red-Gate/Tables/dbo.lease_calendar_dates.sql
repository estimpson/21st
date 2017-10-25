CREATE TABLE [dbo].[lease_calendar_dates]
(
[lease_space] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calendar_date] [datetime] NOT NULL,
[lease] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lease_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attended_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lease_calendar_identity] [int] NOT NULL IDENTITY(1, 1),
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[amount_collected] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lease_calendar_dates] ADD CONSTRAINT [pk_lease_calendar_dates] PRIMARY KEY CLUSTERED  ([lease_space], [calendar_date], [lease_calendar_identity]) ON [PRIMARY]
GO
