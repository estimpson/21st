CREATE TABLE [dbo].[ledger_balances_temporary]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [smallint] NOT NULL,
[period_amount] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ledger_balances_temporary] ADD CONSTRAINT [pk_ledger_balances_temporary] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [ledger_account], [balance_name], [period]) ON [PRIMARY]
GO
