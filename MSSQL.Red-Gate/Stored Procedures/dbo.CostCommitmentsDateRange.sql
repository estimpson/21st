SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CostCommitmentsDateRange]
       @as_begcostid varchar(25),
       @as_endcostid varchar(25),
       @as_begcostsub varchar(25),
       @as_endcostsub varchar(25),
       @as_begaccount varchar(25),
       @as_endaccount varchar(25),
       @as_begcostidclass varchar(25),
       @as_endcostidclass varchar(25),
       @as_begdocumentid1 varchar(25),
       @as_enddocumentid1 varchar(25),
       @ad_asofdate datetime,
       @as_status char(1),
       @as_detailorsummary char(2),
       @as_userid varchar(25),
       @ad_begindate datetime

AS

BEGIN

-- NOTE:  w_create_sql_command_files looks for char(300) or varchar(300)
--        in the final selects for S2 and S4 and changes the length from
--        300 to 170 for ASE.  This was necessary after the 06-Apr-2007 mod.
--        A length of 300 gave the error "Select error: The current query
--        would generate a key size of 726 for a work table.  This exceeds
--        the maximum allowable limit of 600."  If the 300 is changed here,
--        it must also be changed in w_create_sql_command_files_edit.

-- 08-Jul-2013 This SP was previously named CostCommitments.  New name is
--             CostCommitmentsDateRange and it has been modified to use both a
--             begin date and an as of date when selecting transactions.
--             It is not an error that the updates for the uncommitments
--             don't use the begin date.  Because of PO year end, the
--             uncommitments may actually be in a prior year but we need
--             to pick them up in the same year we pick up the PO.

-- 13-Mar-2013 Modified to get gl_cost_transactions.transaction_date instead of
--             gl_cost_transactions.exchange_date for CMC.

-- 30-Jan-2010 Removed ap_items from the Update that uses the APINV GL cost
--             transactions to get the uncommitment transactions for the PO's
--             that commit to GL.

-- 07-May-2009 Don't return rows to the income statements if all of the amounts
--             are zero.

-- 24-Feb-2009 Added logic to use the uncommitment transactions to determine
--             the received amount and the invoiced amount for PO's that
--             commit to GL and the actual transactions for PO's that
--             that do not commit to GL.  Previously, we always used
--             the actual transactions.

-- 04-Oct-2008 Added index hint to query for actual transactions.

-- 12-Feb-2008 1. Added coa to the temporary tables and cost_coa.coa to all
--                joins of cost_coa.
--             2. Added beginning and ending cost ID class.

-- 06-Apr-2007 Added profit group and profit group description to the values
--             returned to the income statements.

-- 15-Dec-2006 Modified WHERE clauses that referred to status to use
--               (@as_status = 'B' OR cost_identifiers.status = @as_status) AND
--             instead of
--               ((cost_identifiers.status = 'C' and @as_status in ('C','B')) OR
--                (cost_identifiers.status = 'O' and @as_status in ('O','B'))) AND
--             because the original syntax brought down AdaptiveServer at
--             Travel Adventures.

-- 06-Sep-2006 Changed *= syntax to LEFT OUTER JOIN syntax.

-- 29-Dec-2005 Modified to return cost_id_description with a length of 300
--             instead of 400.  ASE gave error of key size of 600 exceeded
--             with 400.

-- 18-Nov-2005 When incorporating the below Oct mods to custom reports
--             for Empire, they need coa_level_2 for the income statements.
--             So this stored procedure has been modified to return those
--             values for S2 and S4 for the standard costing, but the standard
--             inquiries and reports do not use them.

-- 27-Oct-2005 Added 2 new columns to #cost_trans for revenue actual and
--             budget amounts that are returned for S1 and S3.

