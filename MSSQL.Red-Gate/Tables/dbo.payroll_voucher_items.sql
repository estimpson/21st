CREATE TABLE [dbo].[payroll_voucher_items]
(
[payroll_calculation_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[voucher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[voucher_sequence] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[voucher_line] [int] NOT NULL,
[check_void] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[check_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [decimal] (18, 6) NULL,
[basis] [decimal] (18, 6) NULL,
[hours] [decimal] (18, 6) NULL,
[rate] [decimal] (18, 6) NULL,
[source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gross] [decimal] (18, 6) NULL,
[pay_periods_taxed] [smallint] NULL,
[update_ytd_balances] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transit_routing_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[basis_hours] [decimal] (18, 6) NULL,
[hours_worked] [decimal] (18, 6) NULL,
[pieces_paid] [decimal] (18, 6) NULL,
[amount_banked] [decimal] (18, 6) NULL,
[hours_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wcb_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_banked] [decimal] (18, 6) NULL,
[entitle_year] [smallint] NULL,
[dd_foreign] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_foreign_bank] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_type_before_void] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_PayrollVoucherItems]
  ON [dbo].[payroll_voucher_items] FOR DELETE

/* 12/20/2005 Changed WHERE clause for deleting entitlement_transactions.

   3/19/2003  Added basis_hours.

   3/05/2003  Do not update a employee_ytd_balances row if the
              document is 'ENT'.

   11/06/2002 Delete the entitlement_transaction if this is an entitlement
              document with a source of 'AUTO' and upd_ytd_balances = 'Y'.

   10/23/2002 Added new columns hours_worked, pieces_paid, amount_banked
              and hours_banked. */

AS
BEGIN
  DECLARE @s_employee varchar(25),
          @i_calendaryear integer,
          @i_entitleyear integer,
          @s_balanceentitlement varchar(25),
          @s_updateytdbalances char(1),
          @s_payrollcalculationid varchar(25),
          @s_voucher varchar(25),
          @s_vouchersequence varchar(25),
          @s_checkvoid char(1),
          @s_document varchar(25),
          @s_documenttype varchar(25),
          @s_payer char(1),
          @s_source varchar(5),
          @c_hours decimal(18,6),
          @c_basishours decimal(18,6),
          @c_hoursworked decimal(18,6),
          @c_hoursbanked decimal(18,6),
          @c_piecespaid decimal(18,6),
          @c_amount decimal(18,6),
          @c_amountbanked decimal(18,6),
          @c_basis decimal(18,6),
          @c_gross decimal(18,6),
          @d_changeddate datetime,
          @i_rowcount integer

  DECLARE deletedpvicursor CURSOR FOR
      /*  Select appropriate columns from the deleted record */
      SELECT update_ytd_balances,
             payroll_calculation_id,
             voucher,
             voucher_sequence,
             check_void,
             document,
             document_type,
             payer,
             source,
             hours,
             amount,
             basis,
             gross,
             basis_hours,
             hours_worked,
             pieces_paid,
             amount_banked,
             hours_banked,
             changed_date,
             entitle_year
        FROM deleted

  OPEN deletedpvicursor

  FETCH deletedpvicursor
   INTO @s_updateytdbalances, @s_payrollcalculationid,
        @s_voucher, @s_vouchersequence, @s_checkvoid,
        @s_document, @s_documenttype, @s_payer, @s_source,
        @c_hours, @c_amount, @c_basis, @c_gross, @c_basishours,
        @c_hoursworked, @c_piecespaid, @c_amountbanked,
        @c_hoursbanked, @d_changeddate, @i_entitleyear

     WHILE @@fetch_status = 0

    BEGIN

      IF @s_updateytdbalances = 'Y'
        BEGIN
          /* a row which updated the employee YTD balances has been deleted...
             now find the employee and
             calendar year which corresponds to the row... */
          SELECT @i_calendaryear = calendar_year,
                 @s_employee = employee
            FROM payroll_vouchers
           WHERE payroll_calculation_id = @s_payrollcalculationid AND
                 voucher = @s_voucher AND
                 voucher_sequence = @s_vouchersequence AND
                 check_void = @s_checkvoid
          /* now we need to update the hours, amount, and basis based on
             the deletion. */
          IF @s_document <> 'ENT'
             BEGIN
               UPDATE employee_ytd_balances
                  SET hours = hours - @c_hours,
                      basis_hours = basis_hours - @c_basishours,
                      amount = amount - @c_amount,
                      basis_amount = basis_amount - @c_basis,
                      gross_amount = gross_amount - @c_gross,
                      hours_worked = hours_worked - @c_hoursworked,
                      hours_banked = hours_banked - @c_hoursbanked,
                      amount_banked = amount_banked - @c_amountbanked,
                      pieces_paid = pieces_paid - @c_piecespaid
                WHERE calendar_year = @i_calendaryear AND
                      employee = @s_employee AND
                      document = @s_document AND
                      document_type = @s_documenttype AND
                      payer = @s_payer
             END
          ELSE

            IF @s_document = 'ENT' and @s_source = 'AUTO'
              /* delete the entitlement transaction for this voucher item */
              BEGIN
                SELECT @s_balanceentitlement = balance_entitlement
                  FROM entitlements
                 WHERE entitlement = @s_documenttype

                DELETE FROM entitlement_transactions
                      WHERE entitle_year = @i_entitleyear AND
                            employee = @s_employee AND
                            entitlement = @s_balanceentitlement AND
                            payroll_calculation_id = @s_payrollcalculationid AND
                            voucher = @s_voucher AND
                            check_void = @s_checkvoid AND
                            entered_date = @d_changeddate
              END

        END

      FETCH deletedpvicursor
       INTO @s_updateytdbalances, @s_payrollcalculationid,
            @s_voucher, @s_vouchersequence, @s_checkvoid,
            @s_document, @s_documenttype, @s_payer, @s_source,
            @c_hours, @c_amount, @c_basis, @c_gross, @c_basishours,
            @c_hoursworked, @c_piecespaid, @c_amountbanked,
            @c_hoursbanked, @d_changeddate, @i_entitleyear

    END

    CLOSE deletedpvicursor
    DEALLOCATE deletedpvicursor
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_PayrollVoucherItems]
  ON [dbo].[payroll_voucher_items] FOR INSERT

