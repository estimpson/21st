CREATE TABLE [dbo].[po_items]
(
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[po_line] [smallint] NOT NULL,
[sort_line] [numeric] (8, 2) NULL,
[line_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendors_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_reason] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receiver] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_po_receiver] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_carrier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expense_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[variance_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[encumber_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requested_by] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity_ordered] [numeric] (18, 6) NULL,
[quantity_received] [numeric] (18, 6) NULL,
[quantity_invoiced] [numeric] (18, 6) NULL,
[quantity_cancelled] [numeric] (18, 6) NULL,
[quantity_tolerance] [numeric] (18, 6) NULL,
[purchasing_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_pricing_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchasing_to_po_pricing_conv] [numeric] (18, 6) NULL,
[price] [numeric] (18, 6) NULL,
[receiver_price] [numeric] (18, 6) NULL,
[price_tolerance] [numeric] (18, 6) NULL,
[extended_amount] [numeric] (18, 6) NULL,
[invoiced_amount] [numeric] (18, 6) NULL,
[cancelled_amount] [numeric] (18, 6) NULL,
[required_date] [datetime] NULL,
[ship_date] [datetime] NULL,
[eta_date] [datetime] NULL,
[last_expedite_date] [datetime] NULL,
[closed_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventoried] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_quantity_uom_to_standard] [numeric] (18, 6) NULL,
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_line] [smallint] NULL,
[po_release] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket_line] [smallint] NULL,
[amleadsrcid] [int] NULL,
[package_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_uom_to_purchasing] [decimal] (18, 6) NULL,
[sycampusid] [int] NULL,
[package_label_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_POItems]
ON [dbo].[po_items] FOR DELETE
AS

-- 20-Oct-2005 Removed code that updated the PO header status.  The
--             status is stored on the PO release.

-- 28-Apr-2005 Added code to update po_blanket_items cumulative
--             quantity ordered and extended amount.  Added code to update
--             PO release status.

-- 24-Jan-2002 Changed the datatype of the numerics from dec to numeric.
--             When they are numeric, MS SQL Server v6.5 gives the error
--             that the datatypes of the local variables are different from
--             that of the columns in the cursor.

-- 18-Jan-2002 Added BEGIN and END to the IF statement that was updating
--             item_locations. Without them, the actual update was not
--             in the IF.

