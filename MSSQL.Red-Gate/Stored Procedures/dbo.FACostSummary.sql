SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[FACostSummary]   @as_begdate datetime,
                                 @as_enddate datetime,
                                 @as_begledgeraccount varchar(50),
                                 @as_endledgeraccount varchar(50),
                                 @as_begunit varchar(25),
                                 @as_endunit varchar(25),
                                 @as_glbook  varchar(25)

AS
BEGIN

-- 19-Apr-2009 Added account description to the final retrieval.


-- 07-Oct-2004 Modified to use the new column gl_date from fa_asset_history
--             using a sql sub-query, rather than the in_service_date
--             on fa_asset_books.  With the introduction of assets created
--             from costing, it is no longer the case that in_service_date
--             corresponds the the g/l entry.

-- 18-Sep-2001 Made Transact-SQL.

-- 06-Sep-2000 Modified to include as_glbook when selecting from the
--             event history. The value in as_glbook isn't necessarily
--             the GL book. It is the value from the selection window.

-- 23-Aug-2000 1. Added script to select the first acquisition asset
--                account change after the selection date rather than
--                ALL asset account changes after the selection date.
--             2. Added script to select original cost changes.

  CREATE TABLE #fa_cost_summary
        (asset_id varchar(50) NULL,
         unit varchar(25) NULL,
         column_type varchar(25) NULL,
         transaction_date DATETIME NULL,
         original_cost DEC(18,6) NULL,
         ledger varchar(25) NULL,
         ledger_account varchar(50) NULL
         )

  /*  Select assets whose asset acquisition account changed after the
      selection end date so we can use information from the History
      table rather than use the current information from the Asset Books
      table. */

  INSERT INTO #fa_cost_summary

  SELECT fa_assets.asset_id,
	 fa_assets.unit,
	 'ENDING',
	 @as_enddate,
	 CONVERT (DEC(18,6),fa_asset_history.acquisition_asset),
	 fa_asset_history.ledger,
	 fa_asset_history.old_value
  FROM	fa_assets, fa_asset_books,fa_asset_history
  WHERE fa_assets.unit >= @as_begunit AND
	fa_assets.unit <= @as_endunit AND
	fa_assets.asset_id = fa_asset_books.asset_id AND
	fa_asset_books.depreciation_book = @as_glbook AND
	(select min(gl_date) from fa_asset_history
           where fa_asset_history.asset_id = fa_asset_books.asset_id
             and fa_asset_history.depreciation_book = fa_asset_books.depreciation_book
             and fa_asset_history.asset_event = 'IN SERVICE'
             and fa_asset_history.column_changed = 'ORIGINAL COST') <= @as_enddate AND
	fa_asset_history.asset_id = fa_asset_books.asset_id AND
	fa_asset_history.depreciation_book = fa_asset_books.depreciation_book AND
	fa_asset_history.gl_date > @as_enddate AND
	fa_asset_history.asset_event = 'ACQ ACCOUNT XFER' AND
        fa_asset_history.gl_date =
           (SELECT Min(gl_date)
              FROM fa_asset_history fah2
             WHERE fah2.asset_id = fa_asset_history.asset_id AND
                   fah2.depreciation_book = fa_asset_history.depreciation_book AND
                   fah2.asset_event = fa_asset_history.asset_event AND
                   fah2.gl_date > @as_enddate AND
                   fah2.old_value >= @as_begledgeraccount AND
                   fah2.old_value <= @as_endledgeraccount ) AND
	fa_asset_history.old_value >= @as_begledgeraccount AND
	fa_asset_history.old_value <= @as_endledgeraccount


  /* Add the assets that have not had a change of Acquisition Account
     since the selection end date. */

 INSERT INTO #fa_cost_summary

 SELECT fa_asset_books.asset_id,
	fa_assets.unit,
	'ENDING',
	@as_enddate,
	fa_asset_books.original_cost,
	units_fixed_assets.ledger,
	fa_assets.acquisition_asset
 FROM fa_assets, fa_asset_books, units_fixed_assets
