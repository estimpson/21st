SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[InventoryValuation] @as_beglocation varchar(25),
                                 @as_endlocation varchar(25),
                                 @as_begunit varchar(25),
                                 @as_endunit varchar(25),
                                 @as_begitem varchar(50),
                                 @as_enditem varchar(50),
                                 @ad_selectdate datetime,
                                 @as_begcommodity varchar(50),
                                 @as_endcommodity varchar(50)

AS

-- 28-Jul-2011 Modified the second select to group by IsNull(...item_description)
--             so that it is identical to the value in the select by.  Otherwise,
--             it gives an error in SQL Server 2000.

-- 18-Jan-2010 Modified Group By for select added on 04-Dec-2009 to group by
--                   Convert(varchar(250), items.item_description)
--             rather than
--                   IsNull(Convert(varchar(250), items.item_description),'Unknown')
--             because the latter gave an error in ASA5 and ASA7.


-- 04-Dec-2009 Create pseudo item/location rows for item/locations that
--             have transactions but that no longer have location rows.
--             Prior to this date it was okay to delete a location with
--             transactions as long as the transactions netted to zero.

-- 15-Jun-2004 Added the Sum function to the two update statements because
--             in MS SQL Server and ASE the quantity and amount would
--             be updated with only the last row, if there were multiple
--             item transaction rows.

-- 24-May-2004 Added IsNull to the commodity selection criteria so that
--             rows with no commodity get selected.

-- 04-Feb-2004 Removed outer joins of items and units_inventory tables
--             because it was messing up the selection on commodity.

-- 09-May-2003 Added beginning and ending commodity to the selection
--             criteria.

BEGIN

  CREATE TABLE #inventory_valuation
       (item                   varchar(50) NOT NULL,
        location               varchar(25) NOT NULL,
        inventory_uom          varchar(25) NULL,
        on_hand_quantity       decimal(18,6) NULL,
        inventory_amount       decimal(18,6) NULL,
        unit                   varchar(25) NULL,
        item_description       varchar(250) NULL,
        unit_name              varchar(40) NULL,
        transaction_quantity   decimal(18,6) NULL,
        transaction_amount     decimal(18,6) NULL )

  /*  Select inventory items
  */
  INSERT INTO #inventory_valuation

    SELECT item_locations.item,
           item_locations.location,
           item_locations.inventory_uom,
           item_locations.on_hand_quantity,
           item_locations.inventory_amount,
           item_locations.unit,
           Convert(varchar(250), items.item_description),
           units_inventory.name,
           0,
           0
      FROM item_locations, items, units_inventory
     WHERE item_locations.item = items.item AND
           item_locations.unit = units_inventory.unit AND
           item_locations.item >= @as_begitem AND
           item_locations.item <= @as_enditem AND
           item_locations.location >= @as_beglocation AND
           item_locations.location <= @as_endlocation AND
           item_locations.unit >= @as_begunit AND
           item_locations.unit <= @as_endunit AND
	     IsNull(items.commodity,'') >= @as_begcommodity AND
	     IsNull(items.commodity,'') <= @as_endcommodity

  ORDER BY item_locations.unit ASC,
           item_locations.item ASC,
           item_locations.location ASC

  -- Prior to 2010 users could delete rows from item_locations
  -- if the location had transactions but all of the balances
  -- were zero.  This causes problems if a user runs a
  -- valuation for a date prior to when the location was deleted.
  -- Insert rows for those items that have transactions but no
  -- longer have locations
  INSERT INTO #inventory_valuation

    SELECT item_transactions.item,
           item_transactions.location,
           '',
           0,
           0,
           item_transactions.unit,
           IsNull(Convert(varchar(250), items.item_description),'Unknown'),
           IsNull(units_inventory.name,'Unknown'),
           0,
           0
      FROM item_transactions
           LEFT OUTER JOIN items
             ON item_transactions.item = items.item
           LEFT OUTER JOIN units_inventory
             ON item_transactions.unit = units_inventory.unit
     WHERE item_transactions.item BETWEEN @as_begitem AND @as_enditem AND
           item_transactions.location BETWEEN @as_beglocation AND @as_endlocation AND
           item_transactions.unit BETWEEN @as_begunit AND @as_endunit AND
	   IsNull(items.commodity,'') BETWEEN @as_begcommodity AND @as_endcommodity AND
           Convert(char(10),item_transactions.gl_date,111) >
                 Convert(char(10),@ad_selectdate,111) AND
           NOT EXISTS (SELECT 1 FROM item_locations
                        WHERE item_transactions.item = item_locations.item
                          AND item_transactions.location = item_locations.location)

  GROUP BY item_transactions.item,
           item_transactions.location,
           item_transactions.unit,
           IsNull(Convert(varchar(250), items.item_description),'Unknown'),
           IsNull(units_inventory.name,'Unknown')

  ORDER BY item_transactions.item,
           item_transactions.location,
           item_transactions.unit


  /* Update the quantities and amounts for the issues that happened after
   the GL date.
  */
  UPDATE #inventory_valuation
     SET transaction_quantity = transaction_quantity -
         (SELECT IsNull(Sum(quantity),0)
            FROM item_transactions
           WHERE item_transactions.item = #inventory_valuation.item AND
                 item_transactions.location = #inventory_valuation.location AND
                 Convert(char(10),item_transactions.gl_date,111) >
                    Convert(char(10),@ad_selectdate,111) AND
                 item_transactions.transaction_type in('ISSUE','ADJ OUT','XFER OUT')),
         transaction_amount = transaction_amount -
         (SELECT IsNull(Sum(amount),0)
            FROM item_transactions
           WHERE item_transactions.item = #inventory_valuation.item AND
                 item_transactions.location = #inventory_valuation.location AND
                 Convert(char(10),item_transactions.gl_date,111) >
                    Convert(char(10),@ad_selectdate,111) AND
                 item_transactions.transaction_type in('ISSUE','ADJ OUT','XFER OUT'))

  /* Update the quantities and amounts for the receipts that happened after
  the GL date.
  */
  UPDATE #inventory_valuation
     SET transaction_quantity = transaction_quantity +
         (SELECT IsNull(Sum(quantity),0)
            FROM item_transactions
           WHERE item_transactions.item = #inventory_valuation.item AND
                 item_transactions.location = #inventory_valuation.location AND
                 Convert(char(10),item_transactions.gl_date,111) >
                    Convert(char(10),@ad_selectdate,111) AND
                 item_transactions.transaction_type NOT in('ISSUE','ADJ OUT','XFER OUT')),
         transaction_amount = transaction_amount +
         (SELECT IsNull(Sum(amount),0)
            FROM item_transactions
           WHERE item_transactions.item = #inventory_valuation.item AND
                 item_transactions.location = #inventory_valuation.location AND
                 Convert(char(10),item_transactions.gl_date,111) >
                    Convert(char(10),@ad_selectdate,111) AND
                 item_transactions.transaction_type NOT in('ISSUE','ADJ OUT','XFER OUT'))

  /* Return those items from the temporary table that have an on-hand
     quantity
  */
SELECT unit,
       unit_name,
       item,
       location,
       item_description,
       on_hand_quantity - transaction_quantity on_hand_qty,
       inventory_uom,
       inventory_amount - transaction_amount on_hand_amt
    FROM #inventory_valuation
   WHERE on_hand_quantity <> transaction_quantity OR
         inventory_amount <> transaction_amount
   ORDER BY unit,
            item,
            location
END
GO
