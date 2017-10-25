CREATE TABLE [dbo].[ledger_organization_levels]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[display_order] [smallint] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ledger_organization_levels] ADD CONSTRAINT [pk_ledger_organization_levels] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [organization_level]) ON [PRIMARY]
GO
