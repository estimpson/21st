CREATE TABLE [dbo].[fa_asset_depreciation_audit]
(
[asset_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[depreciation_book] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fiscal_period] [int] NOT NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asset_life] [decimal] (18, 6) NULL,
[depreciation_method] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[depreciation_basis] [decimal] (18, 6) NULL,
[depreciation_ltd] [decimal] (18, 6) NULL,
[depreciation_period] [decimal] (18, 6) NULL,
[depreciation_calc_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[depreciation_date] [datetime] NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[depreciation_accum_or_exp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glentry_fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glentry_fiscal_period] [int] NULL,
[gl_date] [datetime] NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_asset_depreciation_audit] ADD CONSTRAINT [pk_fa_asset_depreciation_audit] PRIMARY KEY CLUSTERED  ([asset_id], [depreciation_book], [fiscal_year], [fiscal_period], [ledger_account], [depreciation_calc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fa_asset_depr_audit_calcid] ON [dbo].[fa_asset_depreciation_audit] ([depreciation_calc_id]) ON [PRIMARY]
GO
