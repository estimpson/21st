CREATE TABLE [dbo].[signature_list_accounts]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[signature_list] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beginning_organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ending_organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beginning_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ending_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[signature_list_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[signature_list_accounts] ADD CONSTRAINT [pk_signature_list_accounts] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [signature_list], [signature_list_id]) ON [PRIMARY]
GO
