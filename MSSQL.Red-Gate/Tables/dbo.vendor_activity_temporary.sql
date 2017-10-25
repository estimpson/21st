CREATE TABLE [dbo].[vendor_activity_temporary]
(
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buy_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buy_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_sort] [smallint] NULL,
[document_date] [datetime] NULL,
[document_amount] [decimal] (18, 6) NULL,
[posted_amount] [decimal] (18, 6) NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hold] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_date] [datetime] NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[approved_unapproved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_credit_memo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_discount] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selected_document_date] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selected_gl_date] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
