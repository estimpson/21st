SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ARCheckStatus] @as_billcustomer VARCHAR(25),
                               @as_checknumber VARCHAR(25)
AS

-- 08-Feb-2010 Check number is now varchar.

-- 05-Sep-2006 Changed *= syntax to LEFT OUTER JOIN syntax.


-- 11-Sep-2002 Use #ar_checkapps.document_id1 instead of
--             ar_headers.bill_unit for the subquery on companies.

-- 14-Nov-2001 Returned the application_type.

-- 08-Nov-2001 Looked up and returned the currency of the check.

BEGIN

  DECLARE @s_customername VARCHAR(100),
          @s_billaddressid VARCHAR(25),
          @s_address1 VARCHAR(50),
          @s_address2 VARCHAR(50),
          @s_address3 VARCHAR(50),
          @s_city VARCHAR(25),
          @s_state VARCHAR(25),
          @s_postalcode VARCHAR(10),
          @s_country VARCHAR(50)

  CREATE TABLE #ar_checkapps
       (bank_alias                VARCHAR(25) NOT NULL,
       document_class             VARCHAR(2) NOT NULL,
       empower_id                 INT NOT NULL,
       check_void_nsf             CHAR(1) NOT NULL,
       document_id1               VARCHAR(25) NULL,
       bill_customer              VARCHAR(25) NULL,
       check_number               VARCHAR(25) NULL,
       check_type                 VARCHAR(3) NULL,
       check_date                 DATETIME NULL,
       check_amount               DECIMAL(18,6) NULL,
       check_exchanged_amount     DECIMAL(18,6) NULL,
       check_applied_amount       DECIMAL(18,6) NULL,
       fiscal_year                VARCHAR(5) NULL,
       ledger                     VARCHAR(40) NULL,
       check_period               SMALLINT NULL,
       check_gl_date              DATETIME NULL,
       check_gl_entry             VARCHAR(25) NULL,
       ledger_account_code        VARCHAR(50) NULL,
       offset_ledger_account_code VARCHAR(50) NULL,
       reconciled                 CHAR(1) NULL,
       reconciled_date            DATETIME NULL,
       reconciled_id              VARCHAR(25) NULL,
       deposit_id                 VARCHAR(25) NULL,
       deposit_date               DATETIME NULL,
       application_type           VARCHAR(6) NULL,
       document_type              CHAR(1) NULL,
       document                   VARCHAR(25) NULL,
       reversed                   CHAR(1) NULL,
       reversal                   CHAR(1) NULL,
       applied_amount             DECIMAL(18,6) NULL,
       applied_date               DATETIME NULL)


  /*  Select the appropriate check and its applications into the
      temporary table  */
  INSERT INTO #ar_checkapps
    SELECT
       bank_register.bank_alias,
       bank_register.document_class,
       bank_register.document_number,
       bank_register.check_void_nsf,
       bank_register.document_id1,
       bank_register.document_id2,
       bank_register.document_id3,
       bank_register.document_type,
       bank_register.document_date,
       bank_register.document_amount,
       bank_register.exchanged_amount,
       bank_register.applied_amount,
       bank_register.fiscal_year,
       bank_register.ledger,
       bank_register.period,
       bank_register.gl_date,
       bank_register.gl_entry,
       bank_register.ledger_account_code,
       bank_register.offset_ledger_account_code,
       bank_register.reconciled,
       bank_register.reconciled_date,
       bank_register.reconciled_id,
       bank_register.document_group_id,
       bank_register.document_group_date,
       ar_applications.application_type,
       ar_applications.document_type,
       ar_applications.document,
       ar_applications.reversed,
       ar_applications.reversal,
       ar_applications.applied_amount,
       ar_applications.applied_date

    FROM bank_register LEFT OUTER JOIN ar_applications

      ON bank_register.document_id2 = ar_applications.bill_customer AND
         bank_register.document_id3 = ar_applications.check_number

   WHERE bank_register.document_class = 'AR' AND
         bank_register.check_void_nsf = 'C' AND
         bank_register.document_id2 = @as_billcustomer AND
         bank_register.document_id3 = @as_checknumber


  /*  Lookup the customer name and bill address id  */
  SELECT @s_customername = customer_name,
         @s_billaddressid = bill_address_id
    FROM ar_customers
   WHERE customer = @as_billcustomer

  /*  Lookup the address details for the bill address id just looked up */
  SELECT @s_address1 = address_1,
         @s_address2 = address_2,
         @s_address3 = address_3,
         @s_city = city,
         @s_state = state,
         @s_postalcode = postal_code,
         @s_country = country
    FROM addresses
   WHERE address_id = @s_billaddressid

   /*  Select and return what we have stored in the temporary table,
       local variables and columns from the ar_headers table  */
   SELECT #ar_checkapps.bank_alias,
          #ar_checkapps.document_class,
          #ar_checkapps.empower_id,
          #ar_checkapps.check_void_nsf,
          #ar_checkapps.document_id1,
          #ar_checkapps.bill_customer,
          @s_customername bill_customer_name,
          @s_address1 bill_address_1,
          @s_address2 bill_address_2,
          @s_address3 bill_address_3,
          @s_city bill_city,
          @s_state bill_state,
          @s_postalcode bill_postal_code,
          @s_country bill_country,
          #ar_checkapps.check_number,
          #ar_checkapps.check_type,
          #ar_checkapps.check_date,
          #ar_checkapps.check_amount,
          #ar_checkapps.check_exchanged_amount,
          #ar_checkapps.check_applied_amount,
          #ar_checkapps.fiscal_year,
          #ar_checkapps.ledger,
          #ar_checkapps.check_period,
          #ar_checkapps.check_gl_date,
          #ar_checkapps.check_gl_entry,
          #ar_checkapps.ledger_account_code,
          #ar_checkapps.offset_ledger_account_code,
          #ar_checkapps.reconciled,
          #ar_checkapps.reconciled_date,
          #ar_checkapps.reconciled_id,
          #ar_checkapps.deposit_id,
          #ar_checkapps.deposit_date,
          #ar_checkapps.reversed,
          #ar_checkapps.reversal,
          #ar_checkapps.applied_amount,
          #ar_checkapps.applied_date,
          #ar_checkapps.application_type,
          #ar_checkapps.document_type,
          #ar_checkapps.document,
          ar_headers.ship_unit,
          ar_headers.ship_customer,
          ar_headers.bill_unit,
          ar_headers.terms,
          ar_headers.document_date,
          ar_headers.due_date,
          ar_headers.amount doc_amount,
          ar_headers.gl_entry doc_gl_entry,
          ar_headers.gl_date doc_gl_date,
          ar_headers.fiscal_year doc_fiscal_year,
          ar_headers.period doc_period,
          ar_headers.currency,
         (SELECT companies.company_name
            FROM units_receivables, companies
            WHERE units_receivables.unit = #ar_checkapps.document_id1 AND
                  units_receivables.company = companies.company) company_name,
         (SELECT IsNull(currency,'')
            FROM bank_accounts
            WHERE bank_accounts.bank_alias = #ar_checkapps.bank_alias) check_currency
     FROM #ar_checkapps LEFT OUTER JOIN ar_headers
       ON #ar_checkapps.document_type = ar_headers.document_type AND
          #ar_checkapps.document = ar_headers.document
    ORDER BY #ar_checkapps.document_type,
             #ar_checkapps.document
END
GO
