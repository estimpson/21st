CREATE TABLE [dbo].[po_receivers]
(
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bill_of_lading] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clerk] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_carrier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[gl_date] [datetime] NULL,
[received_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_POReceivers]
ON [dbo].[po_receivers] FOR UPDATE
AS
IF UPDATE(location) or UPDATE(ledger_account_code) or UPDATE(fiscal_year) or
   UPDATE(ledger) or UPDATE(gl_entry) or UPDATE(period) or
   UPDATE(gl_date)
  BEGIN
      IF EXISTS (SELECT 1 FROM inserted)
      BEGIN
            UPDATE
                  item_transactions
            SET
                  location = inserted.location,
                  gl_date = inserted.gl_date,
                  gl_entry = inserted.gl_entry,
                  fiscal_year = inserted.fiscal_year,
                  period = inserted.period,
                  credit_ledger_account = inserted.ledger_account_code,
                  ledger = inserted.ledger,
                  changed_date = GetDate(),
                  changed_user_id = inserted.changed_user_id
            FROM
                  item_transactions INNER JOIN
                  inserted ON
                        item_transactions.document_type = 'BILL OF LADING' AND
                        item_transactions.document_id1 = inserted.purchase_order AND
                        item_transactions.document_id2 = inserted.bill_of_lading
      END
END
GO
ALTER TABLE [dbo].[po_receivers] ADD CONSTRAINT [pk_po_receivers] PRIMARY KEY NONCLUSTERED  ([purchase_order], [bill_of_lading]) ON [PRIMARY]
GO
