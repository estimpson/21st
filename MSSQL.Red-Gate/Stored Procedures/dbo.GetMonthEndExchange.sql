SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetMonthEndExchange] @as_fiscalyear varchar(5),
                                     @as_ledger varchar(40),
                                     @as_currency varchar(25),
                                     @as_balancename varchar(25),
                                     @ai_period int
AS

-- 06-Sep-2006 Removed left outer join of gl_cost_transactions to
--             journal_entries. Only want gl_cost_transactions that
--             match the balance name so we have to be able to join
--             to journal_entries.

-- 06-Oct-2003 Modified to only include balance sheet accounts.

-- 12-Mar-2002 Modified to work with separate gain and loss accounts.

BEGIN

  /* create a temporary table to hold those accounts that we need to process
     at month end for currency exchange purposes */
  CREATE TABLE #gl_me_accts
        (fiscal_year VARCHAR(5) NULL,
         ledger VARCHAR(40) NULL,
         ledger_account VARCHAR(50) NULL,
         gain_ledger_account VARCHAR(50) NULL,
         loss_ledger_account VARCHAR(50) NULL)

  /* create a temporary table to hold the summed totals from
     gl_cost_transactions based on accounts that were selected into
     #gl_me_accts */
  CREATE TABLE #gl_me_totals
        (fiscal_year VARCHAR(5) NULL,
         ledger VARCHAR(40) NULL,
         ledger_account VARCHAR(50) NULL,
         gain_ledger_account VARCHAR(50) NULL,
         loss_ledger_account VARCHAR(50) NULL,
         posted_amount DEC(18,6),
         document_amount DEC(18,6))

  /*  Now populate the temp account table with the appropriate accounts
      (accounts that have a gain/loss account specified)  */
  INSERT INTO #gl_me_accts
    SELECT fiscal_year,ledger,ledger_account,exchange_gain_ledger_account,
           exchange_loss_ledger_account
      FROM ledger_accounts
     WHERE fiscal_year = @as_fiscalyear AND ledger = @as_ledger AND
           IsNull(exchange_gain_ledger_account,'') <> '' AND
           ledger_accounts.balance_profit = 'B'

  /*  Use this account table to sum gl/cost transactions  */
  INSERT INTO #gl_me_totals
    SELECT glcost.fiscal_year,
           glcost.ledger,
           glcost.ledger_account,
           #gl_me_accts.gain_ledger_account,
           #gl_me_accts.loss_ledger_account,
           IsNull(SUM(glcost.amount),0),
           IsNull(SUM(glcost.document_amount),0)
      FROM #gl_me_accts,
           gl_cost_transactions glcost,
           journal_entries jes
     WHERE glcost.fiscal_year = #gl_me_accts.fiscal_year AND
           glcost.ledger = #gl_me_accts.ledger AND
           glcost.ledger_account = #gl_me_accts.ledger_account AND
           glcost.document_currency = @as_currency AND
           glcost.period <= @ai_period AND
           glcost.update_balances = 'Y' AND

           (glcost.fiscal_year = jes.fiscal_year AND
            glcost.ledger = jes.ledger AND
            glcost.gl_entry = jes.gl_entry AND
            jes.balance_name = @as_balancename)

   GROUP BY glcost.fiscal_year, glcost.ledger, glcost.ledger_account,
           #gl_me_accts.gain_ledger_account,
           #gl_me_accts.loss_ledger_account

  SELECT * FROM #gl_me_totals
END
GO
