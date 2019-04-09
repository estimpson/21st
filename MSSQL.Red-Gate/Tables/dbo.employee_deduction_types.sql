CREATE TABLE [dbo].[employee_deduction_types]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[deduction_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[begin_date] [datetime] NULL,
[end_date] [datetime] NULL,
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[max_ded_cycle] [decimal] (18, 6) NULL,
[max_ded_year] [decimal] (18, 6) NULL,
[max_ded_ltd] [decimal] (18, 6) NULL,
[vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_status] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transit_routing_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prenotes_required] [smallint] NULL,
[prenotes_given] [smallint] NULL,
[check_sequence] [smallint] NULL,
[dd_account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_message] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_foreign] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_foreign_bank] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exempt_amount] [decimal] (18, 6) NULL,
[employee_deduction_type_line] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_deduction_types] ADD CONSTRAINT [pk_employee_deduction_types] PRIMARY KEY CLUSTERED  ([employee], [deduction_type]) ON [PRIMARY]
GO
