SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_approvers_posting_account] AS
SELECT
	t1.workflow, 
	t1.approver,
	t1.document_id1, 
	t1.document_id2, 
	t1.document_id3, 
	t1.document_type,
	t1.allow_edit_during_approval,
	t1.reapprove_on_edit,
	t1.approver_sequence,
	t1.priority,
	t1.break_point,
	t1.inactive,
	SUM(t1.ledger_amount) AS ledger_amount
FROM
	(SELECT 
		signature_list_workflows.workflow, 
		signature_lists.approver,
		signature_lists.breakpoint break_point,
		gl_cost_transactions.document_id1, 
		gl_cost_transactions.document_id2, 
		gl_cost_transactions.document_id3, 
		gl_cost_transactions.document_type,
		'A' inactive,
		'Y' AS allow_edit_during_approval, 
		'Y' AS reapprove_on_edit, 
		MIN(signature_lists.approver_sequence) AS approver_sequence, 
		MIN(signature_lists.priority) AS priority, 
		ABS(SUM(gl_cost_transactions.amount)) AS ledger_amount
	FROM   
		signature_lists INNER JOIN    
		signature_list_workflows ON
			signature_lists.fiscal_year = signature_list_workflows.fiscal_year AND
			signature_lists.ledger = signature_list_workflows.ledger AND
			signature_lists.signature_list = signature_list_workflows.signature_list INNER JOIN
		signature_list_accounts ON 
			signature_lists.fiscal_year = signature_list_accounts.fiscal_year AND
			signature_lists.ledger = signature_list_accounts.ledger AND
			signature_lists.signature_list = signature_list_accounts.signature_list INNER JOIN
		ledger_accounts ON 
			ledger_accounts.fiscal_year = signature_list_accounts.fiscal_year AND 
			ledger_accounts.ledger = signature_list_accounts.ledger AND 
			ledger_accounts.organization >= signature_list_accounts.beginning_organization AND 
			ledger_accounts.organization <= signature_list_accounts.ending_organization AND 
			ledger_accounts.account >= signature_list_accounts.beginning_account AND 
			ledger_accounts.account <= signature_list_accounts.ending_account INNER JOIN
		gl_cost_transactions ON 
			gl_cost_transactions.fiscal_year = ledger_accounts.fiscal_year AND 
			gl_cost_transactions.ledger = ledger_accounts.ledger AND 
			gl_cost_transactions.ledger_account = ledger_accounts.ledger_account
	WHERE
		gl_cost_transactions.document_line <> 0
	GROUP BY 
		signature_list_workflows.workflow, 
		signature_lists.approver,
		signature_lists.breakpoint,
		gl_cost_transactions.document_id1, 
		gl_cost_transactions.document_id2, 
		gl_cost_transactions.document_id3, 
		gl_cost_transactions.document_type) t1
WHERE
	t1.break_point <= t1.ledger_amount
GROUP BY
	t1.workflow, 
	t1.approver,
	t1.document_id1, 
	t1.document_id2, 
	t1.document_id3, 
	t1.document_type,
	t1.allow_edit_during_approval,
	t1.reapprove_on_edit,
	t1.approver_sequence,
	t1.priority,
	t1.break_point,
	t1.inactive 

GO
