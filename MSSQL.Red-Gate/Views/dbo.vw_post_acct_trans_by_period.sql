SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_post_acct_trans_by_period]
AS
SELECT
	gl_cost_transactions.fiscal_year,
	gl_cost_transactions.ledger,
	gl_cost_transactions.gl_entry,
	gl_cost_transactions.document_type,
	gl_cost_transactions.document_id1,
	gl_cost_transactions.document_line,
	gl_cost_transactions.amount,
	gl_cost_transactions.transaction_date,
	gl_cost_transactions.document_reference1,
	gl_cost_transactions.document_reference2,
	gl_cost_transactions.document_remarks,
	gl_cost_transactions.contract_id,
	gl_cost_transactions.contract_account_id,
	gl_cost_transactions.costrevenue_type_id,
	gl_cost_transactions.document_currency,
	gl_cost_transactions.document_amount,
	gl_cost_transactions.exchange_date,
	gl_cost_transactions.exchange_rate,
	gl_cost_transactions.ledger_account,
	gl_cost_transactions.document_id2,
	gl_cost_transactions.document_id3,
	journal_entries.balance_name,
	journal_entries.document_source,
	journal_entries.period
FROM
	gl_cost_transactions INNER JOIN
	journal_entries ON
		gl_cost_transactions.fiscal_year = journal_entries.fiscal_year AND
		gl_cost_transactions.ledger = journal_entries.ledger AND
		gl_cost_transactions.gl_entry = journal_entries.gl_entry
WHERE
	(gl_cost_transactions.update_balances IS NULL) OR
	(gl_cost_transactions.update_balances = 'Y')
GO
