CREATE TABLE [dbo].[entitlement_transactions]
(
[entitle_year] [smallint] NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[entitlement] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[entered_date] [datetime] NOT NULL,
[transaction_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transaction_date] [datetime] NULL,
[transaction_reference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[accrued_entitlement] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours] [decimal] (18, 6) NULL,
[accrual_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[accrual_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [decimal] (18, 6) NULL,
[entered_date_taken] [datetime] NULL,
[dr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payroll_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_sequence] [smallint] NULL,
[payroll_calculation_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[voucher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_void] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate] [decimal] (18, 6) NULL,
[entitlement_identity] [int] NOT NULL IDENTITY(1, 1),
[time_card_identity] [int] NULL,
[entitlement_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_EntitlementTransactions]
        ON [dbo].[entitlement_transactions] FOR DELETE

AS
  BEGIN

    DECLARE @c_hoursaccrued DECIMAL(18,6),
            @c_hourstaken DECIMAL(18,6),
            @c_hoursaccruedcarry DECIMAL(18,6),
            @c_amountaccrued DECIMAL(18,6),
            @c_amounttaken DECIMAL(18,6),
            @c_amountaccruedcarry DECIMAL(18,6),
            @c_hours DECIMAL(18,6),
            @c_amount DECIMAL(18,6),
            @s_employee varchar(25),
            @s_entitlement varchar(25),
            @s_transactiontype varchar(25),
            @s_transactionreference varchar(50),
            @i_entitleyear SMALLINT,
            @i_rowcount INT

    /*  Select appropriate columns from the deleted record */
    DECLARE deletedenttrncursor CURSOR FOR
        SELECT hours, entitle_year, employee,
               entitlement, transaction_type,
               transaction_reference, amount
          FROM deleted

    OPEN deletedenttrncursor

    FETCH deletedenttrncursor
     INTO @c_hours, @i_entitleyear, @s_employee,
          @s_entitlement, @s_transactiontype,
          @s_transactionreference, @c_amount

     WHILE @@fetch_status = 0

      BEGIN

        /* set the values to zero so we can set the data in the tables later. */
        SELECT @c_hoursaccrued = 0
        SELECT @c_hoursaccruedcarry = 0
        SELECT @c_hourstaken = 0
        SELECT @c_amountaccrued = 0
        SELECT @c_amountaccruedcarry = 0
        SELECT @c_amounttaken = 0

        /* check to see what the transaction type was so we can
           add the hours to the appropriate column. */
        IF @s_transactiontype = 'ACCRUAL'
           BEGIN
             IF UPPER(@s_transactionreference) = 'CARRYOVER'
                BEGIN
                  SELECT @c_hoursaccruedcarry = @c_hours
                  SELECT @c_amountaccruedcarry = @c_amount
                END
             ELSE
                BEGIN
                  SELECT @c_hoursaccrued = @c_hours
                  SELECT @c_amountaccrued = @c_amount
                END
           END
        ELSE
           BEGIN
             /* if the trans type is not accrual... */
             SELECT @c_hourstaken = @c_hours
             SELECT @c_amounttaken = @c_amount
           END

        /* We need to update the hours.
           Subtract them from the appropriate columns. */
        UPDATE entitlement_balances
             SET hours_accrued = hours_accrued - @c_hoursaccrued,
                 hours_accrued_carryover = hours_accrued_carryover - @c_hoursaccruedcarry,
                 hours_taken = hours_taken - @c_hourstaken,
                 amount_accrued = amount_accrued - @c_amountaccrued,
                 amount_accrued_carryover = amount_accrued_carryover - @c_amountaccruedcarry,
                 amount_taken = amount_taken - @c_amounttaken
             WHERE entitle_year = @i_entitleyear AND
                   employee = @s_employee AND
                   entitlement = @s_entitlement

        FETCH deletedenttrncursor
         INTO @c_hours, @i_entitleyear, @s_employee,
              @s_entitlement, @s_transactiontype,
              @s_transactionreference, @c_amount

      END

      CLOSE deletedenttrncursor
      DEALLOCATE deletedenttrncursor

  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_EntitlementTransactions]
        ON [dbo].[entitlement_transactions] FOR INSERT

AS
  BEGIN

    DECLARE @c_hoursaccrued DECIMAL(18,6),
            @c_hourstaken DECIMAL(18,6),
            @c_hoursaccruedcarry DECIMAL (18,6),
            @c_amountaccrued DECIMAL(18,6),
            @c_amounttaken DECIMAL(18,6),
            @c_amountaccruedcarry DECIMAL (18,6),
            @i_entitleyear smallint,
            @s_dummy varchar(25),
            @s_employee varchar(25),
            @s_entitlement varchar(25),
            @s_transactiontype varchar(25),
            @s_transactionreference varchar(50),
            @s_changeduserid varchar(25),
            @c_hours DECIMAL(18,6),
            @c_amount DECIMAL(18,6)

    /* select the appropriate columns from the inserted record */
    DECLARE insertedenttrncursor CURSOR FOR
       SELECT entitle_year, employee, entitlement,
              transaction_type, transaction_reference,
              hours, changed_user_id, amount
         FROM inserted

    OPEN insertedenttrncursor

    FETCH insertedenttrncursor INTO @i_entitleyear,
          @s_employee, @s_entitlement,
          @s_transactiontype, @s_transactionreference,
          @c_hours, @s_changeduserid, @c_amount

     WHILE @@fetch_status = 0

      BEGIN
        /* set the values to zero so we can set the data in the tables later. */
        SELECT @c_hoursaccrued = 0
        SELECT @c_hoursaccruedcarry = 0
        SELECT @c_hourstaken = 0
        SELECT @c_amountaccrued = 0
        SELECT @c_amountaccruedcarry = 0
        SELECT @c_amounttaken = 0

        /* check to see what the transaction type was and
           add the hours to the appropriate column. */
        IF @s_transactiontype = 'ACCRUAL'
           BEGIN
             IF UPPER(@s_transactionreference) = 'CARRYOVER'
                BEGIN
	            SELECT @c_hoursaccruedcarry = @c_hours
	            SELECT @c_amountaccruedcarry = @c_amount
                END
             ELSE
                BEGIN
	            SELECT @c_hoursaccrued = @c_hours
	            SELECT @c_amountaccrued = @c_amount
                END
           END
        ELSE
           BEGIN
             /* if the trans type is not accrual... */
             SELECT @c_hourstaken = @c_hours
             SELECT @c_amounttaken = @c_amount
           END

         /*  determine if a row already exists in the table */
        SELECT @s_dummy = employee
          FROM entitlement_balances
         WHERE entitle_year = @i_entitleyear AND
               employee = @s_employee AND
               entitlement = @s_entitlement

        IF @@ROWCOUNT > 0
           BEGIN
             /* Since we found a row for this employee/entitlement we need
                to update the hours. */

             UPDATE entitlement_balances
                SET hours_accrued = hours_accrued + @c_hoursaccrued,
                    hours_accrued_carryover = hours_accrued_carryover + @c_hoursaccruedcarry,
                    hours_taken = hours_taken + @c_hourstaken,
                    amount_accrued = amount_accrued + @c_amountaccrued,
                    amount_accrued_carryover = amount_accrued_carryover + @c_amountaccruedcarry,
                    amount_taken = amount_taken + @c_amounttaken
              WHERE entitle_year = @i_entitleyear AND
                    employee = @s_employee AND
                    entitlement = @s_entitlement
           END
        ELSE
           BEGIN
             /* since we didn't find an entry we need to do an insert, not update */
             INSERT INTO entitlement_balances
                         (entitle_year, employee, entitlement,
                          hours_accrued, hours_accrued_carryover,
                          hours_taken, changed_date, changed_user_id,
                          amount_accrued, amount_accrued_carryover,
                          amount_taken )
                     VALUES
                         (@i_entitleyear, @s_employee,
                          @s_entitlement, @c_hoursaccrued,
                          @c_hoursaccruedcarry, @c_hourstaken,
                          GetDate(), @s_changeduserid,
                          @c_amountaccrued,
                          @c_amountaccruedcarry, @c_amounttaken )
           END

         FETCH insertedenttrncursor into @i_entitleyear,
               @s_employee, @s_entitlement,
               @s_transactiontype, @s_transactionreference,
               @c_hours, @s_changeduserid, @c_amount
      END

      CLOSE insertedenttrncursor
      DEALLOCATE insertedenttrncursor

  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_EntitlementTransactions]
        ON [dbo].[entitlement_transactions] FOR UPDATE

/** 11/01/2007 Modified to include entitlement_identity when joining on key columns. **/

AS BEGIN
    DECLARE @c_hoursaccrued DECIMAL(18,6),
            @c_hourstaken DECIMAL(18,6),
            @c_hoursaccruedcarry DECIMAL(18,6),
            @c_amountaccrued DECIMAL(18,6),
            @c_amounttaken DECIMAL(18,6),
            @c_amountaccruedcarry DECIMAL(18,6),
            @s_newtransactiontype varchar(25),
            @s_oldtransactiontype varchar(25),
            @s_transactionreference varchar(50),
            @s_employee varchar(25),
            @s_entitlement varchar(25),
            @i_entitleyear SMALLINT,
            @c_newhours DECIMAL(18,6),
            @c_oldhours DECIMAL(18,6),
            @c_newamount DECIMAL(18,6),
            @c_oldamount DECIMAL(18,6)

    /* First select the appropriate columns from the updated record. */
    DECLARE updatedenttrncursor CURSOR FOR
      SELECT inserted.transaction_type,
             deleted.transaction_type,
             inserted.transaction_reference,
             inserted.hours, deleted.hours,
             inserted.amount, deleted.amount,
             inserted.entitle_year, inserted.employee,
             inserted.entitlement
        FROM inserted,deleted
       WHERE inserted.entitle_year = deleted.entitle_year AND
             inserted.employee = deleted.employee AND
             inserted.entitlement = deleted.entitlement AND
             inserted.entered_date = deleted.entered_date AND
             inserted.entitlement_identity = deleted.entitlement_identity

    OPEN updatedenttrncursor

    FETCH updatedenttrncursor
     INTO @s_newtransactiontype, @s_oldtransactiontype,
          @s_transactionreference, @c_newhours, @c_oldhours,
          @c_newamount, @c_oldamount, @i_entitleyear,
          @s_employee, @s_entitlement

     WHILE @@fetch_status = 0

      BEGIN
        /* set the values to zero so we can set the data in the tables later. */
        SELECT @c_hoursaccrued = 0
        SELECT @c_hoursaccruedcarry = 0
        SELECT @c_hourstaken = 0
        SELECT @c_amountaccrued = 0
        SELECT @c_amountaccruedcarry = 0
        SELECT @c_amounttaken = 0

        /* first check to see if the transaction type was changed */
        IF @s_newtransactiontype <> @s_oldtransactiontype
           BEGIN
              IF @s_oldtransactiontype = 'ACCRUAL'
                 BEGIN
                   /* transaction type was changed from ACCRUAL to TAKEN so
                      subtract the old hours from accrued and add the new
                      hours to taken */
                   UPDATE entitlement_balances
                      SET hours_accrued = hours_accrued - @c_oldhours,
/*                        hours_accrued_carryover = hours_accrued_carryover + @c_hoursaccruedcarry, */
                          hours_taken = hours_taken + @c_newhours,
                          amount_accrued = amount_accrued - @c_oldamount,
                          amount_taken = amount_taken + @c_newamount
                    WHERE entitle_year = @i_entitleyear AND
                          employee = @s_employee AND
                          entitlement = @s_entitlement
                 END
              ELSE
                 BEGIN
                   /* transaction type was changed from TAKEN to ACCRUAL so
                      subtract the old hours from taken and add the new
                      hours to accrued */
                   UPDATE entitlement_balances
                      SET hours_taken = hours_taken - @c_oldhours,
/*                        hours_accrued_carryover = hours_accrued_carryover + c_hoursaccruedcarry, */
                          hours_accrued = hours_accrued + @c_newhours,
                          amount_taken = amount_taken - @c_oldamount,
                          amount_accrued = amount_accrued + @c_newamount
                    WHERE entitle_year = @i_entitleyear AND
                          employee = @s_employee AND
                          entitlement = @s_entitlement
                 END
           END
        ELSE
           BEGIN
             /* check to see what the transaction type was and
                add the hours to the appropriate column. */
             IF @s_newtransactiontype = 'ACCRUAL'
                BEGIN
                  IF UPPER(@s_transactionreference) = 'CARRYOVER'
                     BEGIN
                       SELECT @c_hoursaccruedcarry = @c_newhours - @c_oldhours
                       SELECT @c_amountaccruedcarry = @c_newamount - @c_oldamount
                     END
                  ELSE
                     BEGIN
                       SELECT @c_hoursaccrued = @c_newhours - @c_oldhours
                       SELECT @c_amountaccrued = @c_newamount - @c_oldamount
                     END
                END
             ELSE
                BEGIN
                  /* if the trans type is not accrual... */
                  SELECT @c_hourstaken = @c_newhours - @c_oldhours
                  SELECT @c_amounttaken = @c_newamount - @c_oldamount
                END

             /* we need to update the hours
                add them to the appropriate columns. */
             UPDATE entitlement_balances
                SET hours_accrued = hours_accrued + @c_hoursaccrued,
                    hours_accrued_carryover = hours_accrued_carryover + @c_hoursaccruedcarry,
                    hours_taken = hours_taken + @c_hourstaken,
                    amount_accrued = amount_accrued + @c_amountaccrued,
                    amount_accrued_carryover = amount_accrued_carryover + @c_amountaccruedcarry,
                    amount_taken = amount_taken + @c_amounttaken
              WHERE entitle_year = @i_entitleyear AND
                    employee = @s_employee AND
                    entitlement = @s_entitlement
           END
        FETCH updatedenttrncursor
         INTO @s_newtransactiontype, @s_oldtransactiontype,
              @s_transactionreference, @c_newhours, @c_oldhours,
              @c_newamount, @c_oldamount, @i_entitleyear,
              @s_employee, @s_entitlement

      END

      CLOSE updatedenttrncursor
      DEALLOCATE updatedenttrncursor
  END
GO
ALTER TABLE [dbo].[entitlement_transactions] ADD CONSTRAINT [pk_entitlement_transactions] PRIMARY KEY CLUSTERED  ([entitle_year], [employee], [entitlement], [entered_date], [entitlement_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entitlements_accrualid] ON [dbo].[entitlement_transactions] ([accrual_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entitlements_voucher] ON [dbo].[entitlement_transactions] ([entitle_year], [employee], [entitlement], [payroll_calculation_id], [voucher], [check_void]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entitlements_payroll_cycle] ON [dbo].[entitlement_transactions] ([payroll_cycle], [employee]) ON [PRIMARY]
GO
