SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_gl_profit_loss_summary]
AS
SELECT SUM(gl_cost_transactions.amount) * - 1 AS amount,
       MAX(gl_cost_transactions.period) AS period,
       MAX(gl_cost_transactions.fiscal_year) AS fiscal_year,
       MAX(gl_cost_transactions.ledger) AS ledger,
       document_type,
       document_id1,
       document_id2,
       document_id3

  FROM gl_cost_transactions INNER JOIN ledger_accounts
    ON gl_cost_transactions.fiscal_year = ledger_accounts.fiscal_year
   AND gl_cost_transactions.ledger = ledger_accounts.ledger
   AND gl_cost_transactions.ledger_account = ledger_accounts.ledger_account

                            INNER JOIN chart_of_accounts
    ON ledger_accounts.fiscal_year = chart_of_accounts.fiscal_year
   AND ledger_accounts.coa = chart_of_accounts.coa
   AND ledger_accounts.account = chart_of_accounts.account

 WHERE chart_of_accounts.balance_profit = 'P'
   AND chart_of_accounts.debit_credit_stat <> 'S'
   AND (gl_cost_transactions.update_balances = 'Y'
    OR gl_cost_transactions.update_balances IS NULL)

GROUP BY document_type,
	 document_id1,
	 document_id2,
	 document_id3
GO
