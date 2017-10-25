SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UpdatePOItemStatus] @as_purchaseorder varchar(25),
                   @ai_poline smallint,
                   @ac_qtyordered dec(18,6),
                   @ac_qtyinvoiced dec(18,6),
                   @ac_qtycancelled dec(18,6),
                   @ac_qtyreceived dec(18,6),
                   @ac_extendedamt dec(18,6),
                   @ac_invoicedamt dec(18,6),
                   @ac_cancelledamt dec(18,6),
                   @as_status char(1),
                   @as_statusreason char(1),
                   @as_changeduserid varchar(25),
                   @as_receiver char(1)
AS

-- 20-Oct-2005 Removed code that updated the PO header status.  The
--             status is stored on the PO release.

-- 28-Apr-2005 Added code to update the PO release status.

-- 25-Oct-2000 Added receiver and quantity received arguments and on
--             items that are received set the status reason to 'R'
--             when closing.

-- 10-Mar-2000 Don't set the status on NTE lines; otherwise, we may
--             incorrectly close a line that UpdatePOHeaderStatus won't
--             reopen. UpdatePOHeaderStatus only reopens NTE lines when it
--             changes the status of the PO header.

-- 24-Jan-2000 Call UpdatePOHeaderStatus even if no line items changed.

BEGIN   DECLARE @s_updateneeded char(1),
          @s_nte char(1),
          @s_porelease varchar(25)

  SELECT @s_nte = IsNull(not_to_exceed,'N')
    FROM po_headers
   WHERE purchase_order = @as_purchaseorder

  IF @s_nte <> 'Y'
    BEGIN
      SELECT @s_updateneeded = 'N'

      IF @as_receiver = 'Y'
        BEGIN
          IF (@ac_qtyinvoiced + @ac_qtycancelled >= @ac_qtyordered and @ac_qtyordered > 0)
            BEGIN
              /* close this item */
              SELECT @as_status = 'C'
              SELECT @as_statusreason = 'I'
              SELECT @s_updateneeded = 'Y'
            END
          ELSE
            BEGIN
              IF (@ac_qtyreceived + @ac_qtycancelled >= @ac_qtyordered and @ac_qtyordered > 0)
                BEGIN
                  /* close this item */
                  SELECT @as_status = 'C'
                  SELECT @as_statusreason = 'R'
                  SELECT @s_updateneeded = 'Y'
                END
              ELSE
                BEGIN
                  IF @as_status = 'C' AND (@as_statusreason = 'I' OR @as_statusreason = 'R')
                    BEGIN
                      /* this was a closed item so open it up again */
                      SELECT @as_status = 'O'
                      SELECT @as_statusreason = ''
                      SELECT @s_updateneeded = 'Y'
                    END
                END
            END
        END
      ELSE
        BEGIN
          IF (@ac_qtyinvoiced + @ac_qtycancelled >= @ac_qtyordered AND @ac_qtyordered > 0 )
            BEGIN
              /* close this item */
              SELECT @as_status = 'C'
              SELECT @as_statusreason = 'I'
              SELECT @s_updateneeded = 'Y'
            END
          ELSE
            BEGIN
              IF (@ac_invoicedamt + @ac_cancelledamt >= @ac_extendedamt AND
                     @ac_extendedamt > 0 AND @ac_qtyordered = 0 )
                BEGIN
                  /* close this item */
                  SELECT @as_status = 'C'
                  SELECT @as_statusreason = 'I'
                  SELECT @s_updateneeded = 'Y'
                END
              ELSE
                BEGIN
                  IF @as_status = 'C' AND @as_statusreason = 'I'
                    BEGIN
                      /* this was a closed item so open it up again */
                      SELECT @as_status = 'O'
                      SELECT @as_statusreason = ''
                      SELECT @s_updateneeded = 'Y'
                    END
                END
            END
        END

      IF @s_updateneeded = 'Y'
        BEGIN           /*  Update the existing row  */
          UPDATE po_items
             SET status=@as_status, status_reason=@as_statusreason,
                 changed_date=GETDATE(),
                 changed_user_id=@as_changeduserid
            WHERE purchase_order=@as_purchaseorder
              AND po_line=@ai_poline
        END
    END

  /* Call the stored procedure to update the PO release status whether or */
  /* not we updated any items. This serves two purposes:                 */
  /*    1) It ensures that the header and items are always in sync.      */
  /*    2) It closes NTE PO's which have 0 in the quantity and ordered   */
  /*       amount.                                                       */
  SELECT @s_porelease = IsNull(po_release,'')
    FROM po_items
   WHERE purchase_order = @as_purchaseorder
     AND po_line=@ai_poline

  EXECUTE UpdatePOReleaseStatus @as_purchaseorder,
                                @s_porelease,
                                @as_changeduserid

END
GO
