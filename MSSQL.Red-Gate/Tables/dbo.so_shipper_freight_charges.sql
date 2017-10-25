CREATE TABLE [dbo].[so_shipper_freight_charges]
(
[shipper] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sort_line] [decimal] (18, 6) NULL,
[shipper_line] [smallint] NOT NULL,
[invoiced_amount] [decimal] (18, 6) NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[estimated_cost] [decimal] (18, 6) NULL,
[so_line] [smallint] NULL,
[freight_carrier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_of_lading] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_rma_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_shipper_freight_charges] ADD CONSTRAINT [pk_so_shipper_freight_charges] PRIMARY KEY CLUSTERED  ([shipper], [shipper_rma_flag], [shipper_line]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [shipper_freight_sales_order] ON [dbo].[so_shipper_freight_charges] ([sales_order], [so_line]) ON [PRIMARY]
GO
