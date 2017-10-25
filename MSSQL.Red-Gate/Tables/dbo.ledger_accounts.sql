CREATE TABLE [dbo].[ledger_accounts]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[posting_reporting] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[balance_profit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profit_loss_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exchange_gain_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exchange_loss_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_year_ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_year_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[encumbrance_group] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exchange_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exchange_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_register_update] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ledger_accounts] ADD CONSTRAINT [pk_ledger_accounts] PRIMARY KEY NONCLUSTERED  ([fiscal_year], [ledger], [ledger_account]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ledger_accounts_account] ON [dbo].[ledger_accounts] ([fiscal_year], [ledger], [account]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ledger_accounts_encum_group] ON [dbo].[ledger_accounts] ([fiscal_year], [ledger], [encumbrance_group]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ledger_accounts_organization] ON [dbo].[ledger_accounts] ([fiscal_year], [ledger], [organization_level], [organization]) ON [PRIMARY]
GO
