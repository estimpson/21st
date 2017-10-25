CREATE TABLE [dbo].[cost_accounts]
(
[cost_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cost_account_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[budget] [decimal] (18, 6) NULL,
[cost_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_sub] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_accounts] ADD CONSTRAINT [pk_cost_accounts] PRIMARY KEY CLUSTERED  ([cost_account]) ON [PRIMARY]
GO
