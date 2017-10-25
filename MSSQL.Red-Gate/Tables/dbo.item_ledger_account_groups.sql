CREATE TABLE [dbo].[item_ledger_account_groups]
(
[item_ledger_account_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receive_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[issue_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adjust_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receive_ledger_account_credit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[issue_ledger_account_credit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adjust_ledger_account_credit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[variance_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[item_ledger_account_groups] ADD CONSTRAINT [pk_item_ledger_account_groups] PRIMARY KEY CLUSTERED  ([item_ledger_account_group]) ON [PRIMARY]
GO
