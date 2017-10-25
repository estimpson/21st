CREATE TABLE [dbo].[ledger_definition]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[posting_consolidating] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calendar] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entry_identifier] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_scheme] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_period_closed] [smallint] NULL,
[profit_loss_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[retained_earnings_ledger_acct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ledger_definition] ADD CONSTRAINT [pk_ledger_definition] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger]) ON [PRIMARY]
GO
