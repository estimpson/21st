CREATE TABLE [dbo].[ap_applications]
(
[check_selection_identifier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_number] [int] NOT NULL,
[id_sequence] [int] NOT NULL,
[stub_id_number] [int] NULL,
[stub_number] [smallint] NULL,
[number_of_stubs] [smallint] NULL,
[check_number] [int] NULL,
[reversed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reversal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buy_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_cm] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inv_cm_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[separate_check] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[open_amount] [decimal] (18, 6) NULL,
[pay_amount] [decimal] (18, 6) NULL,
[due_date] [datetime] NULL,
[discount_date] [datetime] NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inv_cm_date] [datetime] NULL,
[applied_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[applied_to_invoice_cm] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exchanged_pay_amount] [decimal] (18, 6) NULL,
[gain_loss_amount] [decimal] (18, 6) NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[applied_to_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_APApplications]
ON [dbo].[ap_applications] FOR DELETE
AS

-- 03/22/04 Added code for deleting credit memo applications.

BEGIN
  DECLARE @s_vendor VARCHAR(25),
          @s_invoicecm VARCHAR(25),
          @s_invcmflag char(1),
          @s_discountflag char(1),
          @s_reversal char(1),
          @s_changeduserid VARCHAR(25),
          @c_payamount decimal(18,6),
          @c_exchangedpayamount decimal(18,6),
          @s_bankalias VARCHAR(25)

  DECLARE deletedcursor CURSOR FOR
      SELECT vendor, invoice_cm, inv_cm_flag,
             discount_flag, reversal, pay_amount,
             exchanged_pay_amount, changed_user_id,
             bank_alias
        FROM deleted

  OPEN deletedcursor

  /*  prime fetch  */
  FETCH deletedcursor INTO @s_vendor, @s_invoicecm, @s_invcmflag,
                           @s_discountflag, @s_reversal,
                           @c_payamount,@c_exchangedpayamount,
                           @s_changeduserid, @s_bankalias

  WHILE @@fetch_status = 0

    BEGIN
      /*  any fetch status other than 0 will stop the loop  */
      IF @s_discountflag <> 'Y'
        BEGIN
          IF @s_bankalias = 'CM APPL' OR @s_reversal = 'Y'
            BEGIN
              /* This delete is the result of deleting a credit memo
                 application or manually (i.e. through ISQL) deleting
                 the reversal of a previous application. In the case of
                 a reversal, the pay amount in the application record
                 is negative. In either case, update the applied
                 amount on the AP header. */
               UPDATE ap_headers
                  SET applied_amount =
                        IsNull(applied_amount,0) - @c_payamount,
                      exchanged_applied_amount =
                        IsNull(exchanged_applied_amount,0) -
                        IsNull(@c_exchangedpayamount,0),
                      changed_date = GetDate(),
                      changed_user_id = @s_changeduserid
                WHERE vendor = @s_vendor AND
                      invoice_cm = @s_invoicecm AND
                      inv_cm_flag = @s_invcmflag
            END
          ELSE
            BEGIN
              /* This is not a discount and it's not a reversal, so
                 update the AP headers check selection identifier and
                 select for pay amount. */
              UPDATE ap_headers
                 SET check_selection_identifier = '',
                     select_for_pay_amount =
                          select_for_pay_amount - @c_payamount,
                     exchanged_sel_for_pay_amount =
	                   exchanged_sel_for_pay_amount -
                            IsNull(@c_exchangedpayamount,0),
                     changed_date = GetDate(),
                     changed_user_id = @s_changeduserid
               WHERE vendor = @s_vendor AND
                     invoice_cm = @s_invoicecm AND
                     inv_cm_flag = @s_invcmflag
            END
        END
      /*  get the next deleted row, if any  */
      FETCH deletedcursor INTO @s_vendor, @s_invoicecm,
                               @s_invcmflag,
                               @s_discountflag, @s_reversal,
                               @c_payamount,@c_exchangedpayamount,
                               @s_changeduserid, @s_bankalias

    END

  /* Don't need this cursor any longer */
  CLOSE deletedcursor
  DEALLOCATE deletedcursor

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_APApplications]
ON [dbo].[ap_applications] FOR INSERT
AS
BEGIN

  DECLARE @s_vendor VARCHAR(25),
          @s_invoicecm VARCHAR(25),
          @s_invcmflag char(1),
          @s_checkselectionid VARCHAR(25),
          @s_bankalias VARCHAR(25),
          @s_discountflag char(1),
          @s_reversal char(1),
          @s_changeduserid VARCHAR(25),
          @c_payamount decimal(18,6),
          @c_exchangedpayamount decimal(18,6)

  DECLARE insertedcursor CURSOR FOR
      SELECT vendor, invoice_cm, inv_cm_flag,
             check_selection_identifier, bank_alias, discount_flag,
             reversal,pay_amount,exchanged_pay_amount,changed_user_id
        FROM inserted

  OPEN insertedcursor

  /*  prime fetch  */
  FETCH insertedcursor INTO @s_vendor, @s_invoicecm, @s_invcmflag,
                            @s_checkselectionid, @s_bankalias,
			    @s_discountflag, @s_reversal,
			    @c_payamount, @c_exchangedpayamount,
                            @s_changeduserid

   WHILE @@fetch_status = 0

    BEGIN
       /*  any fetch status other than 0 will stop the loop  */

      IF @s_discountflag <> 'Y'
        BEGIN
          /* This is not a discount, so update the AP header. What
             gets updated depends upon whether or not this is a
             credit memo application AND upon whether or not this is
             a reversal of a previous application. */
          IF @s_bankalias = 'CM APPL' OR @s_reversal = 'Y'
            BEGIN
              /* This insert is the result of manually applying a
                 credit memo to one or more invoices OR this is a
                 reversal of a previous application. In the case of
                 a reversal, the pay amount in the application record
                 is negative. In either case, update the applied
                 amount on the AP header. */
               UPDATE ap_headers
                SET applied_amount =
                      IsNull(applied_amount,0) + @c_payamount,
                    exchanged_applied_amount =
                      IsNull(exchanged_applied_amount,0) +
                      IsNull(@c_exchangedpayamount,0),
                    changed_date = GetDate(),
                    changed_user_id = @s_changeduserid
                WHERE vendor = @s_vendor AND
                      invoice_cm = @s_invoicecm AND
                      inv_cm_flag = @s_invcmflag
            END
          ELSE
            BEGIN
             /* This is not a credit memo application or a reversal so
                update the check selection identifier and the select
                for pay amount.*/
              UPDATE ap_headers
                SET check_selection_identifier = @s_checkselectionid,
                    select_for_pay_amount =
	               IsNull(select_for_pay_amount,0) + @c_payamount,
                    exchanged_sel_for_pay_amount =
	               IsNull(exchanged_sel_for_pay_amount,0) +
                       IsNull(@c_exchangedpayamount,0),
                    changed_date = GetDate(),
                    changed_user_id = @s_changeduserid
                WHERE vendor = @s_vendor AND
                      invoice_cm = @s_invoicecm AND
                      inv_cm_flag = @s_invcmflag
            END
        END

       /*  get the next inserted record, if any  */
       FETCH insertedcursor INTO @s_vendor, @s_invoicecm,
                                 @s_invcmflag,
                                 @s_checkselectionid, @s_bankalias,
                                 @s_discountflag, @s_reversal,
                                 @c_payamount,@c_exchangedpayamount,
                                 @s_changeduserid

    END

    /* Don't need the cursor any longer. */
    CLOSE insertedcursor
    DEALLOCATE insertedcursor

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_APApplications]
ON [dbo].[ap_applications] FOR UPDATE
AS
IF UPDATE (check_number) OR UPDATE(pay_amount)
BEGIN

  DECLARE @s_vendor VARCHAR(25),
          @s_invoicecm VARCHAR(25),
          @s_invcmflag char(1),
          @s_discountflag char(1),
          @s_changeduserid VARCHAR(25),
          @i_oldchecknbr int,
          @i_newchecknbr int,
          @c_oldpayamount decimal(18,6),
          @c_newpayamount decimal(18,6),
          @c_oldexchpayamount decimal(18,6),
          @c_newexchpayamount decimal(18,6),
          @dt_oldapplieddate datetime

  DECLARE updatecursor CURSOR FOR
      SELECT inserted.vendor, inserted.invoice_cm,
             inserted.inv_cm_flag, inserted.discount_flag,
             deleted.check_number, inserted.check_number,
             deleted.pay_amount, inserted.pay_amount,
             deleted.exchanged_pay_amount, inserted.exchanged_pay_amount,
             deleted.applied_date, inserted.changed_user_id
        FROM inserted, deleted
        WHERE inserted.check_selection_identifier =
                 deleted.check_selection_identifier AND
              inserted.bank_alias = deleted.bank_alias AND
              inserted.id_number = deleted.id_number AND
              inserted.id_sequence = deleted.id_sequence

  OPEN updatecursor

  /*  prime fetch  */
  FETCH updatecursor INTO @s_vendor, @s_invoicecm,
                          @s_invcmflag, @s_discountflag,
                          @i_oldchecknbr, @i_newchecknbr,
                          @c_oldpayamount, @c_newpayamount,
                          @c_oldexchpayamount, @c_newexchpayamount,
                          @dt_oldapplieddate, @s_changeduserid

   WHILE @@fetch_status = 0

    BEGIN
       /*  any fetch status other than 0 will stop the loop  */

      IF @s_discountflag <> 'Y' AND
        (@i_oldchecknbr = 0 OR @i_oldchecknbr IS NULL)
        /* This is not a discount nor is it a check replacement,
           so update the AP header information.
        */
        BEGIN
          IF @i_newchecknbr <> 0 AND @i_newchecknbr IS NOT NULL
            BEGIN
              /* A check number was just assigned to the application.
                 Update the AP header to indicate that the invoice was
                 paid. However, only update the AP header if the
                 applied date is NULL. If the applied date is not NULL,
                 this is a check restart and the header does not need
                 to be updated. */
              IF @dt_oldapplieddate IS NULL
                BEGIN
                  UPDATE ap_headers
                    SET check_selection_identifier = '',
                        select_for_pay_amount =
	                    select_for_pay_amount - @c_newpayamount,
                        exchanged_sel_for_pay_amount =
	                    exchanged_sel_for_pay_amount -
                            IsNull(@c_newexchpayamount,0),
                        applied_amount =
                            IsNull(applied_amount,0) + @c_newpayamount,
                        exchanged_applied_amount =
                            IsNull(exchanged_applied_amount,0) +
                            IsNull(@c_newexchpayamount,0),
                        changed_date = GetDate(),
                        changed_user_id = @s_changeduserid
                    WHERE vendor = @s_vendor AND
                          invoice_cm = @s_invoicecm AND
                          inv_cm_flag = @s_invcmflag
                END
            END
          ELSE
            BEGIN
              /* If a check number wasn't just assigned to the application,
                 then a pay_amount must have been updated. Update the
                 AP header with the new select for pay amount. */
              UPDATE ap_headers
                SET select_for_pay_amount =
	                select_for_pay_amount - @c_oldpayamount +
                        @c_newpayamount,
                    exchanged_sel_for_pay_amount =
	                exchanged_sel_for_pay_amount -
                        IsNull(@c_oldexchpayamount,0) +
                        IsNull(@c_newexchpayamount,0),
                    changed_date = GetDate(),
                    changed_user_id = @s_changeduserid
                WHERE vendor = @s_vendor AND
                      invoice_cm = @s_invoicecm AND
                      inv_cm_flag = @s_invcmflag
            END
        END

      /*  get the next updated record, if any  */
      FETCH updatecursor INTO @s_vendor, @s_invoicecm,
                              @s_invcmflag, @s_discountflag,
                              @i_oldchecknbr, @i_newchecknbr,
                              @c_oldpayamount, @c_newpayamount,
                              @c_oldexchpayamount, @c_newexchpayamount,
                              @dt_oldapplieddate, @s_changeduserid


    END

    /* Don't need the cursor any longer. */
    CLOSE updatecursor
    DEALLOCATE updatecursor

END
GO
ALTER TABLE [dbo].[ap_applications] ADD CONSTRAINT [pk_ap_applications] PRIMARY KEY CLUSTERED  ([check_selection_identifier], [id_number], [id_sequence], [bank_alias]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [apapplications_checknumber] ON [dbo].[ap_applications] ([check_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [apapplications_vendor_invcm] ON [dbo].[ap_applications] ([vendor], [invoice_cm], [inv_cm_flag]) ON [PRIMARY]
GO
