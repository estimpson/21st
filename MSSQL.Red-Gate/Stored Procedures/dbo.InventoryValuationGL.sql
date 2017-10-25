SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[InventoryValuationGL] @as_begunit varchar(25),
                                 @as_endunit varchar(25),
                                 @ad_selectdate datetime

AS

BEGIN

-- 15-Dec-2009 Left outer join items when adding the item description
--             so that transactions for deleted items are included.

-- 19-Apr-2008 1. Added IV PROD (item production) transactions.
--             2. Modified selection for Bill of Lading transactions
--                for BOL's not associated with containers because
--                it's now possible to have multiple item transaction
--                rows with different serials for a single gl cost
--                transaction row.

-- 03-Aug-2007 Added DIRECT SALE transactions.

-- 05-Mar-2007 Added POS (point of sale) transactions.

-- 29-Dec-2005 Shortened names of temporary tables to avoid duplicate
--             names in ASE.

  CREATE TABLE #inv_val_gl
       (item                   varchar(50) NOT NULL,
        location               varchar(25) NOT NULL,
        ledger_account         varchar(50) NULL,
        account_description    varchar(50) NULL,
        document_amount        decimal(18,6) NULL,
        amount                 decimal(18,6) NULL )

  CREATE TABLE #inv_val_gl_sum
       (item                   varchar(50) NOT NULL,
        location               varchar(25) NOT NULL,
        ledger_account         varchar(50) NULL,
        account_description    varchar(50) NULL,
        document_amount        decimal(18,6) NULL,
        amount                 decimal(18,6) NULL )

  CREATE TABLE #bol
       (document_id1           varchar(25) NULL,
        document_id2           varchar(25) NULL,
        document_line          smallint null,
        item                   varchar(50) NOT NULL,
        location               varchar(25) NOT NULL)

  -- Select inventory transactions

  INSERT INTO #inv_val_gl

    SELECT item_transactions.item,
           item_transactions.location,
           gl_cost_transactions.ledger_account,
           Max(chart_of_accounts.account_description),
           Sum(gl_cost_transactions.document_amount),
           Sum(gl_cost_transactions.amount)
      FROM item_transactions, gl_cost_transactions, ledger_accounts, chart_of_accounts
     WHERE item_transactions.unit >= @as_begunit
       AND item_transactions.unit <= @as_endunit
       AND Convert(char(10),item_transactions.gl_date,111) <=
                Convert(char(10),@ad_selectdate,111)
       AND ((item_transactions.document_type = 'INVENTORY'
       AND  gl_cost_transactions.document_type = 'IV ITEM')
        OR  (item_transactions.document_type = 'IV PROD'
       AND   gl_cost_transactions.document_type = 'IV PROD'))
       AND gl_cost_transactions.document_id1 = item_transactions.document_id1
       AND gl_cost_transactions.document_id2 = item_transactions.document_id2
       AND gl_cost_transactions.document_id3 = item_transactions.document_id3
       AND ((item_transactions.transaction_type in ('ISSUE','ADJ OUT','XFER OUT')
             AND gl_cost_transactions.document_line = 2)
        OR  (item_transactions.transaction_type not in ('ISSUE','ADJ OUT','XFER OUT')
             AND gl_cost_transactions.document_line = 1))
       AND ledger_accounts.fiscal_year = gl_cost_transactions.fiscal_year
       AND ledger_accounts.ledger = gl_cost_transactions.ledger
       AND ledger_accounts.ledger_account = gl_cost_transactions.ledger_account
       AND chart_of_accounts.fiscal_year = ledger_accounts.fiscal_year
       AND chart_of_accounts.coa = ledger_accounts.coa
       AND chart_of_accounts.account = ledger_accounts.account

  GROUP BY item_transactions.item,
           item_transactions.location,
           gl_cost_transactions.ledger_account

  ORDER BY item_transactions.item ASC,
           item_transactions.location ASC,
           gl_cost_transactions.ledger_account


  -- Select shipper transactions

  INSERT INTO #inv_val_gl

    SELECT item_transactions.item,
           item_transactions.location,
           gl_cost_transactions.ledger_account,
           Max(chart_of_accounts.account_description),
           Sum(gl_cost_transactions.document_amount),
           Sum(gl_cost_transactions.amount)
      FROM item_transactions, gl_cost_transactions, ledger_accounts, chart_of_accounts
     WHERE item_transactions.unit >= @as_begunit
       AND item_transactions.unit <= @as_endunit
       AND Convert(char(10),item_transactions.gl_date,111) <=
                Convert(char(10),@ad_selectdate,111)
       AND item_transactions.document_type = 'SHIPPER'
       AND gl_cost_transactions.document_type = item_transactions.document_type
       AND gl_cost_transactions.document_id1 = item_transactions.document_id1
       AND gl_cost_transactions.document_id2 = item_transactions.document_id2
       AND gl_cost_transactions.document_id3 = item_transactions.document_id3
       AND gl_cost_transactions.document_line = 2
       AND ledger_accounts.fiscal_year = gl_cost_transactions.fiscal_year
       AND ledger_accounts.ledger = gl_cost_transactions.ledger
       AND ledger_accounts.ledger_account = gl_cost_transactions.ledger_account
       AND chart_of_accounts.fiscal_year = ledger_accounts.fiscal_year
       AND chart_of_accounts.coa = ledger_accounts.coa
       AND chart_of_accounts.account = ledger_accounts.account

  GROUP BY item_transactions.item,
           item_transactions.location,
           gl_cost_transactions.ledger_account

  ORDER BY item_transactions.item ASC,
           item_transactions.location ASC,
           gl_cost_transactions.ledger_account


  -- Select bill of lading container transactions

  INSERT INTO #inv_val_gl

    SELECT item_transactions.item,
           item_transactions.location,
           gl_cost_transactions.ledger_account,
           Max(chart_of_accounts.account_description),
           Sum(gl_cost_transactions.document_amount),
           Sum(gl_cost_transactions.amount)
      FROM item_transactions, gl_cost_transactions, ledger_accounts, chart_of_accounts
     WHERE item_transactions.unit >= @as_begunit
       AND item_transactions.unit <= @as_endunit
       AND Convert(char(10),item_transactions.gl_date,111) <=
                Convert(char(10),@ad_selectdate,111)
       AND item_transactions.document_type = 'BILL OF LADING'
       AND IsNull(item_transactions.container_id,'') <> ''
       AND gl_cost_transactions.document_type = item_transactions.document_type
       AND gl_cost_transactions.document_id1 = item_transactions.document_id1
       AND gl_cost_transactions.document_id2 = item_transactions.document_id2
       AND gl_cost_transactions.document_id3 = item_transactions.document_id3
       AND gl_cost_transactions.document_line = item_transactions.document_line
       AND ledger_accounts.fiscal_year = gl_cost_transactions.fiscal_year
       AND ledger_accounts.ledger = gl_cost_transactions.ledger
       AND ledger_accounts.ledger_account = gl_cost_transactions.ledger_account
       AND chart_of_accounts.fiscal_year = ledger_accounts.fiscal_year
       AND chart_of_accounts.coa = ledger_accounts.coa
       AND chart_of_accounts.account = ledger_accounts.account

  GROUP BY item_transactions.item,
           item_transactions.location,
           gl_cost_transactions.ledger_account

  ORDER BY item_transactions.item ASC,
           item_transactions.location ASC,
           gl_cost_transactions.ledger_account

 -- Select bill of lading non-container transactions.  Need to group the
 -- item transactions first.
   INSERT INTO #bol

    SELECT document_id1,
           document_id2,
           document_line,
           Max(item),
           Max(location)
      FROM item_transactions
     WHERE item_transactions.unit >= @as_begunit
       AND item_transactions.unit <= @as_endunit
       AND Convert(char(10),item_transactions.gl_date,111) <=
                Convert(char(10),@ad_selectdate,111)
       AND item_transactions.document_type = 'BILL OF LADING'
       AND IsNull(item_transactions.container_id,'') = ''

  GROUP BY document_id1,
           document_id2,
           document_line

  ORDER BY document_id1,
           document_id2,
           document_line

 INSERT INTO #inv_val_gl

    SELECT #bol.item,
           #bol.location,
           gl_cost_transactions.ledger_account,
           Max(chart_of_accounts.account_description),
           Sum(gl_cost_transactions.document_amount),
           Sum(gl_cost_transactions.amount)
      FROM #bol, gl_cost_transactions, ledger_accounts, chart_of_accounts
     WHERE gl_cost_transactions.document_type = 'BILL OF LADING'
       AND gl_cost_transactions.document_id1 = #bol.document_id1
       AND gl_cost_transactions.document_id2 = #bol.document_id2
       AND gl_cost_transactions.document_id3 = ''
       AND gl_cost_transactions.document_line = #bol.document_line
       AND ledger_accounts.fiscal_year = gl_cost_transactions.fiscal_year
       AND ledger_accounts.ledger = gl_cost_transactions.ledger
       AND ledger_accounts.ledger_account = gl_cost_transactions.ledger_account
       AND chart_of_accounts.fiscal_year = ledger_accounts.fiscal_year
       AND chart_of_accounts.coa = ledger_accounts.coa
       AND chart_of_accounts.account = ledger_accounts.account

  GROUP BY #bol.item,
           #bol.location,
           gl_cost_transactions.ledger_account

  ORDER BY #bol.item ASC,
           #bol.location ASC,
           gl_cost_transactions.ledger_account

 -- Select POS and Direct Sales transactions

  INSERT INTO #inv_val_gl

    SELECT item_transactions.item,
           item_transactions.location,
           gl_cost_transactions.ledger_account,
           Max(chart_of_accounts.account_description),
           Sum(gl_cost_transactions.document_amount),
           Sum(gl_cost_transactions.amount)
      FROM item_transactions, gl_cost_transactions, ledger_accounts, chart_of_accounts
     WHERE item_transactions.unit >= @as_begunit
       AND item_transactions.unit <= @as_endunit
       AND Convert(char(10),item_transactions.gl_date,111) <=
                Convert(char(10),@ad_selectdate,111)
       AND item_transactions.document_type in ('POS','DIRECT SALE')
       AND gl_cost_transactions.document_type = item_transactions.document_type
       AND gl_cost_transactions.document_id1 = item_transactions.document_id1
       AND gl_cost_transactions.document_id2 = item_transactions.document_id2
       AND gl_cost_transactions.document_id3 = item_transactions.document_id3
       AND gl_cost_transactions.document_line = item_transactions.document_line
       AND ledger_accounts.fiscal_year = gl_cost_transactions.fiscal_year
       AND ledger_accounts.ledger = gl_cost_transactions.ledger
       AND ledger_accounts.ledger_account = gl_cost_transactions.ledger_account
       AND chart_of_accounts.fiscal_year = ledger_accounts.fiscal_year
       AND chart_of_accounts.coa = ledger_accounts.coa
       AND chart_of_accounts.account = ledger_accounts.account

  GROUP BY item_transactions.item,
           item_transactions.location,
           gl_cost_transactions.ledger_account

  ORDER BY item_transactions.item ASC,
           item_transactions.location ASC,
           gl_cost_transactions.ledger_account

  -- summarize on ledger_account, item, location
  INSERT INTO #inv_val_gl_sum

    SELECT item,
           location,
           ledger_account,
           Max(account_description),
           Sum(document_amount),
           Sum(amount)
      FROM #inv_val_gl

  GROUP BY ledger_account,
           item,
           location

  ORDER BY ledger_account,
           item,
           location

  -- Add description
  SELECT #inv_val_gl_sum.item,
         #inv_val_gl_sum.location,
         #inv_val_gl_sum.ledger_account,
         #inv_val_gl_sum.account_description,
         #inv_val_gl_sum.document_amount,
         #inv_val_gl_sum.amount,
         IsNull(items.item_description, 'Unknown' )
    FROM #inv_val_gl_sum LEFT OUTER JOIN items
      ON items.item = #inv_val_gl_sum.item
   WHERE (document_amount <> 0 OR amount <> 0)
ORDER BY #inv_val_gl_sum.ledger_account,
         #inv_val_gl_sum.item,
         #inv_val_gl_sum.location


END
GO