-- 24-Oct-2005 Modified for new inquiries that pass detailorsummary values
--             S1, S2, S3, S4 to determine the level of summary for the
--             final select.
--             Cost reports now pass detailorsummary values of S1, S2, S3, S4,
--             the same as the corresponding inquiries.
--             S1 is passed from the Cost ID Summary inquiry and report
--             S2 is passed from the Cost ID Income Statement inquiry and report
--             S3 is passed from the Cost Revision Summary inquiry and report
--             S4 is passed from the Cost Revision Income Statement inquiry and report

-- 22-Mar-2005 Added order by to final select.

-- 17-Dec-2004 Added table cost_id_security to secure by Cost ID and
--             by Cost ID Security Company.

-- 24-Feb-2004 Don't include PO gl_cost_transactions with a non-blank
--             document_id2. They are created by the PO Year End program
--             to "hold" the prior year commitments.

-- 14-Jun-2002 Replaced gl_cost_transactions.transaction_date with
--             gl_cost_transactions.exchange_date. The transaction
--             date is often a document date and doesn't have to be in
--             the period. The exchange_date is the gl_date and will
--             always be in the period.
DECLARE @campusvueintegrated CHAR(1)

	/* Need to read a Preference to find out if this is CMC */
	SELECT @campusvueintegrated = IsNull(value,'')
	    FROM preferences_standard
	    WHERE preference = 'CampusVueIntegrated'
	IF @@rowcount = 0 OR @campusvueintegrated = '' SELECT @campusvueintegrated = 'N'

CREATE TABLE #cost_po_trans
   (cost_id               varchar(25) NULL,
    cost_sub              varchar(25) NULL,
    coa                   varchar(40) NULL,
    account               varchar(25) NULL,
    cost_account          varchar(25) NULL,
    transaction_date      datetime NULL,
    document_id1          varchar(25) NOT NULL,
    document_line         smallint,
    document_reference1   varchar(50) NULL,
    document_reference2   varchar(50) NULL,
    po_amount             dec(18,6) NULL,
    received_amount       dec(18,6) NULL,
    invoiced_amount       dec(18,6) )

CREATE TABLE #cost_trans
   (cost_id               varchar(25) NULL,
    cost_sub              varchar(25) NULL,
    coa                   varchar(40) NULL,
    account               varchar(25) NULL,
    transaction_date      datetime NULL,
    document_id1          varchar(25) NOT NULL,
    document_reference1   varchar(50) NULL,
    document_reference2   varchar(50) NULL,
    document_remarks      text NULL,
    committed_amount      dec(18,6) NULL,
    actual_amount         dec(18,6) NULL,
    budget_amount         dec(18,6) NULL,
    revenue_actual_amount dec(18,6) NULL,
    revenue_budget_amount dec(18,6) NULL)

CREATE TABLE #cost_trans_sum
   (cost_id               varchar(25) NULL,
    cost_sub              varchar(25) NULL,
    coa                   varchar(40) NULL,
    account               varchar(25) NULL,
    transaction_date      datetime NULL,
    committed_amount      dec(18,6) NULL,
    actual_amount         dec(18,6) NULL,
    budget_amount         dec(18,6) NULL)

/* Group all of the GL cost trans for a PO line/cost account. There will
   be multiple GL cost trans if a PO line has the same cost account
   with multiple ledger accounts. Can't group by the text columns so we'll
   have to add those in later.   */
