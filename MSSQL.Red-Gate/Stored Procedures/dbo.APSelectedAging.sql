SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[APSelectedAging] @as_begpayvendor VARCHAR(25),
                                 @as_endpayvendor VARCHAR(25),
                                 @as_begpayunit VARCHAR(25),
                                 @as_endpayunit VARCHAR(25),
                                 @as_begbuyvendor VARCHAR(25),
                                 @as_endbuyvendor VARCHAR(25),
                                 @as_begbuyunit VARCHAR(25),
                                 @as_endbuyunit VARCHAR(25),
                                 @as_begledgeraccount VARCHAR(50),
                                 @as_endledgeraccount VARCHAR(50),
                                 @ad_asofdate datetime,
                                 @ad_selectdate datetime,
                                 @as_ledger_document_currency VARCHAR(25),
                                 @as_agedby varchar(10),
                                 @as_sortby varchar(10),
                                 @is_bucket1 int,
                                 @is_bucket2 int,
                                 @is_bucket3 int,
                                 @is_bucket4 int,
                                 @as_pageby VARCHAR(25)

AS

-- 29-Dec-09 The names of the new temporary tables #ap_selected_aging2 and
--           #ap_selected_aging3 caused errors in ASE, as the first 12? characters
--           need to be unique.  Modified the names of these tables to be
--           #ap_2selected_aging and #ap_3selected_aging.

-- 11-May-09 Modified to select the actual ledger account when the user
--           is aging by ledger account and the ledger accounts are
--           wildcarded (contain question marks).

-- 05-Sep-06 Changed *= syntax to LEFT OUTER JOIN syntax.

-- 20-Jun-01 Modified to select voided checks with no invoices only if the
--           check date is in 1998 or later. This was necessary for clients
--           whose data we converted. Without this date check, checks which
--           were cut prior to 1998 and voided in 1998 were appearing on
--           the report because their corresponding check and invoice
--           weren't converted and the check and void didn't net to zero.

-- 20-Nov-00 Added arguments as_begledgeraccount, as_endledgeraccount and
--           as_pageby.

-- 18-Oct-00 Added arguments as_agedby, as_sortby, is_bucket1, is_bucket2,
--           is_bucket3, is_bucket4.

-- 11-Sep-00 Modified the select statement for checks to select checks
--           that don't have a corresponding invoice. This happens when
--           a check is produced in one period, voided in another, and
--           the invoice is deleted from the first period.

-- 25-Apr-00 Added temporary table and added select statement for checks.
-- 05-Nov-99 Return currency.
-- 27-Jul-99 Don't include intercompany ap_headers.

BEGIN

DECLARE @i_allocatedcount INT

CREATE TABLE #ap_selected_aging
   (vendor VARCHAR(25) NULL,
    inv_cm_flag CHAR(1) NULL,
    invoice_cm VARCHAR(25) NULL,
    buy_unit VARCHAR(25) NULL,
    pay_unit VARCHAR(25) NULL,
    pay_vendor VARCHAR(25) NULL,
    due_date DATETIME NULL,
    received_date DATETIME NULL,
    discount_date DATETIME NULL,
    inv_cm_date DATETIME NULL,
    ledger_account VARCHAR(50) NULL,
    hold_inv_cm CHAR(1) NULL,
    inv_cm_amount DEC(18,6) NULL,
    applied_amount DEC(18,6) NULL,
    open_amount DEC(18,6) NULL,
    days_past_due INT NULL,
    days_past_doc INT NULL,
    vendor_name VARCHAR(100) NULL,
    as_of_date DATETIME NULL,
    select_date DATETIME NULL,
    exchanged_amount DEC(18,6) NULL,
    exchanged_applied_amount DEC(18,6) NULL,
    exchanged_open_amount DEC(18,6) NULL,
    sort_1 VARCHAR(50),
    sort_2 VARCHAR(100))

