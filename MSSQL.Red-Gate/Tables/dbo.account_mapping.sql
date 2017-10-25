CREATE TABLE [dbo].[account_mapping]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[old_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[old_account_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_mapping] ADD CONSTRAINT [pk_account_mapping] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [old_account]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [account_mapping_ledger_account] ON [dbo].[account_mapping] ([fiscal_year], [ledger], [ledger_account]) ON [PRIMARY]
GO
