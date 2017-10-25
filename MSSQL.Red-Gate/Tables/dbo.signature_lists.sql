CREATE TABLE [dbo].[signature_lists]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[signature_list] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[priority] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[breakpoint] [int] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approver_sequence] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[signature_lists] ADD CONSTRAINT [pk_signature_lists] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [signature_list], [approver]) ON [PRIMARY]
GO
