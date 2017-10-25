SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[FACostInterface]    @as_calcid varchar(40),
				    @as_glbook varchar(25)
AS
BEGIN

CREATE TABLE #fa_gl_entries
   	    (asset_id varchar(50) NULL,
             fiscal_year varchar(5) NULL,
     	     period INT NULL,
             ledger varchar(40) NULL,
	     account varchar(50) NULL,
	     amount DEC(18,6) NULL,
	     document_reference varchar(25) NULL,
             gl_entry varchar(25) NULL,
             dep_fiscal_year varchar(5) NULL,
             dep_period INT NULL )

INSERT INTO #fa_gl_entries
SELECT gl_cost_transactions.document_id1,
       gl_cost_transactions.fiscal_year,
       gl_cost_transactions.period,
       gl_cost_transactions.ledger,
       gl_cost_transactions.ledger_account,
       gl_cost_transactions.amount,
       gl_cost_transactions.document_reference1,
       gl_cost_transactions.gl_entry,
       '',
       0
FROM gl_cost_transactions
WHERE gl_cost_transactions.document_reference2 = @as_calcid AND
      gl_cost_transactions.document_type in ('FA INSERVICE','FA ORIG COST CHG')

INSERT INTO #fa_gl_entries
SELECT fa_asset_depreciation_audit.asset_id,
       fa_asset_depreciation_audit.glentry_fiscal_year,
       fa_asset_depreciation_audit.glentry_fiscal_period,
       fa_asset_depreciation_audit.ledger,
       fa_asset_depreciation_audit.ledger_account,
       fa_asset_depreciation_audit.depreciation_period,
       'Depreciation Calculation',
       fa_asset_depreciation_audit.gl_entry,
       fa_asset_depreciation_audit.fiscal_year,
       fa_asset_depreciation_audit.fiscal_period
FROM fa_asset_depreciation_audit
WHERE fa_asset_depreciation_audit.depreciation_calc_id = @as_calcid AND
      fa_asset_depreciation_audit.depreciation_book = @as_glbook

SELECT #fa_gl_entries.asset_id,
       fa_assets.asset_short_description,
       fa_assets.unit,
       units_fixed_assets.name,
       fa_asset_books.in_service_date,
       fa_asset_books.depreciation_method,
       fa_asset_books.asset_life,
       fa_asset_books.life_unit_of_measure,
       #fa_gl_entries.fiscal_year,
       #fa_gl_entries.period,
       #fa_gl_entries.ledger,
       #fa_gl_entries.account,
       #fa_gl_entries.amount,
       #fa_gl_entries.document_reference,
       @as_calcid,
       #fa_gl_entries.gl_entry,
       #fa_gl_entries.dep_fiscal_year,
       #fa_gl_entries.dep_period
    FROM #fa_gl_entries, fa_assets, units_fixed_assets, fa_asset_books
   WHERE #fa_gl_entries.asset_id = fa_assets.asset_id AND
          fa_assets.unit = units_fixed_assets.unit AND
          fa_assets.asset_id = fa_asset_books.asset_id AND
          fa_asset_books.depreciation_book = @as_glbook
   ORDER BY account, dep_fiscal_year, dep_period
END
GO
