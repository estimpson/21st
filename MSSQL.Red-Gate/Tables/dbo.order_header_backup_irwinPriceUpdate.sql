CREATE TABLE [dbo].[order_header_backup_irwinPriceUpdate]
(
[order_no] [numeric] (8, 0) NOT NULL,
[oldprice] [decimal] (20, 6) NULL,
[blanket_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[newprice] [numeric] (10, 8) NOT NULL
) ON [PRIMARY]
GO
