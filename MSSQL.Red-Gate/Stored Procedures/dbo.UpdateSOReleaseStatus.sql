SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UpdateSOReleaseStatus] (@as_salesorder varchar(25),
                                       @as_sorelease varchar(25),
                                       @as_changeduserid varchar(25) )
AS

-- 13-Apr-2010 No longer update the cancelled date.  The cancelled date
--             is on so_headers and applies only to quotes.  It gets set
--             using the SO Scoreboard Cancel Quote option.
BEGIN

  DECLARE @s_updateneeded char(1),
          @s_status char(1),
          @i_count int

  SELECT @s_updateneeded = 'N'

  SELECT @s_status = status
    FROM so_releases
   WHERE sales_order = @as_salesorder
     AND so_release = @as_sorelease

  IF @@rowcount = 1
    -- should always find the sales order
    BEGIN
      SELECT @i_count = Count(*)
        FROM so_items
       WHERE sales_order = @as_salesorder
         AND so_release = @as_sorelease
         AND status <> 'C'

      IF @i_count = 0
        -- didn't find any open items for this SO release
        BEGIN
          IF @s_status = 'O'
            -- SO was open, so close it
            BEGIN
              SELECT @s_status = 'C'
              SELECT @s_updateneeded = 'Y'
            END
        END
      ELSE
        -- found open items for this SO
        BEGIN
          IF @s_status <> 'O'
            BEGIN
              -- this was a closed SO so open it up again
              SELECT @s_status = 'O'
              SELECT @s_updateneeded = 'Y'
            END
        END

      IF @s_updateneeded = 'Y'
        -- Update the existing row
        BEGIN
          UPDATE so_releases
             SET status = @s_status,
                 changed_date = GETDATE(),
                 changed_user_id = @as_changeduserid
           WHERE sales_order = @as_salesorder
             AND so_release = @as_sorelease
        END
    END

END
GO
