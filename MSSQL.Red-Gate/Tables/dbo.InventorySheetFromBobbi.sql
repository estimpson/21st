CREATE TABLE [dbo].[InventorySheetFromBobbi]
(
[Part] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Inventory] [numeric] (12, 6) NULL,
[UnitCost] [numeric] (12, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InventorySheetFromBobbi] ADD CONSTRAINT [PK_InventorySheetFromBobbi] PRIMARY KEY CLUSTERED  ([Part]) ON [PRIMARY]
GO