BEGIN

  DECLARE @s_purchaseorder varchar(25),
          @s_location varchar(25),
          @s_exponreceipt char(1),
          @s_approved char(1),
          @s_blanket char(1),
          @s_porelease varchar(25),
          @s_item varchar(50),
          @c_qtyordered numeric(18,6),
          @c_qtycancelled numeric(18,6),
          @c_qty numeric(18,6),
          @c_potostd numeric(18,6),
          @s_inventoried char(1),
          @c_extendedamt numeric(18,6),
          @c_cancelledamt numeric(18,6),
          @s_linetype char(2),
          @i_blanketline smallint,
          @s_changeduserid varchar(25),
          @i_rowcount int

  /*  Make sure that we have a row in the deleted table for processing */
  SELECT @i_rowcount = Count(*) FROM deleted

  IF @i_rowcount > 0
    BEGIN
      /* To eliminate duplicate code, use a cursor whether one or multiple
         rows are deleted. */
      DECLARE delpoitemcursor CURSOR FOR
        SELECT po_headers.purchase_order,
               IsNull(po_headers.location,''),
               IsNull(po_headers.expense_on_receipt,'N'),
               IsNull(po_headers.approved,'Y'),
               IsNull(po_headers.blanket,'N'),
               IsNull(deleted.po_release,''),
               IsNull(item,''),
               IsNull(quantity_ordered,0), IsNull(quantity_cancelled,0),
               IsNull(po_quantity_uom_to_standard,1),
               IsNull(extended_amount,0), IsNull(cancelled_amount,0),
               IsNull(inventoried,'N'), deleted.changed_user_id,
               line_type, blanket_line
          FROM po_headers,deleted
         WHERE po_headers.purchase_order = deleted.purchase_order

      OPEN delpoitemcursor

      WHILE 1 = 1
        BEGIN
          FETCH delpoitemcursor
           INTO @s_purchaseorder,
                @s_location,
                @s_exponreceipt,
                @s_approved,
                @s_blanket,
                @s_porelease,
                @s_item,
                @c_qtyordered, @c_qtycancelled,
                @c_potostd,
                @c_extendedamt, @c_cancelledamt,
                @s_inventoried, @s_changeduserid,
                @s_linetype, @i_blanketline

          /* any status from the fetch other than 0 will terminate the
             loop. */
          IF @@fetch_status <> 0 BREAK

          IF @c_potostd = 0 SELECT @c_potostd = 1

          /*  Update the status of the po release */
          EXECUTE UpdatePOReleaseStatus @s_purchaseorder,
                                        @s_porelease,
                                        @s_changeduserid

          IF @s_exponreceipt = 'Y' AND @s_approved = 'Y' AND
             @s_inventoried = 'Y' AND @s_item <> '' AND @s_location <> ''
            /* Update the item_locations on order quantity. Only IT lines
               will have inventoried = 'Y'                    */
            BEGIN
              SELECT @c_qty = Round((@c_qtyordered - @c_qtycancelled) * @c_potostd * -1.0,4)
              EXECUTE UpdateItemLocationQuantity
                        @s_item,
                        @s_location,
                        @c_qty,
                        0,
                        @s_changeduserid
            END

          IF @s_blanket = 'Y' AND @s_linetype = 'IT' AND
             @i_blanketline <> 0
             BEGIN
               UPDATE po_blanket_items
                  SET cum_quantity_ordered =
                      cum_quantity_ordered - (@c_qtyordered - @c_qtycancelled),
                      cum_extended_amount =
                      cum_extended_amount - (@c_extendedamt - @c_cancelledamt),
                      changed_date = GetDate(),
                      changed_user_id = @s_changeduserid
                WHERE purchase_order = @s_purchaseorder
                  AND blanket_line = @i_blanketline
             END
        END
      /*  don't need this cursor any longer  */
      CLOSE delpoitemcursor
      DEALLOCATE delpoitemcursor
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_POItems]
ON [dbo].[po_items] FOR INSERT
AS

-- 20-Oct-2005 Removed code that updated the PO header status.  The
--             status is stored on the PO release.

-- 28-Apr-2005 Added code to update po_blanket_items cumulative
--             quantity ordered and extended amount.  Added code to update
--             PO release status.

-- 24-Jan-2002 Changed the datatype of the numerics from dec to numeric.
--             When they are numeric, MS SQL Server v6.5 gives the error
--             that the datatypes of the local variables are different from
--             that of the columns in the cursor.

