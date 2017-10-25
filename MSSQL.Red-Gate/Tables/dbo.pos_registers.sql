CREATE TABLE [dbo].[pos_registers]
(
[pos_register] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pccharge_user] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pos_register_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pccharge_path] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pccharge_processor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pccharge_merchant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pccharge_timeout] [smallint] NULL,
[pccharge_lastvaliddate] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[pos_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_credit_enabled] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_cash_enabled] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_check_enabled] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_onaccount_enabled] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_invoice_credit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_invoice_cash] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_invoice_check] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_invoice_onaccount] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_receipt_credit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_receipt_cash] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_receipt_check] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_printer] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receipt_printer] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receipt_name_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventory_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[number_of_receipts] [smallint] NULL,
[prepayment_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pos_registers] ADD CONSTRAINT [pk_pos_registers] PRIMARY KEY CLUSTERED  ([pos_register]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
