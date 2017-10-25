SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UpdatePOReleaseStatus]
                   @as_purchaseorder varchar(25),
                   @as_porelease varchar(25),
                   @as_changeduserid varchar(25)
AS

BEGIN   DECLARE @s_updateneeded char(1),
          @s_status char(1),
          @s_nte char(1),
          @i_count int,
          @c_amtordered decimal(18,6),
          @c_amtcancelled decimal(18,6),
          @c_amtinvoiced decimal(18,6)

  SELECT @s_updateneeded = 'N'

  SELECT @s_nte = IsNull(not_to_exceed,'N')
    FROM po_headers
   WHERE purchase_order = @as_purchaseorder

  SELECT @s_status = status
    FROM po_releases
   WHERE purchase_order = @as_purchaseorder
     AND po_release = @as_porelease

  IF @s_nte = 'N'
    BEGIN
      SELECT @i_count = Count(*)
        FROM po_items
       WHERE purchase_order = @as_purchaseorder
         AND po_release = @as_porelease
         AND line_type = 'IT' AND status = 'O'

      IF @i_count = 0
        BEGIN
          /* didn't find any open items for this PO */
          IF @s_status = 'O'
            BEGIN
              SELECT @s_status = 'C'
              SELECT @s_updateneeded = 'Y'
            END
        END
      ELSE
        BEGIN
          /* found open items for this PO */
          IF @s_status <> 'O'
            BEGIN
              /* this was a closed item so open it up again */
              SELECT @s_status = 'O'
              SELECT @s_updateneeded = 'Y'
            END
        END
    END
  ELSE
    BEGIN
      /* NTE PO. Close the PO release if the amount invoiced is greater */
      /* than or equal to the amount ordered less the amount cancelled.*/
      /* When the header is closed, close all of the items.            */
      SELECT @c_amtordered = SUM(IsNull(extended_amount,0)),
             @c_amtcancelled = SUM(IsNull(cancelled_amount,0)),
             @c_amtinvoiced = SUM(IsNull(invoiced_amount,0))
        FROM po_items
       WHERE purchase_order = @as_purchaseorder
         AND po_release = @as_porelease
         AND line_type = 'IT'

      IF @c_amtinvoiced >= @c_amtordered - @c_amtcancelled
        BEGIN
          /* Have invoiced more than was ordered for this PO */
          IF @s_status = 'O'
            BEGIN
              SELECT @s_status = 'C'
              SELECT @s_updateneeded = 'Y'
            END
          ELSE
            BEGIN
              IF @s_status <> 'O'
                BEGIN
                  /* Haven't invoiced more than was ordered for this PO*/
                  SELECT @s_status = 'O'
                  SELECT @s_updateneeded = 'Y'
                END
            END
        END
    END

  IF @s_updateneeded = 'Y'
    BEGIN       /*  Update the existing row  */
      UPDATE po_releases
         SET status=@s_status,
             changed_date=GETDATE(),
             changed_user_id=@as_changeduserid
       WHERE purchase_order=@as_purchaseorder
         AND po_release = @as_porelease
       IF @s_nte = 'Y'
        BEGIN
          /* Whenever we update a NTE PO release, we also need to update */
          /* the items.                                                 */
          UPDATE po_items
             SET status=@s_status,
                 status_reason='I',
                 changed_date=GETDATE(),
                 changed_user_id=@as_changeduserid
           WHERE purchase_order=@as_purchaseorder
             AND po_release = @as_porelease
        END
    END
  END
GO