-- This table's format is identical to that of
-- #ap_selected_aging.  It is used as a working
-- table when we need to process ledger accounts
-- that are allocated.
CREATE TABLE #ap_2selected_aging
   (vendor VARCHAR(25) NULL,
    inv_cm_flag CHAR(1) NULL,
    invoice_cm VARCHAR(25) NULL,
    buy_unit VARCHAR(25) NULL,
    pay_unit VARCHAR(25) NULL,
    pay_vendor VARCHAR(25) NULL,
    due_date DATETIME NULL,
    received_date DATETIME NULL,
    discount_date DATETIME NULL,
    inv_cm_date DATETIME NULL,
    ledger_account VARCHAR(50) NULL,
    hold_inv_cm CHAR(1) NULL,
    inv_cm_amount DEC(18,6) NULL,
    applied_amount DEC(18,6) NULL,
    open_amount DEC(18,6) NULL,
    days_past_due INT NULL,
    days_past_doc INT NULL,
    vendor_name VARCHAR(100) NULL,
    as_of_date DATETIME NULL,
    select_date DATETIME NULL,
    exchanged_amount DEC(18,6) NULL,
    exchanged_applied_amount DEC(18,6) NULL,
    exchanged_open_amount DEC(18,6) NULL,
    sort_1 VARCHAR(50),
    sort_2 VARCHAR(100))

-- This table's format is identical to that of
-- #ap_selected_aging.  It is used as a working
-- table when we need to process ledger accounts
-- that are allocated on checks.
CREATE TABLE #ap_3selected_aging
   (vendor VARCHAR(25) NULL,
    inv_cm_flag CHAR(1) NULL,
    invoice_cm VARCHAR(25) NULL,
    buy_unit VARCHAR(25) NULL,
    pay_unit VARCHAR(25) NULL,
    pay_vendor VARCHAR(25) NULL,
    due_date DATETIME NULL,
    received_date DATETIME NULL,
    discount_date DATETIME NULL,
    inv_cm_date DATETIME NULL,
    ledger_account VARCHAR(50) NULL,
    hold_inv_cm CHAR(1) NULL,
    inv_cm_amount DEC(18,6) NULL,
    applied_amount DEC(18,6) NULL,
    open_amount DEC(18,6) NULL,
    days_past_due INT NULL,
    days_past_doc INT NULL,
    vendor_name VARCHAR(100) NULL,
    as_of_date DATETIME NULL,
    select_date DATETIME NULL,
    exchanged_amount DEC(18,6) NULL,
    exchanged_applied_amount DEC(18,6) NULL,
    exchanged_open_amount DEC(18,6) NULL,
    sort_1 VARCHAR(50),
    sort_2 VARCHAR(100))

INSERT INTO #ap_selected_aging
SELECT ap_headers.vendor,
   ap_headers.inv_cm_flag,
   ap_headers.invoice_cm,
   ap_headers.buy_unit,
   ap_headers.pay_unit,
   ap_headers.pay_vendor,
   ap_headers.due_date,
   ap_headers.received_date,
   ap_headers.discount_date,
   ap_headers.inv_cm_date,
   ap_headers.ledger_account_code,
   ap_headers.hold_inv_cm,
   ap_headers.inv_cm_amount,
   IsNull( Sum( ap_applications.pay_amount ), 0) ,
   IsNull(ap_headers.inv_cm_amount - Sum( ap_applications.pay_amount ) ,
            ap_headers.inv_cm_amount) open_amount ,
   DateDiff(day, ap_headers.due_date, @ad_asofdate),
   DateDiff(day, ap_headers.inv_cm_date, @ad_asofdate),
   Min(vendors.vendor_name),
   @ad_asofdate,
   @ad_selectdate,
   ap_headers.exchanged_amount,
   IsNull( Sum( ap_applications.exchanged_pay_amount ), 0) ,
   IsNull(ap_headers.exchanged_amount - Sum( ap_applications.exchanged_pay_amount ) ,
            ap_headers.exchanged_amount) exchanged_open_amount,
   '',
   ''

FROM ap_headers LEFT OUTER JOIN ap_applications
  ON ap_headers.vendor = ap_applications.vendor AND
     ap_headers.inv_cm_flag = ap_applications.inv_cm_flag AND
     ap_headers.invoice_cm = ap_applications.invoice_cm AND
     Convert(char(10),ap_applications.applied_date,111) <=
       Convert(char(10),@ad_selectdate,111) AND
     ap_applications.discount_flag = 'N' AND
     ap_applications.check_number <> 0,
     vendors

