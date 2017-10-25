CREATE TABLE [dbo].[po_blanket_items]
(
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[blanket_line] [smallint] NOT NULL,
[sort_line] [numeric] (8, 2) NULL,
[line_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendors_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receiver] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_carrier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expense_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[variance_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[max_quantity_ordered] [numeric] (18, 6) NULL,
[purchasing_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_pricing_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchasing_to_po_pricing_conv] [numeric] (18, 6) NULL,
[po_quantity_uom_to_standard] [numeric] (18, 6) NULL,
[max_price] [numeric] (18, 6) NULL,
[max_extended_amount] [numeric] (18, 6) NULL,
[inventoried] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cum_quantity_ordered] [numeric] (18, 6) NULL,
[cum_extended_amount] [numeric] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_uom_to_purchasing] [decimal] (18, 6) NULL,
[package_label_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[po_blanket_items] ADD CONSTRAINT [pk_po_blanket_items] PRIMARY KEY CLUSTERED  ([purchase_order], [blanket_line]) ON [PRIMARY]
GO
