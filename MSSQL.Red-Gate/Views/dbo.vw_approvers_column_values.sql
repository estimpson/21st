SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_approvers_column_values] AS
SELECT
	signature_lists.fiscal_year,
	signature_lists.ledger,
	signature_lists.approver,
	signature_lists.approver_sequence,
	signature_lists.breakpoint break_point,
	'Y' allow_edit_during_approval,
	signature_lists.priority,
	'Y' reapprove_on_edit,
	'A' inactive,
	signature_list_workflows.workflow,
	signature_list_workflows.column_source,
	signature_list_accounts.column_value
FROM
	signature_lists INNER JOIN
	signature_list_workflows ON
		signature_lists.fiscal_year = signature_list_workflows.fiscal_year AND
		signature_lists.ledger = signature_list_workflows.ledger AND
		signature_lists.signature_list = signature_list_workflows.signature_list INNER JOIN
	signature_list_accounts ON
		signature_lists.fiscal_year = signature_list_accounts.fiscal_year AND
		signature_lists.ledger = signature_list_accounts.ledger AND
		signature_lists.signature_list = signature_list_accounts.signature_list
WHERE
	ISNULL(signature_list_workflows.list_uses_accounts, 'Y') = 'N'

GO