-- 18-Jan-2002 Added BEGIN and END to the IF statement that was updating
--             item_locations. Without them, the actual update was not
--             in the IF.

  BEGIN

    DECLARE @s_purchaseorder varchar(25),
            @s_item varchar(50),
            @s_location varchar(25),
            @s_exponreceipt char(1),
            @s_approved char(1),
            @s_blanket char(1),
            @s_porelease varchar(25),
            @c_qtyordered numeric(18,6),
            @c_qtycancelled numeric(18,6),
            @c_qty numeric(18,6),
            @c_potostd numeric(18,6),
            @c_extendedamt numeric(18,6),
            @c_cancelledamt numeric(18,6),
            @s_inventoried char(1),
            @s_linetype char(2),
            @i_blanketline smallint,
            @s_changeduserid varchar(25),
            @i_rowcount int

  /*  Make sure that we have a row in the inserted table for processing */
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN
      /* Use a cursor whether one or more rows are inserted. */
      DECLARE inspoitemcursor CURSOR FOR
        SELECT po_headers.purchase_order,
               IsNull(po_headers.location,''),
               IsNull(po_headers.expense_on_receipt,'N'),
               IsNull(po_headers.approved,'Y'),
               IsNull(po_headers.blanket,'N'),
               IsNull(inserted.po_release,''),
               IsNull(item,''),
               IsNull(quantity_ordered,0), IsNull(quantity_cancelled,0),
               IsNull(po_quantity_uom_to_standard,1),
               IsNull(extended_amount,0), IsNull(cancelled_amount,0),
               IsNull(inventoried,'N'), inserted.changed_user_id,
               line_type, blanket_line
        FROM po_headers,inserted
       WHERE po_headers.purchase_order = inserted.purchase_order

      OPEN inspoitemcursor

      WHILE 1 = 1
        BEGIN
          FETCH inspoitemcursor
           INTO @s_purchaseorder,
                @s_location,
                @s_exponreceipt,
                @s_approved,
                @s_blanket,
                @s_porelease,
                @s_item,
                @c_qtyordered, @c_qtycancelled,
                @c_potostd,
                @c_extendedamt, @c_cancelledamt,
                @s_inventoried, @s_changeduserid,
                @s_linetype, @i_blanketline

          /* any status from the fetch other than 0 will terminate the
             loop. */
          IF @@fetch_status <> 0 BREAK

          IF @c_potostd = 0 SELECT @c_potostd = 1

          /*  Update the status of the po release */
          EXECUTE UpdatePOReleaseStatus @s_purchaseorder,
                                        @s_porelease,
                                        @s_changeduserid

          IF @s_exponreceipt = 'Y' AND @s_approved = 'Y' AND
             @s_inventoried = 'Y' AND @s_item <> '' AND @s_location <> ''
            /* Update the item_locations on order quantity. Only IT lines
               will have inventoried = 'Y'                      */
             BEGIN
              SELECT @c_qty = Round((@c_qtyordered - @c_qtycancelled) * @c_potostd,4)
              EXECUTE UpdateItemLocationQuantity
                        @s_item,
                        @s_location,
                        @c_qty,
                        0,
                        @s_changeduserid
             END

          IF @s_blanket = 'Y' AND @s_linetype = 'IT' AND
             @i_blanketline <> 0
             BEGIN
               UPDATE po_blanket_items
                  SET cum_quantity_ordered =
                      cum_quantity_ordered + @c_qtyordered - @c_qtycancelled,
                      cum_extended_amount =
                      cum_extended_amount + @c_extendedamt - @c_cancelledamt,
                      changed_date = GetDate(),
                      changed_user_id = @s_changeduserid
                WHERE purchase_order = @s_purchaseorder
                  AND blanket_line = @i_blanketline
             END
        END
      /*  don't need this cursor any longer  */
      CLOSE inspoitemcursor
      DEALLOCATE inspoitemcursor
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_POItems]
ON [dbo].[po_items] FOR UPDATE
AS

-- 19-Apr-2005 Added code to update po_blanket_items cumulative
--             quantity ordered and extended amount.

-- 24-Jan-2002 Changed datatype of i_poline from int to smallint and of item
--             from varchar(25) to varchar(50) and of the numeric columns from
--             dec to numeric to be consistent with the table definition;
--             otherwise, MS SQL Server 6.5 gives errors that the datatype of
--             the local variables don't match the datatype of the columns
--             in the cursor. For some reason this wasn't a problem in
--             Empower version 5.0. It's as if adding either po_headers or
--             the deleted cursor to the select caused the error.

-- 08-Jan-2001 If more is received than was ordered, don't remove more from
--             the item location on order than was put on order.

-- 25-Oct-2000 Added receiver and quantity received to the arguments for the
--             call to UpdatePOItemStatus.

