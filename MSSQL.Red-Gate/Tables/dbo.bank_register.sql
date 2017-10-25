CREATE TABLE [dbo].[bank_register]
(
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_number] [int] NOT NULL,
[check_void_nsf] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_id2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_id3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_date] [datetime] NULL,
[document_amount] [decimal] (18, 6) NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_date] [datetime] NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[exchanged_amount] [decimal] (18, 6) NULL,
[document_exchange_rate] [decimal] (12, 6) NULL,
[reconciled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reconciled_date] [datetime] NULL,
[reconciled_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_group_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_group_date] [datetime] NULL,
[applied_amount] [decimal] (18, 6) NULL,
[last_date_applied] [datetime] NULL,
[last_fiscal_year_applied] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_period_applied] [smallint] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offset_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account_debit_credit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_reference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_remarks] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_postal_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transit_routing_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[application_currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[application_check_amount] [decimal] (18, 6) NULL,
[application_applied_amount] [decimal] (18, 6) NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_reference2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pos_document_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type_before_void] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_transfer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[bank_register] ADD CONSTRAINT [pk_bank_register] PRIMARY KEY NONCLUSTERED  ([bank_alias], [document_class], [document_number], [check_void_nsf]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [bankregister_docgroupid_key] ON [dbo].[bank_register] ([bank_alias], [document_group_id]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [bank_register_class] ON [dbo].[bank_register] ([document_class], [document_id2], [document_id3]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [bank_register_date] ON [dbo].[bank_register] ([document_date], [document_class]) ON [PRIMARY]
GO
