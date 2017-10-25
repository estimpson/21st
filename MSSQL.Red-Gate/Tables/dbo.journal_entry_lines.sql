CREATE TABLE [dbo].[journal_entry_lines]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [smallint] NULL,
[balance_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_JournalEntryLines]
ON [dbo].[journal_entry_lines] FOR DELETE
AS
BEGIN
  DECLARE @s_fiscalyear varchar(5),
          @s_ledger varchar(40),
          @s_ledgeraccount varchar(50),
          @s_balancename varchar(40),
          @s_changeduserid varchar(25),
          @i_period smallint,
          @c_amount decimal(18,6),
          @i_rowcount int

  SELECT @i_rowcount = Count(*) FROM deleted

  /*  Don't attempt further processing unless we're sure that there is a
      row in the deleted table (assume that i_rowcount is 0 or 1).
      Since this is a statement level trigger it is possible that the
      DELETE statement that fired this trigger may not have deleted a row.
  */

  IF @i_rowcount > 0
    BEGIN

      SELECT @s_fiscalyear=fiscal_year, @s_ledger=ledger,
             @s_ledgeraccount=ledger_account, @s_balancename=balance_name,
             @s_changeduserid=changed_user_id, @i_period=period,
             @c_amount=amount
        FROM deleted

      /*  change the sign of the amount just deleted */
      SELECT @c_amount = @c_amount * -1

      /*  now call the procedure to reflect this deleted amount */
      EXECUTE UpdateAccountBalance @s_fiscalyear, @s_ledger,
                    @s_ledgeraccount, @s_balancename,
                    @s_changeduserid, @i_period, @c_amount

    END

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_JournalEntryLines]
ON [dbo].[journal_entry_lines] FOR INSERT
AS
BEGIN

  DECLARE @s_fiscalyear varchar(5),
          @s_ledger varchar(40),
          @s_ledgeraccount varchar(50),
          @s_balancename varchar(40),
          @i_period smallint,
          @c_amount decimal(18,6),
          @s_changeduserid varchar(25),
          @i_rowcount int

  /*  Make sure that we have a row in the inserted table for processing */
  SELECT @i_rowcount = Count(*) FROM inserted

   IF @i_rowcount = 1
    /*  Have exactly 1 row. No need for a cursor. This should be the
        case for everything but the SQL command file to correct
        ledger balances. Need to check this even though Sybase doesn't.
        We can only create the cursor in the case of a mass insert;
        otherwise, we get an error that jelinesinscursor already exists.
    */
     BEGIN

      /*  Select appropriate columns from the inserted table */
      SELECT @s_fiscalyear=fiscal_year, @s_ledger=ledger,
             @s_ledgeraccount=ledger_account, @s_balancename=balance_name,
             @i_period=period, @c_amount=amount,
             @s_changeduserid=changed_user_id
        FROM inserted

      /*  Add this new entry amount to the balance(s) for the appropriate
          period */

      EXECUTE UpdateAccountBalance @s_fiscalyear, @s_ledger,
                                   @s_ledgeraccount, @s_balancename,
                                   @s_changeduserid, @i_period, @c_amount

    END
  ELSE
    BEGIN
      /* Have multiple rows. This should only happen when the SQL command
         file to correct balances is executed.
      */

      DECLARE jelinesinscursor CURSOR FOR
          SELECT fiscal_year, ledger, ledger_account, balance_name,
                 period, amount, changed_user_id
            FROM inserted

      OPEN jelinesinscursor

      /*  prime fetch  */
      FETCH jelinesinscursor INTO @s_fiscalyear, @s_ledger,
                                @s_ledgeraccount, @s_balancename, @i_period,
                                @c_amount, @s_changeduserid

      WHILE @@FETCH_STATUS = 0
        BEGIN
          /*  any fetch status other than 0 will stop the loop  */

          /*  Add this new entry amount to the balance(s) for the appropriate
              period */

          EXECUTE UpdateAccountBalance @s_fiscalyear, @s_ledger,
                                       @s_ledgeraccount, @s_balancename,
                                       @s_changeduserid, @i_period, @c_amount

           /*  get the next inserted record, if any  */
          FETCH jelinesinscursor INTO @s_fiscalyear, @s_ledger,
                                    @s_ledgeraccount, @s_balancename, @i_period,
                                    @c_amount, @s_changeduserid
        END
       /* Don't need the cursor any longer. */
      CLOSE jelinesinscursor
      DEALLOCATE jelinesinscursor
   END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_JournalEntryLines]
ON [dbo].[journal_entry_lines] FOR UPDATE
AS
BEGIN
  /*  The update has to be for the SAME fiscal year/ledger/gl entry/account.
      Procedures and triggers prior to this trigger should never allow an
      update to this file that would change the fiscal year, ledger,
      gl entry, or account.

      Compute the net difference from the new journal entry amount to the
      old then update the ledger account balance with the net change.  */

  DECLARE @s_fiscalyear varchar(5),
          @s_ledger varchar(40),
          @s_ledgeraccount varchar(50),
          @s_balancename varchar(40),
          @i_period smallint,
          @s_changeduserid varchar(25),
          @c_amount decimal(18,6),
          @i_rowcount int

  /*  Do we have a row to process?  */
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN

      /*  Select the appropriate columns from the inserted/updates tables */
      SELECT @s_fiscalyear=inserted.fiscal_year,
             @s_ledger=inserted.ledger,
             @s_ledgeraccount=inserted.ledger_account,
             @s_balancename=inserted.balance_name,
             @i_period=inserted.period,
             @s_changeduserid=inserted.changed_user_id,
             @c_amount=inserted.amount - deleted.amount
        FROM inserted, deleted
       WHERE inserted.fiscal_year = deleted.fiscal_year AND
             inserted.ledger = deleted.ledger AND
             inserted.gl_entry = deleted.gl_entry AND
             inserted.ledger_account = deleted.ledger_account

      IF @c_amount <> 0
        BEGIN
          EXECUTE UpdateAccountBalance @s_fiscalyear, @s_ledger,
                     @s_ledgeraccount, @s_balancename,
                     @s_changeduserid, @i_period, @c_amount
        END
    END
END
GO
ALTER TABLE [dbo].[journal_entry_lines] ADD CONSTRAINT [pk_journal_entry_lines] PRIMARY KEY NONCLUSTERED  ([fiscal_year], [ledger], [gl_entry], [ledger_account]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [je_lines_ledger_account] ON [dbo].[journal_entry_lines] ([ledger_account], [fiscal_year], [ledger]) ON [PRIMARY]
GO
