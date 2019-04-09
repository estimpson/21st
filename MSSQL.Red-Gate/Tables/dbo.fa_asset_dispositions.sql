CREATE TABLE [dbo].[fa_asset_dispositions]
(
[asset_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[disposition_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disposition_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disposition_date] [datetime] NULL,
[disposition_fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disposition_period] [int] NULL,
[disposition_proceeds] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_asset_dispositions] ADD CONSTRAINT [pk_fa_asset_dispositions] PRIMARY KEY CLUSTERED  ([asset_id]) ON [PRIMARY]
GO
