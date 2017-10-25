CREATE TABLE [dbo].[time_cards]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[payroll_date] [datetime] NOT NULL,
[entry_date] [datetime] NOT NULL,
[payroll_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours] [decimal] (18, 6) NULL,
[rate] [decimal] (18, 6) NULL,
[amount] [decimal] (18, 6) NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_worked] [datetime] NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payroll_calculation_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_sequence] [smallint] NULL,
[pay_periods_taxed] [smallint] NULL,
[voucher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_void] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[accrual_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entitle_year] [smallint] NULL,
[time_card_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_worked] [decimal] (18, 6) NULL,
[pieces_paid] [decimal] (18, 6) NULL,
[shift_worked] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount_banked] [decimal] (18, 6) NULL,
[hours_banked] [decimal] (18, 6) NULL,
[division] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[time_card_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[time_card_identity] [numeric] (18, 0) NOT NULL IDENTITY(1, 1),
[fastudentaidid] [int] NULL,
[start_time] [datetime] NULL,
[end_time] [datetime] NULL,
[workstudy_awardyear] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_TimeCards]
        ON [dbo].[time_cards] FOR DELETE

AS

/** The following installations have a custom version of this trigger: **/
/**     Lott has a custom version of this trigger. **/

/** 2/13/2008 Modified to verify that an absence tracking row exists before
              attempting to delete it.
              Modified to verify that an entitlement transactions row exists before
              attempting to delete it.
**/

/** 11/1/2007 Modified to use time_card_identity when deleting entitlement_transactions and
              employee_absences.
**/

  BEGIN
     DECLARE @s_entitlement varchar(25),
             @s_entaccruedtaken CHAR(1),
             @s_enttranstype varchar(25),
             @s_balanceentitlement varchar(25),
             @s_paytype varchar(25),
             @s_employee varchar(25),
             @s_absencetracking CHAR(1),
             @dt_payrolldate DATETIME,
             @dt_entrydate DATETIME,
             @dt_dateworked DATETIME,
             @i_entitleyear SMALLINT,
             @i_rowcount INTEGER,
		 @i_timecardid INT

     /*  Select appropriate columns from the deleted record */
     DECLARE deletetccursor CURSOR FOR
         SELECT pay_type, employee, date_worked,
                payroll_date, entry_date, entitle_year, time_card_identity
           FROM deleted

     OPEN deletetccursor

     FETCH deletetccursor
      INTO @s_paytype, @s_employee, @dt_dateworked,
             @dt_payrolldate, @dt_entrydate, @i_entitleyear, @i_timecardid

     WHILE @@fetch_status = 0

       BEGIN

         /* First do entitlement processing...
            check to see if the entitlement exists in the
            pay_types table...and select it. */
         SELECT @s_entitlement = entitlement,
                @s_entaccruedtaken = entitlement_accrued_taken
           FROM pay_types
          WHERE pay_type = @s_paytype

         IF @@ROWCOUNT <> 0
            BEGIN
              /* a row exists in the pay_types table, now check to see
                 if the balance_entitlement exists in the entitlements
                 table...and select it. */
              SELECT @s_balanceentitlement = balance_entitlement
                FROM entitlements
               WHERE entitlement = @s_entitlement
              IF @@ROWCOUNT <> 0
                 BEGIN
                   /* Since we found a row for this entry in each
                      table, we need to delete the appropriate row. */
                   IF @s_entaccruedtaken = 'A'
                     BEGIN
                       SELECT @s_enttranstype = 'ACCRUAL'
                     END
                   ELSE
                     BEGIN
                       SELECT @s_enttranstype = 'TAKEN'
                     END
                   SELECT @i_rowcount = count(*)
                     FROM entitlement_transactions
                    WHERE employee = @s_employee AND
                          entitle_year = @i_entitleyear AND
                          entitlement = @s_balanceentitlement AND
                          transaction_type = @s_enttranstype AND
                          entered_date = @dt_entrydate AND
                          time_card_identity = @i_timecardid
                   IF @i_rowcount > 0
                      BEGIN
                        DELETE entitlement_transactions
                         WHERE employee = @s_employee AND
                               entitle_year = @i_entitleyear AND
                               entitlement = @s_balanceentitlement AND
                               transaction_type = @s_enttranstype AND
                               entered_date = @dt_entrydate AND
                               time_card_identity = @i_timecardid
                      END
                 END
            END

         /* Next do absence tracking...
            Check to see if the pay type is set up for
            absence tracking. */
         SELECT @s_absencetracking = absence_tracking
           FROM pay_types
          WHERE pay_type = @s_paytype

         IF @@ROWCOUNT <> 0
            BEGIN
              IF @s_absencetracking = 'Y'
                 BEGIN
                   SELECT @i_rowcount = count(*)
                     FROM employee_absences
                    WHERE employee = @s_employee AND
                          pay_type = @s_paytype AND
                          date_worked = @dt_dateworked AND
                          entry_date = @dt_entrydate AND
                          time_card_identity = @i_timecardid
                   IF @i_rowcount > 0
                      BEGIN
                        DELETE employee_absences
                         WHERE employee = @s_employee AND
                               pay_type = @s_paytype AND
                               date_worked = @dt_dateworked AND
                               entry_date = @dt_entrydate AND
                               time_card_identity = @i_timecardid
                      END
                 END
            END

         FETCH deletetccursor INTO @s_paytype, @s_employee,
                 @dt_dateworked, @dt_payrolldate, @dt_entrydate,
                 @i_entitleyear, @i_timecardid

       END

       CLOSE deletetccursor
       DEALLOCATE deletetccursor

  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_TimeCards]
        ON [dbo].[time_cards] FOR INSERT
