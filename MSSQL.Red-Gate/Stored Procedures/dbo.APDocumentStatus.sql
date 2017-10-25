SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[APDocumentStatus]
         @as_vendor VARCHAR(25),
         @as_invcmflag CHAR(1),
         @as_invoicecm VARCHAR(25)
AS
BEGIN

-- 05-Sep-2006 Changed *= syntax to LEFT OUTER JOIN syntax.

-- 27-Oct-2005 Added RTrim to trim the bank_register.document_type when
--             concatenating it with the discount flag.  For some reason
--             Medway ended up with a space after the document_type when
--             we didn't do this.

-- 17-Mar-2004 Corrected WHERE clause to work for ASA when there are
--             applications but no bank_register rows (i.e. there are
--             credit memo applications). Needed to include
--             "OR bank_register.check_void_nsf IS NULL" because for
--             ASA this part of the WHERE is being evaluation after the
--             LOJ. For SQL Server it is being evaluated as part of the LOJ.

-- 02-Oct-2000 Get pay_vendor_name from ap_headers instead of from vendors.

CREATE TABLE #ap_document_apps
   (vendor VARCHAR(25) NOT NULL,
    inv_cm_flag CHAR(1) NOT NULL,
    invoice_cm VARCHAR(25) NOT NULL,
    buy_unit VARCHAR(25) NULL,
    pay_unit VARCHAR(25) NULL,
    pay_vendor VARCHAR(25) NULL,
    batch VARCHAR(25) NULL,
    contract VARCHAR(40) NULL,
    purchase_order VARCHAR(25) NULL,
    voucher VARCHAR(25) NULL,
    document_class VARCHAR(25) NULL,
    terms VARCHAR(25) NULL,
    inv_cm_date DATETIME NULL,
    received_date DATETIME NULL,
    due_date DATETIME NULL,
    discount_date DATETIME NULL,
    inv_cm_amount DECIMAL(18,6)  NULL,
    tax_amount DECIMAL(18,6)  NULL,
    freight_amount DECIMAL(18,6)  NULL,
    applied_amount DECIMAL(18,6)  NULL,
    matched CHAR(1) NULL,
    matched_reason VARCHAR(25) NULL,
    approver VARCHAR(25) NULL,
    approved CHAR(1) NULL,
    approved_reason VARCHAR(25) NULL,
    hold_inv_cm CHAR(1) NULL,
    separate_check CHAR(1) NULL,
    intercompany CHAR(1) NULL,
    inv_cm_fiscal_year VARCHAR(5) NULL,
    inv_cm_ledger VARCHAR(40) NULL,
    inv_cm_gl_entry VARCHAR(25) NULL,
    inv_cm_period SMALLINT NULL,
    inv_cm_gl_date DATETIME NULL,
    ledger_account_code VARCHAR(50) NULL,
    discount_ledger_account_code VARCHAR(50) NULL,
    currency VARCHAR(25) NULL,
    exchanged_amount DECIMAL(18,6) NULL,
    exchanged_applied_amount DECIMAL(18,6) NULL,
    pay_vendor_name VARCHAR(40) NULL,
    bank_alias VARCHAR(25) NULL,
    check_number INTEGER NULL,
    app_inv_cm_flag CHAR(1) NULL,
    applied_to_invoice_cm VARCHAR(25) NULL,
    reversed CHAR(1) NULL,
    reversal CHAR(1) NULL,
    discount_flag CHAR(1) NULL,
    pay_amount DECIMAL(18,6) NULL,
    exchanged_pay_amount DECIMAL(18,6) NULL,
    applied_date DATETIME NULL)

INSERT INTO #ap_document_apps

SELECT ap_headers.vendor,
  ap_headers.inv_cm_flag,
  ap_headers.invoice_cm,
  ap_headers.buy_unit,
  ap_headers.pay_unit,
  ap_headers.pay_vendor,
  ap_headers.batch,
  ap_headers.contract,
  ap_headers.purchase_order,
  ap_headers.voucher,
  ap_headers.document_class,
  ap_headers.terms,
  ap_headers.inv_cm_date,
  ap_headers.received_date,
  ap_headers.due_date,
  ap_headers.discount_date,
  ap_headers.inv_cm_amount,
  ap_headers.tax_amount,
  ap_headers.freight_amount,
  ap_headers.applied_amount,
  ap_headers.matched,
  ap_headers.matched_reason,
  ap_headers.approver,
  ap_headers.approved,
  ap_headers.approved_reason,
  ap_headers.hold_inv_cm,
  ap_headers.separate_check,
  ap_headers.intercompany,
  ap_headers.fiscal_year,
  ap_headers.ledger,
  ap_headers.gl_entry,
  ap_headers.period,
  ap_headers.gl_date,
  ap_headers.ledger_account_code,
  ap_headers.discount_ledger_account_code,
  ap_headers.currency,
  ap_headers.exchanged_amount,
  ap_headers.exchanged_applied_amount,
  ap_headers.pay_vendor_name,
  ap_applications.bank_alias,
  ap_applications.check_number,
  ap_applications.inv_cm_flag,
  ap_applications.applied_to_invoice_cm,
  ap_applications.reversed,
  ap_applications.reversal,
  ap_applications.discount_flag,
  ap_applications.pay_amount,
  ap_applications.exchanged_pay_amount,
  ap_applications.applied_date

