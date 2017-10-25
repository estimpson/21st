CREATE TABLE [dbo].[employee_pay_types]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NULL,
[end_date] [datetime] NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_sequence] [smallint] NULL,
[pay_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_cost_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_cost_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[standard_cycle_hours] [decimal] (18, 6) NULL,
[max_hours_cycle] [decimal] (18, 6) NULL,
[max_pay_cycle] [decimal] (18, 6) NULL,
[max_hours_year] [decimal] (18, 6) NULL,
[max_pay_year] [decimal] (18, 6) NULL,
[max_hours_ltd] [decimal] (18, 6) NULL,
[max_pay_ltd] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[base_pay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_id_change_date] [datetime] NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_pay_types] ADD CONSTRAINT [pk_employee_pay_types] PRIMARY KEY CLUSTERED  ([employee], [pay_type]) ON [PRIMARY]
GO
