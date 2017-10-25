CREATE TABLE [dbo].[fa_phy_inv_results]
(
[physical_inventory_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asset_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[phy_inv_date] [datetime] NULL,
[phy_inv_employee] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phy_inv_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phy_inv_depn_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_phy_inv_results] ADD CONSTRAINT [pk_fa_phy_inv_results] PRIMARY KEY CLUSTERED  ([physical_inventory_id], [asset_id]) ON [PRIMARY]
GO
