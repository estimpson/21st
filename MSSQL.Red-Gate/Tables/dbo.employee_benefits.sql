CREATE TABLE [dbo].[employee_benefits]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[benefit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NULL,
[end_date] [datetime] NULL,
[basis] [decimal] (18, 6) NULL,
[amount] [decimal] (18, 6) NULL,
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_sequence] [smallint] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deposit_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dependent_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[max_ben_year] [decimal] (18, 6) NULL,
[max_ben_ltd] [decimal] (18, 6) NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_benefits] ADD CONSTRAINT [pk_employee_benefits] PRIMARY KEY CLUSTERED  ([employee], [benefit]) ON [PRIMARY]
GO
