SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ARDocumentStatus] @as_documenttype CHAR(1),
                                  @as_document VARCHAR(25)
AS

-- 19-Nov-2010 Increased contract_po to 30 characters for Williams & Wells.

-- 08-Feb-2010 Check number is now varchar.

-- 05-Sep-2006 Changed *= syntax to LEFT OUTER JOIN syntax.

-- 10-Sep-2002 Return ar_headers.bill_name rather than getting the bill
--             name from the ar_customers.

-- 20-Aug-1999 Return app_bill_customer.

-- 26-Jul-1999 1. Added the application bill_customer to #ar_docapps. Use
--                the bill_customer from the application, not from the
--                ar_header, when linking in the bank register in case the
--                ar_header was paid by a document for another bill_customer
--                (a new feature).
--             2. Don't include bill_customer when linking ar_headers to
--                ar_applications.

BEGIN

  CREATE TABLE #ar_docapps
      (document_type            CHAR(1) NOT NULL,
       document                 VARCHAR(25) NOT NULL,
       ship_unit                VARCHAR(25) NULL,
       bill_unit                VARCHAR(25) NULL,
       ship_customer            VARCHAR(25) NULL,
       bill_customer            VARCHAR(25) NULL,
       bill_customer_name       VARCHAR(100) NULL,
       contract_po              VARCHAR(30) NULL,
       freight_terms            VARCHAR(25) NULL,
       price_group              VARCHAR(25) NULL,
       account_manager          VARCHAR(25) NULL,
       document_class           VARCHAR(25) NULL,
       terms                    VARCHAR(25) NULL,
       finance_charge           VARCHAR(25) NULL,
       currency                 VARCHAR(25) NULL,
       intercompany             CHAR(1) NULL,
       printed                  CHAR(1) NULL,
       document_comments        TEXT NULL,
       tax_exempt_number        VARCHAR(25) NULL,
       doc_fiscal_year          VARCHAR(5) NULL,
       ledger                   VARCHAR(40) NULL,
       doc_gl_entry             VARCHAR(25) NULL,
       doc_period               SMALLINT NULL,
       doc_gl_date              DATETIME NULL,
       ledger_account_code      VARCHAR(50) NULL,
       amount                   DECIMAL(18,6)  NULL,
       exchanged_amount         DECIMAL(18,6)  NULL,
       tax_amount               DECIMAL(18,6)  NULL,
       freight_amount           DECIMAL(18,6)  NULL,
       applied_amount           DECIMAL(18,6)  NULL,
       exchanged_applied_amount DECIMAL(18,6)  NULL,
       document_date            DATETIME NULL,
       due_date                 DATETIME NULL,
       discount_date            DATETIME NULL,
       last_finance_chg_date    DATETIME NULL,
       batch                    VARCHAR(25) NULL,
       check_number             VARCHAR(25) NULL,
       applied_document         VARCHAR(25) NULL,
       reversed                 CHAR(1) NULL,
       reversal                 CHAR(1) NULL,
       application_type         VARCHAR(6) NULL,
       app_applied_amount       DECIMAL(18,6) NULL,
       applied_date             DATETIME NULL,
       app_bill_customer        VARCHAR(25) NULL)

  /*  select the appropriate document as well as applications into the
      temporary table */
  INSERT INTO #ar_docapps
   SELECT
    ar_headers.document_type,
    ar_headers.document,
    ar_headers.ship_unit,
    ar_headers.bill_unit,
    ar_headers.ship_customer,
    ar_headers.bill_customer,
    ar_headers.bill_name,
    ar_headers.contract_po,
    ar_headers.freight_terms,
    ar_headers.price_group,
    ar_headers.account_manager,
    ar_headers.document_class,
    ar_headers.terms,
    ar_headers.finance_charge,
    ar_headers.currency,
    ar_headers.intercompany,
    ar_headers.printed,
    ar_headers.document_comments,
    ar_headers.tax_exempt_number,
    ar_headers.fiscal_year,
    ar_headers.ledger,
    ar_headers.gl_entry,
    ar_headers.period,
    ar_headers.gl_date,
    ar_headers.ledger_account_code,
    ar_headers.amount,
    ar_headers.exchanged_amount,
    ar_headers.tax_amount,
    ar_headers.freight_amount,
    ar_headers.applied_amount,
    ar_headers.exchanged_applied_amount,
    ar_headers.document_date,
    ar_headers.due_date,
    ar_headers.discount_date,
    ar_headers.last_finance_chg_date,
    ar_headers.batch,
    ar_applications.check_number,
    ar_applications.applied_document,
    ar_applications.reversed,
    ar_applications.reversal,
    ar_applications.application_type,
    ar_applications.applied_amount application_applied_amount,
    ar_applications.applied_date,
    ar_applications.bill_customer
    FROM ar_headers LEFT OUTER JOIN ar_applications
      ON ar_headers.document_type = ar_applications.document_type AND
          ar_headers.document = ar_applications.document
    WHERE ar_headers.document_type = @as_documenttype AND
          ar_headers.document = @as_document

