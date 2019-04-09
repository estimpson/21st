CREATE TABLE [dbo].[deduction_types]
(
[deduction_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[deduction_type_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_stub_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priority] [smallint] NULL,
[arrear] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee_ded_type_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_sequence] [smallint] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_invoice_by] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_id_scheme] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deduction_style] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title_iii] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enable_exempt_amount] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allow_employee_edit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[deduction_types] ADD CONSTRAINT [pk_deduction_types] PRIMARY KEY CLUSTERED  ([deduction_type]) ON [PRIMARY]
GO
