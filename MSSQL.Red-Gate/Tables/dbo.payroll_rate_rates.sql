CREATE TABLE [dbo].[payroll_rate_rates]
(
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NOT NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rate] [decimal] (18, 6) NULL,
[ledger] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[rate_action] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_action_value] [decimal] (18, 6) NULL,
[base_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[payroll_rate_rates] ADD CONSTRAINT [pk_payroll_rate_rates] PRIMARY KEY CLUSTERED  ([rate_id], [begin_date], [rate_event]) ON [PRIMARY]
GO
