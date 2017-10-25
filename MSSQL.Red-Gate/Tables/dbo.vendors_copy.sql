CREATE TABLE [dbo].[vendors_copy]
(
[vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[intercompany] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_contract] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_separate_check] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_hold_payment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_invoice_limit] [decimal] (18, 6) NULL,
[hdr_ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_disc_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_expense_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_freight] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_remittance_advice] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_minimum_check_amount] [decimal] (18, 6) NULL,
[d1099_1099_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[d1099_1099_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[d1099_federal_tax_id] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[d1099_state_tax_id] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_buy_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_pay_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_contract_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_contract_account_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_costrevenue_type_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_rni_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_po_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_po_document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_buyer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_freight_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_po_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disadvantaged_business_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_check_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_check_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[d1099_1099_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_invoice_approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_po_approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transit_routing_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prenotes_required] [smallint] NULL,
[prenotes_given] [smallint] NULL,
[last_document_group_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_sales_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_sales_terms_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_notification_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_notification_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO