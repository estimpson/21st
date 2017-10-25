CREATE TABLE [dbo].[so_items]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[so_line] [smallint] NOT NULL,
[sort_line] [decimal] (8, 2) NULL,
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity_ordered] [decimal] (18, 6) NULL,
[quantity_shipped] [decimal] (18, 6) NULL,
[quantity_cancelled] [decimal] (18, 6) NULL,
[selling_qty_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selling_price_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selling_to_price_conv] [decimal] (18, 6) NULL,
[price_list] [decimal] (18, 6) NULL,
[price_discount] [decimal] (18, 6) NULL,
[price_net] [decimal] (18, 6) NULL,
[cost_list] [decimal] (18, 6) NULL,
[cost_discount] [decimal] (18, 6) NULL,
[cost_net] [decimal] (18, 6) NULL,
[po_purchasing_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_po_pricing_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_purchasing_to_pricing_conv] [decimal] (18, 6) NULL,
[selling_to_purchasing_conv] [decimal] (18, 6) NULL,
[selling_extended_amount] [decimal] (18, 6) NULL,
[cost_extended_amount] [decimal] (18, 6) NULL,
[fulfillment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_line] [smallint] NULL,
[po_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_buyer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_date] [datetime] NULL,
[po_sales_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_sales_terms_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_freight_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fulfillment_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_line_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_quantity_ordered] [decimal] (18, 6) NULL,
[po_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_required_date] [datetime] NULL,
[po_ship_date] [datetime] NULL,
[po_eta_date] [datetime] NULL,
[selling_uom_to_standard] [decimal] (18, 6) NULL,
[po_quantity_uom_to_standard] [decimal] (18, 6) NULL,
[mark_up_down] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mark_up_down_percent] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_agent_percent] [decimal] (18, 6) NULL,
[account_manager_percent] [decimal] (18, 6) NULL,
[po_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_gl_date] [datetime] NULL,
[po_document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_cost_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipped_amount] [decimal] (18, 6) NULL,
[cancelled_amount] [decimal] (18, 6) NULL,
[inventoried] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_quantity_tolerance] [decimal] (18, 6) NULL,
[po_price_tolerance] [decimal] (18, 6) NULL,
[so_release] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket_line] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_SOItems]
ON [dbo].[so_items] FOR DELETE
AS

-- 13-Apr-2010 Don't update the release status for quotes.  Quotes
--             get a cancelled status through the SO Scoreboard
--             Cancel Quote option.

-- 07-Jun-2005 Added code to update so_blanket_items cumulative
--             quantity ordered and extended amount.  Added code to update
--             PO release status.
--
--             Added BEGIN and END to the IF statement that was updating
--             item_locations. Without them, the actual update was not
--             in the IF.

