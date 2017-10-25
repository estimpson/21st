CREATE TABLE [dbo].[signature_list_workflows]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[signature_list] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[workflow] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[list_uses_accounts] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column_source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[signature_list_workflows] ADD CONSTRAINT [pk_signature_list_workflows] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [signature_list], [workflow]) ON [PRIMARY]
GO