FROM ap_headers LEFT OUTER JOIN ap_applications
  ON ap_headers.vendor = ap_applications.vendor AND
     ap_headers.inv_cm_flag = ap_applications.inv_cm_flag AND
     ap_headers.invoice_cm = ap_applications.invoice_cm AND
     ap_applications.check_number <> 0

WHERE ap_headers.vendor = @as_vendor AND
  ap_headers.inv_cm_flag = @as_invcmflag AND
  ap_headers.invoice_cm = @as_invoicecm

/* Add the bank register columns to the data */

SELECT #ap_document_apps.vendor,
  #ap_document_apps.inv_cm_flag,
  #ap_document_apps.invoice_cm,
  #ap_document_apps.buy_unit,
  #ap_document_apps.pay_unit,
  #ap_document_apps.pay_vendor,
  #ap_document_apps.batch,
  #ap_document_apps.contract,
  #ap_document_apps.purchase_order,
  #ap_document_apps.voucher,
  #ap_document_apps.document_class,
  #ap_document_apps.terms,
  #ap_document_apps.inv_cm_date,
  #ap_document_apps.received_date,
  #ap_document_apps.due_date,
  #ap_document_apps.discount_date,
  #ap_document_apps.inv_cm_amount,
  #ap_document_apps.tax_amount,
  #ap_document_apps.freight_amount,
  #ap_document_apps.applied_amount,
  #ap_document_apps.matched,
  #ap_document_apps.matched_reason,
  #ap_document_apps.approver,
  #ap_document_apps.approved,
  #ap_document_apps.approved_reason,
  #ap_document_apps.hold_inv_cm,
  #ap_document_apps.separate_check,
  #ap_document_apps.intercompany,
  #ap_document_apps.inv_cm_fiscal_year,
  #ap_document_apps.inv_cm_ledger,
  #ap_document_apps.inv_cm_gl_entry,
  #ap_document_apps.inv_cm_period,
  #ap_document_apps.inv_cm_gl_date,
  #ap_document_apps.ledger_account_code,
  #ap_document_apps.discount_ledger_account_code,
  #ap_document_apps.currency,
  #ap_document_apps.exchanged_amount,
  #ap_document_apps.exchanged_applied_amount,
  #ap_document_apps.bank_alias,
  #ap_document_apps.check_number,
  #ap_document_apps.applied_to_invoice_cm,
  #ap_document_apps.reversed,
  #ap_document_apps.reversal,
  #ap_document_apps.discount_flag,
  #ap_document_apps.pay_amount,
  #ap_document_apps.exchanged_pay_amount,
  #ap_document_apps.applied_date,

(SELECT vendor_name
   FROM vendors
  WHERE vendors.vendor = #ap_document_apps.vendor) vendor_name,

  #ap_document_apps.pay_vendor_name,
  bank_register.check_void_nsf check_void,
  bank_register.document_type check_type,
  bank_register.document_date check_date,
  bank_register.gl_date check_gl_date,
  bank_register.gl_entry check_gl_entry,
  bank_register.fiscal_year check_fiscal_year,
  bank_register.period check_period,
  bank_register.reconciled_date,
  bank_register.reconciled_id,
  IsNull(IsNull(RTrim(bank_register.document_type),
           'A' + #ap_document_apps.app_inv_cm_flag),'') +
     #ap_document_apps.discount_flag check_discount_type

FROM #ap_document_apps LEFT OUTER JOIN bank_register
  ON #ap_document_apps.bank_alias = bank_register.bank_alias AND
     #ap_document_apps.check_number = bank_register.document_number AND
     bank_register.document_class = 'AP' AND

   ((#ap_document_apps.reversal = 'N' AND
    bank_register.check_void_nsf = 'C' ) OR

   (#ap_document_apps.reversal = 'Y' AND
          bank_register.check_void_nsf = 'V'))

ORDER BY bank_register.document_date,
    #ap_document_apps.bank_alias,
    #ap_document_apps.check_number,
    bank_register.check_void_nsf,
    #ap_document_apps.discount_flag

END
GO
