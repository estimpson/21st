SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Create1099TemporaryTables]
    @as_company VARCHAR(25),
    @ai_year INT

AS

-- 25-Nov-2013 Corrected sub-query that determined if there was backup withholding
--             (code 4) for non-employee compensation (code 7).  Previously, the
--             sub-query didn't include company and year.

-- 14-Jan-2013 Corrected Report Code C (Box 14-Gross proceeds paid to an attorney) to
--             pick up amounts of $600 or more.  Previously amounts over $600 were
--             being reported.

-- 20-Dec-2011 1. Report Code C (Box 14-Gross proceeds paid to an attorney) amounts
--                over $600.  We were incorrectly reporting ALL amounts.
--             2. Report Code 8 (Box 8-Substitute payments in lieu of dividents or
--                interest) amounts of $10 or more.  We were incorrectly reporting ALL amounts.

-- 19-Dec-2011 Select code 7 amounts less than $600 if the vendor has
--             backup withholding (code 4).

-- 30-Jul-2011 Use 1099 address from vendors, if specified.
--             Added script to put the company address id into the temporary
--             table.

-- 12-Jan-2004 Report all type 8 amounts, not just amounts over $10.

-- 11-Feb-2002 Added BEGIN TRANSACTIONs and COMMITs so that they are done
--             here rather than in the PowerBuilder script in hopes
--             of solving the GUC problems with this stored procedure.

-- 06-Feb-2001 Added direct deposit (document_type = 'DD') to the
--             bank_register rows which get selected.

-- 03-Feb-2000 Changed s_invcmline and s_invcmsortline from INT to
--             SMALLINT to be consistent with the database. Removed
--             the Converts on those columns from the select. GUC got
--             a cursor fetch error when everything was an INT.
--
--             Also, GUC can't run this from Empower. When they do,
--             they get DBPROC is dead. It's then necessary to drop
--             the temporary tables and recreate them before the
--             stored procedure can be run from ISQL.

BEGIN

DECLARE @s_payvendor VARCHAR(25),
   @s_vendorname VARCHAR(40),
   @s_vendorname2 VARCHAR(40),
   @s_1099name VARCHAR(40),
   @s_1099name2 VARCHAR(40),
   @s_addressid VARCHAR(25),
   @s_1099addressid VARCHAR(25),
   @s_taxid VARCHAR(11),
   @s_lastpayvendor VARCHAR(25),
   @s_lastvendorname VARCHAR(40),
   @s_lastvendorname2 VARCHAR(40),
   @s_lastaddressid VARCHAR(25),
   @s_lasttaxid VARCHAR(11),
   @s_payunit VARCHAR(25),
   @s_code1099 CHAR(1),
   @s_bankalias VARCHAR(25),
   @s_vendor VARCHAR(25),
   @s_invoicecm VARCHAR(25),
   @s_invcmflag CHAR(1),
   @i_invcmline SMALLINT,
   @i_invcmsortline SMALLINT,
   @s_itemdescription VARCHAR(40),
   @s_discountflag CHAR(1),
   @i_checknumber INT,
   @c_paidamount DECIMAL (18,6),
   @c_amount1 DECIMAL (18,6),
   @c_amount2 DECIMAL (18,6),
   @c_amount3 DECIMAL (18,6),
   @c_amount4 DECIMAL (18,6),
   @c_amount5 DECIMAL (18,6),
   @c_amount6 DECIMAL (18,6),
   @c_amount7 DECIMAL (18,6),
   @c_amount8 DECIMAL (18,6),
   @c_amount9 DECIMAL (18,6),
   @c_amount10 DECIMAL (18,6),
   @c_amount11 DECIMAL (18,6),
   @c_amount12 DECIMAL (18,6),
   @d_checkdate DATETIME,
   @d_begdate DATETIME,
   @d_enddate DATETIME,
   @s_companyaddressid VARCHAR(25)

/* declare a cursor to retrieve the invoice item rows which are candidates
   for 1099's based on the user-specified criteria.
*/

