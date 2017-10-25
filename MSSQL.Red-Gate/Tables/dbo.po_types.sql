CREATE TABLE [dbo].[po_types]
(
[po_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[po_type_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_freight] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_quantity] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_price] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_amount] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_on_receipt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expense_on_receipt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_inv_by_item] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_inv_by_po_amount] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_tax] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approver_is_buyer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_approver_source] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_to_exceed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[po_types] ADD CONSTRAINT [pk_po_types] PRIMARY KEY CLUSTERED  ([po_type]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
