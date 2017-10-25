CREATE TABLE [dbo].[po_receiver_items]
(
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bill_of_lading] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bol_line] [smallint] NOT NULL,
[receiver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invoice] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inv_line] [smallint] NULL,
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receiver_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity_received] [numeric] (18, 6) NULL,
[unit_cost] [numeric] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_cost] [numeric] (18, 6) NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[container_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_of_origin] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_cost] [numeric] (18, 6) NULL,
[other_cost] [numeric] (18, 6) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_POReceiverItems]
ON [dbo].[po_receiver_items] FOR DELETE
AS

-- 11-Apr-08 Don't delete inventory transactions for receipts from
--           receive items for a purchase order.  The receiver program
--           now does that so that serial numbers can be assigned.

-- 24-Jan-2002 Changed the datatype of item from varchar(25) to varchar(50),
--             of i_bolline from int to smallint, and the decimals to
--             numeric.

BEGIN
  DECLARE @s_purchaseorder varchar(25),
          @s_billoflading varchar(25),
          @s_receiver varchar(25),
          @i_bolline smallint,
          @c_qtyreceived numeric(18,6),
          @c_potostd numeric(18,6),
          @s_item varchar(50),
          @s_containerid varchar(25),
          @s_changeduserid varchar(25),
          @i_deletedrows int,
          @i_count int

  /*  save the number of rows that were just deleted, if any  */
  SELECT @i_deletedrows = Count(*) from deleted

  IF @i_deletedrows > 0
    BEGIN
      DECLARE deletedporcursor CURSOR FOR
        SELECT purchase_order, bill_of_lading, bol_line, item,
               quantity_received, receiver, IsNull(container_id,''),
               changed_user_id
          FROM deleted

      OPEN deletedporcursor

      /*  any status from the fetch other than 0 will terminate the loop  */
      WHILE 1 = 1
        BEGIN
          FETCH deletedporcursor
           INTO @s_purchaseorder, @s_billoflading, @i_bolline, @s_item,
                @c_qtyreceived, @s_receiver, @s_containerid, @s_changeduserid

          IF @@fetch_status <> 0 BREAK

          UPDATE po_items
             SET quantity_received = quantity_received - @c_qtyreceived,
                 changed_date = GETDATE(),
                 changed_user_id = @s_changeduserid
           WHERE purchase_order = @s_purchaseorder AND
                 po_line = @i_bolline

            /* If this item updated inventory, there will be a row in
               the item_transactions table to delete. The deletion of this
               row will update the item location on-hand quantity. The PO
               items update trigger will update the item location on-order.
               If the item came from Receive Items for a PO rather than
               Receive Items by Container, the item transaction is deleted
               by the user object on the window and we should not delete
               the item transaction here.                                   */
          IF @s_containerid <> ''
            DELETE FROM item_transactions
             WHERE document_type = 'BILL OF LADING' AND
                   document_id1 = @s_purchaseorder AND
                   document_id2 =  @s_billoflading AND
                   document_id3 = @s_receiver AND
                   document_line = @i_bolline

        END

        /*  don't need this cursor any longer  */
        CLOSE deletedporcursor
        DEALLOCATE deletedporcursor
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_POReceiverItems]
ON [dbo].[po_receiver_items] FOR INSERT
AS
BEGIN

-- 11-Apr-08 Don't write inventory transactions for receipts from
--           receive items for a purchase order.  The receiver program
--           now does that so that serial numbers can be assigned.

-- 29-Apr-04 Serial_required was being defaulted to 'Y' if null and
--           should default to 'N'.

-- 25-May-02 Use the item_location unit, not the PO header buy_unit, as
--           the unit on the item transaction.

-- 24-Jan-02 Changed datatype of i_bolline from int to smallint and of item
--           from varchar(25) to varchar(50) and of the numeric columns from
--           dec to numeric to be consistent with the table definition;
--           otherwise, MS SQL Server 6.5 gives errors that the datatypes of
--           the local variables don't match the datatypes of the columns
--           in the cursor.