/* 3/19/2003  Added basis_hours.

   3/05/2003  Do not insert or update a employee_ytd_balances row if the
              document is 'ENT'.

   11/06/2002 Insert an entitlement_transaction if this is an entitlement
              document with a source of 'AUTO' and upd_ytd_balances = 'Y'.

   10/23/2002 Added new columns hours_worked, pieces_paid, amount_banked
              and hours_banked.

    5/13/2002 Modified select on payroll_vouchers to use check_void from
              payroll_voucher_items, instead of check_void = 'C'. */

AS
  BEGIN
    DECLARE @i_calendaryear integer,
            @i_entitleyear integer,
            @i_count integer,
            @s_balanceentitlement varchar(25),
            @s_employee varchar(25),
            @s_dummy varchar(25),
            @s_payrollcalcid varchar(25),
            @s_voucher varchar(25),
            @s_vouchersequence varchar(25),
            @s_checkvoid char(1),
            @s_updateytdbalances char(1),
            @s_document varchar(25),
            @s_documenttype varchar(25),
            @s_payer char(1),
            @s_source varchar(5),
            @c_hours decimal(18,6),
            @c_basishours decimal(18,6),
            @c_hoursworked decimal(18,6),
            @c_hoursbanked decimal(18,6),
            @c_piecespaid decimal(18,6),
            @c_amount decimal(18,6),
            @c_amountbanked decimal(18,6),
            @c_basis decimal(18,6),
            @c_gross decimal(18,6),
            @d_periodenddate datetime,
            @s_changeduserid varchar(25),
            @d_changeddate datetime

    /* first select the appropriate columns from the inserted record */
    DECLARE insertedpvicursor CURSOR FOR
      SELECT payroll_calculation_id, voucher, voucher_sequence,
             check_void, update_ytd_balances, document, document_type,
             payer, hours, amount, basis, gross, source, changed_user_id,
             hours_worked, pieces_paid, amount_banked, hours_banked,
             changed_date, entitle_year, basis_hours
        FROM inserted

    OPEN insertedpvicursor

    FETCH insertedpvicursor
     INTO @s_payrollcalcid, @s_voucher, @s_vouchersequence, @s_checkvoid,
          @s_updateytdbalances, @s_document, @s_documenttype, @s_payer,
          @c_hours, @c_amount, @c_basis, @c_gross, @s_source, @s_changeduserid,
          @c_hoursworked, @c_piecespaid, @c_amountbanked, @c_hoursbanked,
          @d_changeddate, @i_entitleyear, @c_basishours

     WHILE @@fetch_status = 0

       BEGIN
         IF @s_updateytdbalances = 'Y'
            BEGIN
              /* a row which updates the employee YTD balances has been
                 inserted...  now find the employee and
                 calendar year which corresponds to the row... */
              SELECT @i_calendaryear = calendar_year,
                     @d_periodenddate = period_end_date,
                     @s_employee = employee
                FROM payroll_vouchers
               WHERE payroll_calculation_id = @s_payrollcalcid AND
                     voucher = @s_voucher AND
                     voucher_sequence = @s_vouchersequence AND
                     check_void = @s_checkvoid

              IF @s_document <> 'ENT'
                 BEGIN
                  /* now that we have the calendar_year, employee, and
                     the newly inserted row, check to see if a row exists in
                     the employee_ytd_balances table...
                     if yes then update, if no then insert. */
                  SELECT @s_dummy = employee
                    FROM employee_ytd_balances
                   WHERE calendar_year = @i_calendaryear AND
                         employee = @s_employee AND
                         document = @s_document AND
                         document_type = @s_documenttype AND
                         payer = @s_payer

                  IF @@ROWCOUNT <> 0
                     BEGIN
                       /* Since we found a row for this employee/document we
                          need to update the columns in it. */
                       UPDATE employee_ytd_balances
                          SET hours = hours + @c_hours,
                              basis_hours = basis_hours + @c_basishours,
                              amount = amount + @c_amount,
                              basis_amount = basis_amount + @c_basis,
                              gross_amount = gross_amount + @c_gross,
                              changed_date = GetDate(),
                              changed_user_id = @s_changeduserid,
                              hours_worked = hours_worked + @c_hoursworked,
                              hours_banked = hours_banked + @c_hoursbanked,
                              amount_banked = amount_banked + @c_amountbanked,
                              pieces_paid = pieces_paid + @c_piecespaid
                        WHERE calendar_year = @i_calendaryear AND
                              employee = @s_employee AND
                              document = @s_document AND
                              document_type = @s_documenttype AND
                              payer = @s_payer
                     END
                  ELSE
                     BEGIN
                       /* since we didn't find an entry we need to do an insert,
                          not update */
                       INSERT INTO employee_ytd_balances
                                  (calendar_year, employee, document,
                                   document_type, hours, amount, basis_amount,
                                   payer, changed_date, changed_user_id, gross_amount,
                                   hours_worked, pieces_paid, amount_banked, hours_banked,
                                   basis_hours)
                             VALUES
                                  (@i_calendaryear, @s_employee, @s_document,
                                   @s_documenttype, @c_hours, @c_amount,
                                   @c_basis, @s_payer, GetDate(), @s_changeduserid,
                                   @c_gross, @c_hoursworked, @c_piecespaid,
                                   @c_amountbanked, @c_hoursbanked, @c_basishours)
                     END
                 END
              ELSE

                IF @s_document = 'ENT' and @s_source = 'AUTO'
                  BEGIN
                    /* create an entitlement transaction for this voucher item */
                    SELECT @s_balanceentitlement = balance_entitlement
                      FROM entitlements
                     WHERE entitlement = @s_documenttype

                    INSERT INTO entitlement_transactions
                                (entitle_year, employee, entitlement, entered_date,
                                 transaction_type, transaction_date, transaction_reference,
                                 pay_type, accrued_entitlement, hours, changed_date,
                                 changed_user_id, amount, status,
                                 payroll_calculation_id, voucher, check_void)
                         VALUES (@i_entitleyear, @s_employee, @s_balanceentitlement, @d_changeddate,
                                 'ACCRUAL', @d_periodenddate, 'Calc ID ' + @s_payrollcalcid,
                                 '', @s_documenttype, @c_hoursbanked, GetDate(), @s_changeduserid,
                                 @c_amountbanked, 'C', @s_payrollcalcid, @s_voucher, @s_checkvoid)
                  END

            END

            FETCH insertedpvicursor
             INTO @s_payrollcalcid, @s_voucher, @s_vouchersequence, @s_checkvoid,
                  @s_updateytdbalances, @s_document, @s_documenttype, @s_payer, @c_hours,
                  @c_amount, @c_basis, @c_gross, @s_source, @s_changeduserid,
                  @c_hoursworked, @c_piecespaid, @c_amountbanked, @c_hoursbanked,
                  @d_changeddate, @i_entitleyear, @c_basishours
       END

       CLOSE insertedpvicursor
       DEALLOCATE insertedpvicursor
  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_PayrollVoucherItems]
  ON [dbo].[payroll_voucher_items] FOR UPDATE

