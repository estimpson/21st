SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetOrgByPostingAccount]
	@fiscal_year varchar(5),
	@ledger varchar(40),
	@organization_level varchar(40),
	@organization varchar(40),
	@account varchar(25),
	@ledger_account varchar(50),
	@balance_name1 varchar(25),
	@balance_name2 varchar(25),
	@period smallint,
	@to_ledger_account varchar(50),
	@enable_titles bit
AS
BEGIN
	
	DECLARE @sql varchar(4000),
                @sql2 varchar(4000),
                @paramlist  varchar(4000),
                @paramvalues  varchar(4000)

	SELECT @sql = ' 		SELECT
			coa_items.fiscal_year,
			coa_items.account,
			coa_items.account_type,
			coa_items.account_level,
			coa_items.account_description,
			coa_items.balance_profit,
			coa_items.coa,
			coa_items.parent_account,
			ledger_accounts.ledger,
			ledger_accounts.organization_level,
			ledger_accounts.organization,
			ledger_accounts.ledger_account,
			ledger_organizations.organization_description,
			@balance_name1 AS balance_name1,
			@balance_name2 AS balance_name2,
			@period AS period,
			@to_ledger_account AS to_ledger_account,
			(SELECT ledger_balances.period_amount FROM ledger_balances WHERE ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND ledger_balances.ledger = ledger_accounts.ledger AND ledger_balances.ledger_account = ledger_accounts.ledger_account AND ledger_balances.balance_name = @balance_name1 AND ledger_balances.period = @period ) computed_period_amount_balance1,
			(SELECT SUM( ledger_balances.period_amount ) FROM ledger_balances WHERE ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND ledger_balances.ledger = ledger_accounts.ledger AND ledger_balances.ledger_account = ledger_accounts.ledger_account AND ledger_balances.balance_name = @balance_name1 AND ledger_balances.period <= @period ) computed_ytd_amount_balance1,
			(SELECT ledger_balances.period_amount FROM ledger_balances WHERE ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND ledger_balances.ledger = ledger_accounts.ledger AND ledger_balances.ledger_account = ledger_accounts.ledger_account AND ledger_balances.balance_name = @balance_name2 AND ledger_balances.period = @period ) computed_period_amount_balance2,
			(SELECT SUM( ledger_balances.period_amount ) FROM ledger_balances WHERE ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND ledger_balances.ledger = ledger_accounts.ledger AND ledger_balances.ledger_account = ledger_accounts.ledger_account AND ledger_balances.balance_name = @balance_name2 AND ledger_balances.period <= @period ) computed_ytd_amount_balance2,
			(SELECT COUNT(*) FROM ledger_balances WHERE to_ledger_account = ledger_accounts.ledger_account) AS balances_count
		FROM
			coa_items LEFT OUTER JOIN
			ledger_accounts ON
				coa_items.fiscal_year = ledger_accounts.fiscal_year AND
				coa_items.coa = ledger_accounts.coa  AND
				coa_items.account = ledger_accounts.account LEFT OUTER JOIN
			ledger_organizations ON
				ledger_accounts.fiscal_year = ledger_organizations.fiscal_year AND
				ledger_accounts.ledger = ledger_organizations.ledger AND
				ledger_accounts.organization_level = ledger_organizations.organization_level AND
				ledger_accounts.organization = ledger_organizations.organization '
		
	SELECT @sql2 =
			' WHERE
			coa_items.fiscal_year = @fiscal_year AND
			((coa_items.account_type = ''' + 'D' + ''' AND ledger_accounts.ledger = @ledger) '
			IF ISNULL(@enable_titles, 0) = 1
			BEGIN
				SELECT @sql2 = @sql2 + ' OR (coa_items.account_type = ''' + 'T' + ''' AND ledger_accounts.ledger IS NULL)'
			END
			SELECT @sql2 = @sql2 + ') AND NOT
			(coa_items.account_type = ''' + 'D' + ''' AND (ISNULL((SELECT ledger_balances.period_amount FROM ledger_balances WHERE ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND ledger_balances.ledger = ledger_accounts.ledger AND ledger_balances.ledger_account = ledger_accounts.ledger_account AND ledger_balances.balance_name = @balance_name1 AND ledger_balances.period = @period), 0) = 0 AND
			ISNULL((SELECT SUM( ledger_balances.period_amount ) FROM ledger_balances WHERE ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND ledger_balances.ledger = ledger_accounts.ledger AND ledger_balances.ledger_account = ledger_accounts.ledger_account AND ledger_balances.balance_name = @balance_name1 AND ledger_balances.period <= @period ), 0) = 0 AND
			ISNULL((SELECT ledger_balances.period_amount FROM ledger_balances WHERE ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND ledger_balances.ledger = ledger_accounts.ledger AND ledger_balances.ledger_account = ledger_accounts.ledger_account AND ledger_balances.balance_name = @balance_name2 AND ledger_balances.period = @period ), 0) = 0 AND
			ISNULL((SELECT SUM( ledger_balances.period_amount ) FROM ledger_balances WHERE ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND ledger_balances.ledger = ledger_accounts.ledger AND ledger_balances.ledger_account = ledger_accounts.ledger_account AND ledger_balances.balance_name = @balance_name2 AND ledger_balances.period <= @period ), 0) = 0)) '

	IF ISNULL(@account, '') <> ''
	BEGIN
		SELECT @sql2 = @sql2 + ' AND ISNULL(ledger_accounts.account, @account) = @account'
	END
	
	IF ISNULL(@ledger_account, '') <> ''
	BEGIN
		SELECT @sql2 = @sql2 + ' AND ISNULL(ledger_accounts.ledger_account, @ledger_account) = @ledger_account'
	END

	IF ISNULL(@to_ledger_account, '') <> ''
	BEGIN
		SELECT @sql2 = @sql2 + ' AND (ledger_accounts.ledger_account IS NULL OR ledger_accounts.ledger_account IN (SELECT ledger_account FROM ledger_balances WHERE  ledger_balances.fiscal_year = ledger_accounts.fiscal_year AND ledger_balances.ledger = ledger_accounts.ledger AND ledger_balances.ledger_account = ledger_accounts.ledger_account AND ledger_balances.period <= @period AND ledger_balances.to_ledger_account = @to_ledger_account GROUP BY ledger_account))'
	END

	IF ISNULL(@organization_level, '') <> ''
	BEGIN
		SELECT @sql2 = @sql2 + ' AND ISNULL(ledger_accounts.organization_level, @organization_level) = @organization_level'
	END

	IF ISNULL(@organization, '') <> ''
	BEGIN
		SELECT @sql2 = @sql2 + ' AND ISNULL(ledger_accounts.organization, @organization) = @organization'
	END

	SELECT @sql2 = @sql2 + ' ORDER BY
			coa_items.balance_profit,
			coa_items.sort_line,
			coa_items.parent_account,
			coa_items.account,
			coa_items.account_level,
			coa_items.account_type DESC '

	SELECT @paramlist = 'DECLARE @fiscal_year VARCHAR(5),
						@ledger VARCHAR(40),
						@organization_level VARCHAR(40),
						@organization VARCHAR(40),
						@account VARCHAR(25),
						@ledger_account VARCHAR(50),
						@balance_name1 VARCHAR(25),
						@balance_name2 VARCHAR(25),
						@period SMALLINT,
						@to_ledger_account VARCHAR(50)'

	SELECT @paramvalues = ' SELECT @fiscal_year = ''' + ISNULL(@fiscal_year, '') + '''' +
                                    ', @ledger = ''' + ISNULL(@ledger, '') + '''' +
                                    ', @organization_level = ''' + ISNULL(@organization_level, '') + '''' +
                                    ', @organization = ''' + ISNULL(@organization, '') + ''''+
                                    ', @account = ''' + ISNULL(@account, '') + ''''+
                                    ', @ledger_account = ''' + ISNULL(@ledger_account, '') + '''' +
                                    ', @to_ledger_account = ''' + ISNULL(@to_ledger_account, '') + '''' +
                                    ', @balance_name1 = ''' + ISNULL(@balance_name1, '') + '''' +
                                    ', @balance_name2 = ''' + ISNULL(@balance_name2, '') + '''' +
                                    ', @period = ' + CONVERT(VARCHAR, ISNULL(@period, -1))
							

	EXECUTE (@paramlist + @paramvalues + @sql + @sql2)
	
END
GO