BEGIN

  DECLARE @s_salesorder varchar(25),
          @s_documenttype char(1),
          @s_approved char(1),
          @s_sorelease varchar(25),
          @s_item varchar(25),
          @s_location varchar(25),
          @c_qty numeric(18,6),
          @c_qtyordered dec(18,6),
          @c_qtycancelled dec(18,6),
          @c_sotostd dec(18,6),
          @s_inventoried char(1),
          @c_extendedamt numeric(18,6),
          @c_cancelledamt numeric(18,6),
          @s_linetype varchar(2),
          @i_blanketline smallint,
          @s_changeduserid varchar(25),
          @i_rowcount int

  /*  Make sure that we have a row in the deleted table for processing */
  SELECT @i_rowcount = Count(*) FROM deleted

  IF @i_rowcount > 0
    BEGIN
      /* To eliminate duplicate code, use a cursor whether one or multiple
         rows are deleted. Only select deleted items for approved
         sales orders. Quotes and unapproved orders don't update
         inventory. */
      DECLARE delsoitemcursor CURSOR FOR
        SELECT deleted.sales_order,
               so_headers.document_type, so_headers.approved,
               IsNull(deleted.so_release,''),
               IsNull(item,''), IsNull(fulfillment_location,''),
               IsNull(quantity_ordered,0), IsNull(quantity_cancelled,0),
               IsNull(selling_uom_to_standard,1),
               IsNull(selling_extended_amount,0), IsNull(cancelled_amount,0),
               IsNull(inventoried,'N'), deleted.changed_user_id,
               blanket_line
        FROM so_headers,deleted
       WHERE so_headers.sales_order = deleted.sales_order

      OPEN delsoitemcursor

      WHILE 1 = 1
        BEGIN
          FETCH delsoitemcursor
           INTO @s_salesorder, @s_documenttype, @s_approved,
                @s_sorelease,
                @s_item, @s_location,
                @c_qtyordered, @c_qtycancelled,
                @c_sotostd,
                @c_extendedamt, @c_cancelledamt,
                @s_inventoried, @s_changeduserid,
                @i_blanketline

          /* any status from the fetch other than 0 will terminate the
             loop. */
          IF @@fetch_status <> 0 BREAK

          IF @c_sotostd = 0 SELECT @c_sotostd = 1

          /*  Update the status of the SO release */
          IF @s_documenttype <> 'Q'
            EXECUTE UpdateSOReleaseStatus @s_salesorder,
                                          @s_sorelease,
                                          @s_changeduserid

          /* Quotes and unapproved orders don't update inventory. */
          IF @s_documenttype <> 'Q' AND @s_approved = 'Y' AND
             @s_inventoried = 'Y' AND @s_item <> '' AND @s_location <> ''
            /* Update the item_locations sold quantity. */
            BEGIN
              SELECT @c_qty = Round((@c_qtyordered - @c_qtycancelled) * @c_sotostd * -1.0,4)
              EXECUTE UpdateItemLocationQuantity
                      @s_item,
                      @s_location,
                      0,
                      @c_qty,
                      @s_changeduserid
            END

          IF @s_documenttype = 'B' AND @i_blanketline <> 0
            BEGIN
              UPDATE so_blanket_items
                 SET cum_quantity_ordered =
                     cum_quantity_ordered - (@c_qtyordered - @c_qtycancelled),
                     cum_extended_amount =
                     cum_extended_amount - (@c_extendedamt - @c_cancelledamt),
                     changed_date = GetDate(),
                     changed_user_id = @s_changeduserid
               WHERE sales_order = @s_salesorder
                 AND blanket_line = @i_blanketline
            END
        END

      /*  don't need this cursor any longer  */
      CLOSE delsoitemcursor
      DEALLOCATE delsoitemcursor
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_SOItems]
ON [dbo].[so_items] FOR INSERT
AS
-- 13-Apr-2010 Don't update the release status for quotes.  Quotes
--             get a cancelled status through the SO Scoreboard
--             Cancel Quote option.

-- 07-Jun-2005 Added code to update so_blanket_items cumulative
--             quantity ordered and extended amount.  Added code to update
--             SO release status.
--
--             Added BEGIN and END to the IF statement that was updating
--             item_locations. Without them, the actual update was not
--             in the IF.

  BEGIN

    DECLARE @s_salesorder varchar(25),
            @s_documenttype char(1),
            @s_approved char(1),
            @s_item varchar(25),
            @s_location varchar(25),
            @s_sorelease varchar(25),
            @c_qty dec(18,6),
            @c_qtysold dec(18,6),
            @c_qtycancelled dec(18,6),
            @c_sotostd dec(18,6),
            @s_inventoried char(1),
            @c_extendedamt numeric(18,6),
            @c_cancelledamt numeric(18,6),
            @i_blanketline smallint,
            @s_changeduserid varchar(25),
            @i_rowcount int

  /*  Make sure that we have a row in the inserted table for processing */
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN
      /* Use a cursor whether one or more rows are inserted. */
      DECLARE inssoitemcursor CURSOR FOR
        SELECT inserted.sales_order,
               so_headers.document_type, so_headers.approved,
               IsNull(inserted.so_release,''),
               IsNull(item,''), IsNull(fulfillment_location,''),
               IsNull(quantity_ordered,0), IsNull(quantity_cancelled,0),
               IsNull(selling_uom_to_standard,1),
               IsNull(selling_extended_amount,0), IsNull(cancelled_amount,0),
               IsNull(inventoried,'N'), inserted.changed_user_id,
               blanket_line
        FROM so_headers, inserted
       WHERE so_headers.sales_order = inserted.sales_order

      OPEN inssoitemcursor

      WHILE 1 = 1
        BEGIN
          FETCH inssoitemcursor
           INTO @s_salesorder, @s_documenttype, @s_approved,
                @s_sorelease,
                @s_item, @s_location,
                @c_qtysold, @c_qtycancelled,
                @c_sotostd,
                @c_extendedamt, @c_cancelledamt,
                @s_inventoried, @s_changeduserid,
                @i_blanketline

          /* any status from the fetch other than 0 will terminate the
             loop. */
          IF @@fetch_status <> 0 BREAK

          IF @c_sotostd = 0 SELECT @c_sotostd = 1

          /*  Update the status of the SO release, if appropriate */
          IF @s_documenttype <> 'Q'
            EXECUTE UpdateSOReleaseStatus @s_salesorder,
                                          @s_sorelease,
                                          @s_changeduserid

          /* Quotes and unapproved orders don't update inventory. */
          IF @s_documenttype <> 'Q' AND @s_approved = 'Y' AND
             @s_inventoried = 'Y' AND @s_item <> '' AND @s_location <> ''
            /* Update the item_locations sold quantity.*/
            BEGIN
              SELECT @c_qty = Round((@c_qtysold - @c_qtycancelled) * @c_sotostd,4)
              EXECUTE UpdateItemLocationQuantity
                        @s_item,
                        @s_location,
                        0,
                        @c_qty,
                        @s_changeduserid
            END

          IF @s_documenttype = 'B' AND @i_blanketline <> 0
            BEGIN
              UPDATE so_blanket_items
                 SET cum_quantity_ordered =
                     cum_quantity_ordered + (@c_qtysold - @c_qtycancelled),
                     cum_extended_amount =
                     cum_extended_amount + (@c_extendedamt - @c_cancelledamt),
                     changed_date = GetDate(),
                     changed_user_id = @s_changeduserid
               WHERE sales_order = @s_salesorder
                 AND blanket_line = @i_blanketline
            END
        END
      /*  don't need this cursor any longer  */
      CLOSE inssoitemcursor
      DEALLOCATE inssoitemcursor
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_SOItems]
ON [dbo].[so_items] FOR UPDATE
AS

