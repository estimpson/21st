SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UpdateSOItemStatus] @as_salesorder varchar(25),
                   @as_documenttype char(1),
                   @ai_soline int,
                   @ac_qtyordered dec(18,6),
                   @ac_qtyshipped dec(18,6),
                   @ac_qtycancelled dec(18,6),
                   @as_status char(1),
                   @as_changeduserid varchar(25)
AS

-- 13-Apr-2010 Don't update the release status for quotes.  Quotes
--             get a cancelled status through the SO Scoreboard
--             Cancel Quote option.

-- 05-Aug-2005 Set the status to 'C' even if the quantity_ordered
--             is zero.

-- 07-Jun-2005 Added code to update the SO release status.

BEGIN
  DECLARE @s_updateneeded char(1),
          @s_sorelease varchar(25)

  SELECT @s_updateneeded = 'N'

  IF @ac_qtyshipped + @ac_qtycancelled >= @ac_qtyordered
    BEGIN
      IF @as_status <> 'C'
        BEGIN
          -- this item was open so close it
          SELECT @as_status = 'C'
          SELECT @s_updateneeded = 'Y'
        END
    END
  ELSE
    BEGIN
      IF @as_status = 'C'
        BEGIN
          -- this was a closed item so open it up again
          SELECT @as_status = 'O'
          SELECT @s_updateneeded = 'Y'
        END
    END

  IF @s_updateneeded = 'Y'
    BEGIN       -- Update the existing row
      UPDATE so_items
         SET status = @as_status,
             changed_date = GETDATE(),
             changed_user_id = @as_changeduserid
       WHERE sales_order = @as_salesorder
         AND so_line = @ai_soline
    END

 IF @as_documenttype <> 'Q'
   BEGIN
     -- Call the stored procedure to update the SO release status whether or not
     -- we updated any items. This ensures that the release and items are always in sync.
     -- The status on quotes gets set by the SO Scoreboard Cancel Quote option not
     -- based on the status of the items.
     SELECT @s_sorelease = IsNull(so_release,'')
       FROM so_items
      WHERE sales_order = @as_salesorder
        AND so_line=@ai_soline

     EXECUTE UpdateSOReleaseStatus @as_salesorder,
                                   @s_sorelease,
                                   @as_changeduserid
  END

END
GO