DECLARE detcursor CURSOR FOR
    SELECT bank_register.document_id2, bank_register.document_id1,
           ap_items.code_1099, bank_register.bank_alias,
           bank_register.document_number, bank_register.document_date,
           ap_items.vendor, ap_items.invoice_cm, ap_items.inv_cm_flag,
           ap_items.inv_cm_line,
           ap_items.inv_cm_sort_line,
           Convert(decimal(18,6), (ap_items.extended_amount /
               ap_headers.inv_cm_amount) * ap_applications.pay_amount),
           ap_applications.discount_flag
      FROM units_payables_purchasing, bank_register,
           ap_applications, ap_items, ap_headers
     WHERE units_payables_purchasing.company = @as_company AND
           bank_register.document_class = 'AP' AND
           bank_register.check_void_nsf = 'C' AND
           bank_register.document_type IN ('C','M','DD') AND
           bank_register.document_id1 = units_payables_purchasing.unit AND
           Convert(char(8),bank_register.document_date,112 ) >=
                     Convert(char(4), @ai_year) + '01' +'01' AND
           Convert(char(8),bank_register.document_date,112) <=
                     Convert(char(4), @ai_year) + '12' +'31' AND
           ap_applications.bank_alias = bank_register.bank_alias AND
           ap_applications.check_number = bank_register.document_number AND
           ap_items.vendor = ap_applications.vendor AND
           ap_items.inv_cm_flag = ap_applications.inv_cm_flag AND
           ap_items.invoice_cm = ap_applications.invoice_cm  AND
           ap_items.code_1099 <> '' AND ap_items.code_1099 IS NOT NULL AND
           ap_headers.vendor = ap_items.vendor AND
           ap_headers.inv_cm_flag = ap_items.inv_cm_flag AND
           ap_headers.invoice_cm = ap_items.invoice_cm
     ORDER BY bank_register.document_id2, ap_items.code_1099

/*declare a cursor to summarize the detail 1099 table.
*/
DECLARE sumcursor CURSOR FOR
    SELECT pay_vendor, code_1099,
	   Convert( decimal(18,6), sum(paid_amount) )
      FROM t1099_detail_temporary
     WHERE company = @as_company AND
           year_1099 = @ai_year
     GROUP BY pay_vendor, code_1099
    HAVING (code_1099 = '1' AND sum(paid_amount) >= 600) OR
           (code_1099 = '2' AND sum(paid_amount) >= 10) OR
           (code_1099 = '3' AND sum(paid_amount) >= 600) OR
           (code_1099 = '4' AND sum(paid_amount) > 0) OR
           (code_1099 = '5' AND sum(paid_amount) > 0) OR
           (code_1099 = '6' AND sum(paid_amount) >= 600) OR
           (code_1099 = '7' AND (sum(paid_amount) >= 600 OR
               (sum(paid_amount) > 0 AND
               (SELECT IsNull(sum(paid_amount),0)
                  FROM t1099_detail_temporary t_temp
                 WHERE t_temp.company = @as_company AND
                       t_temp.year_1099 = @ai_year AND
                       t_temp.pay_vendor = t1099_detail_temporary.pay_vendor AND
                       code_1099 = '4') > 0 ))) OR
           (code_1099 = '8' AND sum(paid_amount) >= 10) OR
           (code_1099 = '9' AND sum(paid_amount) >= 5000) OR
           (code_1099 = 'A' AND sum(paid_amount) >= 600) OR
           (code_1099 = 'B' AND sum(paid_amount) > 0) OR
           (code_1099 = 'C' AND sum(paid_amount) >= 600)
     ORDER BY pay_vendor, code_1099

BEGIN TRANSACTION

DELETE FROM t1099_detail_temporary
     WHERE company = @as_company AND
           year_1099 <= @ai_year

COMMIT

BEGIN TRANSACTION

DELETE FROM t1099_summary_temporary
     WHERE company = @as_company AND
           year_1099 <= @ai_year

COMMIT

BEGIN TRANSACTION

DELETE FROM t1099_totals_temporary
     WHERE company = @as_company AND
           year_1099 <= @ai_year

COMMIT

/* Get the company address ID
*/

SELECT @s_companyaddressid = address_id,
       @s_1099addressid = address_id_1099
  FROM companies
 WHERE company = @as_company

IF @@rowcount = 0
  BEGIN
    SELECT @s_companyaddressid = ''
    SELECT @s_1099addressid = ''
  END
ELSE
  BEGIN
    /* found the company */
    IF @s_1099addressid IS NOT NULL AND @s_1099addressid <> ''
      BEGIN
        /* if the company has a 1099 address, use it. */
        SELECT @s_companyaddressid = @s_1099addressid
      END
  END


