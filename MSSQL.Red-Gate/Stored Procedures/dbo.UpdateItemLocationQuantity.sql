SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UpdateItemLocationQuantity]
                   @as_item varchar(50),
                   @as_location varchar(25),
                   @ac_stdqtyonorder dec(18,6),
                   @ac_stdqtysold dec(18,6),
                   @as_changeduserid varchar(25)

AS

-- 22-Feb-2002 On an insert into item_locations, populate the min and
--             max average_costs and serial_required.

BEGIN
  DECLARE @c_invtostd dec(18,6),
          @s_invuom varchar(25),
          @s_ledger varchar(40),
          @i_rowcount integer

  /* Get the inventory conversion factor from the item location
     row if it exists. */
  SELECT @c_invtostd = IsNull(inventory_uom_to_standard, 1)
    FROM item_locations
   WHERE item = @as_item AND
         location = @as_location

  IF @@rowcount = 0
    BEGIN
      /* We need to create the item_location row. First get
         some values from the item row. */
      SELECT @s_invuom = standard_uom,
             @s_ledger = ledger
        FROM items
       WHERE item = @as_item

      /* Should always find the item. Insert the item location row.
         Assume a conversion factor of 1.                           */
      INSERT INTO item_locations
          (item, location, inventory_uom,
           inventory_uom_to_standard, on_hand_quantity,
           on_order_quantity, sold_quantity,
           reserved_quantity, inventory_amount,
           average_cost, minimum_ave_cost, maximum_ave_cost,
           serial_required, changed_date, changed_user_id, ledger)
         VALUES (@as_item, @as_location, @s_invuom,
                 1, 0, @ac_stdqtyonorder, @ac_stdqtysold,
                 0, 0,
                 0, 0, 999999999,
                 'N', GetDate(), @as_changeduserid, @s_ledger)
    END
  ELSE
    BEGIN
      /* Found the item location row. Update its on ordered and sold
         quantities.                                                 */
      IF @c_invtostd = 0 SELECT @c_invtostd = 1
      UPDATE item_locations
         SET on_order_quantity = IsNull(on_order_quantity,0) +
                Round(@ac_stdqtyonorder / @c_invtostd, 4 ),
             sold_quantity = IsNull(sold_quantity,0) +
                Round(@ac_stdqtysold / @c_invtostd, 4 ),
             changed_date = GetDate(),
             changed_user_id = @as_changeduserid
       WHERE item = @as_item AND
             location = @as_location
    END
 END
GO
