CREATE TABLE [dbo].[chart_of_accounts]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[coa] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[account_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[balance_profit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[debit_credit_stat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profit_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profit_group_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_4] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_5] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_6] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_7] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_8] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_9] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_10] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_1_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_2_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_3_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_4_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_5_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_6_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_7_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_8_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_9_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_10_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cash_flow_line] [smallint] NULL,
[prior_year_purchases_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wages_benefits] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[chart_of_accounts] ADD CONSTRAINT [pk_chart_of_accounts] PRIMARY KEY NONCLUSTERED  ([fiscal_year], [coa], [account]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [chart_of_accounts_desc] ON [dbo].[chart_of_accounts] ([account_description]) ON [PRIMARY]
GO
