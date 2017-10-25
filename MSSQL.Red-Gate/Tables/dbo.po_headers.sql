CREATE TABLE [dbo].[po_headers]
(
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[buy_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[buy_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entered_datetime] [datetime] NULL,
[po_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_date] [datetime] NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_reason] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requester] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmed_by] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmed_date] [datetime] NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[printed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_freight] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_on_receipt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expense_on_receipt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fob] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [numeric] (18, 6) NULL,
[tax_amount] [numeric] (18, 6) NULL,
[freight_amount] [numeric] (18, 6) NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[gl_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_tax] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[commit_to_gl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buy_contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_to_exceed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_terms_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_comments_standard_clause] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_POHeaders]
ON [dbo].[po_headers] FOR UPDATE
AS

-- 30-Jan-02 Modified retrieve of po_items to return an empty string
--           rather than null if item is null.

IF UPDATE(location) or UPDATE(expense_on_receipt) or UPDATE(approved)
  BEGIN

    DECLARE @s_purchaseorder varchar(25),
            @s_oldlocation varchar(25),
            @s_oldexponreceipt char(1),
            @s_oldapproved char(1),
            @s_newlocation varchar(25),
            @s_newexponreceipt char(1),
            @s_newapproved char(1),
            @i_poline smallint,
            @i_lastpoline smallint,
            @i_maxpoline smallint,
            @s_item varchar(50),
            @c_qtyordered dec(18,6),
            @c_qtycancelled dec(18,6),
            @c_qtyreceived dec(18,6),
            @c_potostd dec(18,6),
            @s_inventoried char (1),
            @c_qty dec(18,6),
            @s_changeduserid varchar(25),
            @i_rowcount int

    /*  Make sure that we have a row in the inserted table for processing */
    SELECT @i_rowcount = Count(*) FROM inserted

    IF @i_rowcount > 0
      BEGIN
        /* Won't do special processing for one row versus many rows.
           We'll always use a cursor to avoid duplicating code. */
        DECLARE updpohdrcursor CURSOR FOR
          SELECT inserted.purchase_order,
                 inserted.location,
                 inserted.expense_on_receipt, inserted.approved,
                 deleted.location,
                 deleted.expense_on_receipt, deleted.approved,
                 inserted.changed_user_id
            FROM inserted, deleted
           WHERE inserted.purchase_order = deleted.purchase_order
           ORDER BY inserted.purchase_order

        OPEN updpohdrcursor

        WHILE 1 = 1
          BEGIN
            FETCH updpohdrcursor
             INTO @s_purchaseorder,
                 	@s_newlocation, @s_newexponreceipt, @s_newapproved,
                  @s_oldlocation, @s_oldexponreceipt, @s_oldapproved,
                  @s_changeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            /* No need for any more work if neither the old nor the new
               expense on receipt value is 'Y'. */
            IF @s_oldexponreceipt <> 'Y' AND @s_newexponreceipt <> 'Y' CONTINUE

            /* No need for any more work if neither the old nor the new
               approved value is 'Y'. */
            IF @s_oldapproved <> 'Y' AND @s_newapproved <> 'Y' CONTINUE

            /* Set some initial values before processing the PO items. */
            SELECT @i_maxpoline = Max(po_line)
              FROM po_items
             WHERE purchase_order = @s_purchaseorder

            IF @i_maxpoline IS NULL SELECT @i_maxpoline = 0

            SELECT @i_lastpoline = 0

            /* Now loop through the po items for this purchase order */
            WHILE @i_lastpoline < @i_maxpoline
              BEGIN
                /* Use a trick used by Monitor to avoid defining a cursor
                   on po_items. */
                SELECT @i_poline = po_line,
                       @s_item = IsNull(item,''),
                       @c_qtyordered = quantity_ordered,
                       @c_qtycancelled = IsNull(quantity_cancelled,0),
                       @c_qtyreceived = IsNull(quantity_received,0),
                       @c_potostd = IsNull(po_quantity_uom_to_standard,1),
                       @s_inventoried = inventoried
                  FROM po_items
                 WHERE purchase_order = @s_purchaseorder AND
                       po_line = ( SELECT Min(po_line)
                                     FROM po_items
                                    WHERE purchase_order = @s_purchaseorder
                                          AND po_line > @i_lastpoline )

                /* Save the PO line */
                SELECT @i_lastpoline = @i_poline

                IF @c_potostd = 0 SELECT @c_potostd = 1


                /* Have a PO item row. Does it need to update inventory? */
                IF @s_inventoried = 'Y' AND @s_item <> '' AND
                  (@c_qtyordered - @c_qtycancelled - @c_qtyreceived ) <> 0
                  BEGIN
                    /* First remove the on order from the old "values". */
                    IF @s_oldexponreceipt = 'Y' AND @s_oldapproved = 'Y'
                      BEGIN
                        SELECT @c_qty = Round((@c_qtyordered - @c_qtycancelled - @c_qtyreceived) *
                                  @c_potostd * -1.0,4)
                        /* Qty will be > 0 if we received more than was ordered. */
                        IF @c_qty < 0
                          BEGIN
                            EXECUTE UpdateItemLocationQuantity
                                @s_item,
                                @s_oldlocation,
                                @c_qty,
                                0,
                                @s_changeduserid
                          END
                      END
                    /* Now add it to the new "values". */
                    IF @s_newexponreceipt = 'Y' AND @s_newapproved = 'Y'
                      BEGIN
                        SELECT @c_qty = Round((@c_qtyordered - @c_qtycancelled - @c_qtyreceived) *
                                  @c_potostd,4)
                        /* Qty will be < 0 if we received more than was ordered. */
                        IF @c_qty > 0
                          BEGIN
                            EXECUTE UpdateItemLocationQuantity
                                @s_item,
                                @s_newlocation,
                                @c_qty,
                                0,
                                @s_changeduserid
                          END
                      END
                  END
              END /* inner loop */
          END /* outer loop */
        /*  don't need this cursor any longer  */
        CLOSE updpohdrcursor
        DEALLOCATE updpohdrcursor
      END /* have one or more rows in inserted */
  END
GO
ALTER TABLE [dbo].[po_headers] ADD CONSTRAINT [pk_po_headers] PRIMARY KEY NONCLUSTERED  ([purchase_order]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [po_headers_approver] ON [dbo].[po_headers] ([approver]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [po_headers_batch] ON [dbo].[po_headers] ([batch], [entered_datetime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [po_headers_vendor] ON [dbo].[po_headers] ([buy_vendor], [purchase_order]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [po_headers_buyer] ON [dbo].[po_headers] ([buyer], [purchase_order]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [poheaders_sales_order] ON [dbo].[po_headers] ([sales_order]) ON [PRIMARY]
GO
