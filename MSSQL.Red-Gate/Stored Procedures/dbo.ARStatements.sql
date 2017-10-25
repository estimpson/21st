SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ARStatements] @as_begbillcustomer VARCHAR(25),
                              @as_endbillcustomer VARCHAR(25),
                              @as_begbillunit VARCHAR(25),
                              @as_endbillunit VARCHAR(25),
                              @as_begcycle VARCHAR(25),
                              @as_endcycle VARCHAR(25),
                              @ad_asofdate datetime,
                              @ad_selectdate datetime,
                              @as_begcustomerclass VARCHAR(25),
                              @as_endcustomerclass VARCHAR(25)
AS
BEGIN

-- 08-Feb-2010 Check number is now varchar.

-- 02-Jun-2008 Added IsNulls around ar_customers.customer_class.

-- 17-May-2008 Added selection by Customer Class.

-- 03-Apr-2007 Exclude pos_paid invoices from the ar_headers select.

-- 06-Sep-2006 Changed *= syntax to LEFT OUTER JOIN syntax.

-- 12-Oct-2005 When selecting from the bank_register, use the new
--             column application_check_amount rather than document_amount.
--             Application_check_amount is in the currency of the
--             applications, whereas document_amount may no longer be in
--             the currency of the applications.
--
--             When selecting from the bank_register, select checks that
--             were NSF'ed after the select date. Previously, NSF checks
--             were not selected.

-- 17-Mar-2004 Corrected WHERE clause to work for ASA when there are
--             bank_register rows but no application rows (i.e. there
--             is unapplied cash ). Needed to include
--             "OR ar_applications.reversal IS NULL " because ASA
--             evaluates this part of the WHERE after the LOJ.
--             SQL Server evaluates it as part of the LOJ and didn't
--             need it.

