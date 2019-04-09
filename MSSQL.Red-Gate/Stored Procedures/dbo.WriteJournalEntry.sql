SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE
[dbo].[WriteJournalEntry] @as_fiscalyear varchar(5),
			@as_ledger varchar(40),
			@as_glentry varchar(25) OUTPUT,
			@as_jedescription varchar(50),
			@as_balancename varchar(40),
			@as_entrydate varchar(10),
			@as_entrytype varchar(3),
			@as_relatedglentry varchar(25),
			@as_userid varchar(25),
			@ai_period integer,
			@as_approved char(1),
			@as_currency varchar(25),
			@as_createdby varchar(25) AS

-- 06-Mar-2014	Added argument createdby to use for update of journal_entries table.
-- 12-Aug-2013	Modified to update journal_entries if approved is changed.
-- 25-Apr-2013	Added argument currency to use for update of journal_entries table.
-- 04-Feb-2013	Added argument approved to use for update of journal_entries table.

BEGIN
  DECLARE @s_entryidentifier varchar(40),
          @i_recordcount smallint

/*   Do we need a journal entry number?  If so execute the procedure that
     will do the work for us. */
  IF RTRIM(@as_glentry) IS NULL
    BEGIN
      SELECT @s_entryidentifier = entry_identifier
        FROM ledger_definition
       WHERE fiscal_year=@as_fiscalyear AND ledger=@as_ledger
      EXECUTE GetNextIdentifier 'JOURNAL ENTRY', @s_entryidentifier, @as_glentry OUTPUT
    END

/*  Do we already have this journal entry on file? */
  SELECT @i_recordcount = COUNT(*)
    FROM journal_entries
   WHERE fiscal_year=@as_fiscalyear AND ledger=@as_ledger AND
         gl_entry=@as_glentry

/*  write a journal entry header record in the case where a header record
    doesn't already exist. */
  IF @i_recordcount=0
    BEGIN
    INSERT INTO journal_entries
      (fiscal_year, ledger, gl_entry, period, balance_name,
      je_description, entry_date, entry_type, related_gl_entry,
      changed_date, changed_user_id, approved, currency, created_by)
      VALUES
      (@as_fiscalyear, @as_ledger ,@as_glentry, @ai_period, @as_balancename,
      @as_jedescription, @as_entrydate, @as_entrytype, @as_relatedglentry,
      GETDATE(), @as_userid, @as_approved, @as_currency, @as_createdby)
    END
  ELSE
    BEGIN
                UPDATE journal_entries
                   SET approved = @as_approved,
                       changed_user_id = @as_userid,
                       changed_date = GETDATE()
                 WHERE fiscal_year = @as_fiscalyear AND
                       ledger = @as_ledger AND
                       gl_entry = @as_glentry AND
                       ( approved is null OR approved <> @as_approved )
    END
END
GO
