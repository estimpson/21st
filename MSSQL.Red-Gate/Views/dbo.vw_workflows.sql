SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_workflows] AS
SELECT
	*,
	CASE WHEN t1.column_source = 'PostingAccountColumn' THEN 'Y' ELSE 'N' END is_posting_account_workflow
FROM
	(
	SELECT
		'EmployeeAddressChange' workflow,
		CASE WHEN preferences_standard.value = 'U' THEN 'A' ELSE 'I' END inactive,
		'N' sequential,
		'Y' allow_edit_after_approval,
		'N' allow_edit_during_approval,
		'UnitColumn' column_source,
		'EMP ADDRESS CHG' document_type
	FROM
		preferences_standard 
	WHERE
		preference = 'PYEmployeeAddressChangeApprovalBy'
	UNION ALL
	SELECT
		'EmployeeDeductionTypeChange' workflow,
		CASE WHEN preferences_standard.value = 'U' THEN 'A' ELSE 'I' END inactive,
		'N' sequential,
		'Y' allow_edit_after_approval,
		'N' allow_edit_during_approval,
		'UnitColumn' column_source,
		'EMP DED CHG' document_type
	FROM
		preferences_standard 
	WHERE
		preference = 'PYEmployeeDeductionTypeChangeApprovalBy'
	UNION ALL
	SELECT
		'EmployeeDirectDepositChange' workflow,
		CASE WHEN preferences_standard.value = 'U' THEN 'A' ELSE 'I' END inactive,
		'N' sequential,
		'Y' allow_edit_after_approval,
		'N' allow_edit_during_approval,
		'UnitColumn' column_source,
		'EMP DED CHG' document_type
	FROM
		preferences_standard 
	WHERE
		preference = 'PYEmployeeDirectDepositChangeApprovalBy'
	) t1
GO
