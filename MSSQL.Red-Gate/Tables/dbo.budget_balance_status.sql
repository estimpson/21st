CREATE TABLE [dbo].[budget_balance_status]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[open_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[budget_balance_status] ADD CONSTRAINT [pk_budget_balance_status] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [balance_name]) ON [PRIMARY]
GO