WHERE ap_headers.pay_vendor = vendors.vendor AND
   ap_headers.pay_vendor >= @as_begpayvendor  AND
   ap_headers.pay_vendor <= @as_endpayvendor AND
   ap_headers.pay_unit >= @as_begpayunit AND
   ap_headers.pay_unit <= @as_endpayunit AND
   ap_headers.vendor >= @as_begbuyvendor  AND
   ap_headers.vendor <= @as_endbuyvendor AND
   ap_headers.buy_unit >= @as_begbuyunit AND
   ap_headers.buy_unit <= @as_endbuyunit AND
 ((ap_headers.ledger_account_code >= @as_begledgeraccount AND
   ap_headers.ledger_account_code <= @as_endledgeraccount) OR
   ap_headers.ledger_account_code like '%?%') AND
   ap_headers.approved = 'Y' AND
   ap_headers.intercompany <> 'Y' AND
   ap_headers.inv_cm_amount <> 0 AND
   Convert(char(10),ap_headers.gl_date,111) <=
      Convert(char(10),@ad_selectdate,111)

GROUP BY ap_headers.buy_unit,
   ap_headers.vendor,
   ap_headers.inv_cm_flag,
   ap_headers.invoice_cm,
   ap_headers.pay_unit,
   ap_headers.pay_vendor,
   ap_headers.due_date,
   ap_headers.received_date,
   ap_headers.discount_date,
   ap_headers.inv_cm_date,
   ap_headers.ledger_account_code,
   ap_headers.hold_inv_cm,
   ap_headers.inv_cm_amount,
   ap_headers.exchanged_amount

HAVING IsNull(ap_headers.inv_cm_amount - Sum( ap_applications.pay_amount ),
            ap_headers.inv_cm_amount) <> 0

ORDER BY ap_headers.pay_unit,
         ap_headers.pay_vendor,
         ap_headers.inv_cm_date,
         ap_headers.inv_cm_flag DESC,
         ap_headers.invoice_cm

-- If the user is aging by ledger account, see if any of the selected
-- documents have an allocated ledger account.
IF @as_pageby <> 'UNIT'
  BEGIN
    SELECT @i_allocatedcount = Count(*)
      FROM #ap_selected_aging
     WHERE ledger_account like '%?%'

    IF @i_allocatedcount > 0
      BEGIN
        --  Some of the documents have a question mark in the ledger
        --  account.  Get the actual ledger accounts for those documents
        INSERT INTO #ap_2selected_aging
        SELECT vendor,
               inv_cm_flag,
               invoice_cm,
               buy_unit,
               pay_unit,
               pay_vendor,
               due_date,
               received_date,
               discount_date,
               inv_cm_date,
               glc.ledger_account,
               hold_inv_cm,
               glc.document_amount * -1,
               0,
               0,
               days_past_due,
               days_past_doc,
               vendor_name,
               as_of_date,
               select_date,
               glc.amount *-1,
               0,
               0,
               sort_1,
               sort_2
          FROM #ap_selected_aging, gl_cost_transactions glc
         WHERE #ap_selected_aging.ledger_account like '%?%'
           AND glc.document_id1 = invoice_cm
           AND glc.document_id2 = vendor
           AND glc.document_id3 = inv_cm_flag
           AND glc.document_type in ('AP INVOICE','AP CREDIT MEMO')
           AND glc.document_line = 0

        --  Get the actual ledger accounts for the check applications
        --  and the credit memo applications that were applied to the
        --  documents with allocated ledger accounts
        INSERT INTO #ap_2selected_aging
        SELECT #ap_selected_aging.vendor,
               #ap_selected_aging.inv_cm_flag,
               #ap_selected_aging.invoice_cm,
               #ap_selected_aging.buy_unit,
               #ap_selected_aging.pay_unit,
               #ap_selected_aging.pay_vendor,
               #ap_selected_aging.due_date,
               #ap_selected_aging.received_date,
               #ap_selected_aging.discount_date,
               #ap_selected_aging.inv_cm_date,
               glc.ledger_account,
               #ap_selected_aging.hold_inv_cm,
               0,
               glc.document_amount,
               0,
               days_past_due,
               days_past_doc,
               vendor_name,
               as_of_date,
               select_date,
               0,
               glc.amount,
               0,
               sort_1,
               sort_2
          FROM #ap_selected_aging, ap_applications app, gl_cost_transactions glc
         WHERE #ap_selected_aging.ledger_account like '%?%'
           AND #ap_selected_aging.vendor = app.vendor
           AND #ap_selected_aging.inv_cm_flag = app.inv_cm_flag
           AND #ap_selected_aging.invoice_cm = app.invoice_cm
           and  Convert(char(10),app.applied_date,111) <=
                          Convert(char(10),@ad_selectdate,111)
           AND app.discount_flag = 'N'
           AND app.check_number <> 0
           AND glc.document_id1 = Convert(varchar(25),app.check_number)
           AND glc.document_id2 = app.bank_alias
           AND document_type in ('AP Check','AP Check Void','AP CM APPL','AP CM APPL REv')
           AND glc.document_line = app.id_sequence

        -- replace the rows in ap_selected_aging with rows that
        -- have the actual ledger account
        DELETE FROM #ap_selected_aging
         WHERE #ap_selected_aging.ledger_account like '%?%'

        INSERT INTO #ap_selected_aging
        SELECT vendor,
               inv_cm_flag,
               invoice_cm,
               buy_unit,
               pay_unit,
               pay_vendor,
               due_date,
               received_date,
               discount_date,
               inv_cm_date,
               ledger_account,
               hold_inv_cm,
               sum(inv_cm_amount),
               sum(applied_amount),
               sum(inv_cm_amount - applied_amount),
               days_past_due,
               days_past_doc,
               vendor_name,
               as_of_date,
               select_date,
               sum(exchanged_amount),
               sum(exchanged_applied_amount),
               sum(exchanged_amount - exchanged_applied_amount),
               sort_1,
               sort_2
          FROM #ap_2selected_aging
         WHERE ledger_account >= @as_begledgeraccount AND
               ledger_account <= @as_endledgeraccount
      GROUP BY vendor,
               inv_cm_flag,
               invoice_cm,
               buy_unit,
               pay_unit,
               pay_vendor,
               due_date,
               received_date,
               discount_date,
               inv_cm_date,
               ledger_account,
               hold_inv_cm,
               days_past_due,
               days_past_doc,
               vendor_name,
               as_of_date,
               select_date,
               sort_1,
               sort_2

        -- Don't need this data anymore.
        DELETE FROM #ap_2selected_aging
      END
  END

