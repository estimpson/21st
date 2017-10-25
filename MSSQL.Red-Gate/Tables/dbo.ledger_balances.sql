CREATE TABLE [dbo].[ledger_balances]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [smallint] NOT NULL,
[period_amount] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[to_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_LedgerBalances]
ON [dbo].[ledger_balances] FOR INSERT
AS
BEGIN
  /*  Make sure that new ledger balance amount gets posted to the
      appropriate balance(s) for the appropriate period  */

  DECLARE @s_fiscalyear varchar(5),
          @s_ledger varchar(40),
          @s_ledgeraccount varchar(50),
          @s_balancename varchar(40),
          @i_period smallint,
          @c_periodamount decimal(18,6),
          @s_changeduserid varchar(25),
          @i_rowcount int

  /*  Determine how many rows there are to process.  */
  SELECT @i_rowcount=Count(*) FROM inserted

  IF @i_rowcount = 1
    /*  Have exactly 1 row. No need for a cursor. This should be the
        case for everything but a year-end balance copy.
    */
    BEGIN

      /*  Select the appropriate columns  */
      SELECT @s_fiscalyear=fiscal_year, @s_ledger=ledger,
             @s_ledgeraccount=ledger_account, @s_balancename=balance_name,
             @i_period=period, @c_periodamount=period_amount,
             @s_changeduserid=changed_user_id
        FROM inserted

      /*  Update the appropriate balances */
      EXECUTE UpdateGLBalances @s_fiscalyear, @s_ledger,
                               @s_ledgeraccount, @s_balancename,
                               @s_changeduserid, @i_period,
                               @c_periodamount

    END

  ELSE
    BEGIN
      /* Have multiple rows. This should only happen when the year-end
         copy balances program does its mass insert.
      */
      DECLARE insertedcursor CURSOR FOR
          SELECT fiscal_year, ledger, ledger_account, balance_name,
                 period, period_amount, changed_user_id
            FROM inserted

      OPEN insertedcursor

      /*  prime fetch  */
      FETCH insertedcursor INTO @s_fiscalyear, @s_ledger, @s_ledgeraccount,
                                @s_balancename, @i_period,
                                @c_periodamount, @s_changeduserid

      WHILE @@FETCH_STATUS = 0
        BEGIN
          /*  any fetch status other than 0 will stop the loop  */

          EXECUTE UpdateGLBalances @s_fiscalyear, @s_ledger,
                                   @s_ledgeraccount, @s_balancename,
                                   @s_changeduserid, @i_period,
                                   @c_periodamount

          /*  get the next inserted record, if any  */
          FETCH insertedcursor INTO @s_fiscalyear, @s_ledger, @s_ledgeraccount,
                                    @s_balancename, @i_period,
                                    @c_periodamount, @s_changeduserid
        END
      /* Don't need the cursor any longer. */
      CLOSE insertedcursor
      DEALLOCATE insertedcursor
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_LedgerBalances]
ON [dbo].[ledger_balances] FOR UPDATE
AS
BEGIN
  /*  The update has to be for the SAME
                 fiscal year/ledger/account/balance/period.
      Procedures and triggers prior to this trigger should never allow an
      update to this file that would change the fiscal year, ledger,
      account, balance name or period.

      Compute the net difference from the new period balance amount to the
      old then update the ledger account balance with the net change.  */

  DECLARE @s_fiscalyear varchar(5),
          @s_ledger varchar(40),
          @s_ledgeraccount varchar(50),
          @s_balancename varchar(40),
          @i_period smallint,
          @s_changeduserid varchar(25),
          @c_periodamount decimal(18,6),
          @i_rowcount int


  /*  Determine how many rows there are to process.  */
  SELECT @i_rowcount=Count(*) FROM inserted

  IF @i_rowcount = 1
    /*  Have exactly 1 row. No need for a cursor. This should be the
        case for everything but a year-end balance copy.
    */
    BEGIN

      /*  Select the appropriate columns  */
      SELECT @s_fiscalyear=inserted.fiscal_year,
             @s_ledger=inserted.ledger,
             @s_ledgeraccount=inserted.ledger_account,
             @s_balancename=inserted.balance_name,
             @i_period=inserted.period,
             @s_changeduserid=inserted.changed_user_id,
             @c_periodamount=inserted.period_amount - deleted.period_amount
        FROM inserted, deleted
       WHERE inserted.fiscal_year = deleted.fiscal_year AND
             inserted.ledger = deleted.ledger AND
             inserted.ledger_account = deleted.ledger_account AND
             inserted.balance_name = deleted.balance_name AND
             inserted.period = deleted.period

      IF @c_periodamount <> 0
        BEGIN
          EXECUTE UpdateGLBalances @s_fiscalyear, @s_ledger,
                                   @s_ledgeraccount, @s_balancename,
                                   @s_changeduserid, @i_period, @c_periodamount
        END
    END

  ELSE
    BEGIN
      /* Have multiple rows. This should only happen when the year-end
         copy balances program does its mass insert.
      */
      DECLARE updatecursor CURSOR FOR
          SELECT inserted.fiscal_year, inserted.ledger,
                 inserted.ledger_account, inserted.balance_name,
                 inserted.period, inserted.changed_user_id,
                 inserted.period_amount - deleted.period_amount
            FROM inserted, deleted
            WHERE inserted.fiscal_year = deleted.fiscal_year AND
                  inserted.ledger = deleted.ledger AND
                  inserted.ledger_account = deleted.ledger_account AND
                  inserted.balance_name = deleted.balance_name AND
                  inserted.period = deleted.period

      OPEN updatecursor

      /*  prime fetch  */
      FETCH updatecursor INTO @s_fiscalyear, @s_ledger,
                              @s_ledgeraccount, @s_balancename,
                              @i_period, @s_changeduserid,
                              @c_periodamount

      WHILE @@FETCH_STATUS = 0
        BEGIN
          /*  any fetch status other than 0 will stop the loop  */

          IF @c_periodamount <> 0
            BEGIN
              EXECUTE UpdateGLBalances @s_fiscalyear, @s_ledger,
                                       @s_ledgeraccount, @s_balancename,
                                       @s_changeduserid, @i_period,
                                       @c_periodamount
            END

         /*  get the next updated record, if any  */
         FETCH updatecursor INTO @s_fiscalyear, @s_ledger,
                                  @s_ledgeraccount, @s_balancename,
                                  @i_period, @s_changeduserid,
                                  @c_periodamount

        END

      /* Don't need the cursor any longer. */
      CLOSE updatecursor
      DEALLOCATE updatecursor
    END
END
GO
ALTER TABLE [dbo].[ledger_balances] ADD CONSTRAINT [pk_ledger_balances] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [ledger_account], [balance_name], [period]) ON [PRIMARY]
GO