/* retrieve the item rows which match the user-specified criteria so
   that they can be inserted into the detail 1099 table.
*/

BEGIN TRANSACTION

OPEN detcursor

WHILE 1 = 1

  BEGIN

    FETCH detcursor
      INTO @s_payvendor, @s_payunit, @s_code1099, @s_bankalias,
           @i_checknumber, @d_checkdate, @s_vendor, @s_invoicecm,
           @s_invcmflag, @i_invcmline, @i_invcmsortline,
           @c_paidamount, @s_discountflag

   IF @@fetch_status <> 0 BREAK


    IF @s_discountflag = 'Y'
      BEGIN
        SELECT @s_itemdescription = 'Discount'
      END
    ELSE
      BEGIN
        /* For some reason, s_itemdescription always comes back with
           garbage data when it is returned through the cursor, even if
           the Select statement uses the Convert function to convert the
           data from text to VARCHAR(40). Therefore, we'll look it up in a
           separate step.
        */
        SELECT @s_itemdescription = Convert(VARCHAR(40), item_description)
          FROM ap_items
         WHERE invoice_cm = @s_invoicecm AND
               inv_cm_flag = @s_invcmflag AND
               inv_cm_line = @i_invcmline AND
               vendor = @s_vendor
      END

    /* Code '4' is backup withholding.  It will appear as a negative
       amount on the invoice, to offset the positive amount for
       code '7', nonemployee compensation. On the 1099, we want it to
       be positive.
    */
    IF @s_code1099 = '4' SELECT @c_paidamount = @c_paidamount * -1

    INSERT INTO t1099_detail_temporary

        (year_1099, company, pay_vendor, pay_unit, code_1099,
         bank_alias, check_number, check_date,
         invoice_cm, inv_cm_sort_line, item_description, paid_amount)
      VALUES
        (@ai_year, @as_company, @s_payvendor, @s_payunit, @s_code1099,
         @s_bankalias, @i_checknumber, @d_checkdate,
         @s_invoicecm, @i_invcmsortline, @s_itemdescription, @c_paidamount)

  END

CLOSE detcursor
DEALLOCATE detcursor

COMMIT

/* now summarize the detail records into the summary 1099 temporary
   table and the totals 1099 temporary table.
*/

BEGIN TRANSACTION

OPEN sumcursor

SELECT @s_lastpayvendor = 'FirstOne'

