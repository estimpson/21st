SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_post_acct_period_balances]
AS
SELECT
	ledger_balances.fiscal_year,
	ledger_balances.ledger,
	ledger_balances.ledger_account,
    ledger_balances.balance_name,
	ledger_balances.period,
	ledger_balances.period_amount,
	(SELECT sum(period_amount) FROM ledger_balances AS lb1 WHERE lb1.fiscal_year = ledger_balances.fiscal_year AND lb1.ledger = ledger_balances.ledger AND lb1.ledger_account = ledger_balances.ledger_account AND lb1.period <= ledger_balances.period) AS period_amount_ytd,
	coa_items.account_description,
	calendar_periods.period_name,
	ledger_organizations.organization_description
FROM
	ledger_balances INNER JOIN
	ledger_accounts ON
		ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND
		ledger_balances.ledger = ledger_accounts.ledger AND
		ledger_balances.ledger_account = ledger_accounts.ledger_account INNER JOIN
	coa_items ON
		ledger_accounts.fiscal_year = coa_items.fiscal_year AND
		ledger_accounts.coa = coa_items.coa AND
		ledger_accounts.account = coa_items.account AND
		coa_items.account_type = 'D' INNER JOIN
	ledger_definition ON
		ledger_balances.fiscal_year = ledger_definition.fiscal_year AND
		ledger_balances.ledger = ledger_definition.ledger INNER JOIN
	calendar_periods ON
		ledger_balances.fiscal_year = calendar_periods.fiscal_year AND
		ledger_definition.calendar = calendar_periods.calendar AND
		ledger_balances.period = calendar_periods.period INNER JOIN
	ledger_organizations ON
		ledger_accounts.fiscal_year = ledger_organizations.fiscal_year AND
		ledger_accounts.ledger = ledger_organizations.ledger AND
		ledger_accounts.organization_level = ledger_organizations.organization_level AND
		ledger_accounts.organization = ledger_organizations.organization
GO
