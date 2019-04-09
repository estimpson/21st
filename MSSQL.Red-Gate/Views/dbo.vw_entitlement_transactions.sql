SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_entitlement_transactions] AS
SELECT
	entitlement_transactions.employee,
	entitlement_transactions.transaction_date entitlement_transaction_date,
	entitlement_transactions.transaction_type entitlement_transaction_type,
	entitlement_transactions.entitlement_comment entitlement_transaction_comments,
	entitlement_transactions.entitlement entitlement_type,
	CONVERT(VARCHAR(5), entitlement_transactions.entitle_year) entitlement_year,
	entitlement_transactions.hours,
	entitlements.description entitlement_type_description,
	CASE WHEN entitlement_transactions.transaction_type = 'TAKEN' THEN entitlement_transactions.hours * -1 ELSE entitlement_transactions.hours END hours_balance
FROM
	entitlement_transactions INNER JOIN
	entitlements ON
		entitlement_transactions.entitlement = entitlements.entitlement
GO