WHILE 1 = 1

  BEGIN

    FETCH sumcursor
     INTO @s_payvendor, @s_code1099, @c_paidamount

    /* If we're at EOF, don't leave the loop quite yet. Still need to
       write a 1099 totals row for the last vendor processed.
    */
    IF @@fetch_status <> 0 SELECT @s_payvendor = 'LastOne'


    IF @s_payvendor <> @s_lastpayvendor
      BEGIN
        IF @s_lastpayvendor <> 'FirstOne'
          BEGIN
            /* Insert a record into the totals table. The totals table is
               used to produce the 1099 forms. The only way that we can
               get all 3 forms to print on a page is to use the label
               datawindow style. This style does not support group
               breaks. This means that we need to put all 10 possible
               1099 amounts for this vendor into one row.  So... we're
               using the old-fashioned COBOL way of saving everything in
               "working storage" to do that.  Insert the saved values
               into the totals1099 temporary table now.
            */
            INSERT INTO t1099_totals_temporary

               (year_1099, company, pay_vendor, vendor_name,
                vendor_name_2, vendor_tax_id, vendor_address_id,
                amount_1, amount_2, amount_3, amount_4, amount_5,
                amount_6, amount_7, amount_8, amount_9, amount_10,
                amount_11, amount_12, company_address_id)
              VALUES

               (@ai_year, @as_company, @s_lastpayvendor, @s_lastvendorname,
                @s_lastvendorname2, @s_lasttaxid, @s_lastaddressid,
                @c_amount1, @c_amount2, @c_amount3, @c_amount4, @c_amount5,
                @c_amount6, @c_amount7, @c_amount8, @c_amount9, @c_amount10,
                @c_amount11, @c_amount12, @s_companyaddressid)

          END



        /* no more vendors to process */
        IF @s_payvendor = 'LastOne' BREAK

        /* Get the vendor name, taxpayer ID, and address ID for
           this vendor. This way we can look them up once and store
           them on each row, rather than having each SQL statement
           which uses them look them up.
        */

        SELECT @s_vendorname = vendor_name,
               @s_vendorname2 = vendor_name_2,
               @s_1099name = d1099_1099_name,
               @s_1099name2 = d1099_1099_name_2,
               @s_taxid = d1099_federal_tax_id,
               @s_addressid = IsNull(pay_address_id, address_id),
               @s_1099addressid = address_id_1099
          FROM vendors
         WHERE vendor = @s_payvendor

        IF @@rowcount = 0
          BEGIN
            SELECT @s_vendorname = ''
            SELECT @s_vendorname2 = ''
            SELECT @s_taxid = ''
            SELECT @s_addressid = ''
            SELECT @s_1099addressid = ''
          END
        ELSE
          BEGIN
            /* found the vendor */
            IF @s_1099name IS NOT NULL AND @s_1099name <> ''
              BEGIN
                /* if the vendor has a 1099 name, use it. */
                SELECT @s_vendorname = @s_1099name
                IF @s_1099name2 IS NOT NULL
                  SELECT @s_vendorname2 = @s_1099name2
                ELSE
                  SELECT @s_vendorname2 = ''
              END
            IF @s_1099addressid IS NOT NULL AND @s_1099addressid <> ''
              BEGIN
                /* if the vendor has a 1099 address, use it. */
                SELECT @s_addressid = @s_1099addressid
              END
          END

        /* Save the information for this vendor in the "last" fields */
        SELECT @s_lastpayvendor = @s_payvendor

        SELECT @s_lastvendorname = @s_vendorname
        SELECT @s_lastvendorname2 = @s_vendorname2
        SELECT @s_lasttaxid = @s_taxid
        SELECT @s_lastaddressid = @s_addressid

        SELECT @c_amount1 = 0
        SELECT @c_amount2 = 0
        SELECT @c_amount3 = 0
        SELECT @c_amount4 = 0
        SELECT @c_amount5 = 0
        SELECT @c_amount6 = 0
        SELECT @c_amount7 = 0
        SELECT @c_amount8 = 0
        SELECT @c_amount9 = 0
        SELECT @c_amount10 = 0
        SELECT @c_amount11 = 0
        SELECT @c_amount12 = 0

      END

    /* insert this row into the summary 1099 temporary table. */

    INSERT INTO t1099_summary_temporary
           (year_1099, company, pay_vendor, code_1099,
            paid_amount, vendor_name, vendor_tax_id)
       VALUES
           (@ai_year, @as_company, @s_payvendor, @s_code1099,
            @c_paidamount, @s_vendorname, @s_taxid)

    /* save the amount based on the 1099 code */
    IF @s_code1099 = '1'
      SELECT @c_amount1 = @c_paidamount
    ELSE
      BEGIN
        IF @s_code1099 = '2'
          SELECT @c_amount2 = @c_paidamount
        ELSE
          BEGIN
            IF @s_code1099 = '3'
              SELECT @c_amount3 = @c_paidamount
            ELSE
              BEGIN
                IF @s_code1099 = '4'
                  SELECT @c_amount4 = @c_paidamount
                ELSE
                  BEGIN
                    IF @s_code1099 = '5'
                      SELECT @c_amount5 = @c_paidamount
                    ELSE
                      BEGIN
                        IF @s_code1099 = '6'
                          SELECT @c_amount6 = @c_paidamount
                        ELSE
                          BEGIN
                            IF @s_code1099 = '7'
                              SELECT @c_amount7 = @c_paidamount
                            ELSE
                              BEGIN
                                IF @s_code1099 = '8'
                                  SELECT @c_amount8 = @c_paidamount
                                ELSE
                                  BEGIN
                                    IF @s_code1099 = '9'
                                      SELECT @c_amount9 = @c_paidamount
                                    ELSE
                                      BEGIN
                                        IF @s_code1099 = 'A'
			                        SELECT @c_amount10 = @c_paidamount
                                        ELSE
                                          BEGIN
                                            IF @s_code1099 = 'B'
			                            SELECT @c_amount11 = @c_paidamount
                                            ELSE
                                              BEGIN
                                                IF @s_code1099 = 'C'
    			                                SELECT @c_amount12 = @c_paidamount
                                              END
                                          END
                                      END
                                  END
                              END
                          END
                      END
                  END
              END
          END
      END
  /* End loop */
  END

CLOSE sumcursor
DEALLOCATE sumcursor

COMMIT

END
GO
