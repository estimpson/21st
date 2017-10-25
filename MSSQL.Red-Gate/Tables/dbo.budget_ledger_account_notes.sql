CREATE TABLE [dbo].[budget_ledger_account_notes]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_id] [int] NOT NULL IDENTITY(1, 1),
[note_date] [datetime] NOT NULL,
[note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[follow_up_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[budget_ledger_account_notes] ADD CONSTRAINT [pk_budget_ledger_account_notes] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [balance_name], [ledger_account], [note_id]) ON [PRIMARY]
GO