/* 12/20/2005 Changed WHERE clause for updating entitlement_transactions.

   3/19/2003  Added basis_hours.

   3/05/2003  Do not insert or update a employee_ytd_balances row if the
              document is 'ENT'.

   11/06/2002 Update the entitlement_transaction if this is an entitlement
              document with a source of 'AUTO' and upd_ytd_balances = 'Y'.

   10/23/2002 Added new columns hours_worked, pieces_paid, amount_banked
              and hours_banked. */

AS
IF UPDATE(amount) OR UPDATE(basis) OR UPDATE(hours) OR UPDATE(gross) OR
   UPDATE(hours_worked) OR UPDATE(pieces_paid) OR UPDATE(amount_banked) OR
   UPDATE(hours_banked) OR UPDATE(basis_hours)

BEGIN
  DECLARE @s_employee varchar(25),
          @i_calendaryear integer,
          @i_entitleyear integer,
          @c_hours decimal(18,6),
          @c_basishours decimal(18,6),
          @c_hoursworked decimal(18,6),
          @c_hoursbanked decimal(18,6),
          @c_piecespaid decimal(18,6),
          @c_amount decimal(18,6),
          @c_amountbanked decimal(18,6),
          @c_basis decimal(18,6),
          @c_gross decimal(18,6),
          @s_updateytdbalances char(1),
          @s_balanceentitlement varchar(25),
          @s_payrollcalculationid varchar(25),
          @s_voucher varchar(25),
          @s_vouchersequence varchar(25),
          @s_checkvoid char(1),
          @s_document varchar(25),
          @s_documenttype varchar(25),
          @s_payer char(1),
          @s_source varchar(5),
          @c_oldhours decimal(18,6),
          @c_oldbasishours decimal(18,6),
          @c_oldhoursworked decimal(18,6),
          @c_oldhoursbanked decimal(18,6),
          @c_oldpiecespaid decimal(18,6),
          @c_oldamount decimal(18,6),
          @c_oldamountbanked decimal(18,6),
          @c_oldbasis decimal(18,6),
          @c_oldgross decimal(18,6),
          @c_newhours decimal(18,6),
          @c_newbasishours decimal(18,6),
          @c_newhoursworked decimal(18,6),
          @c_newhoursbanked decimal(18,6),
          @c_newpiecespaid decimal(18,6),
          @c_newamount decimal(18,6),
          @c_newamountbanked decimal(18,6),
          @c_newbasis decimal(18,6),
          @c_newgross decimal(18,6),
          @d_changeddate datetime

  DECLARE updatedpvicursor CURSOR FOR
    SELECT inserted.update_ytd_balances,
           deleted.payroll_calculation_id,
           deleted.voucher, deleted.voucher_sequence,
           deleted.check_void, deleted.document,
           deleted.document_type, deleted.payer,
           deleted.source, deleted.entitle_year,
           deleted.changed_date,
           deleted.hours, deleted.amount, deleted.basis,
           deleted.gross, deleted.hours_worked,
           deleted.pieces_paid, deleted.amount_banked,
           deleted.hours_banked, deleted.basis_hours,
           inserted.hours, inserted.amount, inserted.basis,
           inserted.gross, inserted.hours_worked,
           inserted.pieces_paid, inserted.amount_banked,
           inserted.hours_banked, inserted.basis_hours
      FROM inserted, deleted
     WHERE inserted.payroll_calculation_id = deleted.payroll_calculation_id AND
           inserted.voucher = deleted.voucher AND
           inserted.voucher_sequence = deleted.voucher_sequence AND
           inserted.voucher_line = deleted.voucher_line AND
           inserted.check_void = deleted.check_void

  OPEN updatedpvicursor

  FETCH updatedpvicursor
   INTO @s_updateytdbalances, @s_payrollcalculationid, @s_voucher,
           @s_vouchersequence, @s_checkvoid, @s_document, @s_documenttype,
           @s_payer, @s_source, @i_entitleyear, @d_changeddate,
           @c_oldhours, @c_oldamount, @c_oldbasis, @c_oldgross,
           @c_oldhoursworked, @c_oldpiecespaid, @c_oldamountbanked,
           @c_oldhoursbanked, @c_oldbasishours, @c_newhours, @c_newamount,
           @c_newbasis, @c_newgross, @c_newhoursworked, @c_newpiecespaid,
           @c_newamountbanked, @c_newhoursbanked, @c_newbasishours

     WHILE @@fetch_status = 0

    BEGIN
      IF @s_updateytdbalances = 'Y'
         BEGIN
           /* a row has been updated...now find the employee and
              calendar year which corresponds to the row... */
           SELECT @i_calendaryear = calendar_year,
                  @s_employee  = employee
             FROM payroll_vouchers
            WHERE payroll_calculation_id = @s_payrollcalculationid AND
                  voucher = @s_voucher AND
                  voucher_sequence = @s_vouchersequence AND
                  check_void = @s_checkvoid
           /* since we are going to be updating, we have to work
              with differences. */
           SELECT @c_hours = @c_newhours - @c_oldhours
           SELECT @c_basishours = @c_newbasishours - @c_oldbasishours
           SELECT @c_amount = @c_newamount - @c_oldamount
           SELECT @c_basis = @c_newbasis - @c_oldbasis
           SELECT @c_gross = @c_newgross - @c_oldgross
           SELECT @c_hoursworked = @c_newhoursworked - @c_oldhoursworked
           SELECT @c_hoursbanked = @c_newhoursbanked - @c_oldhoursbanked
           SELECT @c_amountbanked = @c_newamountbanked - @c_oldamountbanked
           SELECT @c_piecespaid = @c_newpiecespaid - @c_oldpiecespaid

           IF @s_document <> 'ENT'
              BEGIN
                /* now we need to update the hours, amount, basis and gross */
                UPDATE employee_ytd_balances
                  SET hours = hours + @c_hours,
                      basis_hours = basis_hours + @c_basishours,
                      amount = amount + @c_amount,
                      basis_amount = basis_amount + @c_basis,
                      gross_amount = gross_amount + @c_gross,
                      hours_worked = hours_worked + @c_hoursworked,
                      hours_banked = hours_banked + @c_hoursbanked,
                      amount_banked = amount_banked + @c_amountbanked,
                      pieces_paid = pieces_paid + @c_piecespaid
                WHERE calendar_year = @i_calendaryear AND
                      employee = @s_employee AND
                      document = @s_document AND
                      document_type = @s_documenttype AND
                      payer = @s_payer
              END
           ELSE

              IF @s_document = 'ENT' and @s_source = 'AUTO'
                /* update the entitlement transaction for this voucher item */
                BEGIN
                  SELECT @s_balanceentitlement = balance_entitlement
                    FROM entitlements
                   WHERE entitlement = @s_documenttype

                  UPDATE entitlement_transactions
                     SET hours = hours + @c_hoursbanked,
                         amount = amount + @c_amountbanked
                   WHERE entitle_year = @i_entitleyear AND
                         employee = @s_employee AND
                         entitlement = @s_balanceentitlement AND
                         payroll_calculation_id = @s_payrollcalculationid AND
                         voucher = @s_voucher AND
                         check_void = @s_checkvoid AND
                         entered_date = @d_changeddate
                END
         END

      FETCH updatedpvicursor
       INTO @s_updateytdbalances, @s_payrollcalculationid, @s_voucher,
            @s_vouchersequence, @s_checkvoid, @s_document, @s_documenttype,
            @s_payer, @s_source, @i_entitleyear, @d_changeddate,
            @c_oldhours, @c_oldamount, @c_oldbasis,
            @c_oldgross, @c_oldhoursworked, @c_oldpiecespaid,
            @c_oldamountbanked, @c_oldhoursbanked, @c_oldbasishours,
            @c_newhours, @c_newamount, @c_newbasis, @c_newgross,
            @c_newhoursworked, @c_newpiecespaid, @c_newamountbanked,
            @c_newhoursbanked, @c_newbasishours

    END

    CLOSE updatedpvicursor
    DEALLOCATE updatedpvicursor
END
GO
ALTER TABLE [dbo].[payroll_voucher_items] ADD CONSTRAINT [pk_payroll_voucher_items] PRIMARY KEY CLUSTERED  ([payroll_calculation_id], [voucher], [voucher_sequence], [voucher_line], [check_void]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [payroll_voucher_items_document] ON [dbo].[payroll_voucher_items] ([document], [document_type], [payroll_calculation_id]) ON [PRIMARY]
GO
