CREATE TABLE [dbo].[ap_items]
(
[vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[inv_cm_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invoice_cm] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[inv_cm_line] [smallint] NOT NULL,
[inv_cm_sort_line] [smallint] NULL,
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase_order_line] [smallint] NULL,
[line_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[code_1099] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expense_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[variance_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receiver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [decimal] (18, 6) NULL,
[unit_of_measure] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price] [decimal] (18, 6) NULL,
[extended_amount] [decimal] (18, 6) NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[matched] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[matched_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase_order_sort_line] [decimal] (8, 2) NULL,
[bill_of_lading] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c1099r_employee_contrb_amt] [decimal] (18, 6) NULL,
[c1099r_fed_tax_withheld_amt] [decimal] (18, 6) NULL,
[c1099r_distribution_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c1099r_total_distribution] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c1099r_taxable_amt_not_det] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c1099r_ira_sep_simple] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amleadsrcid] [int] NULL,
[amleadexpenseid] [int] NULL,
[amleadexpense_adstart] [datetime] NULL,
[amleadexpense_adend] [datetime] NULL,
[sycampusid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ap_items] ADD CONSTRAINT [pk_ap_items] PRIMARY KEY CLUSTERED  ([vendor], [invoice_cm], [inv_cm_flag], [inv_cm_line]) ON [PRIMARY]
GO