CREATE TABLE [dbo].[CommodityDefn]
(
[CommodityID] [int] NOT NULL IDENTITY(1, 1),
[ParentCommodityID] [int] NULL,
[CommodityCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommodityDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DrAccount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Virtual] [bit] NOT NULL CONSTRAINT [DF__Commodity__Virtu__0A54486F] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommodityDefn] ADD CONSTRAINT [PK__CommodityDefn__086BFFFD] PRIMARY KEY CLUSTERED  ([CommodityID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommodityDefn] ADD CONSTRAINT [FK__Commodity__Paren__09602436] FOREIGN KEY ([ParentCommodityID]) REFERENCES [dbo].[CommodityDefn] ([CommodityID])
GO