AS

/** 12/6/2007 Modified to put time_card_comment in entitlement_comment. **/

/** 11/1/2007 Modified to put time_card_identity on entitlement_transactions and
              employee_absences.
**/

/** The following installations have a custom version of this trigger: **/
/**     Tolko has a custom version of this trigger. **/

/** 7/10/2007 Increase size of s_transreference from 25 to 50. **/

/** 10/16/2006 Modified to include time_card_identity when joining on key columns. **/

/** 4/1/2003 The absence tracking comment is updated with the time card comment.
             MS SQL Server does not allow reference to text columns in the inserted or
             deleted tables.  In order to retrieve the time_card_comment, the time_card
             table has to be joined to the inserted table.
**/

  BEGIN
    DECLARE @s_entitlement varchar(25),
            @s_entaccruedtaken CHAR(1),
            @s_enttranstype varchar(25),
            @s_balanceentitlement varchar(25),
            @s_transreference varchar(50),
            @s_paytype varchar(25),
            @s_employee varchar(25),
            @s_accrualid varchar(25),
            @s_absencetracking CHAR(1),
            @s_changeduserid varchar(25),
            @dt_payrolldate DATETIME,
            @dt_entrydate DATETIME,
            @dt_dateworked DATETIME,
            @i_entitleyear SMALLINT,
            @c_hours DECIMAL(18,6),
            @c_hourspaid DECIMAL(18,6),
            @c_hoursworked DECIMAL(18,6),
            @c_hoursbanked DECIMAL(18,6),
            @c_amount DECIMAL(18,6),
            @c_amountbanked DECIMAL(18,6),
            @c_amountpaid DECIMAL(18,6),
            @c_entaccruedfactor DECIMAL(18,6),
            @s_payrollcycle varchar(25),
		@s_comment CHAR(400),
		@i_timecardid INT


    /* First select the appropriate columns from the inserted record. */
    DECLARE inserttccursor CURSOR FOR
       SELECT inserted.pay_type, inserted.employee, inserted.payroll_date, inserted.date_worked,
              inserted.entry_date, inserted.entitle_year, inserted.hours, inserted.amount,
              inserted.changed_user_id, inserted.hours_worked, inserted.hours_banked,
              inserted.amount_banked, inserted.accrual_id, inserted.payroll_cycle,
		  CONVERT(CHAR(400),time_cards.time_card_comment),
		  inserted.time_card_identity
         FROM inserted, time_cards
        WHERE inserted.employee = time_cards.employee and
              inserted.payroll_date = time_cards.payroll_date and
              inserted.entry_date = time_cards.entry_date and
              inserted.time_card_identity = time_cards.time_card_identity

    OPEN inserttccursor

    FETCH inserttccursor
     INTO @s_paytype, @s_employee, @dt_payrolldate, @dt_dateworked,
          @dt_entrydate, @i_entitleyear, @c_hourspaid, @c_amountpaid,
          @s_changeduserid, @c_hoursworked, @c_hoursbanked, @c_amountbanked,
          @s_accrualid, @s_payrollcycle, @s_comment, @i_timecardid

    WHILE @@fetch_status = 0

      BEGIN
        /* First do entitlement processing...
           Check to see if the entitlement exists in the
           pay_types table...and select it. */
        SELECT @s_entitlement = entitlement,
               @s_entaccruedtaken = entitlement_accrued_taken,
               @c_entaccruedfactor = entitlement_accrued_factor
          FROM pay_types
         WHERE pay_type = @s_paytype

        IF @@ROWCOUNT <> 0
           BEGIN
             /* a row exists in the pay_types table, now check to see
                if the balance_entitlement exists in the entitlements
                table...and select it. */
             SELECT @s_balanceentitlement = balance_entitlement
               FROM entitlements
              WHERE entitlement = @s_entitlement

             IF @@ROWCOUNT <> 0
                BEGIN
                  /* Since we found a row for this entry in each
                     table, we need to create an entitlement transaction */
                 IF @s_entaccruedtaken = 'A'
                   BEGIN
                     SELECT @s_enttranstype = 'ACCRUAL'
                     SELECT @c_amount = @c_amountbanked
                     SELECT @c_hours = Round( @c_hoursbanked * @c_entaccruedfactor , 4 )
                   END
                 ELSE
                   BEGIN
                     SELECT @s_enttranstype = 'TAKEN'
                     SELECT @c_amount = @c_amountpaid
                     SELECT @c_hours = @c_hourspaid
                   END
                 IF @s_accrualid IS NULL or @s_accrualid = ''
                   BEGIN
                     SELECT @s_transreference = 'Time Card ' + @s_payrollcycle
                   END
                 ELSE
                   BEGIN
                     SELECT @s_transreference = 'Accrual ID ' + @s_accrualid
                   END
                 IF @s_comment IS NULL or @s_comment = ''
                   BEGIN
                     SELECT @s_comment = 'Time Card'
                   END
                 INSERT INTO entitlement_transactions
                       (entitle_year, employee, entitlement,
                        entered_date, transaction_type, transaction_date,
                        transaction_reference, pay_type, accrued_entitlement,
                        hours, changed_date, changed_user_id, amount, accrual_id,
                        time_card_identity, entitlement_comment )
                    VALUES
                        (@i_entitleyear, @s_employee, @s_balanceentitlement,
                         @dt_entrydate, @s_enttranstype, @dt_dateworked,
                         @s_transreference, @s_paytype, @s_entitlement,
                         @c_hours, GetDate(), @s_changeduserid, @c_amount, @s_accrualid,
                         @i_timecardid, @s_comment )
                 END
           END


        /* Next do absence tracking...
           Check to see if the pay type is set up for
           absence tracking. */
        SELECT @s_absencetracking = absence_tracking
          FROM pay_types
         WHERE pay_type = @s_paytype

        IF @@ROWCOUNT <> 0
           BEGIN
             IF @s_absencetracking = 'Y'
                BEGIN
                  IF @s_comment IS NULL or @s_comment = ''
                     BEGIN
                       SELECT @s_comment = 'Time Card'
                     END
                  INSERT INTO employee_absences
                       (employee, pay_type, date_worked, entry_date,
                        payroll_date, absence_comment, supervisor, hours, cost,
                        changed_date, changed_user_id, time_card_identity )
                    VALUES
                        (@s_employee, @s_paytype, @dt_dateworked,
                         @dt_entrydate, @dt_payrolldate, @s_comment,
                         NULL, @c_hourspaid, @c_amountpaid, GetDate(),
                         @s_changeduserid, @i_timecardid )
                 END
           END

        FETCH inserttccursor
         INTO @s_paytype, @s_employee, @dt_payrolldate, @dt_dateworked,
              @dt_entrydate, @i_entitleyear, @c_hourspaid, @c_amountpaid,
              @s_changeduserid, @c_hoursworked, @c_hoursbanked, @c_amountbanked,
              @s_accrualid, @s_payrollcycle, @s_comment, @i_timecardid

      END

      CLOSE inserttccursor
      DEALLOCATE inserttccursor

  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_TimeCards]
        ON [dbo].[time_cards] FOR UPDATE
