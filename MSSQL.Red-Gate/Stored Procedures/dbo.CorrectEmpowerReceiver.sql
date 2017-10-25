SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CorrectEmpowerReceiver]
         @as_ponumber   varchar(25),
         @as_shipper    varchar(20),
         @as_part       varchar(25),
         @ac_quantity   numeric(18,6),
         @adt_datestamp datetime

AS

-- This procedure is called when a receiver is corrected or deleted 
-- from the Monitor Audit Trail table. In some cases, receivers are 
-- actually deleted from the Audit Trail table. In other cases, they are 
-- flagged with a type of D.

-- 17-Apr-2008 Removed references to preferences_site.

-- 23-Feb-2004 Created from SQLAnywhere version.

BEGIN
DECLARE @i_bolline       SMALLINT,
        @s_invoice       VARCHAR(25),
        @s_shipper       VARCHAR(25),
        @c_cost          NUMERIC(18,6),
        @c_quantityrecvd NUMERIC(18,6),
        @c_amount        NUMERIC(18,6),
        @i_count         INTEGER,
        @s_deletehdr     char(1),
        @s_appenddate    char(1)

  -- Get the preference that indicates if we need to append 
  -- the date to the shipper.
  SELECT @s_appenddate = IsNull(value,'')
    FROM preferences_standard
   WHERE preference = 'MonitorAppendDateToShipper'
  IF @@rowcount = 0 OR @s_appenddate = '' SELECT @s_appenddate = 'Y'

  IF @s_appenddate = 'Y'
    SELECT @s_shipper = LTrim(RTrim(@as_shipper)) + '_' + Convert(char(6),@adt_datestamp,12)
  ELSE
    SELECT @s_shipper = LTrim(RTrim(@as_shipper))

  -- Is this shipper/part in the po_receiver_items table? 
  SELECT @i_bolline = bol_line, 
         @c_cost = unit_cost, 
         @s_invoice = IsNull(invoice,''), 
         @c_quantityrecvd = quantity_received
    FROM po_receiver_items 
   WHERE po_receiver_items.purchase_order = @as_ponumber AND
         po_receiver_items.bill_of_lading = @s_shipper AND
         po_receiver_items.item = @as_part

  IF @@rowcount <> 0 AND @i_bolline > 0 AND @s_invoice = ''
    BEGIN
      -- this shipper/part is in the po_receiver_items table and has not
      -- been invoiced so we need to adjust its received quantity. 

      -- Calculate an amount for this item based on the received quantity
      -- and the receiver cost. Quantity will be passed as a negative
      -- number.
      SELECT @c_amount = ROUND(@ac_quantity * @c_cost, 2)

      SELECT @s_deletehdr = 'N'

      -- If the user deleted the entire received quantity, delete the 
      -- receiver and its GL cost transactions. 
      IF @c_quantityrecvd + @ac_quantity = 0
        BEGIN
          DELETE FROM po_receiver_items
           WHERE po_receiver_items.purchase_order = @as_ponumber AND
                 po_receiver_items.bill_of_lading = @s_shipper AND
                 po_receiver_items.item = @as_part

          DELETE FROM gl_cost_transactions
           WHERE document_type = 'BILL OF LADING' AND
                 document_id1 = @as_ponumber AND
                 document_id2 = @s_shipper AND
                 document_id3 = '' AND
                 document_line = @i_bolline

          -- If this bill of lading doesn't have any other items, we
          -- can delete the header.
          SELECT @i_count = COUNT(*)
            FROM po_receiver_items
           WHERE po_receiver_items.purchase_order = @as_ponumber AND
                 po_receiver_items.bill_of_lading = @s_shipper
          IF @i_count = 0 SELECT @s_deletehdr = 'Y'
        END
      ELSE
        BEGIN
          -- Update the quantity and amount on the receiver item row.
          UPDATE po_receiver_items
             SET quantity_received = quantity_received + @ac_quantity,
                 total_cost = total_cost + @c_amount,
                 changed_date = GetDate(), 
                 changed_user_id = 'MONITOR'
           WHERE po_receiver_items.purchase_order = @as_ponumber AND
                 po_receiver_items.bill_of_lading = @s_shipper AND
                 po_receiver_items.item = @as_part

          -- Now update the item GL cost transaction. We'll do the
          -- header GL cost transaction below.
          UPDATE gl_cost_transactions
             SET quantity = quantity + @ac_quantity,
                 amount = amount + @c_amount,
                 document_amount = document_amount + @c_amount, 
                 changed_date = GetDate(), 
                 changed_user_id = 'MONITOR'
           WHERE document_type = 'BILL OF LADING' AND
                 document_id1 = @as_ponumber AND
                 document_id2 = @s_shipper AND
                 document_id3 = '' AND
                 document_line = @i_bolline
        END

      -- Check the flag to see if we need to delete the header or update
      -- it.
      IF @s_deletehdr = 'Y'
        BEGIN
          DELETE FROM po_receivers
           WHERE po_receivers.purchase_order = @as_ponumber AND
                 po_receivers.bill_of_lading = @s_shipper

          DELETE FROM gl_cost_transactions
           WHERE document_type = 'BILL OF LADING' AND
                 document_id1 = @as_ponumber AND
                 document_id2 = @s_shipper AND
                 document_id3 = '' AND
                 document_line = 0
        END
      ELSE
        BEGIN
          UPDATE gl_cost_transactions
             SET amount = amount - @c_amount,
                 document_amount = document_amount - @c_amount, 
                 changed_date = GetDate(), 
                 changed_user_id = 'MONITOR'
           WHERE document_type = 'BILL OF LADING' AND
                 document_id1 = @as_ponumber AND
                 document_id2 = @s_shipper AND
                 document_id3 = '' AND
                 document_line = 0
        END
    END
END
GO