IF UPDATE(quantity_ordered) or UPDATE(quantity_invoiced) or
   UPDATE(quantity_cancelled) or UPDATE(quantity_received) or
   UPDATE(extended_amount) or UPDATE(invoiced_amount) or UPDATE(cancelled_amount) or
   UPDATE(item) or UPDATE(inventoried) or UPDATE(po_quantity_uom_to_standard)
  BEGIN

    DECLARE @s_purchaseorder varchar(25),
            @i_poline smallint,
            @s_location varchar(25),
            @s_exponreceipt char(1),
            @s_approved char(1),
            @s_blanket char(1),
            @c_qtyordered numeric(18,6),
            @c_qtyreceived numeric(18,6),
            @c_qtyinvoiced numeric(18,6),
            @c_qtycancelled numeric(18,6),
            @c_potostd numeric(18,6),
            @c_extendedamt numeric(18,6),
            @c_invoicedamt numeric(18,6),
            @c_cancelledamt numeric(18,6),
            @s_status char (1),
            @s_statusreason char(1),
            @s_item varchar(50),
            @s_inventoried char(1),
            @s_olditem varchar(50),
            @c_oldqtyordered numeric(18,6),
            @c_oldqtyreceived numeric(18,6),
            @c_oldqtycancelled numeric(18,6),
            @c_oldextendedamt numeric(18,6),
            @c_oldcancelledamt numeric(18,6),
            @c_qty numeric(18,6),
            @c_oldpotostd numeric(18,6),
            @s_oldinventoried char(1),
            @s_linetype varchar(2),
            @i_blanketline smallint,
            @s_changeduserid varchar(25),
            @s_receiver char(1),
            @i_rowcount int

    /*  Make sure that we have a row in the inserted table for processing */
    SELECT @i_rowcount = Count(*) FROM inserted

    IF @i_rowcount > 0
      BEGIN
        DECLARE updpoitemcursor CURSOR FOR
          SELECT inserted.purchase_order, inserted.po_line,
                 IsNull(po_headers.location,''),
                 IsNull(po_headers.expense_on_receipt,'N'),
                 IsNull(po_headers.approved,'Y'),
                 IsNull(po_headers.blanket,'N'),
                 IsNull(inserted.quantity_ordered,0),
                 IsNull(inserted.quantity_received,0),
                 IsNull(inserted.quantity_invoiced,0),
                 IsNull(inserted.quantity_cancelled,0),
                 IsNull(inserted.po_quantity_uom_to_standard,1),
                 IsNull(inserted.extended_amount,0),
                 IsNull(inserted.invoiced_amount,0),
                 IsNull(inserted.cancelled_amount,0),
                 inserted.status,
                 inserted.status_reason,
                 IsNull(inserted.item,''),
                 IsNull(inserted.inventoried,'N'),
                 IsNull(deleted.item,''),
                 IsNull(deleted.quantity_ordered,0),
                 IsNull(deleted.quantity_received,0),
                 IsNull(deleted.quantity_cancelled,0),
                 IsNull(deleted.po_quantity_uom_to_standard,1),
                 IsNull(deleted.extended_amount,0),
                 IsNull(deleted.cancelled_amount,0),
                 IsNull(deleted.inventoried,'N'),
                 inserted.changed_user_id,
                 inserted.receiver,
                 inserted.line_type, inserted.blanket_line
            FROM po_headers, inserted, deleted
           WHERE inserted.purchase_order = deleted.purchase_order AND
                 inserted.po_line = deleted.po_line AND
                 po_headers.purchase_order = inserted.purchase_order
        ORDER BY inserted.purchase_order, inserted.po_line

        OPEN updpoitemcursor

        WHILE 1 = 1
          BEGIN
            FETCH updpoitemcursor
             INTO @s_purchaseorder, @i_poline,
                  @s_location,
                  @s_exponreceipt,
                  @s_approved,
                  @s_blanket,
                  @c_qtyordered, @c_qtyreceived, @c_qtyinvoiced,
                  @c_qtycancelled, @c_potostd,
                  @c_extendedamt, @c_invoicedamt, @c_cancelledamt,
                  @s_status, @s_statusreason,
                  @s_item, @s_inventoried,
                  @s_olditem, @c_oldqtyordered,
                  @c_oldqtyreceived, @c_oldqtycancelled,
                  @c_oldpotostd, @c_oldextendedamt, @c_oldcancelledamt,
                  @s_oldinventoried, @s_changeduserid,
                  @s_receiver,
                  @s_linetype, @i_blanketline

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            IF @c_potostd = 0 SELECT @c_potostd = 1
            IF @c_oldpotostd = 0 SELECT @c_oldpotostd = 1

            /*  Update the status of this item, if appropriate */
            EXECUTE UpdatePOItemStatus @s_purchaseorder,
                                       @i_poline,
                                       @c_qtyordered,
                                       @c_qtyinvoiced,
                                       @c_qtycancelled,
                                       @c_qtyreceived,
                                       @c_extendedamt,
                                       @c_invoicedamt,
                                       @c_cancelledamt,
                                       @s_status,
                                       @s_statusreason,
                                       @s_changeduserid,
                                       @s_receiver

            IF @s_exponreceipt = 'Y' AND @s_approved = 'Y' AND
              (@s_item <> @s_olditem OR
               @s_inventoried <> @s_oldinventoried OR
               @c_qtyordered - @c_qtycancelled - @c_qtyreceived <>
                  @c_oldqtyordered - @c_oldqtycancelled - @c_oldqtyreceived OR
               @c_potostd <> @c_oldpotostd)
              BEGIN
              /* Have a change which affects inventory. */
                /* First, remove the old item values. Then add the new. */
                IF @s_oldinventoried = 'Y' and @s_olditem <> ''
                  BEGIN
                    SELECT @c_qty = Round((@c_oldqtyordered - @c_oldqtycancelled - @c_oldqtyreceived) *
                                @c_oldpotostd * -1.0,4)
                    /* Qty will be > 0 if we received more than was ordered. */
                    IF @c_qty < 0
                      BEGIN
                        EXECUTE UpdateItemLocationQuantity
                                  @s_olditem,
                                  @s_location,
                                  @c_qty,
                                  0,
                                  @s_changeduserid
                      END
                  END
                IF @s_inventoried = 'Y' and @s_item <> ''
                  BEGIN
                    SELECT @c_qty = Round((@c_qtyordered - @c_qtycancelled - @c_qtyreceived) *
                                @c_potostd,4)
                    IF @c_qty > 0
                      BEGIN
                        EXECUTE UpdateItemLocationQuantity
                                  @s_item,
                                  @s_location,
                                  @c_qty,
                                  0,
                                  @s_changeduserid
                      END
                  END
              END /* have a change that affects inventory */

           IF @s_blanket = 'Y' AND @s_linetype = 'IT' AND
              @i_blanketline <> 0
              BEGIN
                UPDATE po_blanket_items
                   SET cum_quantity_ordered =
                       cum_quantity_ordered + (@c_qtyordered - @c_qtycancelled)
                                  - (@c_oldqtyordered - @c_oldqtycancelled),
                       cum_extended_amount =
                       cum_extended_amount + (@c_extendedamt - @c_cancelledamt)
                                  - (@c_oldextendedamt - @c_oldcancelledamt),
                       changed_date = GetDate(),
                       changed_user_id = @s_changeduserid
                 WHERE purchase_order = @s_purchaseorder
                   AND blanket_line = @i_blanketline
             END /* have a blanket item to update */

          END /* while loop */
          /*  don't need this cursor any longer  */
          CLOSE updpoitemcursor
          DEALLOCATE updpoitemcursor
      END /* have one or more rows in inserted */
  END
GO
ALTER TABLE [dbo].[po_items] ADD CONSTRAINT [pk_po_items] PRIMARY KEY NONCLUSTERED  ([purchase_order], [po_line]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [po_items_item] ON [dbo].[po_items] ([item]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [poitems_sales_order] ON [dbo].[po_items] ([sales_order], [so_line]) ON [PRIMARY]
GO
