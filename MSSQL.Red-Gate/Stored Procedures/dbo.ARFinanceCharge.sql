SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ARFinanceCharge] @as_beginvoice VARCHAR(25),
                                 @as_endinvoice VARCHAR(25),
                                 @as_begbillcustomer VARCHAR(25),
                                 @as_endbillcustomer VARCHAR(25),
                                 @as_begbillunit VARCHAR(25),
                                 @as_endbillunit VARCHAR(25),
                                 @as_begfincharge VARCHAR(25),
                                 @as_endfincharge VARCHAR(25),
                                 @ad_asofdate datetime

AS

-- 05-Sep-06 Changed *= syntax to LEFT OUTER JOIN syntax.

BEGIN

CREATE TABLE #ar_fincharge_tmp
        (document_type CHAR(1) NULL,
         document varchar(25) NULL,
         bill_unit varchar(25) NULL,
         bill_customer varchar(25) NULL,
         ship_customer varchar(25) NULL,
         due_date datetime NULL,
         document_date datetime NULL,
         gl_date datetime NULL,
         as_of_date datetime NULL,
         amount decimal(18,6) NULL,
         applied_amount decimal(18,6) NULL,
         open_amount decimal(18,6) NULL,
         days_past_due int NULL,
         bill_customer_name varchar(100) NULL,
         exchanged_amount decimal(18,6) NULL,
         exchanged_applied_amount decimal(18,6) NULL,
         exchanged_open_amount decimal(18,6) NULL)

INSERT INTO #ar_fincharge_tmp
  SELECT ar_headers.document_type,
    ar_headers.document,
    ar_headers.bill_unit,
    ar_headers.bill_customer,
    ar_headers.ship_customer,
    ar_headers.due_date,
    ar_headers.document_date,
    ar_headers.gl_date,
    @ad_asofdate,
    ar_headers.amount,
    IsNull(Sum(ar_applications.applied_amount),0),
    ar_headers.amount -
       IsNull(Sum(ar_applications.applied_amount),0) open_amount,
    DateDiff(day,ar_headers.due_date, @ad_asofdate),
    ar_customers.customer_name,
    ar_headers.exchanged_amount,
    IsNull(SUM(ar_applications.offset_exchanged_amount * -1),0),
    ar_headers.exchanged_amount -
           IsNull(SUM(ar_applications.offset_exchanged_amount * -1),0)
  FROM ar_headers LEFT OUTER JOIN ar_applications
    ON ar_headers.document = ar_applications.document AND
       ar_headers.document_type = ar_applications.document_type AND
       Convert(char(10),ar_applications.applied_date,111) <=
                Convert(char(10),@ad_asofdate,111) AND
       ar_applications.application_type <> 'OVERPY',
       ar_customers
 WHERE ar_headers.bill_customer = ar_customers.customer AND
       Convert(char(10),ar_headers.due_date,111) <=
                Convert(char(10),@ad_asofdate,111) AND
       IsNull(ar_headers.bill_customer,' ') >= @as_begbillcustomer AND
       IsNull(ar_headers.bill_customer,' ') <= @as_endbillcustomer AND
       IsNull(ar_headers.bill_unit,' ') >= @as_begbillunit AND
       IsNull(ar_headers.bill_unit,' ') <= @as_endbillunit AND
       IsNull(ar_headers.document,' ') >= @as_beginvoice AND
       IsNull(ar_headers.document,' ') <= @as_endinvoice AND
       IsNull(ar_customers.hdr_finance_charge,' ') >= @as_begfincharge AND
       IsNull(ar_customers.hdr_finance_charge,' ') <= @as_endfincharge AND
       ar_headers.amount > 0
 GROUP BY ar_headers.document_type,
          ar_headers.document,
          ar_headers.bill_unit,
          ar_headers.bill_customer,
          ar_headers.ship_customer,
          ar_headers.amount,
          ar_headers.due_date,
          ar_headers.document_date,
          ar_headers.gl_date,
          ar_customers.customer_name,
          ar_headers.exchanged_amount
 HAVING ar_headers.amount -
       IsNull(Sum(ar_applications.applied_amount),0) > 0

SELECT document_type,
    document,
    bill_unit,
    bill_customer,
    ship_customer,
    due_date,
    document_date,
    gl_date,
    as_of_date,
    amount,
    applied_amount,
    open_amount,
    days_past_due,
    bill_customer_name,
    exchanged_amount,
    exchanged_applied_amount,
    exchanged_open_amount
FROM #ar_fincharge_tmp
ORDER BY bill_unit,
         bill_customer_name,
         bill_customer,
         document_type DESC,
         document

END
GO
