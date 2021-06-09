CREATE TABLE [dbo].[IrwinPriceImport]
(
[Part] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Price] [numeric] (20, 10) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IrwinPriceImport] ADD CONSTRAINT [PK_IrwinPriceImport] PRIMARY KEY CLUSTERED  ([Part]) ON [PRIMARY]
GO
