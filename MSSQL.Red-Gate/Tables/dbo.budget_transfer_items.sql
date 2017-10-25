CREATE TABLE [dbo].[budget_transfer_items]
(
[budget_transfer_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[budget_transfer_line] [smallint] NOT NULL,
[ledger_account] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transaction_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[budget_transfer_items] ADD CONSTRAINT [pk_budget_transfer_items] PRIMARY KEY CLUSTERED  ([budget_transfer_id], [budget_transfer_line]) ON [PRIMARY]
GO
