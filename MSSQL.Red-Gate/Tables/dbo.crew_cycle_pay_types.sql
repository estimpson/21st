CREATE TABLE [dbo].[crew_cycle_pay_types]
(
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cycle_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scheduled_hours] [decimal] (18, 6) NULL,
[scheduled_pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scheduled_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[additional_hours_pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[additional_hours_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[sort_line] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crew_cycle_pay_types] ADD CONSTRAINT [pk_crew_cycle_pay_types] PRIMARY KEY CLUSTERED  ([crew], [cycle_id], [scheduled_pay_type]) ON [PRIMARY]
GO
