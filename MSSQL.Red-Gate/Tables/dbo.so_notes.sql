CREATE TABLE [dbo].[so_notes]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[so_line] [smallint] NOT NULL,
[sort_line] [decimal] (8, 2) NULL,
[standard_clause] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quote_print] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_print] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_print] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_advice_print] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_of_lading_print] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_print] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[markings] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_notes] ADD CONSTRAINT [pk_so_notes] PRIMARY KEY CLUSTERED  ([sales_order], [so_line]) ON [PRIMARY]
GO