WHERE fa_assets.unit >= @as_begunit AND
	fa_assets.unit <= @as_endunit AND
	fa_assets.acquisition_asset >= @as_begledgeraccount AND
	fa_assets.acquisition_asset <= @as_endledgeraccount AND
	fa_assets.unit = units_fixed_assets.unit AND
	fa_assets.asset_id = fa_asset_books.asset_id AND
	fa_asset_books.depreciation_book = @as_glbook AND
	(select min(gl_date) from fa_asset_history
           where fa_asset_history.asset_id = fa_asset_books.asset_id
             and fa_asset_history.depreciation_book = fa_asset_books.depreciation_book
             and fa_asset_history.asset_event = 'IN SERVICE'
             and fa_asset_history.column_changed = 'ORIGINAL COST') <= @as_enddate AND
	NOT fa_assets.asset_id IN
	 (SELECT asset_id FROM #fa_cost_summary ) AND
	(( fa_assets.status <> 'D') OR
	 ( fa_assets.status = 'D' AND
	    fa_assets.disposition_date > @as_enddate ) )


  /* If the original cost changed after the selection end date, get the
     original cost as of the selection end date. This will be on the
     earliest dated asset history AFTER the selection end date. */

  UPDATE #fa_cost_summary
     SET #fa_cost_summary.original_cost =
           CONVERT( DEC(18,6), fa_asset_history.old_value )
    FROM fa_asset_history
   WHERE fa_asset_history.asset_id = #fa_cost_summary.asset_id AND
         fa_asset_history.depreciation_book = @as_glbook AND
         fa_asset_history.gl_date > @as_enddate AND
         fa_asset_history.asset_event = 'ORIGINAL COST CHG' AND
         fa_asset_history.gl_date =
           (SELECT Min(gl_date)
              FROM fa_asset_history fah2
             WHERE fah2.asset_id = fa_asset_history.asset_id AND
                   fah2.asset_event = fa_asset_history.asset_event AND
                   fah2.gl_date > @as_enddate )

  /* Select the original cost changes made to this ledger account between
     the selection dates. */
  INSERT INTO #fa_cost_summary

  SELECT fa_assets.asset_id,
         fa_assets.unit,
         'COST CHG',
         fa_asset_history.gl_date,
         CONVERT (DEC(18,6),fa_asset_history.new_value) -
            CONVERT (DEC(18,6),fa_asset_history.old_value),
         fa_asset_history.ledger,
         fa_asset_history.acquisition_asset
  FROM fa_assets, fa_asset_books, fa_asset_history
  WHERE fa_assets.unit >= @as_begunit AND
        fa_assets.unit <= @as_endunit AND
        fa_assets.asset_id = fa_asset_books.asset_id AND
        fa_assets.asset_id = fa_asset_history.asset_id AND
        fa_asset_books.depreciation_book = @as_glbook AND
        fa_asset_history.depreciation_book = fa_asset_books.depreciation_book AND
        fa_asset_history.asset_event = 'ORIGINAL COST CHG' AND
        fa_asset_history.column_changed = 'ORIGINAL COST' AND
        fa_asset_history.gl_date >= @as_begdate AND
        fa_asset_history.gl_date <= @as_enddate AND
        fa_asset_history.acquisition_asset >= @as_begledgeraccount AND
        fa_asset_history.acquisition_asset <= @as_endledgeraccount

 /* Select the acquisitions made to this ledger account between the
    selection dates. */

  INSERT INTO #fa_cost_summary

  SELECT fa_assets.asset_id,
         fa_assets.unit,
	 'ACQ',
	 fa_asset_books.in_service_date,
         CONVERT (DEC(18,6),fa_asset_history.new_value),
	 fa_asset_history.ledger,
         fa_asset_history.acquisition_asset
  FROM fa_assets, fa_asset_books, fa_asset_history
  WHERE fa_assets.unit >= @as_begunit AND
	fa_assets.unit <= @as_endunit AND
	fa_assets.asset_id = fa_asset_books.asset_id AND
	fa_assets.asset_id = fa_asset_history.asset_id AND
	fa_asset_books.depreciation_book = @as_glbook AND
      fa_asset_history.depreciation_book = fa_asset_books.depreciation_book AND
	fa_asset_history.asset_event = 'IN SERVICE' AND
	fa_asset_history.column_changed = 'ORIGINAL COST' AND
	fa_asset_history.gl_date >= @as_begdate AND
	fa_asset_history.gl_date <= @as_enddate AND
	fa_asset_history.acquisition_asset >= @as_begledgeraccount AND
	fa_asset_history.acquisition_asset <= @as_endledgeraccount


  /* Select the dispositions made to this ledger account between the
     selection dates.*/

  INSERT INTO #fa_cost_summary

  SELECT fa_assets.asset_id,
         fa_assets.unit,
         fa_asset_history.asset_event,
         fa_asset_books.in_service_date,
         CONVERT (DEC(18,6),fa_asset_history.new_value),
         fa_asset_history.ledger,
         fa_asset_history.acquisition_asset
  FROM fa_assets, fa_asset_books, fa_asset_history
  WHERE fa_assets.unit >= @as_begunit AND
	fa_assets.unit <= @as_endunit AND
	fa_assets.acquisition_asset >= @as_begledgeraccount AND
	fa_assets.acquisition_asset <= @as_endledgeraccount AND
	fa_assets.asset_id = fa_asset_books.asset_id AND
	fa_assets.asset_id = fa_asset_history.asset_id AND
	fa_asset_books.depreciation_book = @as_glbook AND
	fa_asset_history.depreciation_book = fa_asset_books.depreciation_book AND
	fa_asset_history.asset_event = 'DISPOSE' AND
	fa_asset_history.column_changed = 'ORIGINAL COST' AND
	fa_asset_history.gl_date >= @as_begdate AND
	fa_asset_history.gl_date <= @as_enddate


  /* Select the transfers into and out of ledger accounts between the
     selection dates. */

  INSERT INTO #fa_cost_summary

  SELECT fa_assets.asset_id,
         fa_assets.unit,
	 fa_asset_history.asset_event,
	 fa_asset_books.in_service_date,
         CONVERT (DEC(18,6),fa_asset_history.new_value),
	 fa_asset_history.ledger,
         fa_asset_history.acquisition_asset
  FROM fa_assets, fa_asset_books, fa_asset_history
  WHERE fa_assets.unit >= @as_begunit AND
	fa_assets.unit <= @as_endunit AND
	fa_assets.asset_id = fa_asset_books.asset_id AND
	fa_assets.asset_id = fa_asset_history.asset_id AND
	fa_asset_books.depreciation_book = @as_glbook AND
	fa_asset_history.depreciation_book = fa_asset_books.depreciation_book AND
       (fa_asset_history.asset_event = 'ACQ ACCOUNT XFER-IN' OR
	fa_asset_history.asset_event = 'ACQ ACCOUNT XFER-OUT') AND
	fa_asset_history.column_changed = 'ORIGINAL COST' AND
	fa_asset_history.gl_date >= @as_begdate AND
	fa_asset_history.gl_date <= @as_enddate AND
	fa_asset_history.acquisition_asset >= @as_begledgeraccount AND
	fa_asset_history.acquisition_asset <= @as_endledgeraccount


  /* Select the end result from the temporary table. Add in the
     asset description and the unit description. */

  SELECT #fa_cost_summary.asset_id,
	 fa_assets.asset_short_description,
         #fa_cost_summary.unit,
	 units_fixed_assets.name,
         #fa_cost_summary.column_type ,
         #fa_cost_summary.transaction_date ,
         #fa_cost_summary.original_cost ,
	 #fa_cost_summary.ledger,
         #fa_cost_summary.ledger_account,
         (select account_description
            from chart_of_accounts coa, ledger_accounts, ledger_definition, preferences_standard
           where preferences_standard.preference = 'GLFiscalYear'
             and ledger_definition.fiscal_year = preferences_standard.value
             and ledger_definition.ledger =  #fa_cost_summary.ledger
             and ledger_accounts.fiscal_year = ledger_definition.fiscal_year
             and ledger_accounts.ledger = ledger_definition.ledger
             and ledger_accounts.ledger_account = #fa_cost_summary.ledger_account
             and coa.fiscal_year = ledger_accounts.fiscal_year
             and coa.coa = ledger_accounts.coa
             and coa.account = ledger_accounts.account)
  FROM #fa_cost_summary, fa_assets, units_fixed_assets
  WHERE #fa_cost_summary.asset_id = fa_assets.asset_id AND
	 fa_assets.unit = units_fixed_assets.unit
ORDER BY #fa_cost_summary.ledger,
	 #fa_cost_summary.ledger_account,
	 #fa_cost_summary.unit,
	 #fa_cost_summary.asset_id


END
GO
