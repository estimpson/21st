SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ARCustomerAging] @as_billcustomer VARCHAR(25),
                                 @ad_asofdate datetime,
                                 @ad_selectdate datetime
AS

-- 03-Dec-10 Order by days_past_due DESC first.

-- 08-Feb-10 Check number is now varchar.

-- 03-Apr-07 Exclude pos_paid invoices from the ar_headers select.

-- 05-Sep-06 Changed *= syntax to LEFT OUTER JOIN syntax.

-- 01-Jul-02 When selecting from the bank_register, select checks that
--           were NSF'ed after the select date. Previously, NSF checks
--           were not selected.

-- 09-Nov-01 When selecting from the bank_register, use the new
--           column application_check_amount rather than document_amount.
--           Application_check_amount is in the currency of the
--           applications, whereas document_amount may no longer be in
--           the currency of the applications.

-- 27-Jul-99 Don't include intercompany ar_headers.

BEGIN

  CREATE TABLE #ar_customer_aging
        (document_type CHAR(1) NULL,
         document VARCHAR(25) NULL,
         bill_unit VARCHAR(25) NULL,
         bill_customer VARCHAR(25) NULL,
         due_date DATETIME NULL,
         document_date DATETIME NULL,
         amount DEC(18,6) NULL,
         applied_amount DEC(18,6) NULL,
         days_past_due INT NULL,
         bill_customer_name VARCHAR(100) NULL)

  /*  Select invoices and credit memos along with associated summed
      application rows for the appropriate selection date into a temporary
      table.  Later we'll return a result set from this table.
  */

  INSERT INTO #ar_customer_aging

  SELECT ar_headers.document_type,
         ar_headers.document,
         ar_headers.bill_unit,
         ar_headers.bill_customer,
         ar_headers.due_date,
         ar_headers.document_date,
         ar_headers.amount,
         IsNull(SUM(ar_applications.applied_amount),0) applied_amount,
         DateDiff(day,ar_headers.due_date, @ad_asofdate) days_past_due,
         ar_customers.customer_name bill_customer_name

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
         ar_headers.bill_customer = @as_billcustomer AND
         ar_headers.amount <> 0 AND
         ar_headers.intercompany <> 'Y' AND
         IsNull(ar_headers.pos_paid,'N') <> 'Y'

  GROUP BY ar_headers.document_type,
           ar_headers.document,
           ar_headers.bill_unit,
           ar_headers.bill_customer,
           ar_headers.amount,
           ar_headers.due_date,
           ar_headers.document_date,
           ar_customers.customer_name

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
         bank_register.application_check_amount * -1,
         IsNull(SUM(ar_applications.applied_amount) * -1,0) applied_amount,
         0,
         ar_customers.customer_name

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
         bank_register.document_id2 = @as_billcustomer

  GROUP BY bank_register.document_id3,
           bank_register.document_id2,
           bank_register.document_id1,
           bank_register.application_check_amount,
           bank_register.document_date,
           ar_customers.customer_name

  /* Return those document rows from the temporary table that have
     unapplied balances
  */
  SELECT document_type,
         document,
         bill_unit,
         bill_customer,
         due_date,
         document_date,
         amount,
         applied_amount,
         amount - applied_amount open_amount,
         days_past_due,
         bill_customer_name
    FROM #ar_customer_aging
   WHERE applied_amount <> amount
   ORDER BY days_past_due DESC,
            document_type DESC,
            document
END
GO