-- Select appropriate check and summed application rows into the
-- temporary table. For now put them into #ap_2selected_aging.
-- This query usually returns no rows.  It only returns rows if
-- there are checks with GL dates prior to the GL dates on the
-- documents they paid.
INSERT INTO #ap_2selected_aging
SELECT ap_applications.vendor,
       'A',
       LTrim(Convert(VARCHAR(25), ap_applications.check_number)),
       ap_applications.buy_unit,
       ap_applications.pay_unit,
       ap_applications.pay_vendor,
       NULL,
       NULL,
       NULL,
       Max(bank_register.document_date),
       ap_applications.ledger_account_code,
       '',
       0,
       0,
       IsNull(Sum(ap_applications.pay_amount * -1),0),
       0,
       0,
       vendors.vendor_name,
       @ad_asofdate,
       @ad_selectdate,
       0,
       0,
       IsNull(Sum(ap_applications.exchanged_pay_amount * -1), 0),
       ap_applications.bank_alias,
       ''

FROM ap_applications,
     bank_register,
     vendors

WHERE ap_applications.vendor = vendors.vendor AND
      ap_applications.bank_alias = bank_register.bank_alias AND
      ap_applications.check_number = bank_register.document_number AND
      Convert(char(10), ap_applications.applied_date, 111) <=
          Convert(char(10), @ad_selectdate, 111) AND
     (EXISTS (SELECT 1 FROM ap_headers
          WHERE ap_headers.vendor = ap_applications.vendor AND
                ap_headers.inv_cm_flag = ap_applications.inv_cm_flag AND
                ap_headers.invoice_cm = ap_applications.invoice_cm AND
                Convert(char(10), ap_headers.gl_date, 111) >
                    Convert(char(10), @ad_selectdate, 111 )) OR
     (NOT EXISTS (SELECT 1 FROM ap_headers
          WHERE ap_headers.vendor = ap_applications.vendor AND
                ap_headers.inv_cm_flag = ap_applications.inv_cm_flag AND
                ap_headers.invoice_cm = ap_applications.invoice_cm AND
                Convert(char(10), ap_headers.gl_date, 111) <=
                    Convert(char(10), @ad_selectdate, 111 )) AND
       bank_register.document_type = 'V' AND
       Convert(char(10), bank_register.gl_date, 111) > '1997/12/31')) AND
      ap_applications.pay_vendor >= @as_begpayvendor AND
      ap_applications.pay_vendor <= @as_endpayvendor AND
      ap_applications.pay_unit >= @as_begpayunit AND
      ap_applications.pay_unit <= @as_endpayunit AND
      ap_applications.vendor >= @as_begbuyvendor AND
      ap_applications.vendor <= @as_endbuyvendor AND
      ap_applications.buy_unit >= @as_begbuyunit AND
      ap_applications.buy_unit <= @as_endbuyunit AND
      ap_applications.ledger_account_code >= @as_begledgeraccount AND
      ap_applications.ledger_account_code <= @as_endledgeraccount AND
      ap_applications.discount_flag = 'N' AND
      bank_register.document_class = 'AP' AND
      ((ap_applications.reversal = 'N' AND
       bank_register.check_void_nsf = 'C') OR
      (ap_applications.reversal = 'Y' AND
      bank_register.check_void_nsf = 'V'))

