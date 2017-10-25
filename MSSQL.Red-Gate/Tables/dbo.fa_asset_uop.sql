CREATE TABLE [dbo].[fa_asset_uop]
(
[asset_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[uop_date] [datetime] NOT NULL,
[uop_units] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_asset_uop] ADD CONSTRAINT [pk_fa_asset_uop] PRIMARY KEY CLUSTERED  ([asset_id], [uop_date]) ON [PRIMARY]
GO
