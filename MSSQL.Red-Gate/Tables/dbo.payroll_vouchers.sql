CREATE TABLE [dbo].[payroll_vouchers]
(
[payroll_calculation_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[voucher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[voucher_sequence] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_number] [int] NULL,
[check_void] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[check_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_end_date] [datetime] NULL,
[calendar_year] [smallint] NULL,
[amount] [decimal] (18, 6) NULL,
[exchanged_amount] [decimal] (18, 6) NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_date] [datetime] NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employment_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transit_routing_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_message] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eir_business_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[t4a] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[province_id] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_foreign] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_foreign_bank] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_type_before_void] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[payroll_vouchers] ADD CONSTRAINT [pk_payroll_vouchers] PRIMARY KEY CLUSTERED  ([payroll_calculation_id], [voucher], [voucher_sequence], [check_void]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [payroll_vouchers_check_number] ON [dbo].[payroll_vouchers] ([bank_alias], [check_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [payroll_vouchers_unit] ON [dbo].[payroll_vouchers] ([calendar_year], [unit], [eir_business_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [payroll_vouchers_employee] ON [dbo].[payroll_vouchers] ([employee], [check_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [payroll_vouchers_end_date] ON [dbo].[payroll_vouchers] ([period_end_date], [bank_alias], [check_number]) ON [PRIMARY]
GO
