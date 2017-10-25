CREATE TABLE [dbo].[fa_depn_calc_id]
(
[depreciation_calc_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[depreciation_date] [datetime] NOT NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asset_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_depn_calc_id] ADD CONSTRAINT [pk_fa_depn_calc_id] PRIMARY KEY CLUSTERED  ([depreciation_calc_id]) ON [PRIMARY]
GO