SELECT #ar_docapps.document_type,
       #ar_docapps.document,
       #ar_docapps.ship_unit,
       #ar_docapps.bill_unit,
       #ar_docapps.ship_customer,
       #ar_docapps.bill_customer,
       #ar_docapps.contract_po,
       #ar_docapps.freight_terms,
       #ar_docapps.price_group,
       #ar_docapps.account_manager,
       #ar_docapps.document_class,
       #ar_docapps.terms,
       #ar_docapps.finance_charge,
       #ar_docapps.currency,
       #ar_docapps.intercompany,
       #ar_docapps.printed,
       #ar_docapps.document_comments,
       #ar_docapps.tax_exempt_number,
       #ar_docapps.doc_fiscal_year,
       #ar_docapps.ledger,
       #ar_docapps.doc_gl_entry,
       #ar_docapps.doc_period,
       #ar_docapps.doc_gl_date,
       #ar_docapps.ledger_account_code,
       #ar_docapps.amount,
       #ar_docapps.exchanged_amount,
       #ar_docapps.tax_amount,
       #ar_docapps.freight_amount,
       #ar_docapps.applied_amount,
       #ar_docapps.exchanged_applied_amount,
       #ar_docapps.document_date,
       #ar_docapps.due_date,
       #ar_docapps.discount_date,
       #ar_docapps.last_finance_chg_date,
       #ar_docapps.batch,
       #ar_docapps.check_number,
       #ar_docapps.applied_document,
       #ar_docapps.reversed,
       #ar_docapps.reversal,
       #ar_docapps.application_type,
       #ar_docapps.app_applied_amount,
       #ar_docapps.applied_date,
      (SELECT customer_name
         FROM ar_customers
         WHERE ar_customers.customer=#ar_docapps.ship_customer) ship_customer_name,
       #ar_docapps.bill_customer_name,
       bank_register.check_void_nsf check_nsf,
       bank_register.document_type check_type,
       bank_register.document_date check_date,
       bank_register.gl_date check_gl_date,
       bank_register.gl_entry check_gl_entry,
       bank_register.fiscal_year check_fiscal_year,
       bank_register.period check_period,
       bank_register.reconciled_date,
       bank_register.reconciled_id,
       IsNull(IsNull(bank_register.document_type,
                  'A' + #ar_docapps.document_type), '') +
             #ar_docapps.application_type check_discount_type,
       #ar_docapps.app_bill_customer

  FROM #ar_docapps LEFT OUTER JOIN bank_register

    ON #ar_docapps.app_bill_customer = bank_register.document_id2 AND
       #ar_docapps.check_number = bank_register.document_id3 AND
       bank_register.document_class = 'AR' AND
     ((#ar_docapps.reversal='N' AND bank_register.check_void_nsf='C') OR
      (#ar_docapps.reversal='Y' AND
       (bank_register.check_void_nsf='N' OR bank_register.document_type='C')))

ORDER BY check_date,
         check_discount_type

END
GO
