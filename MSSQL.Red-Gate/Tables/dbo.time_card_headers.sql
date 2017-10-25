CREATE TABLE [dbo].[time_card_headers]
(
[payroll_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[time_card_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[payroll_date] [datetime] NOT NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_submitted] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[time_card_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_payroll_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[time_card_headers] ADD CONSTRAINT [pk_time_card_headers] PRIMARY KEY CLUSTERED  ([payroll_cycle], [time_card_group], [payroll_date], [time_card_type]) ON [PRIMARY]
GO