INSERT INTO #cost_po_trans
  SELECT cost_accounts.cost_id,
         cost_accounts.cost_sub,
         cost_accounts.coa,
         cost_accounts.account,
         gl_cost_transactions.contract_account_id,
	 CASE WHEN @campusvueintegrated = 'Y' THEN gl_cost_transactions.transaction_date ELSE gl_cost_transactions.exchange_date END,
         gl_cost_transactions.document_id1,
         gl_cost_transactions.document_line,
         gl_cost_transactions.document_reference1,
         gl_cost_transactions.document_reference2,
         sum(gl_cost_transactions.amount),
         0, 0
    FROM gl_cost_transactions,
         cost_accounts,
         cost_identifiers,
         cost_id_security
   WHERE cost_accounts.cost_id = cost_identifiers.cost_id and
         cost_accounts.cost_sub = cost_identifiers.cost_sub and
         gl_cost_transactions.contract_account_id = cost_accounts.cost_account and
         gl_cost_transactions.exchange_date <= @ad_asofdate and
         gl_cost_transactions.exchange_date >= @ad_begindate and
         gl_cost_transactions.document_type = 'PO' and
         gl_cost_transactions.document_id1 >= @as_begdocumentid1 and
         gl_cost_transactions.document_id1 <= @as_enddocumentid1 and
         gl_cost_transactions.document_id2 = '' and
         cost_accounts.cost_id >= @as_begcostid and
         cost_accounts.cost_id <= @as_endcostid and
         cost_accounts.cost_sub >= @as_begcostsub and
         cost_accounts.cost_sub <= @as_endcostsub and
         cost_accounts.account >= @as_begaccount and
         cost_accounts.account <= @as_endaccount and
         IsNull(cost_identifiers.cost_id_class,'') >= @as_begcostidclass and
         IsNull(cost_identifiers.cost_id_class,'') <= @as_endcostidclass and
         (@as_status = 'B' OR cost_identifiers.status = @as_status) AND
         cost_id_security.user_id = @as_userid AND
         cost_id_security.cost_id = cost_identifiers.cost_id
GROUP BY cost_accounts.cost_id,
         cost_accounts.cost_sub,
         cost_accounts.coa,
         cost_accounts.account,
         gl_cost_transactions.contract_account_id,
	 CASE WHEN @campusvueintegrated = 'Y' THEN gl_cost_transactions.transaction_date ELSE gl_cost_transactions.exchange_date END,
         gl_cost_transactions.document_id1,
         gl_cost_transactions.document_line,
         gl_cost_transactions.document_reference1,
         gl_cost_transactions.document_reference2
ORDER BY cost_accounts.cost_id ASC,
         cost_accounts.cost_sub ASC,
         cost_accounts.account ASC,
         CASE WHEN @campusvueintegrated = 'Y' THEN gl_cost_transactions.transaction_date ELSE gl_cost_transactions.exchange_date END ASC,
         gl_cost_transactions.document_id1 ASC,
         gl_cost_transactions.document_line ASC

/* Sum up the receipts for the PO line/cost account. If the item
   is not expensed on receipt, there won't be any BILL OF LADING
   gl cost trans. Use the Actual transactions for the PO's that
   did not commit to GL */
UPDATE #cost_po_trans
   SET received_amount =
    IsNull((SELECT Sum(amount)
      FROM gl_cost_transactions glc
      WHERE glc.document_type = 'BILL OF LADING' AND
            glc.document_id1 = #cost_po_trans.document_id1 AND
            glc.document_line = #cost_po_trans.document_line AND
            glc.contract_account_id = #cost_po_trans.cost_account AND
            glc.exchange_date <= @ad_asofdate AND
            glc.update_balances = 'Y'),0)
  FROM po_headers
 WHERE po_headers.purchase_order = #cost_po_trans.document_id1
   AND IsNull(commit_to_gl,'N') = 'N'

/* Use the uncommitment transactions for the PO's that commited to GL */
UPDATE #cost_po_trans
   SET received_amount =
    IsNull((SELECT Sum(amount)
      FROM gl_cost_transactions glc
      WHERE glc.document_type = 'PORCV' AND
            glc.document_id1 = #cost_po_trans.document_id1 AND
            glc.document_line = #cost_po_trans.document_line AND
            glc.contract_account_id = #cost_po_trans.cost_account AND
            glc.exchange_date <= @ad_asofdate AND
            glc.update_balances = 'Y'),0) * -1.0
  FROM po_headers
 WHERE po_headers.purchase_order = #cost_po_trans.document_id1
   AND IsNull(commit_to_gl,'N') = 'Y'

