SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_payroll_checks] AS
SELECT
	ISNULL(payroll_cycles.payroll_cycle, payroll_vouchers.payroll_calculation_id) payroll_cycle,
	payroll_vouchers.employee,
	bank_register.bank_alias,
	bank_register.document_number,
	bank_register.check_void_nsf,
	bank_register.document_class,
	CASE WHEN bank_register.check_void_nsf = 'V' THEN -1 ELSE 1 END multiplier
FROM
	bank_register INNER JOIN
	payroll_vouchers ON
		bank_register.bank_alias = payroll_vouchers.bank_alias AND
		bank_register.document_number = payroll_vouchers.check_number AND
		bank_register.check_void_nsf = payroll_vouchers.check_void LEFT OUTER JOIN
	payroll_cycles ON
		payroll_vouchers.payroll_calculation_id = payroll_cycles.payroll_calculation_id
WHERE
	bank_register.document_class = 'PY' 
GROUP BY
	payroll_cycles.payroll_cycle, 
	payroll_vouchers.payroll_calculation_id,
	payroll_vouchers.employee,
	bank_register.bank_alias,
	bank_register.document_number,
	bank_register.check_void_nsf,
	bank_register.document_class
GO
