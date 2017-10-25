CREATE TABLE [dbo].[vendor_items]
(
[vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vendors_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_contract] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rating] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[received] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchasing_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_pricing_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchasing_to_po_pricing_conv] [decimal] (18, 6) NULL,
[receiver_tol_units] [decimal] (18, 6) NULL,
[receiver_tol_percent] [decimal] (5, 2) NULL,
[price_tol_dollars] [decimal] (18, 6) NULL,
[price_tol_percent] [decimal] (5, 2) NULL,
[shipping_quantity] [decimal] (18, 6) NULL,
[taxable_1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxable_2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_po_date] [datetime] NULL,
[last_po_quantity] [decimal] (18, 6) NULL,
[last_po_price] [decimal] (18, 6) NULL,
[last_po_lead_time] [smallint] NULL,
[avg_po_lead_time] [smallint] NULL,
[number_of_orders] [smallint] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expense_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price] [decimal] (18, 6) NULL,
[number_of_receipts] [smallint] NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_quantity_uom_to_standard] [decimal] (18, 6) NULL,
[po_price_uom_to_standard] [decimal] (18, 6) NULL,
[expense_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_vendor] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[required_days] [smallint] NULL,
[gross_price] [decimal] (18, 6) NULL,
[discount] [decimal] (18, 6) NULL,
[package_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_uom_to_purchasing] [decimal] (18, 6) NULL,
[label_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vendor_items] ADD CONSTRAINT [pk_vendor_items] PRIMARY KEY CLUSTERED  ([vendor], [item]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [vendor_items_item] ON [dbo].[vendor_items] ([item], [vendor]) ON [PRIMARY]
GO
