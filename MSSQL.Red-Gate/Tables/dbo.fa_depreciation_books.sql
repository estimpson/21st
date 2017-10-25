CREATE TABLE [dbo].[fa_depreciation_books]
(
[depreciation_book] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[depn_audit_trail] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_depreciation_books] ADD CONSTRAINT [pk_fa_depreciation_books] PRIMARY KEY CLUSTERED  ([depreciation_book]) ON [PRIMARY]
GO