-- 10/3/2001 Removed the update of receiver_comments into the note column
--           in item_transactions because Sybase and MS SQL Server do not
--           allow local variables of type text.  Tried changing the @s_comments
--           variable from text to varchar(250) and using the Convert function
--           but Sybase gave the error message 'The text table and the table
--           referenced by the text pointer disagree' and MS SQL Server did
--           not update the column.

  DECLARE @s_purchaseorder varchar(25),
          @s_billoflading varchar(25),
          @s_receiver varchar(25),
          @i_bolline smallint,
          @s_item varchar(50),
          @s_unit varchar(25),
          @s_exponreceipt char(1),
          @s_inventoried char(1),
          @s_location varchar(25),
          @s_debitledgeraccount varchar(50),
          @s_creditledgeraccount varchar(50),
          @s_ledger varchar(40),
          @s_fiscalyear varchar(5),
          @s_glentry varchar(25),
          @s_serialrequired char(1),
          @s_serialnumber varchar(25),
          @s_containerid varchar(25),
          @s_package varchar(25),
          @s_countryoforigin varchar(25),
          @s_ivtcontainerid varchar(25),
          @s_ivtpackage varchar(25),
          @d_gldate datetime,
          @i_period smallint,
          @c_qtyreceived numeric(18,6),
          @c_potostd numeric(18,6),
          @c_invtostd numeric(18,6),
          @c_qtyinventoried numeric(18,6),
          @c_totalcost numeric(18,6),
          @s_changeduserid varchar(25),
          @i_rowcount int,
          @i_count int

  /*  is there a row in the inserted table?  */
  SELECT @i_rowcount = Count(*) from inserted

  IF @i_rowcount > 0
    BEGIN

      /* Will use a cursor whether one row or multiple rows were
         inserted. It makes for less coding. */
      DECLARE insporeccursor CURSOR FOR
        SELECT purchase_order, bill_of_lading, IsNull(item,''),
               bol_line, quantity_received, total_cost,
               ledger_account_code,
               receiver, changed_user_id, IsNull(container_id,''),
               package, country_of_origin
          FROM inserted

      OPEN insporeccursor

      WHILE 1 = 1
        BEGIN
          FETCH insporeccursor
           INTO @s_purchaseorder, @s_billoflading, @s_item,
                @i_bolline, @c_qtyreceived, @c_totalcost,
                @s_debitledgeraccount,
                @s_receiver, @s_changeduserid, @s_containerid,
                @s_package, @s_countryoforigin


          /* any status from the fetch other than 0 will terminate the
             loop. */
          IF @@fetch_status <> 0 BREAK

          UPDATE po_items
             SET quantity_received = quantity_received + @c_qtyreceived,
                 changed_date = GETDATE(),
                 changed_user_id = @s_changeduserid
           WHERE purchase_order = @s_purchaseorder AND
                 po_line = @i_bolline

          /* If the item is blank, we won't be updating inventory. */
          IF @s_item = '' CONTINUE

          /* See if this receiver is for a purchase order item that updated
             inventory. If it is, we need to insert an item_transaction.
             The PO items update trigger will take care of updating the
             item location row so we don't need to do that here.*/
          SELECT @s_exponreceipt = IsNull(expense_on_receipt,'N')
            FROM po_headers
           WHERE purchase_order = @s_purchaseorder

          /* Purchase orders which don't expense on receipt, don't
             update inventory. */
          IF @s_exponreceipt <> 'Y' CONTINUE

          /* The PO expenses on receipt. Is the item inventoried? */
          SELECT @s_inventoried = IsNull(inventoried,'N'),
                 @c_potostd = IsNull(po_quantity_uom_to_standard,1)
            FROM po_items
           WHERE purchase_order = @s_purchaseorder AND
                 po_line = @i_bolline

          IF @s_inventoried <> 'Y' CONTINUE

          /* If the item came from Receive Items for a PO rather than
             Receive Items by Container, the item transaction is written
             by a user object on the window and we should not write the
             item transaction here.  */
          IF @s_containerid = '' CONTINUE
	
          IF @c_potostd = 0 SELECT @c_potostd = 1

          /* The item did update inventory so write an item transaction
             row for the receipt. Need several values from the receiver
             header.  */
          SELECT @s_location = location,
                 @d_gldate = gl_date,
                 @s_glentry = gl_entry,
                 @s_fiscalyear = fiscal_year,
                 @i_period = period,
                 @s_creditledgeraccount = ledger_account_code,
                 @s_ledger = ledger
            FROM po_receivers
           WHERE purchase_order = @s_purchaseorder AND
                 bill_of_lading = @s_billoflading

          /* Need to convert the received quantity into an inventory
             quantity. Get the inventory conversion factor from the item
             location row if it exists. */
          SELECT @c_invtostd = IsNull(inventory_uom_to_standard, 1),
                 @s_serialrequired = IsNull(serial_required, 'N'),
                 @s_unit = IsNull(unit,'')
            FROM item_locations
           WHERE item = @s_item AND
                 location = @s_location

          /* Check for null, as well as zero, in case the above
             retrieve failed. */
          IF @c_invtostd IS NULL OR @c_invtostd = 0
            SELECT @c_invtostd = 1

          /* use the same math that we used to update the item_location. */
          SELECT @c_qtyinventoried = ROUND(@c_qtyreceived * @c_potostd,4)
          SELECT @c_qtyinventoried = ROUND(@c_qtyinventoried / @c_invtostd,4)

          /* Check for null, as well as zero, in case the above
             retrieve failed. */
          IF @s_serialrequired IS NULL OR @s_serialrequired = ''
            SELECT @s_serialrequired = 'N'

          IF @s_serialrequired = 'Y'
            BEGIN
                SELECT @s_serialnumber = @s_receiver
                SELECT @s_ivtcontainerid = @s_containerid
                SELECT @s_ivtpackage = @s_package
            END
          ELSE
            BEGIN
                SELECT @s_serialnumber = ''
                SELECT @s_ivtcontainerid = ''
                SELECT @s_ivtpackage = ''
            END

          INSERT INTO item_transactions
             (item, location, serial_number,
              gl_date, gl_entry, fiscal_year, period,
              transaction_type, quantity, amount,
              changed_date, changed_user_id, unit,
              debit_ledger_account, credit_ledger_account,
              batch, ledger, document_type,
              document_id1, document_id2, document_id3,
              document_line, container_id, package,
              country_of_origin )
            VALUES
             (@s_item, @s_location, @s_serialnumber,
              @d_gldate, @s_glentry, @s_fiscalyear, @i_period,
              'RECEIPT', @c_qtyinventoried, @c_totalcost,
              GetDate(), @s_changeduserid, @s_unit,
              @s_debitledgeraccount, @s_creditledgeraccount,
              @s_glentry, @s_ledger, 'BILL OF LADING',
              @s_purchaseorder, @s_billoflading, @s_receiver,
              @i_bolline, @s_ivtcontainerid, @s_ivtpackage,
              @s_countryoforigin )

        END /* loop */
        /*  don't need this cursor any longer  */
        CLOSE insporeccursor
        DEALLOCATE insporeccursor
    END /* have one or more rows in inserted */
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_POReceiverItems]
ON [dbo].[po_receiver_items] FOR UPDATE
AS
IF UPDATE (quantity_received) or UPDATE (ledger_account_code) or
   UPDATE (total_cost) or UPDATE(country_of_origin) or
   UPDATE (container_id) or UPDATE (package)
