SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ARSelectedAging] @as_begcustomer VARCHAR(25),
                                 @as_endcustomer VARCHAR(25),
                                 @as_begunit VARCHAR(25),
                                 @as_endunit VARCHAR(25),
                                 @as_begledgeraccount VARCHAR(50),
                                 @as_endledgeraccount VARCHAR(50),
                                 @ad_asofdate datetime,
                                 @ad_selectdate datetime,
                                 @as_currency varchar(10),
                                 @as_agedby varchar(10),
                                 @as_sortby varchar(10),
                                 @as_agecustomer varchar(10),
                                 @is_bucket1 int,
                                 @is_bucket2 int,
                                 @is_bucket3 int,
                                 @as_pageby VARCHAR(25)
AS

-- 19-Nov-2010 Increased contract_po to 30 characters for Williams & Wells.

-- 08-Feb-10 Check number is now varchar.

-- 03-Apr-07 Exclude pos_paid invoices from the ar_headers select.

-- 05-Sep-06 Changed *= syntax to LEFT OUTER JOIN syntax.

-- 10-Jul-02 In the final sort, included customer after sort2 so that
--           when sort2 is customer_name, customers with the same name
--           but a different ID are treated separately.

-- 01-Jul-02 When selecting from the bank_register, select checks that
--           were NSF'ed after the select date. Previously, NSF checks
--           were not selected.

-- 30-Jan-02 Modified the update that updates sort_2 with customer_name
--           to update sort_2 with an empty string if customer_name is
--           null because Brazosport was getting an error about trying to
--           insert a null value into sort_2 even though none of their
--           customer names were null.

-- 09-Nov-01 When selecting from the bank_register, use the new
--           column application_check_amount rather than document_amount.
--           Application_check_amount is in the currency of the
--           applications, whereas document_amount may no longer be in
--           the currency of the applications.

-- 02-Jul-01 Set dayspastdoc for checks. Previously, it was set to 0.

-- 01-Mar-01 Changed the STR function in the select statement for
--           checks to CONVERT. STR is a SQL server only function
--           and did not work in SQL Anywhere. Also changed ledger
--           account in bank register to offset_ledger_account.

-- 16-Nov-00 Added arguments as_begledgeraccount, as_endledgeraccount
--               and as_pageby.

-- 23-Oct-00 Added arguments as_agedby, as_sortby, as_agecustomer,
--           is_bucket1, is_bucket2 and is_bucket3.

-- 12-May-00 Reworked UPDATE statements to not use left outer joins in
--           the subqueries. MS SQL Server 7.0 didn't like the LOJ's.

-- 03-Dec-99 Return currency.

-- 27-Jul-99 Don't include intercompany ar_headers.

