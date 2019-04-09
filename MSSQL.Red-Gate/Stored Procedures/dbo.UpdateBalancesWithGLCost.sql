SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UpdateBalancesWithGLCost] @as_fiscalyear VARCHAR(25),
                                          @as_ledger VARCHAR(40),
                                          @ai_period int
AS

BEGIN

-- Procedure to update journal entry lines and ledger balances
-- with GL cost transactions for a specific period.

-- 23-May-2014 Modified to use gl_cost_transactions rather than ledger_balances to update
--             the current year profit loss account.  Otherwise, we run into problems
--             when an account is defined as a posting account at more than one
--             organizational level.

  DECLARE @s_profitlossaccount varchar(50),
          @s_fiscalyear VARCHAR(25),
          @s_ledger VARCHAR(40),
          @i_start int,
          @i_length int,
          @i_questionpos int,
          @i_rowcount int,
          @s_error char(1)

  SELECT @s_fiscalyear = UPPER(@as_fiscalyear)
  SELECT @s_ledger = UPPER(@as_ledger)
  SELECT @s_error = 'N'

  SELECT @s_profitlossaccount = IsNull(profit_loss_ledger_account,'')
    FROM ledger_definition
    WHERE fiscal_year = @s_fiscalyear
      AND ledger = @s_ledger

  IF @@rowcount = 0 OR @s_profitlossaccount = ''
    PRINT 'Could not get profit loss account.  This procedure cannot be used.'
  ELSE
    BEGIN
      SELECT @i_rowcount = Count(*)
        FROM ledger_accounts
       WHERE fiscal_year = @s_fiscalyear
         AND ledger = @s_ledger
         AND IsNull(profit_loss_ledger_account,'') <> ''
      IF @i_rowcount > 0
        BEGIN
          SELECT @s_error = 'Y'
          PRINT 'Profit loss account is specified on individual ledger accounts.  This procedure cannot be used.'
        END
      ELSE
        BEGIN
          SELECT @i_questionpos = Charindex('?',@s_profitlossaccount)
          IF @i_questionpos = 0
            SELECT @i_start = 0, @i_length = 0
          ELSE
            BEGIN
              -- Get the wildcard start and length
              SELECT @i_start = IsNull(value,0)
                FROM preferences_standard
               WHERE preference = 'GLWildcardStart'
              IF @@rowcount = 0 SELECT @i_start = 0

              SELECT @i_length = IsNull(value,0)
                FROM preferences_standard
               WHERE preference = 'GLWildcardLength'
              IF @@rowcount = 0 SELECT @i_length = 0

              IF @i_start = 0 OR @i_length = 0
                BEGIN
                  SELECT @s_error = 'Y'
                  PRINT 'Could not get wildcard start or length.  This procedure cannot be used.'
                END
              ELSE
                BEGIN
                  SELECT @i_rowcount = Count(*)
                    FROM gl_cost_transactions, journal_entries
                   WHERE gl_cost_transactions.fiscal_year = @s_fiscalyear AND
                         gl_cost_transactions.ledger = @s_ledger AND
                         gl_cost_transactions.period = @ai_period AND
                         gl_cost_transactions.update_balances = 'Y' AND
                         gl_cost_transactions.ledger_account like REPLACE(@s_profitlossaccount, '?', '%') AND
                         journal_entries.ledger = gl_cost_transactions.ledger AND
                         journal_entries.fiscal_year = gl_cost_transactions.fiscal_year AND
                         journal_entries.gl_entry = gl_cost_transactions.gl_entry AND
                         journal_entries.balance_name = 'ACTUAL'
                  IF @i_rowcount > 0
                    BEGIN
                      -- One or more profit loss accounts have something posted to them.
               	      -- This script can't run for those accounts. To make it correct, we
                      -- would need inserts for the accounts that don't have anything
                      -- posted and updates for the ones that do.
                      SELECT @s_error = 'Y'
                      PRINT 'One or more profit/loss accounts have values posted to them.  This procedure cannot be used.'
                    END
                END
            END
        END

      IF @s_error = 'N'
        BEGIN

          BEGIN TRANSACTION

          -- Delete from journal_entry_lines first because it has a delete
          -- trigger which updates ledger_balances.
          DELETE FROM journal_entry_lines
            WHERE fiscal_year = @s_fiscalyear
              AND ledger = @s_ledger
              AND period = @ai_period
              AND balance_name = 'ACTUAL'

          DELETE FROM ledger_balances
           WHERE fiscal_year = @s_fiscalyear
             AND ledger = @s_ledger
             AND period = @ai_period
             AND balance_name = 'ACTUAL'

          INSERT INTO journal_entry_lines
            (fiscal_year, ledger, gl_entry, ledger_account, period, balance_name,
             amount, changed_date, changed_user_id)
            SELECT gl_cost_transactions.fiscal_year,
                   gl_cost_transactions.ledger,
                   gl_cost_transactions.gl_entry,
                   gl_cost_transactions.ledger_account,
                   gl_cost_transactions.period,
                   'ACTUAL',
                   ROUND(SUM(gl_cost_transactions.amount),2),
                   GetDate(),
                   'DBA'
              FROM gl_cost_transactions, journal_entries
             WHERE gl_cost_transactions.fiscal_year = @s_fiscalyear AND
                   gl_cost_transactions.ledger = @s_ledger AND
                   gl_cost_transactions.period = @ai_period AND
                   gl_cost_transactions.update_balances = 'Y' AND
                   journal_entries.ledger = gl_cost_transactions.ledger AND
                   journal_entries.fiscal_year = gl_cost_transactions.fiscal_year AND
                   journal_entries.gl_entry = gl_cost_transactions.gl_entry AND
                   journal_entries.balance_name = 'ACTUAL'
            GROUP BY gl_cost_transactions.fiscal_year,
                     gl_cost_transactions.ledger,
                     gl_cost_transactions.gl_entry,
                     gl_cost_transactions.ledger_account,
                     gl_cost_transactions.period

          IF @i_start = 0
            BEGIN
              -- Have a single profit loss account.  Does it have
              -- anything posted to it?
              IF NOT EXISTS
                (SELECT 1
                   FROM ledger_balances
                  WHERE fiscal_year = @s_fiscalyear AND
                        ledger = @s_ledger AND
                        period = @ai_period AND
                        balance_name = 'ACTUAL' AND
                        ledger_account = @s_profitlossaccount)

                INSERT INTO ledger_balances
                  (fiscal_year, ledger, ledger_account, balance_name, period,
                   period_amount, changed_date, changed_user_id)
                  SELECT @s_fiscalyear,
                         @s_ledger,
                         @s_profitlossaccount,
                         'ACTUAL',
                         @ai_period,
                         ROUND(SUM(gl_cost_transactions.amount),2),
                         GetDate(),
                         'DBA'
                    FROM gl_cost_transactions, journal_entries, ledger_accounts, chart_of_accounts
                   WHERE gl_cost_transactions.fiscal_year = @s_fiscalyear AND
                         gl_cost_transactions.ledger = @s_ledger AND
                         gl_cost_transactions.period = @ai_period AND
                         gl_cost_transactions.update_balances = 'Y' AND
                         journal_entries.ledger = gl_cost_transactions.ledger AND
                         journal_entries.fiscal_year = gl_cost_transactions.fiscal_year AND
                         journal_entries.gl_entry = gl_cost_transactions.gl_entry AND
                         journal_entries.balance_name = 'ACTUAL' AND
                         ledger_accounts.fiscal_year = gl_cost_transactions.fiscal_year AND
                         ledger_accounts.ledger = gl_cost_transactions.ledger AND
                         ledger_accounts.ledger_account = gl_cost_transactions.ledger_account AND
                         ledger_accounts.balance_profit = 'P' AND
                         chart_of_accounts.fiscal_year = ledger_accounts.fiscal_year AND
                         chart_of_accounts.coa = ledger_accounts.coa AND
                         chart_of_accounts.account = ledger_accounts.account AND
                         chart_of_accounts.debit_credit_stat <> 'S'
              ELSE
                -- The current year P/L account is already in ledger_balances
                UPDATE ledger_balances
                   SET period_amount = period_amount +
                  (SELECT ROUND(SUM(gl_cost_transactions.amount),2)
                     FROM gl_cost_transactions, journal_entries, ledger_accounts, chart_of_accounts
                    WHERE gl_cost_transactions.fiscal_year = @s_fiscalyear AND
                          gl_cost_transactions.ledger = @s_ledger AND
                          gl_cost_transactions.period = @ai_period AND
                          gl_cost_transactions.update_balances = 'Y' AND
                          journal_entries.ledger = gl_cost_transactions.ledger AND
                          journal_entries.fiscal_year = gl_cost_transactions.fiscal_year AND
                          journal_entries.gl_entry = gl_cost_transactions.gl_entry AND
                          journal_entries.balance_name = 'ACTUAL' AND
                          ledger_accounts.fiscal_year = gl_cost_transactions.fiscal_year AND
                          ledger_accounts.ledger = gl_cost_transactions.ledger AND
                          ledger_accounts.ledger_account = gl_cost_transactions.ledger_account AND
                          ledger_accounts.balance_profit = 'P' AND
                          chart_of_accounts.fiscal_year = ledger_accounts.fiscal_year AND
                          chart_of_accounts.coa = ledger_accounts.coa AND
                          chart_of_accounts.account = ledger_accounts.account AND
                          chart_of_accounts.debit_credit_stat <> 'S'),
                          changed_date = GetDate(),
                          changed_user_id = 'DBA'
                    WHERE fiscal_year = @s_fiscalyear AND
                          ledger = @s_ledger AND
                          balance_name = 'ACTUAL' AND
                          period = @ai_period AND
                          ledger_account = @s_profitlossaccount

            END
          ELSE
            BEGIN
              -- Have a wildcarded profit loss account.
              INSERT INTO ledger_balances
                (fiscal_year, ledger, ledger_account, balance_name, period,
                 period_amount, changed_date, changed_user_id)
                SELECT @s_fiscalyear,
                       @s_ledger,
                       CASE @i_questionpos
                         WHEN 0 THEN
                             @s_profitlossaccount
                         WHEN 1 THEN
                             SUBSTRING(gl_cost_transactions.ledger_account,@i_start,@i_length) + SUBSTRING(@s_profitlossaccount, 2, LEN(@s_profitlossaccount) - 1)
                         WHEN LEN(@s_profitlossaccount) THEN
                             SUBSTRING(@s_profitlossaccount, 1, LEN(@s_profitlossaccount) - 1) + SUBSTRING(gl_cost_transactions.ledger_account,@i_start,@i_length)
                         ELSE
                             SUBSTRING(@s_profitlossaccount, 1, @i_questionpos - 1) +
                             SUBSTRING(gl_cost_transactions.ledger_account,@i_start,@i_length) +
                             SUBSTRING(@s_profitlossaccount, @i_questionpos + 1, LEN(@s_profitlossaccount) - @i_questionpos)
                       END,
                       'ACTUAL',
                       @ai_period,
                       ROUND(SUM(gl_cost_transactions.amount),2),
                       CONVERT(datetime,GETDATE()),
                       'DBA'
                  FROM gl_cost_transactions, journal_entries, ledger_accounts, chart_of_accounts
                 WHERE gl_cost_transactions.fiscal_year = @s_fiscalyear AND
                       gl_cost_transactions.ledger = @s_ledger AND
                       gl_cost_transactions.period = @ai_period AND
                       gl_cost_transactions.update_balances = 'Y' AND
                       journal_entries.ledger = gl_cost_transactions.ledger AND
                       journal_entries.fiscal_year = gl_cost_transactions.fiscal_year AND
                       journal_entries.gl_entry = gl_cost_transactions.gl_entry AND
                       journal_entries.balance_name = 'ACTUAL' AND
                       ledger_accounts.fiscal_year = gl_cost_transactions.fiscal_year AND
                       ledger_accounts.ledger = gl_cost_transactions.ledger AND
                       ledger_accounts.ledger_account = gl_cost_transactions.ledger_account AND
                       ledger_accounts.balance_profit = 'P' AND
                       chart_of_accounts.fiscal_year = ledger_accounts.fiscal_year AND
                       chart_of_accounts.coa = ledger_accounts.coa AND
                       chart_of_accounts.account = ledger_accounts.account AND
                       chart_of_accounts.debit_credit_stat <> 'S'
                GROUP BY
                       CASE @i_questionpos
                         WHEN 0 THEN
                             @s_profitlossaccount
                         WHEN 1 THEN
                             SUBSTRING(gl_cost_transactions.ledger_account,@i_start,@i_length) + SUBSTRING(@s_profitlossaccount, 2, LEN(@s_profitlossaccount) - 1)
                         WHEN LEN(@s_profitlossaccount) THEN
                             SUBSTRING(@s_profitlossaccount, 1, LEN(@s_profitlossaccount) - 1) + SUBSTRING(gl_cost_transactions.ledger_account,@i_start,@i_length)
                         ELSE
                             SUBSTRING(@s_profitlossaccount, 1, @i_questionpos - 1) +
                             SUBSTRING(gl_cost_transactions.ledger_account,@i_start,@i_length) +
                             SUBSTRING(@s_profitlossaccount, @i_questionpos + 1, LEN(@s_profitlossaccount) - @i_questionpos)
                       END
            END

          COMMIT TRANSACTION
        END
    END
END

GO