-- 13-Apr-2010 Added document_type to the arguments passed to
--             UpdateSOItemStatus.

-- 07-Jun-2005 Added code to update so_blanket_items cumulative
--             quantity ordered and extended amount.

IF UPDATE(quantity_ordered) or UPDATE(quantity_shipped) or
   UPDATE(quantity_cancelled) or UPDATE(item) or UPDATE(inventoried) or
   UPDATE(selling_extended_amount) or UPDATE(cancelled_amount) or
   UPDATE(fulfillment_location) or UPDATE(selling_uom_to_standard)
  BEGIN

    DECLARE @s_salesorder varchar(25),
            @i_soline int,
            @s_documenttype char(1),
            @s_approved char(1),
            @s_status char(1),
            @s_item varchar(25),
            @s_location varchar(25),
            @s_inventoried char(1),
            @c_qtyordered dec(18,6),
            @c_qtyshipped dec(18,6),
            @c_qtycancelled dec(18,6),
            @c_sotostd dec(18,6),
            @c_extendedamt numeric(18,6),
            @c_cancelledamt numeric(18,6),
            @s_olditem varchar(25),
            @s_oldlocation varchar(25),
            @s_oldinventoried char(1),
            @c_oldqtyordered dec(18,6),
            @c_oldqtyshipped dec(18,6),
            @c_oldqtycancelled dec(18,6),
            @c_oldsotostd dec(18,6),
            @c_oldextendedamt numeric(18,6),
            @c_oldcancelledamt numeric(18,6),
            @c_qty dec(18,6),
            @i_blanketline smallint,
            @s_changeduserid varchar(25),
            @i_rowcount int

    /*  Make sure that we have a row in the inserted table for processing */
    SELECT @i_rowcount = Count(*) FROM inserted

    IF @i_rowcount > 0
      BEGIN
        /* Only select approved sales orders. */
        DECLARE updsoitemcursor CURSOR FOR
          SELECT inserted.sales_order, inserted.so_line,
                 so_headers.document_type, so_headers.approved,
                 IsNull(inserted.status,''),
                 IsNull(inserted.item,''),
                 IsNull(inserted.fulfillment_location,''),
                 IsNull(inserted.inventoried,'N'),
                 IsNull(inserted.quantity_ordered,0),
                 IsNull(inserted.quantity_shipped,0),
                 IsNull(inserted.quantity_cancelled,0),
                 IsNull(inserted.selling_uom_to_standard,1),
                 IsNull(inserted.selling_extended_amount,0),
                 IsNull(inserted.cancelled_amount,0),
                 IsNull(deleted.item,''),
                 IsNull(deleted.fulfillment_location,''),
                 IsNull(deleted.inventoried,'N'),
                 IsNull(deleted.quantity_ordered,0),
                 IsNull(deleted.quantity_shipped,0),
                 IsNull(deleted.quantity_cancelled,0),
                 IsNull(deleted.selling_uom_to_standard,1),
                 IsNull(deleted.selling_extended_amount,0),
                 IsNull(deleted.cancelled_amount,0),
                 inserted.blanket_line,
                 inserted.changed_user_id
            FROM so_headers, inserted, deleted
           WHERE inserted.sales_order = deleted.sales_order AND
                 inserted.so_line = deleted.so_line AND
                 so_headers.sales_order = inserted.sales_order
        ORDER BY inserted.sales_order, inserted.so_line

        OPEN updsoitemcursor

        WHILE 1 = 1
          BEGIN
            FETCH updsoitemcursor
             INTO @s_salesorder, @i_soline,
                  @s_documenttype, @s_approved, @s_status,
                  @s_item, @s_location, @s_inventoried,
                  @c_qtyordered, @c_qtyshipped,
                  @c_qtycancelled, @c_sotostd,
                  @c_extendedamt, @c_cancelledamt,
                  @s_olditem, @s_oldlocation, @s_oldinventoried,
                  @c_oldqtyordered, @c_oldqtyshipped,
                  @c_oldqtycancelled, @c_oldsotostd,
                  @c_oldextendedamt, @c_oldcancelledamt,
                  @i_blanketline,
                  @s_changeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            IF @c_sotostd = 0 SELECT @c_sotostd = 1
            IF @c_oldsotostd = 0 SELECT @c_oldsotostd = 1

            /* now call the procedure that will update the so_item
               status and if necessary, the so_release status */
            EXECUTE UpdateSOItemStatus @s_salesorder, @s_documenttype,
                                        @i_soline, @c_qtyordered,
                                        @c_qtyshipped, @c_qtycancelled, @s_status,
                                        @s_changeduserid

            /* Quotes and unapproved orders don't update inventory. */
            IF @s_documenttype <> 'Q' AND @s_approved = 'Y' AND
              (@s_item <> @s_olditem OR
               @s_location <> @s_oldlocation OR
               @s_inventoried <> @s_oldinventoried OR
               @c_qtyordered - @c_qtycancelled - @c_qtyshipped <>
                  @c_oldqtyordered - @c_oldqtycancelled - @c_oldqtyshipped OR
               @c_sotostd <> @c_oldsotostd)
              BEGIN
              /* Have a change which affects inventory. */
                /* First, remove the old item values. Then add the new. */
                IF @s_oldinventoried = 'Y' AND @s_olditem <> '' AND
                   @s_oldlocation <> ''
                  BEGIN
                    SELECT @c_qty = Round((@c_oldqtyordered - @c_oldqtycancelled - @c_oldqtyshipped) *
                                @c_oldsotostd * -1.0,4)
                    /* Qty will be > 0 if we shipped more than was ordered. */
                    IF @c_qty < 0
                      BEGIN
                        EXECUTE UpdateItemLocationQuantity
                                  @s_olditem,
                                  @s_oldlocation,
                                  0,
                                  @c_qty,
                                  @s_changeduserid
                      END
                  END
                IF @s_inventoried = 'Y' AND @s_item <> '' AND
                   @s_location <> ''
                  BEGIN
                    SELECT @c_qty = Round((@c_qtyordered - @c_qtycancelled - @c_qtyshipped) *
                                @c_sotostd,4)
                    IF @c_qty > 0
                      BEGIN
                        EXECUTE UpdateItemLocationQuantity
                                  @s_item,
                                  @s_location,
                                  0,
                                  @c_qty,
                                  @s_changeduserid
                      END
                  END
              END /* have a change that affects inventory */

          IF @s_documenttype = 'B' AND @i_blanketline <> 0
              BEGIN
                UPDATE so_blanket_items
                   SET cum_quantity_ordered =
                       cum_quantity_ordered + (@c_qtyordered - @c_qtycancelled)
                                  - (@c_oldqtyordered - @c_oldqtycancelled),
                       cum_extended_amount =
                       cum_extended_amount + (@c_extendedamt - @c_cancelledamt)
                                  - (@c_oldextendedamt - @c_oldcancelledamt),
                       changed_date = GetDate(),
                       changed_user_id = @s_changeduserid
                 WHERE sales_order = @s_salesorder
                   AND blanket_line = @i_blanketline
             END /* have a blanket item to update */

          END /* while loop */
          /*  don't need this cursor any longer  */
          CLOSE updsoitemcursor
          DEALLOCATE updsoitemcursor
      END /* have one or more rows in inserted */
  END
GO
ALTER TABLE [dbo].[so_items] ADD CONSTRAINT [pk_so_items] PRIMARY KEY CLUSTERED  ([sales_order], [so_line]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [so_items_item] ON [dbo].[so_items] ([item], [fulfillment_location]) ON [PRIMARY]
GO
