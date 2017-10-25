CREATE TABLE [dbo].[req_headers]
(
[requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[requester] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requisition_date] [datetime] NULL,
[buy_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_date] [datetime] NULL,
[period] [int] NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[printed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [numeric] (18, 6) NULL,
[tax_amount] [numeric] (18, 6) NULL,
[freight_amount] [numeric] (18, 6) NULL,
[document_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_comments_on_po] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entered_datetime] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_notification] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receipt_email_notification] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requisition_reason] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_comments_standard_clause] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[req_headers] ADD CONSTRAINT [pk_req_headers] PRIMARY KEY NONCLUSTERED  ([requisition]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [req_headers_batch] ON [dbo].[req_headers] ([batch], [entered_datetime]) ON [PRIMARY]
GO