GROUP BY ap_applications.bank_alias,
         ap_applications.check_number,
         ap_applications.vendor,
         ap_applications.buy_unit,
         ap_applications.pay_unit,
         ap_applications.pay_vendor,
         ap_applications.ledger_account_code,
         vendors.vendor_name

HAVING IsNull(Sum(ap_applications.pay_amount * -1),0) <> 0

IF @as_pageby = 'UNIT'
  BEGIN
    -- Not aging by ledger account. Put all of the check rows into
    -- the primary temporary table.  (Usually there will be no check
    -- rows.)
    INSERT INTO #ap_selected_aging
      SELECT * FROM #ap_2selected_aging
  END
ELSE
  BEGIN
    -- Aging by ledger account.  Put the check rows that aren't
    -- allocated into the temporary table and delete them from
    -- temp table 2
    INSERT INTO #ap_selected_aging
      SELECT * FROM #ap_2selected_aging
       WHERE ledger_account NOT like '%?%'

    DELETE FROM #ap_2selected_aging
       WHERE ledger_account NOT like '%?%'

    -- Only thing left in the secondary temporary table are the allocated
    -- ledger accounts. Are there any?
    SELECT @i_allocatedcount = Count(*)
      FROM #ap_2selected_aging

    IF @i_allocatedcount > 0
      BEGIN
        -- Get the actual ledger accounts for the checks
        INSERT INTO #ap_3selected_aging
        SELECT #ap_2selected_aging.vendor,
               #ap_2selected_aging.inv_cm_flag,
               #ap_2selected_aging.invoice_cm,
               #ap_2selected_aging.buy_unit,
               #ap_2selected_aging.pay_unit,
               #ap_2selected_aging.pay_vendor,
               #ap_2selected_aging.due_date,
               #ap_2selected_aging.received_date,
               #ap_2selected_aging.discount_date,
               #ap_2selected_aging.inv_cm_date,
               glc.ledger_account,
               #ap_2selected_aging.hold_inv_cm,
               glc.document_amount * -1,
               0,
               0,
               days_past_due,
               days_past_doc,
               vendor_name,
               as_of_date,
               select_date,
               glc.amount *-1,
               0,
               0,
               '',
               sort_2
          FROM #ap_2selected_aging, ap_applications app, gl_cost_transactions glc
         WHERE #ap_2selected_aging.sort_1 = app.bank_alias
           AND #ap_2selected_aging.invoice_cm = Convert(varchar(25),app.check_number)
           AND  Convert(char(10),app.applied_date,111) <=
                          Convert(char(10),@ad_selectdate,111)
           AND app.discount_flag = 'N'
           AND glc.document_id1 = #ap_2selected_aging.invoice_cm
           AND glc.document_id2 = sort_1
           AND glc.document_type = 'AP Check'
           AND glc.document_line = app.id_sequence

        --  Get the actual ledger accounts for the invoices and credit
        --  memos that were paid by the checks and that have dates
        --  before the as of date.
        INSERT INTO #ap_3selected_aging
        SELECT #ap_2selected_aging.vendor,
               #ap_2selected_aging.inv_cm_flag,
               #ap_2selected_aging.invoice_cm,
               #ap_2selected_aging.buy_unit,
               #ap_2selected_aging.pay_unit,
               #ap_2selected_aging.pay_vendor,
               #ap_2selected_aging.due_date,
               #ap_2selected_aging.received_date,
               #ap_2selected_aging.discount_date,
               #ap_2selected_aging.inv_cm_date,
               glc.ledger_account,
               #ap_2selected_aging.hold_inv_cm,
               0,
               glc.document_amount,
               0,
               days_past_due,
               days_past_doc,
               vendor_name,
               as_of_date,
               select_date,
               0,
               glc.amount,
               0,
               '',
               sort_2
          FROM #ap_2selected_aging, ap_applications app, gl_cost_transactions glc
         WHERE #ap_2selected_aging.sort_1 = app.bank_alias
           AND #ap_2selected_aging.invoice_cm = Convert(varchar(25),app.check_number)
           AND  Convert(char(10),app.applied_date,111) <=
                          Convert(char(10),@ad_selectdate,111)
           AND app.discount_flag = 'N'
           AND glc.document_id1 = app.invoice_cm
           AND glc.document_id2 = app.vendor
           AND glc.document_id3 = app.inv_cm_flag
           AND document_type in ('AP INVOICE','AP CREDIT MEMO')
           AND glc.document_line = 0
           AND  Convert(char(10),glc.exchange_date,111) <=
                          Convert(char(10),@ad_selectdate,111)

        -- Put the rows with the actual ledger accounts into the
        -- primary temporary table.
        INSERT INTO #ap_selected_aging
        SELECT vendor,
               inv_cm_flag,
               invoice_cm,
               buy_unit,
               pay_unit,
               pay_vendor,
               due_date,
               received_date,
               discount_date,
               inv_cm_date,
               ledger_account,
               hold_inv_cm,
               sum(inv_cm_amount),
               sum(applied_amount),
               sum(inv_cm_amount - applied_amount),
               days_past_due,
               days_past_doc,
               vendor_name,
               as_of_date,
               select_date,
               sum(exchanged_amount),
               sum(exchanged_applied_amount),
               sum(exchanged_amount - exchanged_applied_amount),
               sort_1,
               sort_2
          FROM #ap_3selected_aging
         WHERE ledger_account >= @as_begledgeraccount AND
               ledger_account <= @as_endledgeraccount
      GROUP BY vendor,
               inv_cm_flag,
               invoice_cm,
               buy_unit,
               pay_unit,
               pay_vendor,
               due_date,
               received_date,
               discount_date,
               inv_cm_date,
               ledger_account,
               hold_inv_cm,
               days_past_due,
               days_past_doc,
               vendor_name,
               as_of_date,
               select_date,
               sort_1,
               sort_2

      END
  END

 -- put the appropriate columns into the sort columns in the temporary table
IF @as_pageby = 'UNIT'
  BEGIN
    UPDATE #ap_selected_aging
       SET sort_1 = pay_unit
  END
ELSE
  BEGIN
    UPDATE #ap_selected_aging
       SET sort_1 = ledger_account
  END

IF @as_sortby = 'NAME'
  BEGIN
    UPDATE #ap_selected_aging
       SET sort_2 = vendor_name
  END
ELSE
  BEGIN
    UPDATE #ap_selected_aging
       SET sort_2 = pay_vendor
  END

SELECT vendor,
       inv_cm_flag,
       invoice_cm,
       buy_unit,
       pay_unit,
       pay_vendor,
       due_date,
       received_date,
       discount_date,
       inv_cm_date,
       hold_inv_cm,
       inv_cm_amount,
       applied_amount,
       open_amount,
       days_past_due,
       days_past_doc,
       vendor_name,
       as_of_date,
       select_date,
       exchanged_amount,
       exchanged_applied_amount,
       exchanged_open_amount,
       sort_1,
       sort_2
  FROM #ap_selected_aging
 ORDER BY sort_1,
          sort_2,
          inv_cm_date,
          inv_cm_flag DESC,
          invoice_cm
END
GO