/* Sum up the invoices for the PO line/cost account. If the PO line
   was expensed on receipt, the invoice line won't have a cost account
   and, therefore, won't get double counted in the received amount
   and the invoiced amount. Use the Actual transactions for the PO's that
   did not commit to GL */
UPDATE #cost_po_trans
   SET invoiced_amount =
    IsNull((SELECT Sum(amount)
      FROM gl_cost_transactions glc, ap_items
      WHERE glc.contract_account_id = #cost_po_trans.cost_account AND
            glc.exchange_date <= @ad_asofdate AND
            glc.document_type in ('AP Invoice','AP Credit Memo', 'AP INVOICE', 'AP CREDIT MEMO') AND
            glc.update_balances = 'Y' AND
            ap_items.invoice_cm = glc.document_id1 AND
            ap_items.vendor = glc.document_id2 AND
            ap_items.inv_cm_flag = glc.document_id3 AND
            ap_items.inv_cm_line = glc.document_line AND
            IsNull(ap_items.purchase_order,'') = #cost_po_trans.document_id1 AND
            IsNull(ap_items.purchase_order_line,0) = #cost_po_trans.document_line AND
            ap_items.line_type='PL'),0)
  FROM po_headers
 WHERE po_headers.purchase_order = #cost_po_trans.document_id1
   AND IsNull(commit_to_gl,'N') = 'N'

/* Use the uncommitment transactions for the PO's that commited to GL */
UPDATE #cost_po_trans
   SET invoiced_amount =
    IsNull((SELECT Sum(amount)
      FROM gl_cost_transactions glc
      WHERE glc.document_type = 'APINV' AND
            glc.document_id1 = #cost_po_trans.document_id1 AND
            glc.document_line = #cost_po_trans.document_line AND
            glc.contract_account_id = #cost_po_trans.cost_account AND
            glc.exchange_date <= @ad_asofdate AND
            glc.update_balances = 'Y'),0) * -1.0
  FROM po_headers
 WHERE po_headers.purchase_order = #cost_po_trans.document_id1
   AND IsNull(commit_to_gl,'N') = 'Y'

/* Delete the rows that would give a commitment amount of zero or less. */
DELETE
  FROM #cost_po_trans
 WHERE po_amount <= received_amount + invoiced_amount

IF @as_detailorsummary = 'D'
  BEGIN
    /* User wants the PO commitment transactions. */
    INSERT INTO #cost_trans
      SELECT #cost_po_trans.cost_id,
             #cost_po_trans.cost_sub,
             #cost_po_trans.coa,
             #cost_po_trans.account,
             #cost_po_trans.transaction_date,
             #cost_po_trans.document_id1,
             #cost_po_trans.document_reference1,
             #cost_po_trans.document_reference2,
             po_items.item_description document_remarks,
             #cost_po_trans.po_amount -
                 #cost_po_trans.received_amount -
                 #cost_po_trans.invoiced_amount,
             0, 0, 0, 0
        FROM #cost_po_trans LEFT OUTER JOIN po_items
          ON po_items.purchase_order = #cost_po_trans.document_id1 AND
             po_items.po_line = #cost_po_trans.document_line
  END
