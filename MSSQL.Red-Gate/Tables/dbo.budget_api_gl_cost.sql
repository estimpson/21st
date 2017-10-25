CREATE TABLE [dbo].[budget_api_gl_cost]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger_account] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [smallint] NOT NULL,
[amount] [numeric] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[budget_api_gl_cost] ADD CONSTRAINT [pk_budget_api_gl_cost] PRIMARY KEY NONCLUSTERED  ([fiscal_year], [ledger], [organization_level], [organization], [balance_name], [ledger_account], [period]) ON [PRIMARY]
GO
