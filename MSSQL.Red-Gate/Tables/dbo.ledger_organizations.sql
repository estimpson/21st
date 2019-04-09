CREATE TABLE [dbo].[ledger_organizations]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reports_to_organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reports_to_organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_segment] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[due_from_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_to_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[report_column] [smallint] NULL,
[report_column_description] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fund_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ledger_organizations] ADD CONSTRAINT [pk_ledger_organizations] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [organization_level], [organization]) ON [PRIMARY]
GO
