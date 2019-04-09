SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_payroll_document_summary_ytd] AS
SELECT
	payroll_vouchers.calendar_year,
	payroll_vouchers.employee,
	payroll_documents.document_description basis_description,
	CASE 
		WHEN payroll_voucher_items.document = 'PAY' THEN
			(SELECT check_stub_description FROM pay_types WHERE pay_types.pay_type = payroll_voucher_items.document_type) 
		WHEN payroll_voucher_items.document = 'NCR' THEN
			(SELECT check_stub_description FROM pay_types WHERE pay_types.pay_type = payroll_voucher_items.document_type) 
		WHEN payroll_voucher_items.document = 'DED' THEN
			(SELECT check_stub_description FROM deduction_types WHERE deduction_types.deduction_type = payroll_voucher_items.document_type) 
		WHEN payroll_voucher_items.document = 'TAX' THEN
			(SELECT check_stub_description FROM tax_types WHERE tax_types.tax_type = payroll_voucher_items.document_type) 
		WHEN payroll_voucher_items.document = 'BEN' THEN
			(SELECT check_stub_description FROM benefits WHERE benefits.benefit_type = payroll_voucher_items.document_type) 
		WHEN payroll_voucher_items.document = 'RET' THEN
			(SELECT check_stub_description FROM retirement_plans WHERE retirement_plans.retirement_plan = payroll_voucher_items.document_type) 
		WHEN payroll_voucher_items.document = 'ENT' THEN
			(SELECT check_stub_description FROM entitlements WHERE entitlements.entitlement = payroll_voucher_items.document_type) 
		ELSE '' 
	END AS basis_type_description,
	SUM(payroll_voucher_items.amount) AS document_amount_adjusted,
	SUM(CASE 
			WHEN payroll_voucher_items.payer = 'E' THEN
				CASE 
					WHEN payroll_documents.summation_sign = 'N' THEN 
						payroll_voucher_items.amount * -1 
					ELSE 
						payroll_voucher_items.amount 
					END
			ELSE
				0
		END) AS employee_document_amount,
	payroll_documents.sort_order basis_sort_line
FROM
	payroll_vouchers INNER JOIN
	payroll_voucher_items ON
		payroll_vouchers.payroll_calculation_id = payroll_voucher_items.payroll_calculation_id AND
		payroll_vouchers.voucher = payroll_voucher_items.voucher AND
		payroll_vouchers.voucher_sequence = payroll_voucher_items.voucher_sequence AND
		payroll_vouchers.check_void = payroll_voucher_items.check_void INNER JOIN
	payroll_documents ON 
		payroll_voucher_items.document = payroll_documents.document
WHERE
	ISNULL(check_number, 0) <> 0 AND
	ISNULL(payroll_voucher_items.update_ytd_balances, 'N') = 'Y'
GROUP BY
	payroll_vouchers.calendar_year, 
	payroll_vouchers.employee, 
	payroll_voucher_items.document,
	payroll_voucher_items.document_type,
	payroll_documents.document_description, 
	payroll_documents.sort_order
GO
