CREATE TABLE [dbo].[so_blanket_items]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[blanket_line] [smallint] NOT NULL,
[sort_line] [decimal] (8, 2) NULL,
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selling_qty_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selling_price_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selling_to_price_conv] [decimal] (18, 6) NULL,
[blanket_price] [decimal] (18, 6) NULL,
[cum_quantity_ordered] [numeric] (18, 6) NULL,
[cum_extended_amount] [numeric] (18, 6) NULL,
[fulfillment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fulfillment_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_line_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selling_uom_to_standard] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_blanket_items] ADD CONSTRAINT [pk_so_blanket_items] PRIMARY KEY CLUSTERED  ([sales_order], [blanket_line]) ON [PRIMARY]
GO
