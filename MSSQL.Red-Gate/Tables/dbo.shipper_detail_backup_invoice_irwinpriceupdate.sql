CREATE TABLE [dbo].[shipper_detail_backup_invoice_irwinpriceupdate]
(
[shipper] [int] NOT NULL,
[part_original] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oldprice] [numeric] (20, 6) NULL,
[newprice] [numeric] (10, 8) NOT NULL
) ON [PRIMARY]
GO
