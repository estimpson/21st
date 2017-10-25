CREATE TABLE [dbo].[coa_items]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[coa] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[account_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_level] [smallint] NULL,
[balance_profit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[debit_credit_stat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cash_flow_line] [smallint] NULL,
[parent_account] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prior_year_purchases_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort_line] [numeric] (8, 2) NULL,
[wages_benefits] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[coa_items] ADD CONSTRAINT [pk_coa_items] PRIMARY KEY CLUSTERED  ([fiscal_year], [coa], [account], [account_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[coa_items] ADD CONSTRAINT [FK_coa_items_coa_headers] FOREIGN KEY ([fiscal_year], [coa]) REFERENCES [dbo].[coa_headers] ([fiscal_year], [coa]) ON DELETE CASCADE ON UPDATE CASCADE
GO
