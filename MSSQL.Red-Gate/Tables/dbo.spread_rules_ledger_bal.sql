CREATE TABLE [dbo].[spread_rules_ledger_bal]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[spread_rule] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[spread_rules_ledger_bal] ADD CONSTRAINT [pk_spread_rules_ledger_bal] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [ledger_account], [balance_name]) ON [PRIMARY]
GO
