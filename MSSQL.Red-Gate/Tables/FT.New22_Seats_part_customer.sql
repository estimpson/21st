CREATE TABLE [FT].[New22_Seats_part_customer]
(
[part] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_standard_pack] [numeric] (20, 6) NOT NULL,
[taxable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_unit] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upc_code] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket_price] [numeric] (20, 6) NULL
) ON [PRIMARY]
GO