BEGIN

  CREATE TABLE #ar_customer_aging
        (document_type CHAR(1) NULL,
         document VARCHAR(25) NULL,
         unit VARCHAR(25) NULL,
         customer VARCHAR(25) NULL,
         due_date DATETIME NULL,
         document_date DATETIME NULL,
         gl_date DATETIME NULL,
         ledger_account_code VARCHAR(50),
         as_of_date DATETIME NULL,
         select_date DATETIME NULL,
         amount DEC(18,6) NULL,
         applied_amount DEC(18,6) NULL,
         days_past_due INT NULL,
         days_past_doc INT NULL,
         customer_name VARCHAR(100) NULL,
         exchanged_amount DEC(18,6) NULL,
         exchanged_applied_amount DEC(18,6) NULL,
         contract_po VARCHAR(30) NULL,
         sort_1 VARCHAR(50),
         sort_2 VARCHAR(100))

  /*  Select invoices and credit memos along with associated summed
      application rows for the appropriate selection date into a temporary
      table.  Later we'll return a result set from this table.
  */
  IF @as_agecustomer = 'BILL'
    BEGIN
      INSERT INTO #ar_customer_aging

      SELECT ar_headers.document_type,
             ar_headers.document,
             ar_headers.bill_unit,
             ar_headers.bill_customer,
             ar_headers.due_date,
             ar_headers.document_date,
             ar_headers.gl_date,
             ar_headers.ledger_account_code,
             @ad_asofdate as_of_date,
             @ad_selectdate select_date,
             ar_headers.amount,
             IsNull(SUM(ar_applications.applied_amount),0),
             DateDiff(day, ar_headers.due_date, @ad_asofdate),
             DateDiff(day, ar_headers.document_date, @ad_asofdate),
             Min(ar_customers.customer_name),
             ar_headers.exchanged_amount,
             IsNull(SUM(ar_applications.offset_exchanged_amount * -1),0),
             ar_headers.contract_po,
             '',
             ''

        FROM ar_headers LEFT OUTER JOIN ar_applications

          ON ar_headers.document = ar_applications.document AND
             ar_headers.document_type = ar_applications.document_type AND
             Convert(char(10),ar_applications.applied_date,111) <=
                Convert(char(10),@ad_selectdate,111) AND
             ar_applications.application_type <> 'OVERPY',

             ar_customers

       WHERE ar_headers.bill_customer = ar_customers.customer AND
             Convert(char(10),ar_headers.gl_date,111) <=
                Convert(char(10),@ad_selectdate,111) AND
             ar_headers.amount <> 0 AND
             ar_headers.intercompany <> 'Y' AND
             IsNull(ar_headers.pos_paid,'N') <> 'Y' AND
             (ar_headers.bill_customer >= @as_begcustomer AND
              ar_headers.bill_customer <= @as_endcustomer) AND
             (ar_headers.bill_unit >= @as_begunit AND
              ar_headers.bill_unit <= @as_endunit) AND
             (ar_headers.ledger_account_code >= @as_begledgeraccount AND
              ar_headers.ledger_account_code <= @as_endledgeraccount)

      GROUP BY ar_headers.document_type,
               ar_headers.document,
               ar_headers.bill_unit,
               ar_headers.bill_customer,
               ar_headers.amount,
               ar_headers.due_date,
               ar_headers.document_date,
               ar_headers.gl_date,
               ar_headers.ledger_account_code,
               ar_headers.exchanged_amount,
               ar_headers.contract_po
    END
  ELSE
    BEGIN
    -- aging by ship customer instead of bill customer
      INSERT INTO #ar_customer_aging

      SELECT ar_headers.document_type,
             ar_headers.document,
             ar_headers.ship_unit,
             ar_headers.ship_customer,
             ar_headers.due_date,
             ar_headers.document_date,
             ar_headers.gl_date,
             ar_headers.ledger_account_code,
             @ad_asofdate as_of_date,
             @ad_selectdate select_date,
             ar_headers.amount,
             IsNull(SUM(ar_applications.applied_amount),0),
             DateDiff(day, ar_headers.due_date, @ad_asofdate),
             DateDiff(day, ar_headers.document_date, @ad_asofdate),
             Min(ar_customers.customer_name),
             ar_headers.exchanged_amount,
             IsNull(SUM(ar_applications.offset_exchanged_amount * -1),0),
             ar_headers.contract_po,
             '',
             ''

        FROM ar_headers LEFT OUTER JOIN ar_applications

          ON ar_headers.document = ar_applications.document AND
             ar_headers.document_type = ar_applications.document_type AND
             Convert(char(10),ar_applications.applied_date,111) <=
                Convert(char(10),@ad_selectdate,111) AND
             ar_applications.application_type <> 'OVERPY',

             ar_customers

       WHERE ar_headers.ship_customer = ar_customers.customer AND
             Convert(char(10),ar_headers.gl_date,111) <=
                Convert(char(10),@ad_selectdate,111) AND
             ar_headers.amount <> 0 AND
             ar_headers.intercompany <> 'Y' AND
             IsNull(ar_headers.pos_paid,'N') <> 'Y' AND
             (ar_headers.ship_customer >= @as_begcustomer AND
              ar_headers.ship_customer <= @as_endcustomer) AND
             (ar_headers.ship_unit >= @as_begunit AND
              ar_headers.ship_unit <= @as_endunit) AND
             (ar_headers.ledger_account_code >= @as_begledgeraccount AND
              ar_headers.ledger_account_code <= @as_endledgeraccount)

      GROUP BY ar_headers.document_type,
               ar_headers.document,
               ar_headers.ship_unit,
               ar_headers.ship_customer,
               ar_headers.amount,
               ar_headers.due_date,
               ar_headers.document_date,
               ar_headers.gl_date,
               ar_headers.ledger_account_code,
               ar_headers.exchanged_amount,
               ar_headers.contract_po
    END

  /*  Move the summed exchanged amount for credit memos to the exchanged
      amount column used for invoices and checks.  Since we don't have an
      IF statement this will have to do.

      Trash what was summed above and start over by summing the normal
      credit memo to invoice applications.

      While we're working on credit memos, set the days past due to 0
      because credit memos aren't ever past due. */

  UPDATE #ar_customer_aging
     SET days_past_due = 0,
         exchanged_applied_amount =
        IsNULL((SELECT SUM(IsNull(ar_applications.exchanged_amount * -1,0))
           FROM ar_applications
          WHERE ar_applications.document_type =
                   #ar_customer_aging.document_type AND
                ar_applications.document = #ar_customer_aging.document AND
                ar_applications.application_type <> 'CHECK' AND
                Convert(char(10),ar_applications.applied_date,111) <=
                   Convert(char(10),@ad_selectdate,111)), 0)
   WHERE document_type = 'C'

  /*  Now update the summed total with credit memo to check applications */
  UPDATE #ar_customer_aging
     SET exchanged_applied_amount = exchanged_applied_amount +
        IsNull((SELECT SUM(IsNull(ar_applications.offset_exchanged_amount * -1,0))
           FROM ar_applications
          WHERE ar_applications.document_type =
                   #ar_customer_aging.document_type AND
                ar_applications.document = #ar_customer_aging.document AND
                ar_applications.application_type = 'CHECK' AND
                Convert(char(10),ar_applications.applied_date,111) <=
                   Convert(char(10),@ad_selectdate,111)), 0)
   WHERE document_type = 'C'

  /*  Select approriate check and summed application rows into the temporary
      table as well.
  */

  INSERT INTO #ar_customer_aging
  SELECT 'A',
         bank_register.document_id3,
         bank_register.document_id1,
         bank_register.document_id2,
         bank_register.document_date,
         bank_register.document_date,
         bank_register.gl_date,
         bank_register.offset_ledger_account_code,
         @ad_asofdate,
         @ad_selectdate,
         bank_register.application_check_amount * -1,
         IsNull(SUM(ar_applications.applied_amount) * -1,0),
         0,
         DateDiff(day, bank_register.document_date, @ad_asofdate),
         ar_customers.customer_name,
         bank_register.exchanged_amount * -1,
         IsNull(SUM(ar_applications.exchanged_amount) * -1,0),
         '',
         '',
         ''

    FROM bank_register LEFT OUTER JOIN ar_applications

      ON bank_register.document_id3 = ar_applications.check_number AND
         bank_register.document_id2 = ar_applications.bill_customer AND
         Convert(char(10),ar_applications.applied_date,111) <=
             Convert(char(10),@ad_selectdate,111) AND
         ar_applications.application_type
            NOT IN ('DISCNT', 'ADJUST', 'WRTOFF'),

         ar_customers

   WHERE bank_register.document_class = 'AR' AND
         bank_register.check_void_nsf = 'C' AND
        (bank_register.document_type <> 'N' OR
         (bank_register.document_type = 'N' AND
          EXISTS (SELECT 1 FROM bank_register br_voids
                   WHERE br_voids.document_class = 'AR'
                     AND br_voids.check_void_nsf = 'N'
                     AND br_voids.document_id3 = bank_register.document_id3
                     AND br_voids.document_id2 = bank_register.document_id2
                     AND Convert(char(10),br_voids.gl_date,111) >
                         Convert(char(10),@ad_selectdate,111)))) AND
         bank_register.document_id2 = ar_customers.customer AND
         Convert(char(10),bank_register.gl_date,111) <=
            Convert(char(10),@ad_selectdate,111) AND
         bank_register.document_id2 <> 'NON-AR' AND
         (bank_register.document_id2 >= @as_begcustomer AND
          bank_register.document_id2 <= @as_endcustomer) AND
         (bank_register.document_id1 >= @as_begunit AND
          bank_register.document_id1 <= @as_endunit) AND
         (bank_register.offset_ledger_account_code >= @as_begledgeraccount AND
          bank_register.offset_ledger_account_code <= @as_endledgeraccount)

  GROUP BY bank_register.document_id3,
           bank_register.document_id2,
           bank_register.document_id1,
           bank_register.application_check_amount,
           bank_register.document_date,
           bank_register.gl_date,
           bank_register.offset_ledger_account_code,
           ar_customers.customer_name,
           bank_register.exchanged_amount

  /* put the appropriate columns into the sort columns in the temporary table */
  IF @as_pageby = 'UNIT'
    BEGIN
      UPDATE #ar_customer_aging
         SET sort_1 = unit
    END
  ELSE
    BEGIN
      UPDATE #ar_customer_aging
         SET sort_1 = ledger_account_code
    END

  IF @as_sortby = 'NAME'
    BEGIN
      UPDATE #ar_customer_aging
         SET sort_2 = IsNull(customer_name,'')
    END
  ELSE
    BEGIN
      UPDATE #ar_customer_aging
         SET sort_2 = customer
    END

  /* Return those document rows from the temporary table that have
     unapplied balances
  */
  SELECT document_type,
         document,
         unit,
         customer,
         due_date,
         document_date,
         gl_date,
         as_of_date,
         select_date,
         amount,
         applied_amount,
         amount - applied_amount open_amount,
         days_past_due,
         days_past_doc,
         customer_name,
         exchanged_amount,
         exchanged_applied_amount,
         exchanged_amount - exchanged_applied_amount exchanged_open_amount,
         contract_po,
         sort_1,
         sort_2
    FROM #ar_customer_aging
   WHERE applied_amount <> amount
   ORDER BY sort_1,
            sort_2,
            customer,
            document_date,
            document_type DESC,
            document
END
GO
