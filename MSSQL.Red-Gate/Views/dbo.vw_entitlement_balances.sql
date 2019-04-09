SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_entitlement_balances] AS
SELECT
	entitlement_balances.entitlement entitlement_type,
	entitlement_balances.employee,
	CONVERT(VARCHAR(5), entitlement_balances.entitle_year) entitlement_year,
	entitlements.description entitlement_type_description,
	employees.employee_first_name + ' ' + employees.employee_last_name employee_name,
	employees.division employee_division,
	employees.location employee_location,
	employees.unit,
	entitlement_balances.amount_accrued_carryover,
	entitlement_balances.amount_accrued,
	entitlement_balances.amount_taken,
	ISNULL(entitlement_balances.amount_accrued_carryover, 0) + ISNULL(entitlement_balances.amount_accrued, 0) - ISNULL(entitlement_balances.amount_taken, 0) amount_balance, 
	entitlement_balances.hours_accrued_carryover,
	entitlement_balances.hours_accrued,
	entitlement_balances.hours_taken,
	ISNULL(entitlement_balances.hours_accrued_carryover, 0) + ISNULL(entitlement_balances.hours_accrued, 0) - ISNULL(entitlement_balances.hours_taken, 0) hours_balance
FROM
	entitlement_balances INNER JOIN
	employees ON
		entitlement_balances.employee = employees.employee INNER JOIN
	entitlements ON
		entitlement_balances.entitlement = entitlements.entitlement
WHERE
	EXISTS (SELECT 1 FROM entitlement_transactions WHERE entitlement_transactions.entitle_year = entitlement_balances.entitle_year AND entitlement_transactions.employee = entitlement_balances.employee AND entitlement_transactions.entitlement = entitlement_balances.entitlement)

GO
