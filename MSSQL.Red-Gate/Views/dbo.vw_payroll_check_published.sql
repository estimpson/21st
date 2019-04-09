SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_payroll_check_published] AS
SELECT
	vw_payroll_checks.payroll_cycle,
	vw_payroll_checks.employee,
	bank_register.document_date,
	YEAR(bank_register.document_date) calendar_year,
	bank_register.bank_account,
	CONVERT(VARCHAR(25), bank_register.document_number) check_number,
	bank_register.document_type,
	bank_register.direct_deposit direct_deposit,
	bank_register.dd_account_type direct_deposit_account_type,
	bank_register.bank_account bank_account_number,
	bank_register.transit_routing_no transit_routing_number,
	bank_register.document_amount * vw_payroll_checks.multiplier document_amount,
	bank_register.document_amount document_amount_adjusted,
	bank_register_published.file_id
FROM
	bank_register_published INNER JOIN
	bank_register ON
		bank_register_published.bank_alias = bank_register.bank_alias AND
		bank_register_published.document_class = bank_register.document_class AND
		bank_register_published.document_number = bank_register.document_number AND
		bank_register_published.check_void_nsf = bank_register.check_void_nsf INNER JOIN
	vw_payroll_checks ON
		bank_register_published.bank_alias = vw_payroll_checks.bank_alias AND
		bank_register_published.document_class = vw_payroll_checks.document_class AND
		bank_register_published.document_number = vw_payroll_checks.document_number AND
		bank_register_published.check_void_nsf = vw_payroll_checks.check_void_nsf 
WHERE
	bank_register.document_type <> 'V'
GO