BEGIN

-- 11-Apr-08 Don't update inventory transactions for receipts from
--           receive items for a purchase order.  The receiver program
--           now does that so that serial numbers can be assigned.

-- 01-Oct-02 Updated country_of_origin on item_transactions.

-- 24-Jan-02 Changed datatype of i_bolline from int to smallint and of item
--           from varchar(25) to varchar(50) and of the numeric columns from
--           dec to numeric to be consistent with the table definition;
--           otherwise, MS SQL Server 6.5 gives errors that the datatype of
--           the local variables don't match the datatype of the columns
--           in the cursor.

-- 10/3/2001 Removed the update of receiver_comments into the note column
--           in item_transactions because Sybase and MS SQL Server do not
--           allow local variables of type text.  Tried changing the @s_comments
--           variable from text to varchar(250) and using the Convert function
--           but Sybase gave the error message 'The text table and the table
--           referenced by the text pointer disagree' and MS SQL Server did
--           not update the column.

  DECLARE @s_purchaseorder varchar(25),
          @s_billoflading varchar(25),
          @s_receiver varchar(25),
          @i_bolline smallint,
          @s_changeduserid varchar(25),
          @c_oldqtyreceived numeric(18,6),
          @c_newqtyreceived numeric(18,6),
          @c_qtyinventoried numeric(18,6),
          @c_totalcost numeric(18,6),
          @s_ledgeraccountcode varchar(50),
          @s_item varchar(50),
          @s_location varchar(25),
          @c_potostd numeric(18,6),
          @c_invtostd numeric(18,6),
          @i_rowcount int,
          @s_countryoforigin varchar(25),
          @s_containerid varchar(25),
          @s_package varchar(25),
          @i_count int

  /*  Do we have a row to process?  */
  SELECT @i_rowcount = Count(*) from inserted

  IF @i_rowcount > 0
    BEGIN
      DECLARE updporcursor CURSOR FOR
        SELECT inserted.purchase_order,
               inserted.bill_of_lading,
               inserted.bol_line,
               inserted.quantity_received,
               deleted.quantity_received,
               inserted.total_cost,
               inserted.ledger_account_code,
               inserted.item,
               inserted.receiver,
               inserted.changed_user_id,
               inserted.country_of_origin,
               IsNull(inserted.container_id,''),
               inserted.package
          FROM inserted, deleted
          WHERE inserted.purchase_order = deleted.purchase_order AND
              inserted.bill_of_lading = deleted.bill_of_lading AND
              inserted.bol_line = deleted.bol_line AND
              inserted.receiver = deleted.receiver

      OPEN updporcursor

      WHILE 1 = 1
        BEGIN
          FETCH updporcursor
           INTO @s_purchaseorder, @s_billoflading, @i_bolline,
                @c_newqtyreceived, @c_oldqtyreceived, @c_totalcost,
                @s_ledgeraccountcode, @s_item,
                @s_receiver, @s_changeduserid, @s_countryoforigin,
                @s_containerid, @s_package

          /* any status from the fetch other than 0 will terminate the
             loop. */
          IF @@fetch_status <> 0 BREAK

          IF @c_newqtyreceived <> @c_oldqtyreceived
            UPDATE po_items
               SET quantity_received = quantity_received +
                        (@c_newqtyreceived - @c_oldqtyreceived),
                   changed_date = GETDATE(),
                   changed_user_id = @s_changeduserid
             WHERE purchase_order = @s_purchaseorder AND
                   po_line = @i_bolline

          /* If the item came from Receive Items for a PO rather than
             Receive Items by Container, the item transaction is updated
             by a user object on the window and we should not update
             the item transaction here. */
          IF @s_containerid = '' CONTINUE

          /* Need the location for the transaction. */
          SELECT @s_location = location
            FROM item_transactions
           WHERE document_type = 'BILL OF LADING' AND
                 document_id1 = @s_purchaseorder AND
                 document_id2 =  @s_billoflading AND
                 document_id3 = @s_receiver AND
                 document_line = @i_bolline

          /* If there is no transaction, we're done. */
          IF @@rowcount = 0 CONTINUE

          /* Need the conversion factor to convert the PO quantity to
             a standard quantity. */
          SELECT @c_potostd = IsNull(po_quantity_uom_to_standard,1)
            FROM po_items
           WHERE purchase_order = @s_purchaseorder AND
                 po_line = @i_bolline

          IF @c_potostd = 0 SELECT @c_potostd = 1

          /* Need to convert the received quantity into an inventory
             quantity. Get the inventory conversion factor from the item
             location row if it exists. */
          SELECT @c_invtostd = IsNull(inventory_uom_to_standard, 1)
            FROM item_locations
           WHERE item = @s_item AND
                 location = @s_location

          /* Check for null, as well as zero, in case the above
             retrieve failed. */
          IF @c_invtostd IS NULL OR @c_invtostd = 0
            SELECT @c_invtostd = 1

          /* use the same math that we used to update the item_location. */
          SELECT @c_qtyinventoried = ROUND(@c_newqtyreceived * @c_potostd,4)
          SELECT @c_qtyinventoried = ROUND(@c_qtyinventoried / @c_invtostd,4)

          /* The item did update inventory. The PO items update trigger
             will update the item location row. We just need to update
             the item transaction. */
          UPDATE item_transactions
             SET quantity = @c_qtyinventoried,
                 amount = @c_totalcost,
                 debit_ledger_account = @s_ledgeraccountcode,
                 changed_date = GetDate(),
                 changed_user_id = @s_changeduserid,
                 country_of_origin = @s_countryoforigin,
                 container_id = @s_containerid,
                 package = @s_package
           WHERE document_type = 'BILL OF LADING' AND
                 document_id1 = @s_purchaseorder AND
                 document_id2 =  @s_billoflading AND
                 document_id3 = @s_receiver AND
                 document_line = @i_bolline
        END

        /*  don't need this cursor any longer  */
        CLOSE updporcursor
        DEALLOCATE updporcursor
    END
END
GO
ALTER TABLE [dbo].[po_receiver_items] ADD CONSTRAINT [pk_po_receiver_items] PRIMARY KEY NONCLUSTERED  ([purchase_order], [bill_of_lading], [bol_line], [receiver]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [po_receiver_items_bol] ON [dbo].[po_receiver_items] ([bill_of_lading], [bol_line]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [po_receiver_items_item] ON [dbo].[po_receiver_items] ([item], [purchase_order]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [po_receiver_items_receiver] ON [dbo].[po_receiver_items] ([receiver]) ON [PRIMARY]
GO
