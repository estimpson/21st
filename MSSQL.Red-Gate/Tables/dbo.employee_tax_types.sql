CREATE TABLE [dbo].[employee_tax_types]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tax_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[marital_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exemptions] [smallint] NULL,
[additional_tax] [decimal] (18, 6) NULL,
[dr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_sequence] [smallint] NULL,
[begin_date] [datetime] NULL,
[end_date] [datetime] NULL,
[exempt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fcit_annual_taxable_reduction] [decimal] (18, 6) NULL,
[wcb_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[federal_tax_credit_rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[federal_tax_credit_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_tax_credit_rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_tax_credit_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee_tax_percent] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_tax_types] ADD CONSTRAINT [pk_employee_tax_types] PRIMARY KEY CLUSTERED  ([employee], [tax_type]) ON [PRIMARY]
GO
