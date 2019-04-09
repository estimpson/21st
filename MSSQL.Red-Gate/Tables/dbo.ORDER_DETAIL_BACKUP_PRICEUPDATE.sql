CREATE TABLE [dbo].[ORDER_DETAIL_BACKUP_PRICEUPDATE]
(
[order_no] [numeric] (8, 0) NOT NULL,
[OLDPRICE] [numeric] (20, 6) NULL,
[NEWPRICE] [numeric] (10, 8) NOT NULL,
[part_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Part] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
