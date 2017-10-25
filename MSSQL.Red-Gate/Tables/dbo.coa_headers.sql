CREATE TABLE [dbo].[coa_headers]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[coa] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[coa_headers] ADD CONSTRAINT [pk_coa_headers] PRIMARY KEY CLUSTERED  ([fiscal_year], [coa]) ON [PRIMARY]
GO
