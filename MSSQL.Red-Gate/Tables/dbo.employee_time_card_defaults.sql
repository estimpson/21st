CREATE TABLE [dbo].[employee_time_card_defaults]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[time_card_sort] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scheduled_hours] [decimal] (18, 6) NULL,
[pieces_paid] [decimal] (18, 6) NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[additional_hours_pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[additional_hours_rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[additional_hours_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_time] [datetime] NULL,
[end_time] [datetime] NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_time_card_defaults] ADD CONSTRAINT [pk_employee_time_card_defaults] PRIMARY KEY CLUSTERED  ([employee], [time_card_sort]) ON [PRIMARY]
GO
