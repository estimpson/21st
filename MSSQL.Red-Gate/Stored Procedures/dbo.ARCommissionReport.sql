SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ARCommissionReport]
                                    @as_fiscalyear VARCHAR(5),
                                    @ai_period integer,
                                    @as_agentormanager varchar(8),
                                    @as_acctmgrbegin VARCHAR(25),
                                    @as_acctmgrend VARCHAR(25),
                                    @as_salesagtbegin VARCHAR(25),
                                    @as_salesagtend VARCHAR(25)
AS

-- 01-Feb-2008	Modified the final select to select from ar_headers
--		where the document_type is 'I'.

-- 05-Sep-2006 Changed *= syntax to LEFT OUTER JOIN syntax.


-- 21-Mar-2002 Modified to not select rows with an empty account manager
--             or an empty sales agent. Previously, it didn't select them
--             if the value was null.

BEGIN

  DECLARE @c_amount decimal(18,6),
          @s_document VARCHAR(25),
          @s_customer VARCHAR(25),
          @d_documentdate datetime

  DECLARE commcursor CURSOR FOR
    SELECT ar_headers.document,
           ar_headers.amount,
           ar_headers.bill_customer,
           ar_headers.document_date
     FROM ar_headers, ar_applications
    WHERE ar_headers.document_type = ar_applications.document_type AND
          ar_headers.document = ar_applications.document AND
          ar_headers.document_type = 'I' AND
          (ar_headers.amount - ar_headers.applied_amount = 0) AND
          ar_applications.fiscal_year = @as_fiscalyear
    GROUP BY ar_headers.document,
             ar_headers.amount,
             ar_headers.bill_customer,
             ar_headers.document_date
    HAVING MAX(ar_applications.period) = @ai_period
    ORDER BY ar_headers.document

  CREATE TABLE #ar_commission_rpt
          (bill_customer VARCHAR(25) NULL,
          bill_customer_name VARCHAR(100) NULL,
          account_manager VARCHAR(25) NULL,
          sales_agent VARCHAR(25) NULL,
          item VARCHAR(50) NULL,
          item_description TEXT NULL,
          document VARCHAR(25) NULL,
          document_date DATETIME NULL,
          document_line SMALLINT,
          last_applied_date DATETIME NULL,
          extended_amount DECIMAL(18,6) NULL,
          cash_applied_amount DECIMAL(18,6) NULL,
          credit_applied_amount DECIMAL(18,6) NULL)

  OPEN commcursor

  WHILE 1 = 1
      BEGIN
      FETCH commcursor INTO @s_document, @c_amount, @s_customer, @d_documentdate

      IF @@fetch_status <> 0 BREAK

      INSERT INTO #ar_commission_rpt
      SELECT ar_headers.bill_customer,
             customer_name,
             ar_headers.account_manager,
             ar_headers.sales_agent,
             item,
             '',
             ar_headers.document,
             ar_headers.document_date,
             ar_items.document_line,
             MAX(ar_applications.applied_date),
             MAX(extended_amount),
             (SELECT SUM(ar_applications.applied_amount)
              FROM ar_applications
              WHERE ar_applications.document_type = 'I' AND
                    ar_applications.document = @s_document AND
                    ar_applications.application_type = 'CHECK'),
             (SELECT SUM(ar_applications.applied_amount)
               FROM ar_applications
              WHERE ar_applications.document_type = 'I' AND
                    ar_applications.document = @s_document AND
                    ar_applications.application_type <> 'CHECK')
        FROM ar_applications, ar_items, ar_customers, ar_headers
        WHERE ar_headers.document = @s_document AND
            ar_headers.document_type = 'I' AND
            ar_customers.customer = @s_customer AND
            ar_headers.document = ar_applications.document AND
            ar_headers.document_type = ar_applications.document_type AND
            ar_headers.document = ar_items.document AND
            ar_headers.document_type = ar_items.document_type AND
            ar_items.line_type = 'IT'
        GROUP BY ar_headers.bill_customer,
            customer_name,
            ar_headers.account_manager,
            ar_headers.sales_agent,
            item,
            ar_headers.document,
            ar_headers.document_date,
            ar_items.document_line,
            extended_amount
   END

CLOSE commcursor
DEALLOCATE commcursor

SELECT  ar_headers.bill_customer,
        bill_customer_name,
        ar_headers.account_manager,
        ar_headers.sales_agent,
        #ar_commission_rpt.item,
        ar_items.item_description,
        #ar_commission_rpt.document,
        ar_headers.document_date,
        #ar_commission_rpt.document_line,
        last_applied_date,
        #ar_commission_rpt.extended_amount,
        IsNull(cash_applied_amount,0),
        IsNull(credit_applied_amount,0),
        ar_items.account_manager_percent,
        ar_items.sales_agent_percent,
        account_manager_description,
        sales_agent_description

    FROM #ar_commission_rpt LEFT OUTER JOIN sales_agents
      ON #ar_commission_rpt.sales_agent = sales_agents.sales_agent

         LEFT OUTER JOIN account_managers
      ON #ar_commission_rpt.account_manager = account_managers.account_manager,

          ar_items, ar_headers

    WHERE #ar_commission_rpt.document = ar_items.document AND
        #ar_commission_rpt.document_line = ar_items.document_line AND
        ar_items.document_type = 'I' AND
        ar_headers.document = ar_items.document AND
        ar_headers.document_type = ar_items.document_type AND
      ((@as_agentormanager = 'MANAGER' AND
        IsNull(ar_items.account_manager_percent,0) <> 0 AND
        IsNull(#ar_commission_rpt.account_manager,'') <> '' AND
        #ar_commission_rpt.account_manager >= @as_acctmgrbegin AND
        #ar_commission_rpt.account_manager <= @as_acctmgrend) OR
       (@as_agentormanager = 'AGENT' AND
        IsNull(ar_items.sales_agent_percent,0) <> 0 AND
        IsNull(#ar_commission_rpt.sales_agent,'') <> '' AND
        #ar_commission_rpt.sales_agent >= @as_salesagtbegin AND
        #ar_commission_rpt.sales_agent <= @as_salesagtend ))

    ORDER BY ar_headers.account_manager,
        ar_headers.bill_customer,
        #ar_commission_rpt.document,
        #ar_commission_rpt.item

END
GO
