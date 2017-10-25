CREATE TABLE [dbo].[so_shipper_discounts]
(
[shipper] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sort_line] [decimal] (18, 6) NULL,
[shipper_line] [smallint] NOT NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_percent] [decimal] (18, 6) NULL,
[discount_basis] [decimal] (18, 6) NULL,
[discount_amount] [decimal] (18, 6) NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contract_account_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_agent_percent] [decimal] (18, 6) NULL,
[account_manager_percent] [decimal] (18, 6) NULL,
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_rma_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_shipper_discounts] ADD CONSTRAINT [pk_so_shipper_discounts] PRIMARY KEY CLUSTERED  ([shipper], [shipper_rma_flag], [shipper_line]) ON [PRIMARY]
GO
