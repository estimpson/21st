CREATE TABLE [dbo].[so_blanket_other_expenses]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[blanket_line] [smallint] NOT NULL,
[sort_line] [decimal] (8, 2) NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket_price] [decimal] (18, 6) NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cum_quantity_invoiced] [numeric] (18, 6) NULL,
[cum_invoiced_amount] [numeric] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_blanket_other_expenses] ADD CONSTRAINT [pk_so_blanket_other_expenses] PRIMARY KEY CLUSTERED  ([sales_order], [blanket_line]) ON [PRIMARY]
GO
