SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[FAGLJournalEntries] @as_assetid varchar(50),
				    @ad_asofdate datetime,
				    @as_glbook varchar(25)
		

AS
BEGIN

-- 18-Sep-2001 Made Transact-SQL.

-- 31-Aug-2001 Replaced SUBSTRING(gl_cost_transactions.document_type, 1, 3)
--             = 'FA ' with a list of document types. With a list, SQL
--             Anywhere uses the gl_cost_transactions primary key in the
--             case where the primary key starts with document_type (the
--             early Empower users). With the SUBSTRING, the query read
--             the GL cost transactions sequentially. For users whose
--             primary key starts with document_id1, it doesn't matter.

CREATE TABLE #fa_gl_entries
   	    (fiscal_year varchar(5) NULL,
     	     period INT NULL,
           ledger varchar(40) NULL,
	     account varchar(50) NULL,
	     amount DEC(18,6) NULL,
	     trans_date DATETIME NULL,
	     document_reference varchar(25) NULL)

INSERT INTO #fa_gl_entries

SELECT DISTINCT gl_cost_transactions.fiscal_year,
                gl_cost_transactions.period,
                gl_cost_transactions.ledger,
                gl_cost_transactions.ledger_account,
                gl_cost_transactions.amount,
                gl_cost_transactions.transaction_date,
                gl_cost_transactions.document_reference1
FROM fa_asset_history,gl_cost_transactions
WHERE fa_asset_history.asset_id = @as_assetid AND
      fa_asset_history.gl_date >= @ad_asofdate AND
      gl_cost_transactions.document_type in ('FA INSERVICE',
      'FA ACQ ACCT CHG','FA ORIG COST CHG','FA DEPN ACCT CHG',
      'FA DISP') AND
      gl_cost_transactions.document_id1 = fa_asset_history.asset_id

INSERT INTO #fa_gl_entries

SELECT fa_asset_depreciation_audit.glentry_fiscal_year,
       fa_asset_depreciation_audit.glentry_fiscal_period,
       fa_asset_depreciation_audit.ledger,
       fa_asset_depreciation_audit.ledger_account,
       fa_asset_depreciation_audit.depreciation_period,
       fa_asset_depreciation_audit.gl_date,
       'Depreciation Calculation'
FROM fa_asset_depreciation_audit
WHERE fa_asset_depreciation_audit.asset_id = @as_assetid AND
      fa_asset_depreciation_audit.gl_date >= @ad_asofdate AND
      fa_asset_depreciation_audit.depreciation_book = @as_glbook AND
      fa_asset_depreciation_audit.gl_entry IS NOT NULL

SELECT fiscal_year,
       period,
       ledger,
       account,
       amount,
       trans_date,
       document_reference
    FROM #fa_gl_entries
   ORDER BY trans_date DESC,
	    account
END
GO
