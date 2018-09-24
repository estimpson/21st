CREATE TABLE [dbo].[ap_headers]
(
[vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[inv_cm_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invoice_cm] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[buy_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entered_datetime] [datetime] NULL,
[contract] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[voucher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inv_cm_date] [datetime] NULL,
[received_date] [datetime] NULL,
[due_date] [datetime] NULL,
[discount_date] [datetime] NULL,
[inv_cm_amount] [decimal] (18, 6) NULL,
[tax_amount] [decimal] (18, 6) NULL,
[freight_amount] [decimal] (18, 6) NULL,
[applied_amount] [decimal] (18, 6) NULL,
[select_for_pay_amount] [decimal] (18, 6) NULL,
[matched] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[matched_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hold_inv_cm] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[separate_check] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_date] [datetime] NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_selection_identifier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[intercompany] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exchanged_amount] [decimal] (18, 6) NULL,
[exchanged_sel_for_pay_amount] [decimal] (18, 6) NULL,
[exchanged_applied_amount] [decimal] (18, 6) NULL,
[check_message] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved_date] [datetime] NULL,
[pay_vendor_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_postal_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ap_headers] ADD CONSTRAINT [pk_ap_headers] PRIMARY KEY NONCLUSTERED  ([vendor], [invoice_cm], [inv_cm_flag]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [apheaders_approver] ON [dbo].[ap_headers] ([approver]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [apheaders_batch] ON [dbo].[ap_headers] ([batch]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_AP_Headers_1] ON [dbo].[ap_headers] ([invoice_cm], [inv_cm_flag], [gl_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [apheaders_pay_invcm] ON [dbo].[ap_headers] ([pay_vendor], [inv_cm_flag], [invoice_cm]) ON [PRIMARY]
GO
