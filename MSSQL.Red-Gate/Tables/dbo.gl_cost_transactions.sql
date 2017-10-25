CREATE TABLE [dbo].[gl_cost_transactions]
(
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_line] [smallint] NOT NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[contract_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[contract_account_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[costrevenue_type_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[transaction_date] [datetime] NULL,
[amount] [decimal] (18, 6) NULL,
[document_amount] [decimal] (18, 6) NULL,
[document_currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exchange_date] [datetime] NULL,
[exchange_rate] [decimal] (12, 6) NULL,
[document_reference1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_reference2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_remarks] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[application] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [decimal] (18, 6) NULL,
[unit_of_measure] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_defined_text] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_defined_number] [decimal] (18, 6) NULL,
[user_defined_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_balances] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fa_depreciation_calc_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_GlCostTransactions]
ON [dbo].[gl_cost_transactions] FOR DELETE
AS

-- 09-Oct-2006	Moved to Transact and modified accordingly.

BEGIN

  DECLARE @i_deletedrows int,
          @s_fiscalyear varchar(5),
          @s_ledger varchar(40),
          @s_glentry varchar(25),
          @s_ledgeraccount varchar(50),
          @s_updatebalances char(1),
          @c_amount dec(18,6)

  /*  save the number of rows that were just deleted, if any  */
  SELECT @i_deletedrows = @@rowcount

  IF @i_deletedrows > 0
    BEGIN
      IF @i_deletedrows = 1
        BEGIN
           /*  Only 1 row was deleted. Did it update the balances? */
          SELECT @s_updatebalances=IsNull(update_balances, 'Y')
            FROM deleted

          IF @s_updatebalances = 'Y'
            BEGIN
              UPDATE journal_entry_lines
                 SET journal_entry_lines.amount = journal_entry_lines.amount -
                     deleted.amount
                FROM deleted
               WHERE journal_entry_lines.fiscal_year=deleted.fiscal_year
                 AND journal_entry_lines.ledger=deleted.ledger
                 AND journal_entry_lines.gl_entry=deleted.gl_entry
                 AND journal_entry_lines.ledger_account=deleted.ledger_account
            END
        END
      ELSE
        BEGIN
          /*  more than 1 row was deleted  */

          DECLARE deletedcursor CURSOR FOR
            SELECT fiscal_year, ledger, gl_entry, ledger_account,
                   IsNull(update_balances,'Y'),
                   SUM(amount)
              FROM deleted
             GROUP BY fiscal_year, ledger, gl_entry, ledger_account,
                      IsNull(update_balances,'Y')

          OPEN deletedcursor

          /*  prime fetch  */
          FETCH deletedcursor INTO @s_fiscalyear, @s_ledger, @s_glentry,
                                      @s_ledgeraccount, @s_updatebalances,
                                      @c_amount

          /* any status from the fetch other than 0 will terminate the loop. */
          WHILE @@fetch_status = 0

            BEGIN
              IF @s_updatebalances = 'Y'
                BEGIN

                  /*  cursor will summarize amounts by fiscal year, ledger,
                      gl entry and account so that we only issue an update
                      once per this combination.  */
                  UPDATE journal_entry_lines
                     SET journal_entry_lines.amount =
                           journal_entry_lines.amount - @c_amount
                   WHERE journal_entry_lines.fiscal_year=@s_fiscalyear
                     AND journal_entry_lines.ledger=@s_ledger
                     AND journal_entry_lines.gl_entry=@s_glentry
                     AND journal_entry_lines.ledger_account=@s_ledgeraccount

                END
                /*  get the next group of deleted records, if any */
                FETCH deletedcursor
                 INTO @s_fiscalyear, @s_ledger, @s_glentry,
                      @s_ledgeraccount, @s_updatebalances, @c_amount
            END

            /*  don't need this cursor any longer  */
            CLOSE deletedcursor
            DEALLOCATE deletedcursor

          END
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_GlCostTransactions]
ON [dbo].[gl_cost_transactions] FOR INSERT
AS

