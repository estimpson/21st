CREATE TABLE [dbo].[fa_asset_groups]
(
[asset_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asset_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_asset_groups] ADD CONSTRAINT [pk_fa_asset_groups] PRIMARY KEY CLUSTERED  ([asset_id], [asset_group]) ON [PRIMARY]
GO
