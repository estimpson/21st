CREATE TABLE [dbo].[retirement_adjustments]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[payroll_date] [datetime] NOT NULL,
[entry_datetime] [datetime] NOT NULL,
[payroll_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[retirement_plan] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [decimal] (18, 6) NULL,
[basis] [decimal] (18, 6) NULL,
[payer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payroll_calculation_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_sequence] [smallint] NULL,
[voucher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_void] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[arrear_calculation_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[arrear_voucher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[basis_hours] [decimal] (18, 6) NULL,
[adjustment_identity] [int] NOT NULL IDENTITY(1, 1),
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[retirement_adjustments] ADD CONSTRAINT [pk_retirement_adjustments] PRIMARY KEY CLUSTERED  ([employee], [payroll_date], [entry_datetime], [adjustment_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [retirement_adj_cycle_employee] ON [dbo].[retirement_adjustments] ([payroll_cycle], [employee], [voucher]) ON [PRIMARY]
GO
