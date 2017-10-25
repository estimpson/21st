CREATE TABLE [dbo].[ar_items]
(
[document_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_line] [smallint] NOT NULL,
[sort_line] [smallint] NULL,
[line_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [decimal] (18, 6) NULL,
[pricing_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_price] [decimal] (18, 6) NULL,
[extended_amount] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selling_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_analysis_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selling_to_price_conv] [decimal] (18, 5) NULL,
[selling_to_sa_conv] [decimal] (18, 5) NULL,
[total_cost] [decimal] (18, 6) NULL,
[shipper] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_line] [smallint] NULL,
[invoice_line_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_agent_percent] [decimal] (18, 6) NULL,
[account_manager_percent] [decimal] (18, 6) NULL,
[country_of_origin] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_line] [smallint] NULL,
[customer_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_eligible] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_items] ADD CONSTRAINT [pk_ar_items] PRIMARY KEY CLUSTERED  ([document_type], [document], [document_line]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ar_items_sales_order] ON [dbo].[ar_items] ([sales_order], [so_line], [document]) ON [PRIMARY]
GO
