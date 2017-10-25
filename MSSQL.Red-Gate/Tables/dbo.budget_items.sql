CREATE TABLE [dbo].[budget_items]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger_account] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[budget] [numeric] (18, 6) NULL,
[spread_rule] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[budget_items] ADD CONSTRAINT [pk_budget_items] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [balance_name], [organization_level], [organization], [ledger_account]) ON [PRIMARY]
GO
