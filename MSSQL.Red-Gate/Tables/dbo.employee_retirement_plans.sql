CREATE TABLE [dbo].[employee_retirement_plans]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[retirement_plan] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NULL,
[end_date] [datetime] NULL,
[percent_rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount_rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[r_cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[r_dr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_sequence] [smallint] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deposit_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_retirement_plans] ADD CONSTRAINT [pk_employee_retirement_plans] PRIMARY KEY CLUSTERED  ([employee], [retirement_plan]) ON [PRIMARY]
GO
