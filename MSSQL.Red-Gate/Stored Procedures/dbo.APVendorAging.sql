SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[APVendorAging] @as_payvendor VARCHAR(25),
                               @ad_asofdate DATETIME,
                               @ad_selectdate DATETIME
AS

-- 11-Feb-09 Select invoices wher pay_vendor = @as_payvendor not where
--           vendor = @as_payvendor.

-- 07-Sep-06 Changed *= syntax to LEFT OUTER JOIN syntax.

-- 11-Sep-00 Modified the select statement for checks to select checks
--           that don't have a corresponding invoice. This happens when
--           a check is produced in one period, voided in another, and
--           the invoice is deleted from the first period.

-- 25-Apr-00 Added temporary table and added select statement for checks.

-- 27-Jul-99 Don't include intercompany ap_headers.

BEGIN  CREATE TABLE #ap_vendor_aging
   (vendor VARCHAR(25) NULL,
    inv_cm_flag CHAR(1) NULL,
    invoice_cm VARCHAR(25) NULL,
    buy_unit VARCHAR(25) NULL,
    pay_unit VARCHAR(25) NULL,
    pay_vendor VARCHAR(25) NULL,
    due_date DATETIME NULL,
    inv_cm_date DATETIME NULL,
    hold_inv_cm CHAR(1) NULL,
    inv_cm_amount DEC(18,6) NULL,
    applied_amount DEC(18,6) NULL,
    open_amount DEC(18,6) NULL,
    days_past_due INT NULL,
    vendor_name VARCHAR(100) NULL)

INSERT INTO #ap_vendor_aging
SELECT ap_headers.vendor,
    ap_headers.inv_cm_flag,
    ap_headers.invoice_cm,
    ap_headers.buy_unit,
    ap_headers.pay_unit,
    ap_headers.pay_vendor,
    ap_headers.due_date,
    ap_headers.inv_cm_date,
    ap_headers.hold_inv_cm,
    ap_headers.inv_cm_amount,
    IsNull(Sum(ap_applications.pay_amount),0),
    IsNull(ap_headers.inv_cm_amount - Sum(ap_applications.pay_amount),
              ap_headers.inv_cm_amount) open_amount,
    DateDiff(day,ap_headers.due_date, @ad_asofdate) days_past_due,
    vendors.vendor_name

FROM ap_headers LEFT OUTER JOIN ap_applications ON
   ap_headers.vendor = ap_applications.vendor AND
   ap_headers.inv_cm_flag = ap_applications.inv_cm_flag AND
   ap_headers.invoice_cm = ap_applications.invoice_cm AND

   Convert(char(10),ap_applications.applied_date,111) <=
       Convert(char(10),@ad_selectdate,111) AND
   ap_applications.discount_flag = 'N' AND
   ap_applications.check_number <> 0,

   vendors

WHERE ap_headers.pay_vendor = @as_payvendor AND
   ap_headers.approved = 'Y' AND
   ap_headers.intercompany <> 'Y' AND
   ap_headers.inv_cm_amount <> 0 AND
   Convert(char(10),ap_headers.gl_date,111) <=
       Convert(char(10),@ad_selectdate,111) AND
   ap_headers.pay_vendor = vendors.vendor

GROUP BY ap_headers.pay_unit,
         ap_headers.pay_vendor,
         ap_headers.buy_unit,
         ap_headers.vendor,
         ap_headers.inv_cm_flag,
         ap_headers.invoice_cm,
         ap_headers.inv_cm_date,
         ap_headers.due_date,
         ap_headers.inv_cm_amount,
         ap_headers.hold_inv_cm,
         vendors.vendor_name

HAVING IsNull(SUM(ap_applications.pay_amount),0) <> ap_headers.inv_cm_amount

ORDER BY ap_headers.pay_unit,
         ap_headers.pay_vendor,
         ap_headers.buy_unit,
         ap_headers.vendor,
         ap_headers.inv_cm_date,
         ap_headers.inv_cm_flag DESC,
         ap_headers.invoice_cm

-- Select appropriate check and summed application rows into the
-- temporary table.
INSERT INTO #ap_vendor_aging
SELECT ap_applications.vendor,
       'A',
       LTrim(Str(ap_applications.check_number)),
       ap_applications.buy_unit,
       ap_applications.pay_unit,
       ap_applications.pay_vendor,
       NULL,
       Max(bank_register.document_date),
       '',
       0,
       0,
       IsNull(Sum(ap_applications.pay_amount * -1), 0),
       NULL,
       vendors.vendor_name

FROM ap_applications,
     bank_register,
     vendors

WHERE ap_applications.vendor = vendors.vendor AND
      ap_applications.bank_alias = bank_register.bank_alias AND
      ap_applications.check_number = bank_register.document_number AND
      Convert(char(10), ap_applications.applied_date, 111 ) <=
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
       bank_register.document_type = 'V')) AND
      ap_applications.pay_vendor = @as_payvendor AND
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
         vendors.vendor_name

HAVING IsNull(Sum(ap_applications.pay_amount * -1), 0) <> 0

SELECT vendor,
    inv_cm_flag,
    invoice_cm,
    buy_unit,
    pay_unit,
    pay_vendor,
    due_date,
    inv_cm_date,
    hold_inv_cm,
    inv_cm_amount,
    applied_amount,
    open_amount,
    days_past_due,
    vendor_name
FROM #ap_vendor_aging
ORDER BY pay_unit,
         vendor_name,
         pay_vendor,
         inv_cm_date,
         inv_cm_flag DESC,
         invoice_cm

END
GO
