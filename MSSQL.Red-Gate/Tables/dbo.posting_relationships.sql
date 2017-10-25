CREATE TABLE [dbo].[posting_relationships]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[relationship] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[to_ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[to_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[posting_relationships] ADD CONSTRAINT [pk_posting_relationships] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [ledger_account], [relationship], [to_ledger], [to_ledger_account]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [post_rel_to_ledger_account] ON [dbo].[posting_relationships] ([fiscal_year], [to_ledger], [to_ledger_account]) ON [PRIMARY]
GO