AS

/** 2/13/2008 Modified to verify that an absence tracking row exists before
              attempting to delete it.
              Modified to verify that an entitlement transaction row exists before
              attempting to delete it.
**/

/** 12/6/2007 Modified to put time_card_comment in entitlement_comment. **/

/** The following installations have a custom version of this trigger: **/
/**     Tolko has a custom version of this trigger. **/

/** 11/1/2007 Modified to use time_card_identity when updating entitlement_transactions
              and employee_absences.
**/

/** 7/10/2007 Increase size of s_transreference from 25 to 50. **/

/** 10/16/2006 Modified to include time_card_identity when joining on key columns. **/

/** 7/16/2003 The absence tracking comment was not updated with the time card comment.
             Modified the IF statement to include the time_card_comment column. Changed the
			cursor SELECT sstatement to get the new comment from the time card
			since MS SQL Server does not allow you to get a text column from
			the inserted buffer. Changed the insert and update sql for the employee
			absenses to use the time card comment.
**/

IF UPDATE(amount) OR UPDATE(amount_banked) OR UPDATE(hours) OR
   UPDATE(hours_banked) OR UPDATE(hours_worked) OR UPDATE(date_worked) OR
   UPDATE(entitle_year) OR UPDATE(pay_type) or UPDATE(time_card_comment)
  BEGIN
    DECLARE @s_oldentitlement varchar(25),
            @s_newentitlement varchar(25),
            @s_oldbalanceentitlement varchar(25),
            @s_newbalanceentitlement varchar(25),
            @s_accruedentitlement varchar(25),
            @s_accrualid varchar(25),
            @s_payrollcycle varchar(25),
            @s_transreference varchar(50),
            @s_oldpaytype varchar(25),
            @s_newpaytype varchar(25),
            @s_oldentaccruedtaken CHAR(1),
            @s_newentaccruedtaken CHAR(1),
            @c_oldentaccruedfactor DECIMAL(18,6),
            @c_newentaccruedfactor DECIMAL(18,6),
            @s_oldenttranstype varchar(25),
            @s_newenttranstype varchar(25),
            @s_employee varchar(25),
            @s_changeduserid varchar(25),
            @s_oldabsencetracking CHAR(1),
            @s_newabsencetracking CHAR(1),
		@s_time_card_comment CHAR(400),
            @c_hours DECIMAL(18,6),
            @c_hourspaid DECIMAL(18,6),
            @c_hoursworked DECIMAL(18,6),
            @c_hoursbanked DECIMAL(18,6),
            @c_amount DECIMAL(18,6),
            @c_amountpaid DECIMAL(18,6),
            @c_amountbanked DECIMAL(18,6),
            @dt_transdate DATETIME,
            @dt_olddateworked DATETIME,
            @dt_newdateworked DATETIME,
            @dt_entrydate DATETIME,
            @i_oldentitleyear SMALLINT,
            @i_newentitleyear SMALLINT,
            @i_oldrowcount SMALLINT,
            @i_newrowcount SMALLINT,
            @i_rowcount SMALLINT,
            @i_timecardid INT

    /* First select the appropriate data from the updated row. */
    DECLARE updatetccursor CURSOR FOR
      SELECT deleted.pay_type,
             inserted.pay_type,
             inserted.hours,
             inserted.hours_worked,
             inserted.hours_banked,
             inserted.amount,
             inserted.amount_banked,
             deleted.employee,
             deleted.entry_date,
             deleted.date_worked,
             inserted.date_worked,
             deleted.entitle_year,
             inserted.entitle_year,
             inserted.changed_user_id,
             inserted.accrual_id,
             inserted.payroll_cycle,
		 CONVERT(CHAR(400),time_cards.time_card_comment),
             inserted.time_card_identity
        FROM inserted, deleted , time_cards
       WHERE inserted.employee = deleted.employee AND
             inserted.payroll_date = deleted.payroll_date AND
             inserted.entry_date = deleted.entry_date and
             inserted.time_card_identity = deleted.time_card_identity and
		 inserted.employee = time_cards.employee and
             inserted.payroll_date = time_cards.payroll_date and
             inserted.entry_date = time_cards.entry_date and
             inserted.time_card_identity = time_cards.time_card_identity


    OPEN updatetccursor

    FETCH updatetccursor
     INTO @s_oldpaytype, @s_newpaytype, @c_hourspaid, @c_hoursworked,
          @c_hoursbanked, @c_amountpaid, @c_amountbanked,
          @s_employee, @dt_entrydate, @dt_olddateworked,
          @dt_newdateworked, @i_oldentitleyear, @i_newentitleyear,
          @s_changeduserid, @s_accrualid, @s_payrollcycle, @s_time_card_comment,
          @i_timecardid

    WHILE @@fetch_status = 0

      BEGIN

        /* First do entitlement processing...
           Check to see if the entitlement exists in the
           pay_types table...and select it. */
        SELECT @s_oldentitlement = entitlement,
               @s_oldentaccruedtaken = entitlement_accrued_taken,
               @c_oldentaccruedfactor = entitlement_accrued_factor
          FROM pay_types
         WHERE pay_type = @s_oldpaytype
        SELECT @s_newentitlement = entitlement,
               @s_newentaccruedtaken = entitlement_accrued_taken,
               @c_newentaccruedfactor = entitlement_accrued_factor
          FROM pay_types
         WHERE pay_type = @s_newpaytype

        /* check to see if the balance_entitlement exists in the
           entitlements table...and select it. */
        SELECT @s_oldbalanceentitlement = balance_entitlement
          FROM entitlements
         WHERE entitlement = @s_oldentitlement
        SELECT @i_oldrowcount = @@ROWCOUNT
        SELECT @s_newbalanceentitlement = balance_entitlement
          FROM entitlements
         WHERE entitlement = @s_newentitlement
        SELECT @i_newrowcount = @@ROWCOUNT

        IF @i_oldrowcount <> 0
        AND @i_newrowcount <> 0
        AND @s_oldbalanceentitlement = @s_newbalanceentitlement
        AND @s_oldentaccruedtaken = @s_newentaccruedtaken
        AND @i_oldentitleyear = @i_newentitleyear
           BEGIN
             /* Since we found a row for this entry in each
                table, we need to update the appropriate row */
             IF @s_oldentaccruedtaken = 'A'
               BEGIN
                 SELECT @s_oldenttranstype = 'ACCRUAL'
                 SELECT @c_hours = Round( @c_hoursbanked * @c_oldentaccruedfactor, 4 )
                 SELECT @c_amount = @c_amountbanked
               END
             ELSE
               BEGIN
                 SELECT @s_oldenttranstype = 'TAKEN'
                 SELECT @c_hours = @c_hourspaid
                 SELECT @c_amount = @c_amountpaid
               END
             UPDATE entitlement_transactions
                SET hours = @c_hours,
                    amount = @c_amount,
                    transaction_date = @dt_newdateworked,
                    pay_type = @s_newpaytype,
                    accrued_entitlement = @s_newentitlement,
                    entitlement_comment = @s_time_card_comment
              WHERE employee = @s_employee AND
                    entitle_year = @i_oldentitleyear AND
                    entitlement = @s_oldbalanceentitlement AND
                    transaction_type = @s_oldenttranstype AND
                    entered_date = @dt_entrydate AND
                    time_card_identity = @i_timecardid
           END
        ELSE
           BEGIN
             IF @i_oldrowcount <> 0
                /* we will need to delete the old row, if there was one,
                   and insert a new one, if needed, so that the triggers
                   on entitlement_transactions will work */
                BEGIN
                  SELECT @i_rowcount = count(*)
                    FROM entitlement_transactions
                   WHERE entitle_year = @i_oldentitleyear
                     AND employee = @s_employee
                     AND entitlement  = @s_oldbalanceentitlement
                     AND entered_date = @dt_entrydate
                     AND time_card_identity = @i_timecardid
                  IF @i_rowcount > 0
                     BEGIN
                       DELETE entitlement_transactions
                             WHERE entitle_year = @i_oldentitleyear
                               AND employee = @s_employee
                               AND entitlement  = @s_oldbalanceentitlement
                               AND entered_date = @dt_entrydate
                               AND time_card_identity = @i_timecardid
                     END
                END

             IF @i_newrowcount <> 0
                BEGIN
                  IF @s_newentaccruedtaken = 'A'
                    BEGIN
                      SELECT @s_newenttranstype = 'ACCRUAL'
                      SELECT @c_hours = Round( @c_hoursbanked * @c_newentaccruedfactor, 4 )
                      SELECT @c_amount = @c_amountbanked
                    END
                  ELSE
                    BEGIN
                      SELECT @s_newenttranstype = 'TAKEN'
                      SELECT @c_hours = @c_hourspaid
                      SELECT @c_amount = @c_amountpaid
                    END
                  IF @s_accrualid IS NULL or @s_accrualid = ''
                    BEGIN
                      SELECT @s_transreference = 'Time Card ' + @s_payrollcycle
                    END
                  ELSE
                    BEGIN
                      SELECT @s_transreference = 'Accrual ID ' + @s_accrualid
                    END
                  INSERT INTO entitlement_transactions
                        (entitle_year, employee, entitlement,
                         entered_date, transaction_type, transaction_date,
                         transaction_reference, pay_type, accrued_entitlement,
                         hours, changed_date, changed_user_id, amount, accrual_id,
                         time_card_identity, entitlement_comment )
                     VALUES
                        (@i_newentitleyear, @s_employee, @s_newbalanceentitlement,
                         @dt_entrydate, @s_newenttranstype,
                         @dt_newdateworked, @s_transreference,
                         @s_newpaytype, @s_newentitlement, @c_hours, GetDate(),
                         @s_changeduserid, @c_amount, @s_accrualid,
                         @i_timecardid, @s_time_card_comment )
                END
            END

        /* Next do absence tracking...
           Check to see if the pay type is set up for
           absence tracking. */
        SELECT @s_oldabsencetracking = absence_tracking
          FROM pay_types
         WHERE pay_type = @s_oldpaytype

        SELECT @i_oldrowcount = @@ROWCOUNT

        SELECT @s_newabsencetracking = absence_tracking
          FROM pay_types
         WHERE pay_type = @s_newpaytype

        SELECT @i_newrowcount = @@ROWCOUNT

        IF @i_oldrowcount <> 0 AND @i_newrowcount <> 0
           BEGIN
             IF @s_oldabsencetracking = 'Y' AND @s_newabsencetracking = 'Y'
                BEGIN
                  UPDATE employee_absences
                     SET pay_type = @s_newpaytype,
                         hours = @c_hourspaid,
                         cost = @c_amountpaid,
                         date_worked = @dt_newdateworked,
			 absence_comment = @s_time_card_comment
                   WHERE employee = @s_employee AND
                         pay_type = @s_oldpaytype AND
                         date_worked = @dt_olddateworked AND
                         entry_date = @dt_entrydate AND
                         time_card_identity = @i_timecardid
                 END

             IF @s_oldabsencetracking <> 'Y' AND @s_newabsencetracking = 'Y'
                 BEGIN
                   INSERT INTO employee_absences
                    (employee, pay_type, date_worked, entry_date,
                     absence_comment, hours, cost,
                     changed_date, changed_user_id, time_card_identity)
                   VALUES
                    (@s_employee, @s_newpaytype, @dt_newdateworked, @dt_entrydate,
                     @s_time_card_comment, @c_hourspaid, @c_amountpaid,
                     GetDate(), @s_changeduserid, @i_timecardid)
                 END

             IF @s_oldabsencetracking = 'Y' AND @s_newabsencetracking <> 'Y'
                 BEGIN
                   SELECT @i_rowcount = count(*)
                     FROM employee_absences
                    WHERE employee = @s_employee AND
                          pay_type = @s_oldpaytype AND
                          date_worked = @dt_olddateworked AND
                          entry_date = @dt_entrydate AND
                          time_card_identity = @i_timecardid
                   IF @i_rowcount > 0
                      BEGIN
                        DELETE employee_absences
                        WHERE employee = @s_employee AND
                              pay_type = @s_oldpaytype AND
                              date_worked = @dt_olddateworked AND
                              entry_date = @dt_entrydate AND
                              time_card_identity = @i_timecardid
                      END
                 END
           END

           FETCH updatetccursor
            INTO @s_oldpaytype, @s_newpaytype, @c_hourspaid, @c_hoursworked,
                 @c_hoursbanked, @c_amountpaid, @c_amountbanked,
                 @s_employee, @dt_entrydate, @dt_olddateworked,
                 @dt_newdateworked, @i_oldentitleyear, @i_newentitleyear,
                 @s_changeduserid, @s_accrualid, @s_payrollcycle, @s_time_card_comment,
                 @i_timecardid

      END

      CLOSE updatetccursor
      DEALLOCATE updatetccursor

  END
GO
ALTER TABLE [dbo].[time_cards] ADD CONSTRAINT [pk_time_cards] PRIMARY KEY CLUSTERED  ([employee], [payroll_date], [entry_date], [time_card_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [time_cards_accrualid] ON [dbo].[time_cards] ([accrual_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [time_cards_batch] ON [dbo].[time_cards] ([batch], [payroll_cycle], [payroll_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [time_cards_payroll_calcid] ON [dbo].[time_cards] ([payroll_calculation_id], [voucher], [check_void]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [time_cards_crew] ON [dbo].[time_cards] ([payroll_cycle], [crew], [payroll_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [time_cards_cycle_employee] ON [dbo].[time_cards] ([payroll_cycle], [employee], [voucher]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [time_cards_payroll_cycle] ON [dbo].[time_cards] ([payroll_cycle], [time_card_group], [payroll_date]) ON [PRIMARY]
GO
