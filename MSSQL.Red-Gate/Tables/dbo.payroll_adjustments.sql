CREATE TABLE [dbo].[payroll_adjustments]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[payroll_date] [datetime] NOT NULL,
[entry_datetime] [datetime] NOT NULL,
[payroll_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours] [decimal] (18, 6) NULL,
[rate] [decimal] (18, 6) NULL,
[amount] [decimal] (18, 6) NULL,
[basis] [decimal] (18, 6) NULL,
[gross] [decimal] (18, 6) NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[basis_hours] [decimal] (18, 6) NULL,
[eir_business_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[payroll_adjustments] ADD CONSTRAINT [pk_payroll_adjustments] PRIMARY KEY CLUSTERED  ([employee], [payroll_date], [entry_datetime]) ON [PRIMARY]
GO