ELSE
  BEGIN
    /* User is doing a cost revision or cost ID summary. We'll need
       actual and commitment amounts. First put a primary key on the
       temporary table of PO transactions to speed up the subquery
       against this table.                                           */
    CREATE INDEX pk_cost_po_trans ON #cost_po_trans (cost_account)

   /* Need to do the next insert into an intermediate temporary table
      that doesn't contain document_remarks because Sybase does not
      allow a select with a temporary table that contains a text column
      that has an order by. */
   INSERT INTO #cost_trans_sum
      SELECT cost_accounts.cost_id,
             cost_accounts.cost_sub,
             cost_accounts.coa,
             cost_accounts.account,
             GetDate(),
             IsNull((SELECT Sum(po_amount - received_amount - invoiced_amount)
                       FROM #cost_po_trans
                      WHERE #cost_po_trans.cost_account = cost_accounts.cost_account),0),
             IsNull((SELECT Sum(amount)
                       FROM gl_cost_transactions with (index(glcosttrans_cost_account)), journal_entries
                      WHERE gl_cost_transactions.contract_account_id = cost_accounts.cost_account AND
                            gl_cost_transactions.exchange_date >= @ad_begindate and
                            gl_cost_transactions.exchange_date <= @ad_asofdate AND
                            gl_cost_transactions.update_balances='Y' AND
                            journal_entries.fiscal_year=gl_cost_transactions.fiscal_year AND
                            journal_entries.ledger=gl_cost_transactions.ledger AND
                            journal_entries.gl_entry=gl_cost_transactions.gl_entry AND
                            journal_entries.balance_name='ACTUAL'),0)
             + IsNull((SELECT Sum(amount)
                       FROM gl_cost_transactions
                      WHERE gl_cost_transactions.contract_account_id = cost_accounts.cost_account AND
                            gl_cost_transactions.exchange_date >= @ad_begindate and
                            gl_cost_transactions.exchange_date <= @ad_asofdate AND
                            gl_cost_transactions.document_id2='ACTUAL' AND
                            gl_cost_transactions.document_type = 'COST ACCOUNT'),0),
             cost_accounts.budget
        FROM cost_accounts,
             cost_identifiers,
             cost_id_security
       WHERE cost_accounts.cost_id = cost_identifiers.cost_id AND
             cost_identifiers.cost_sub = cost_accounts.cost_sub AND
             cost_accounts.cost_id >= @as_begcostid AND
             cost_accounts.cost_id <= @as_endcostid AND
             cost_accounts.cost_sub >= @as_begcostsub AND
             cost_accounts.cost_sub <= @as_endcostsub AND
             IsNull(cost_identifiers.cost_id_class,'') >= @as_begcostidclass and
             IsNull(cost_identifiers.cost_id_class,'') <= @as_endcostidclass and
            (@as_status = 'B' OR cost_identifiers.status = @as_status) AND
             cost_id_security.user_id = @as_userid AND
             cost_id_security.cost_id = cost_identifiers.cost_id
    ORDER BY cost_accounts.cost_id ASC,
             cost_accounts.cost_sub ASC

    /* now put the data from #cost_trans_sum into #cost_trans
       but if we are returning data to a summary S1 or S3, then we
       need to put the amount in one of the expense or revenue columns */
    IF @as_detailorsummary = 'S1' or @as_detailorsummary = 'S3'
      BEGIN
        INSERT INTO #cost_trans
         SELECT cost_id,
                 cost_sub,
                 coa,
                 account,
                 transaction_date,
                 '',
                 '',
                 '',
                 '',
                 committed_amount,
                 actual_amount,
                 budget_amount,
                 0,
                 0
            FROM #cost_trans_sum
           WHERE exists (select 1 from cost_coa where cost_coa.account = #cost_trans_sum.account
                                                   and cost_coa.coa = #cost_trans_sum.coa
                                                   and cost_coa.account_type = 'E')
               OR not exists (select 1 from cost_coa where cost_coa.account = #cost_trans_sum.account
                                                       and cost_coa.coa = #cost_trans_sum.coa)
        INSERT INTO #cost_trans
         SELECT cost_id,
                 cost_sub,
                 coa,
                 account,
                 transaction_date,
                 '',
                 '',
                 '',
                 '',
                 0,
                 0,
                 0,
                 actual_amount,
                 budget_amount
            FROM #cost_trans_sum
           WHERE exists (select 1 from cost_coa where cost_coa.account = #cost_trans_sum.account
                                                   and cost_coa.coa = #cost_trans_sum.coa
                                                   and cost_coa.account_type = 'R')
      END
    ELSE
      BEGIN
        INSERT INTO #cost_trans
         SELECT cost_id,
                 cost_sub,
                 coa,
                 account,
                 transaction_date,
                 '',
                 '',
                 '',
                 '',
                 committed_amount,
                 actual_amount,
                 budget_amount,
                 0,
                 0
            FROM #cost_trans_sum
           WHERE committed_amount <> 0 OR actual_amount <> 0 OR budget_amount <> 0
      END
  END

IF @as_detailorsummary = 'S1'
  BEGIN
    /* S1 does the return for the Cost ID Summary inquiry and report*/
    SELECT #cost_trans.cost_id,
           CONVERT(CHAR(300),cost_identifiers.description) cost_id_description,
           SUM( #cost_trans.committed_amount ),
           SUM( #cost_trans.actual_amount ),
           SUM (#cost_trans.budget_amount * cost_identifiers.percent_complete / 100 ),
           SUM( #cost_trans.revenue_actual_amount ),
           SUM (#cost_trans.revenue_budget_amount * cost_identifiers.percent_complete / 100 ),
           cost_identifiers.customer,
           cost_identifiers.start_date,
           cost_identifiers.closed_date
      FROM #cost_trans, cost_identifiers
     WHERE cost_identifiers.cost_id = #cost_trans.cost_id AND
           cost_identifiers.cost_sub =
               (select MIN( cost_sub ) from cost_identifiers ci3 where ci3.cost_id = #cost_trans.cost_id)
    GROUP BY #cost_trans.cost_id,
             CONVERT(CHAR(300),cost_identifiers.description),
             cost_identifiers.customer,
             cost_identifiers.start_date,
             cost_identifiers.closed_date
    ORDER BY #cost_trans.cost_id
  END

IF @as_detailorsummary = 'S2'
  BEGIN
    /* S2 does the return for the Cost ID Income Statement inquiry and report */
    SELECT #cost_trans.cost_id,
           #cost_trans.account,
           CONVERT(CHAR(300),cost_identifiers.description) cost_id_description,
           cost_coa.account_description,
           cost_coa.profit_group,
           cost_coa.profit_group_description,
           cost_coa.coa_level_1,
           cost_coa.coa_level_1_description,
           cost_coa.coa_level_2,
           cost_coa.coa_level_2_description,
           cost_coa.account_type,
           SUM( #cost_trans.committed_amount ),
           SUM( #cost_trans.actual_amount ),
           SUM (#cost_trans.budget_amount * cost_identifiers.percent_complete / 100 )
      FROM #cost_trans LEFT OUTER JOIN cost_coa
        ON #cost_trans.coa = cost_coa.coa
       AND #cost_trans.account = cost_coa.account,
           cost_identifiers
     WHERE cost_identifiers.cost_id = #cost_trans.cost_id AND
           cost_identifiers.cost_sub =
               (select MIN( cost_sub ) from cost_identifiers ci3 where ci3.cost_id = #cost_trans.cost_id)
    GROUP BY #cost_trans.cost_id,
             #cost_trans.account,
             CONVERT(CHAR(300),cost_identifiers.description),
             cost_coa.account_description,
             cost_coa.profit_group,
             cost_coa.profit_group_description,
             cost_coa.coa_level_1,
             cost_coa.coa_level_1_description,
             cost_coa.coa_level_2,
             cost_coa.coa_level_1,
             cost_coa.coa_level_1_description,
             cost_coa.coa_level_2,
             cost_coa.coa_level_2_description,
             cost_coa.account_type
    ORDER BY #cost_trans.cost_id,
             cost_coa.profit_group,
             cost_coa.coa_level_1,
             cost_coa.coa_level_2,
             #cost_trans.account
  END

IF @as_detailorsummary = 'S3'
  BEGIN
    /* S3 does the return for the Cost Revision Summary inquiry and report*/
    SELECT #cost_trans.cost_id,
           #cost_trans.cost_sub,
           CONVERT(CHAR(300),cost_identifiers.description) cost_id_description,
           SUM( #cost_trans.committed_amount ),
           SUM( #cost_trans.actual_amount ),
           SUM (#cost_trans.budget_amount * cost_identifiers.percent_complete / 100 ),
           SUM( #cost_trans.revenue_actual_amount ),
           SUM (#cost_trans.revenue_budget_amount * cost_identifiers.percent_complete / 100 ),
           cost_identifiers.customer,
           cost_identifiers.start_date,
           cost_identifiers.closed_date
      FROM #cost_trans, cost_identifiers
     WHERE cost_identifiers.cost_id = #cost_trans.cost_id AND
           cost_identifiers.cost_sub = #cost_trans.cost_sub
    GROUP BY #cost_trans.cost_id,
             #cost_trans.cost_sub,
             CONVERT(CHAR(300),cost_identifiers.description),
             cost_identifiers.customer,
             cost_identifiers.start_date,
             cost_identifiers.closed_date
    ORDER BY #cost_trans.cost_id,
             #cost_trans.cost_sub
  END

IF @as_detailorsummary = 'S4'
  BEGIN
    /* S4 does the return for the Cost Revision Income Statement inquiry and report */
    SELECT #cost_trans.cost_id,
           #cost_trans.cost_sub,
           #cost_trans.account,
           CONVERT(CHAR(300),cost_identifiers.description) cost_id_description,
           cost_coa.account_description,
           cost_coa.profit_group,
           cost_coa.profit_group_description,
           cost_coa.coa_level_1,
           cost_coa.coa_level_1_description,
           cost_coa.coa_level_2,
           cost_coa.coa_level_2_description,
           cost_coa.account_type,
           SUM( #cost_trans.committed_amount ),
           SUM( #cost_trans.actual_amount ),
           SUM (#cost_trans.budget_amount * cost_identifiers.percent_complete / 100 )
      FROM #cost_trans LEFT OUTER JOIN cost_coa
        ON #cost_trans.coa = cost_coa.coa
       AND #cost_trans.account = cost_coa.account,
           cost_identifiers
     WHERE cost_identifiers.cost_id = #cost_trans.cost_id AND
           cost_identifiers.cost_sub = #cost_trans.cost_sub
    GROUP BY #cost_trans.cost_id,
             #cost_trans.cost_sub,
             #cost_trans.account,
             CONVERT(CHAR(300),cost_identifiers.description),
             cost_coa.account_description,
             cost_coa.profit_group,
             cost_coa.profit_group_description,
             cost_coa.coa_level_1,
             cost_coa.coa_level_1_description,
             cost_coa.coa_level_2,
             cost_coa.coa_level_2_description,
             cost_coa.account_type
    ORDER BY #cost_trans.cost_id,
             #cost_trans.cost_sub,
             cost_coa.profit_group,
             cost_coa.coa_level_1,
             cost_coa.coa_level_2,
             #cost_trans.account
  END

IF @as_detailorsummary = 'D' or @as_detailorsummary = 'S'
  BEGIN
    SELECT #cost_trans.cost_id,
           #cost_trans.cost_sub,
           #cost_trans.account,
           cost_identifiers.description cost_id_description,
           cost_coa.account_description,
           #cost_trans.transaction_date,
           #cost_trans.document_id1,
           #cost_trans.document_reference1,
           #cost_trans.document_reference2,
           #cost_trans.document_remarks,
           #cost_trans.committed_amount,
           #cost_trans.actual_amount,
           #cost_trans.budget_amount,
           cost_identifiers.customer,
           cost_identifiers.start_date,
           cost_identifiers.closed_date,
           cost_identifiers.percent_complete
      FROM #cost_trans LEFT OUTER JOIN cost_coa
        ON #cost_trans.coa = cost_coa.coa
       AND #cost_trans.account = cost_coa.account,
           cost_identifiers
     WHERE cost_identifiers.cost_id = #cost_trans.cost_id AND
           cost_identifiers.cost_sub = #cost_trans.cost_sub
    ORDER BY #cost_trans.cost_id,
             #cost_trans.cost_sub,
             #cost_trans.account,
             #cost_trans.transaction_date,
             #cost_trans.document_id1
  END
END
GO
