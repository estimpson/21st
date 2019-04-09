CREATE TABLE [dbo].[budget_transfer_headers]
(
[budget_transfer_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transfer_description] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transaction_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transfer_date] [datetime] NULL,
[spread_rule] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount_1] [numeric] (18, 6) NULL,
[amount_2] [numeric] (18, 6) NULL,
[amount_3] [numeric] (18, 6) NULL,
[amount_4] [numeric] (18, 6) NULL,
[amount_5] [numeric] (18, 6) NULL,
[amount_6] [numeric] (18, 6) NULL,
[amount_7] [numeric] (18, 6) NULL,
[amount_8] [numeric] (18, 6) NULL,
[amount_9] [numeric] (18, 6) NULL,
[amount_10] [numeric] (18, 6) NULL,
[amount_11] [numeric] (18, 6) NULL,
[amount_12] [numeric] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[budget_transfer_headers] ADD CONSTRAINT [pk_budget_transfer_headers] PRIMARY KEY CLUSTERED  ([budget_transfer_id]) ON [PRIMARY]
GO
