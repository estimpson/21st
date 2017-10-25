CREATE TABLE [dbo].[item_physical_inventory_result]
(
[physical_inventory_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[serial_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[phy_inv_date] [datetime] NULL,
[phy_inv_employee] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phy_inv_qty] [decimal] (18, 6) NULL,
[phy_inv_section] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phy_inv_aisle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phy_inv_shelf] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[item_physical_inventory_result] ADD CONSTRAINT [pk_item_physical_inv_result] PRIMARY KEY CLUSTERED  ([physical_inventory_id], [item], [location], [serial_number]) ON [PRIMARY]
GO