-- 09-Oct-2006	Moved to Transact and modified accordingly.

BEGIN
  DECLARE @s_fiscalyear varchar(5),
          @s_ledger varchar(40),
          @s_glentry varchar(25),
          @s_ledgeraccount varchar(50),
          @i_period smallint,
          @c_amount decimal(18,6),
          @s_updatebalances char(1),
          @s_changeduserid varchar(25),
          @s_balancename varchar(40),
          @c_jelineamount decimal(18,6)

  DECLARE insertedcursor CURSOR FOR
      SELECT fiscal_year, ledger, gl_entry, ledger_account, period,
             amount, IsNull(update_balances, 'Y'),
             changed_user_id
        FROM inserted

  OPEN insertedcursor

  /*  prime fetch  */
  FETCH insertedcursor INTO @s_fiscalyear, @s_ledger, @s_glentry,
                            @s_ledgeraccount, @i_period, @c_amount,
                            @s_updatebalances, @s_changeduserid

  WHILE @@fetch_status = 0
    BEGIN
      /*  any fetch status other than 0 will stop the loop  */

      IF @s_updatebalances = 'Y'
        BEGIN
          /*  Lookup the entry header record to determine the balance name */
          SELECT @s_balancename = balance_name
            FROM journal_entries
           WHERE fiscal_year = @s_fiscalyear AND
                 ledger = @s_ledger AND
                 gl_entry = @s_glentry

          /*  determine if a row already exists in the journal_entry_lines
              table for this gl entry/account and select the amount column
              while we're at it.  */
          SELECT @c_jelineamount = amount
            FROM journal_entry_lines
           WHERE fiscal_year = @s_fiscalyear AND
                 ledger = @s_ledger AND
                 gl_entry = @s_glentry AND
                 ledger_account = @s_ledgeraccount

          IF @@ROWCOUNT > 0
            BEGIN
              /*  Since we found a journal entry line for this entry/account we
                  need to update the amount  */

              /*  Add the new transaction amount to the amount that is
                  already there for this entry line item */

              UPDATE journal_entry_lines
                 SET amount = amount + @c_amount
               WHERE fiscal_year = @s_fiscalyear AND
                     ledger = @s_ledger AND
                     gl_entry = @s_glentry AND
                     ledger_account = @s_ledgeraccount
            END

          ELSE
            /*  assume that any error means row not found  which means
                that we need to do an insert not an update  */

            BEGIN

              INSERT INTO journal_entry_lines
                    ( fiscal_year, ledger, gl_entry, ledger_account,
                      period, balance_name, amount,
                      changed_date, changed_user_id )
                 VALUES
                    ( @s_fiscalyear, @s_ledger, @s_glentry,
                      @s_ledgeraccount,
                      @i_period, @s_balancename, @c_amount,
                      GETDATE(), @s_changeduserid )
            END

        END

      /*  read the next inserted row, if any  */
      FETCH insertedcursor INTO @s_fiscalyear, @s_ledger, @s_glentry,
                              @s_ledgeraccount, @i_period, @c_amount,
                              @s_updatebalances, @s_changeduserid
    END

  /*  don't need this cursor any longer */
  CLOSE insertedcursor
  DEALLOCATE insertedcursor
END
GO
ALTER TABLE [dbo].[gl_cost_transactions] ADD CONSTRAINT [pk_gl_cost_transactions] PRIMARY KEY NONCLUSTERED  ([document_id1], [document_id2], [document_id3], [document_type], [document_line], [ledger_account], [contract_id], [contract_account_id], [costrevenue_type_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [glcosttrans_cost_account] ON [dbo].[gl_cost_transactions] ([contract_account_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [glcosttrans_doc_type] ON [dbo].[gl_cost_transactions] ([fiscal_year], [ledger], [document_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [glcosttrans_gl_entry] ON [dbo].[gl_cost_transactions] ([gl_entry]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [glcosttrans_ledger_account] ON [dbo].[gl_cost_transactions] ([ledger_account], [fiscal_year], [ledger]) ON [PRIMARY]
GO