-- 10/19/2000 Sort by document_date instead of document_type/document.
  CREATE TABLE #ar_statements
        (document_type CHAR(1) NULL,
         document VARCHAR(25) NULL,
         bill_unit VARCHAR(25) NULL,
         bill_customer VARCHAR(25) NULL,
         due_date DATETIME NULL,
         document_date DATETIME NULL,
         gl_date DATETIME NULL,
         amount DEC(18,6) NULL,
         applied_amount DEC(18,6) NULL,
         days_past_due INT NULL,
         statement_cycle VARCHAR(25) NULL,
         bill_customer_name VARCHAR(100) NULL,

         bill_address_id VARCHAR(25) NULL,
         bill_address_1 VARCHAR(50) NULL,
         bill_address_2 VARCHAR(50) NULL,
         bill_address_3 VARCHAR(50) NULL,
         bill_city VARCHAR(25) NULL,
         bill_state VARCHAR(25) NULL,
         bill_postal_code VARCHAR(10) NULL,
         bill_country VARCHAR(50) NULL,

         bill_contact_id VARCHAR(25) NULL,
         contact_first_name VARCHAR(40) NULL,
         contact_last_name VARCHAR(40) NULL,

         remit_to VARCHAR(50) NULL,
         remit_address_1 VARCHAR(50) NULL,
         remit_address_2 VARCHAR(50) NULL,
         remit_address_3 VARCHAR(50) NULL,
         remit_city VARCHAR(25) NULL,
         remit_state VARCHAR(25) NULL,
         remit_postal_code VARCHAR(10) NULL,
         remit_country VARCHAR(50) NULL)


  /*  Select invoices and credit memos along with associated summed
      application rows for the appropriate selection date into a temporary
      table.  Later we'll return a result set from this table.
  */

  INSERT INTO #ar_statements
        (document_type, document, bill_unit, bill_customer, due_date,
         document_date, gl_date, amount, applied_amount, days_past_due,
         statement_cycle, bill_customer_name, bill_address_id,
         bill_contact_id, remit_to)

  SELECT ar_headers.document_type,
         ar_headers.document,
         ar_headers.bill_unit,
         ar_headers.bill_customer,
         ar_headers.due_date,
         ar_headers.document_date,
         ar_headers.gl_date,
         ar_headers.amount,
         IsNull(SUM(ar_applications.applied_amount),0),
         DateDiff(day,ar_headers.due_date, @ad_asofdate),
         MIN(ar_customers.statement_cycle),
         MIN(ar_customers.customer_name),
         MIN(ar_customers.bill_address_id),
         MIN(ar_customers.bill_contact_id),
         MIN(ar_customers.remit_to)

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
         (ar_headers.bill_customer >= @as_begbillcustomer AND
          ar_headers.bill_customer <= @as_endbillcustomer) AND
         (IsNull(ar_headers.bill_unit,'') >= @as_begbillunit AND
          IsNull(ar_headers.bill_unit,'') <= @as_endbillunit) AND
          IsNull(ar_customers.customer_class,'') >= @as_begcustomerclass AND
          IsNull(ar_customers.customer_class,'') <= @as_endcustomerclass

  GROUP BY ar_headers.document_type,
           ar_headers.document,
           ar_headers.bill_unit,
           ar_headers.bill_customer,
           ar_headers.amount,
           ar_headers.due_date,
           ar_headers.document_date,
           ar_headers.gl_date

  /*  Select approriate check and summed application rows into the temporary
      table as well.
  */

  INSERT INTO #ar_statements
        (document_type, document, bill_unit, bill_customer, due_date,
         document_date, gl_date, amount, applied_amount, days_past_due,
         statement_cycle, bill_customer_name, bill_address_id,
         bill_contact_id, remit_to)
  SELECT 'A',
         bank_register.document_id3,
         bank_register.document_id1,
         bank_register.document_id2,
         bank_register.document_date,
         bank_register.document_date,
         bank_register.gl_date,
         bank_register.application_check_amount * -1,
         IsNull(SUM(ar_applications.applied_amount) * -1,0),
         0,
         MIN(ar_customers.statement_cycle),
         MIN(ar_customers.customer_name),
         MIN(ar_customers.bill_address_id),
         MIN(ar_customers.bill_contact_id),
         MIN(ar_customers.remit_to)

    FROM bank_register LEFT OUTER JOIN ar_applications

      ON bank_register.document_id3 = ar_applications.check_number AND
         bank_register.document_id2 = ar_applications.bill_customer AND
         Convert(char(10),ar_applications.applied_date,111) <=
             Convert(char(10),@ad_selectdate,111) AND
         ar_applications.application_type
            NOT IN ('DISCNT', 'ADJUST', 'WRTOFF'),

         ar_customers

   WHERE bank_register.document_id2 <> 'NON-AR' AND
         bank_register.document_class = 'AR' AND
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
         (bank_register.document_id2 >= @as_begbillcustomer AND
          bank_register.document_id2 <= @as_endbillcustomer) AND
         (IsNull(bank_register.document_id1,'') >= @as_begbillunit AND
          IsNull(bank_register.document_id1,'') <= @as_endbillunit) AND
          IsNull(ar_customers.customer_class,'') >= @as_begcustomerclass AND
          IsNull(ar_customers.customer_class,'') <= @as_endcustomerclass

  GROUP BY bank_register.document_id3,
           bank_register.document_id2,
           bank_register.document_id1,
           bank_register.application_check_amount,
           bank_register.document_date,
           bank_register.gl_date

  /*  Delete rows for documents that have been fully applied
  */
  DELETE
    FROM #ar_statements
   WHERE applied_amount = amount OR
         IsNull(statement_cycle,'') < @as_begcycle OR
         IsNull(statement_cycle,'') > @as_endcycle

  /*  Now update the remaining rows with the remit-to and bill-to addresses
      as well as the contact name

      Start with the bill-to address
  */

  UPDATE #ar_statements
     SET bill_address_1 = addresses.address_1,
         bill_address_2 = addresses.address_2,
         bill_address_3 = addresses.address_3,
         bill_city = addresses.city,
         bill_state = addresses.state,
         bill_postal_code = addresses.postal_code,
         bill_country = addresses.country
    FROM addresses
   WHERE addresses.address_id = bill_address_id

  /*  Now update the contact names */
  UPDATE #ar_statements
     SET contact_first_name = contacts.first_name,
         contact_last_name = contacts.last_name
    FROM contacts
   WHERE contacts.contact_id = bill_contact_id

  /*  Now update the remit to address */
  UPDATE #ar_statements
     SET remit_address_1 = addresses.address_1,
         remit_address_2 = addresses.address_2,
         remit_address_3 = addresses.address_3,
         remit_city = addresses.city,
         remit_state = addresses.state,
         remit_postal_code = addresses.postal_code,
         remit_country = addresses.country
    FROM remit_to_identifiers, addresses
   WHERE remit_to_identifiers.remit_to = #ar_statements.remit_to AND
         addresses.address_id = remit_to_identifiers.address_id

  /* The only rows remaining in the temporary table are those rows that
     should appear on the customer statement, so return all rows
  */
  SELECT document_type,
         document,
         bill_unit,
         bill_customer,
         due_date,
         document_date,
         gl_date,
         @ad_asofdate as_of_date,
         @ad_selectdate select_date,
         amount,
         applied_amount,
         amount - applied_amount open_amount,
         days_past_due,
         statement_cycle,
         bill_customer_name,
         bill_address_id,
         bill_address_1,
         bill_address_2,
         bill_address_3,
         bill_city,
         bill_state,
         bill_postal_code,
         bill_country,
         bill_contact_id,
         contact_first_name,
         contact_last_name,
         remit_to,
         remit_address_1,
         remit_address_2,
         remit_address_3,
         remit_city,
         remit_state,
         remit_postal_code,
         remit_country

    FROM #ar_statements
   ORDER BY bill_unit,
            bill_customer,
            document_date
END
GO
