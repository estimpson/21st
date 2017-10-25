SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UpdateAPChecks]
    @as_checkselectionidentifier varchar(25),
    @as_bankalias varchar(25),
    @as_directdeposit char(1),
    @as_payunit varchar(25),
    @as_fiscalyear varchar(5),
    @as_glentry varchar(25),
    @as_checktype varchar(3),
    @as_sort1 varchar(25),
    @as_sort2 varchar(25),
    @as_sort3 varchar(25),
    @as_sort4 varchar(25),
    @as_userid varchar(25),
    @ad_checkdate datetime,
    @ad_gldate datetime,
    @ai_period smallint,
    @ai_begchknum int

AS
BEGIN

-- 22-May-2012 Corrected so that the sort value is populated with an
--             empty string rather than with check_amount when the
--             corresponding preference value is blank.  Added
--             id_number as the final sort so that checks for a given
--             vendor come out in the same order they were shown on
--             the proof report.

-- 08-Sep-2006 Removed *= from join of ap_applications.vendor to
--             vendors.vendor.

/* 29-Apr-2006 Changed columns that were char to varchar. */

/* 07-Mar-2002 Replaced "" in an IF statement with '' because "" is what
               is used around column names. */

/* 01-Jun-2001 As part of the 28-Sep-2000 mod, some ap_headers columns
              (pay_vendor_name, pay_vendor_name_2, pay_postal_code, and
              pay_address_1) were added to the group by for applcursor.
              This caused an error when a credit memo with one of these
              values different from the invoice values was assigned to a
              check. The group by caused the invoices to end up on one
              check and the credit memo on another even though they
              belonged on the same check. Took these columns out of the
              group by and used MIN functions on them. This may cause the
              values from the credit memo rather than from the invoices
              to be used on the check, but we will only get one row in
              bank_register. */

/* 28-Sep-2000 Write pay address from ap_headers to the bank_register.
   Get the pay address columns from ap_headers instead of from addresses. */

 /* declare a cursor to sort based on the user-specified sort criteria */

  DECLARE sortcursor CURSOR FOR
        SELECT id_number, check_amount, pay_vendor, number_of_stubs,
               pay_address_1, pay_address_2, pay_address_3, pay_city,
               pay_state, pay_postal_code, pay_country, pay_vendor_name,
               pay_vendor_name_2
          FROM ap_check_sort_temporary
         WHERE check_selection_identifier = @as_checkselectionidentifier AND
               bank_alias = @as_bankalias
         ORDER BY sort1, sort2, sort3, sort4, id_number

 DECLARE
    @s_ledger varchar(40),
    @s_cashledgeraccount varchar(50),
    @i_idnumber int,
    @i_numberofstubs smallint,
    @i_nextchecknumber int,
    @i_banklastchecknumber int,
    @i_banklastdirectdepositnumber int,
    @i int,
    @s_reconciled char(1),
    @d_reconcileddate datetime,
    @s_reconciledid varchar(25),
    @c_checkamount decimal(18,6),
    @s_checkamount varchar(20),
    @s_payvendor varchar(25),
    @s_payvendorname varchar(40),
    @s_checkname varchar(40),
    @s_checkname2 varchar(40),
    @s_remittanceadvice char(1),
    @s_payaddress1 varchar(50),
    @s_payaddress2 varchar(50),
    @s_payaddress3 varchar(50),
    @s_paycity varchar(25),
    @s_paystate varchar(25),
    @s_postalcode varchar(15),
    @s_paycountry varchar(50),
    @s_sortvalue1 varchar(40),
    @s_sortvalue2 varchar(40),
    @s_sortvalue3 varchar(40),
    @s_sortvalue4 varchar(40)

  /* declare a cursor to retrieve the application rows which match the
     user-specified criteria. don't select records which already have a
     check number. This happens when the user restarts part of a check run.
  */

  DECLARE applcursor CURSOR FOR
        SELECT ap_applications.id_number,
               MAX(ap_applications.number_of_stubs),
               CONVERT(decimal(18,6),SUM(ap_applications.pay_amount)),
               vendors.vendor,
               vendors.vendor_name,
               MIN(ap_headers.pay_vendor_name),
               MIN(ap_headers.pay_vendor_name_2),
               vendors.chk_remittance_advice,
               IsNull(MIN(ap_headers.pay_postal_code), ''),
               MIN(ap_headers.pay_address_1),
               MIN(ap_headers.pay_address_2),
               MIN(ap_headers.pay_address_3),
               MIN(ap_headers.pay_city),
               MIN(ap_headers.pay_state),
               MIN(ap_headers.pay_country)

          FROM ap_applications, vendors, ap_headers

         WHERE ap_headers.vendor = ap_applications.vendor AND
               ap_headers.inv_cm_flag = ap_applications.inv_cm_flag AND
               ap_headers.invoice_cm = ap_applications.invoice_cm AND
               ap_applications.pay_vendor = vendors.vendor AND
               ap_applications.check_selection_identifier =
                      @as_checkselectionidentifier AND
               ap_applications.bank_alias = @as_bankalias AND
               ap_applications.direct_deposit = @as_directdeposit AND
              (ap_applications.check_number = 0 OR
               ap_applications.check_number IS NULL)

        GROUP BY ap_applications.id_number,
                 vendors.vendor,
                 vendors.vendor_name,
                 vendors.chk_remittance_advice

        ORDER BY ap_applications.id_number

 /* get the cash ledger account and the previous last check number
     for this bank alias.
  */
 SELECT @s_ledger = ledger,
        @s_cashledgeraccount = ledger_account,
        @i_banklastchecknumber = last_check_number,
        @i_banklastdirectdepositnumber = last_direct_deposit_number
   FROM bank_accounts
  WHERE bank_alias = @as_bankalias

  /* what to do if not found? */

  /* retrieve the application rows which match the user-specified
     criteria.
  */
 OPEN applcursor

  WHILE 1 = 1
    BEGIN
      FETCH applcursor
       INTO @i_idnumber,@i_numberofstubs,@c_checkamount,@s_payvendor,
            @s_payvendorname, @s_checkname, @s_checkname2, @s_remittanceadvice,
            @s_postalcode, @s_payaddress1, @s_payaddress2, @s_payaddress3,
            @s_paycity, @s_paystate, @s_paycountry

      IF @@fetch_status <> 0 BREAK

  	/* If we have a check name, use it instead of the vendor name */
      IF @s_checkname <> '' SELECT @s_payvendorname = @s_checkname

     /* The sort fields in the check sort file are all character fields.
         Turn the check amount into a string with leading zeros just in
         case the  user wants to sort on check amount. Check amounts will
         never be negative, so don't worry about handling negative numbers.
      */
      SELECT @s_checkamount = LTRIM(STR(@c_checkamount,19,6))
      SELECT @s_checkamount =
           SUBSTRING( '00000000000000000000', 1,
              20 - (CHARINDEX('%|',@s_checkamount + '%|') - 1)) +
           @s_checkamount

/*
      /* Does the user want to sort on postal code? If so, we need
         to select postal code from addresses. We couldn't do that
         as part of applcursor because we would have needed to use
         vendors (which is the inner table of an outer join) in another
         join clause. This is not allowed in Sybase or MS SQL Server.
       */
       IF @as_sort1 = 'postal_code' OR @as_sort2 = 'postal_code' OR
          @as_sort3 = 'postal_code' OR @as_sort4 = 'postal_code'
         BEGIN
           SELECT @s_postalcode = IsNull(postal_code,'')
             FROM addresses
            WHERE address_id = @s_addressid
           IF @@rowcount = 0 SELECT @s_postalcode = ''
         END
*/

       /* Now that we know the amount of this check and the vendor,
          vendor name, remittance advice, and postal code for the check,
          put the check into the check sort file.

          First, determine the sort fields.
       */
       IF @as_sort1 = 'pay_vendor'
          SELECT @s_sortvalue1 = @s_payvendor
       ELSE
         BEGIN
           IF @as_sort1 = 'pay_vendor_name'
              SELECT @s_sortvalue1 = @s_payvendorname
           ELSE
             BEGIN
               IF @as_sort1 ='remittance_advice'
                 SELECT @s_sortvalue1 = @s_remittanceadvice
               ELSE
                 BEGIN
                   IF @as_sort1 ='postal_code'
                     SELECT @s_sortvalue1 = @s_postalcode
                   ELSE
                     BEGIN
                       IF @as_sort1 ='check_amount'
                         SELECT @s_sortvalue1 = @s_checkamount
                       ELSE
                         SELECT @s_sortvalue1 = ''
                     END
                 END
             END
         END

       IF @as_sort2 = 'pay_vendor'
          SELECT @s_sortvalue2 = @s_payvendor
       ELSE
         BEGIN
           IF @as_sort2 = 'pay_vendor_name'
              SELECT @s_sortvalue2 = @s_payvendorname
           ELSE
             BEGIN
               IF @as_sort2 ='remittance_advice'
                 SELECT @s_sortvalue2 = @s_remittanceadvice
               ELSE
                 BEGIN
                   IF @as_sort2 ='postal_code'
                     SELECT @s_sortvalue2 = @s_postalcode
                   ELSE
                     BEGIN
                       IF @as_sort2 ='check_amount'
                         SELECT @s_sortvalue2 = @s_checkamount
                       ELSE
                         SELECT @s_sortvalue2 = ''
                     END
                 END
             END
         END

       IF @as_sort3 = 'pay_vendor'
          SELECT @s_sortvalue3 = @s_payvendor
       ELSE
         BEGIN
           IF @as_sort3 = 'pay_vendor_name'
              SELECT @s_sortvalue3 = @s_payvendorname
           ELSE
             BEGIN
               IF @as_sort3 ='remittance_advice'
                 SELECT @s_sortvalue3 = @s_remittanceadvice
               ELSE
                 BEGIN
                   IF @as_sort3 ='postal_code'
                     SELECT @s_sortvalue3 = @s_postalcode
                   ELSE
                     BEGIN
                       IF @as_sort3 ='check_amount'
                         SELECT @s_sortvalue3 = @s_checkamount
                       ELSE
                         SELECT @s_sortvalue3 = ''
                     END
                 END
             END
         END

       IF @as_sort4 = 'pay_vendor'
          SELECT @s_sortvalue4 = @s_payvendor
       ELSE
         BEGIN
           IF @as_sort4 = 'pay_vendor_name'
              SELECT @s_sortvalue4 = @s_payvendorname
           ELSE
             BEGIN
               IF @as_sort4 ='remittance_advice'
                 SELECT @s_sortvalue4 = @s_remittanceadvice
               ELSE
                 BEGIN
                   IF @as_sort4 ='postal_code'
                     SELECT @s_sortvalue4 = @s_postalcode
                   ELSE
                     BEGIN
                       IF @as_sort4 ='check_amount'
                         SELECT @s_sortvalue4 = @s_checkamount
                       ELSE
                         SELECT @s_sortvalue4 = ''
                     END
                 END
             END
         END

      INSERT INTO ap_check_sort_temporary
        (check_selection_identifier, bank_alias,
         sort1, sort2, sort3, sort4,
         pay_vendor, id_number, check_amount, number_of_stubs,
         pay_address_1, pay_address_2, pay_address_3, pay_city,
         pay_state, pay_postal_code, pay_country, pay_vendor_name,
         pay_vendor_name_2)
        VALUES
        (@as_checkselectionidentifier, @as_bankalias,
         @s_sortvalue1, @s_sortvalue2, @s_sortvalue3, @s_sortvalue4,
         @s_payvendor, @i_idnumber, @c_checkamount, @i_numberofstubs,
         @s_payaddress1, @s_payaddress2, @s_payaddress3, @s_paycity,
         @s_paystate, @s_postalcode, @s_paycountry, @s_checkname,
         @s_checkname2)

   END

  CLOSE applcursor

  DEALLOCATE applcursor

  /* save the beginning check number */
  SELECT @i_nextchecknumber = @ai_begchknum

  /* Now sort based on the user-specified sort criteria */
  OPEN sortcursor

  WHILE 1 = 1
    BEGIN
      FETCH sortcursor
       INTO @i_idnumber, @c_checkamount, @s_payvendor, @i_numberofstubs,
            @s_payaddress1, @s_payaddress2, @s_payaddress3, @s_paycity,
            @s_paystate, @s_postalcode, @s_paycountry, @s_checkname,
            @s_checkname2

      IF @@fetch_status <> 0 BREAK

      /* If we need more than one stub for this check, then we need
         to destroy some checks before we assign the actual check
         number to these applications.
      */
      SELECT @i = 1

      WHILE @i < @i_numberofstubs
        BEGIN

          /* Insert a destroyed check into the bank register table. */
          INSERT INTO bank_register
            (bank_alias, document_class, document_number, check_void_nsf,
             document_type, document_group_date, reconciled,
             reconciled_date, reconciled_id, document_amount,
             exchanged_amount, applied_amount, document_date, fiscal_year,
             period, gl_date, gl_entry, ledger, document_group_id,
             bank_account_debit_credit, changed_date, changed_user_id,
             pay_address_1, pay_address_2, pay_address_3, pay_city,
             pay_state, pay_postal_code, pay_country, pay_vendor_name,
             pay_vendor_name_2 )
           VALUES
            (@as_bankalias, 'AP', @i_nextchecknumber, 'C',
             'D', GetDate(), 'Y', @ad_checkdate, @as_userid,
              0, 0, 0, @ad_checkdate, @as_fiscalyear,
              @ai_period, @ad_gldate, @as_glentry, @s_ledger,
              @as_checkselectionidentifier, 'D', GetDate(), @as_userid,
              @s_payaddress1, @s_payaddress2, @s_payaddress3, @s_paycity,
              @s_paystate, @s_postalcode, @s_paycountry,
              @s_checkname, @s_checkname2 )

         /* increment the check number */
          SELECT @i_nextchecknumber = @i_nextchecknumber + 1
          SELECT @i = @i + 1

       END

       /* Assign the actual check number and the applied date to the
          applications table rows.
       */
       UPDATE ap_applications
          SET check_number = @i_nextchecknumber,
              applied_date = @ad_gldate,
              changed_date = GetDate(),
              changed_user_id = @as_userid

        WHERE check_selection_identifier = @as_checkselectionidentifier AND
              bank_alias = @as_bankalias AND
              direct_deposit = @as_directdeposit AND
              id_number = @i_idnumber

        /* Insert a row into the check table. */
        IF @c_checkamount = 0
          BEGIN
            SELECT @s_reconciled = 'Y'
            SELECT @d_reconcileddate = @ad_checkdate
            SELECT @s_reconciledid = @as_userid
          END
        ELSE
          BEGIN
            SELECT @s_reconciled = 'N'
            SELECT @d_reconcileddate = NULL
            SELECT @s_reconciledid = ''
          END

        INSERT INTO bank_register
           (bank_alias, document_class, document_number, check_void_nsf,
            document_id1, document_id2, document_type,
            document_group_date, reconciled, reconciled_date,
            reconciled_id, document_amount,
            applied_amount, ledger_account_code, document_date,
            fiscal_year, period, gl_date, gl_entry, ledger,
            last_date_applied, last_fiscal_year_applied,
            last_period_applied, document_group_id,
            bank_account_debit_credit, changed_date, changed_user_id,
            pay_address_1, pay_address_2, pay_address_3, pay_city,
            pay_state, pay_postal_code, pay_country, pay_vendor_name,
            pay_vendor_name_2 )
          VALUES
            (@as_bankalias, 'AP', @i_nextchecknumber, 'C',
             @as_payunit, @s_payvendor, @as_checktype,
             @ad_checkdate, @s_reconciled, @d_reconcileddate,
             @s_reconciledid, @c_checkamount,
             @c_checkamount, @s_cashledgeraccount, @ad_checkdate,
             @as_fiscalyear, @ai_period, @ad_gldate, @as_glentry,
             @s_ledger, @ad_gldate, @as_fiscalyear, @ai_period,
             @as_checkselectionidentifier, 'D', GetDate(), @as_userid,
             @s_payaddress1, @s_payaddress2, @s_payaddress3, @s_paycity,
             @s_paystate, @s_postalcode, @s_paycountry,
             @s_checkname, @s_checkname2 )

        /* Increment the check number */
        SELECT @i_nextchecknumber = @i_nextchecknumber + 1

    END

  CLOSE sortcursor
  DEALLOCATE sortcursor

  DELETE
    FROM ap_check_sort_temporary
   WHERE check_selection_identifier = @as_checkselectionidentifier AND
         bank_alias = @as_bankalias

  /* If the last check number assigned in this run is greater than the
     previous last check number for this bank alias, update the last
     check number.
  */
  IF @i_nextchecknumber > @ai_begchknum
    BEGIN
      /* We wrote a check. so, subtract 1 from the next check
         number to get the last used check number.
      */
      SELECT @i_nextchecknumber = @i_nextchecknumber - 1

      IF @as_directdeposit = 'Y'
        BEGIN
          IF @i_nextchecknumber > @i_banklastdirectdepositnumber
            BEGIN

              UPDATE bank_accounts
                 SET last_direct_deposit_number = @i_nextchecknumber,
                     changed_date = GetDate(),
                     changed_user_id = @as_userid
               WHERE bank_alias = @as_bankalias

            END
        END
      ELSE
        BEGIN
          IF @i_nextchecknumber > @i_banklastchecknumber
            BEGIN

              UPDATE bank_accounts
                 SET last_check_number = @i_nextchecknumber,
                     changed_date = GetDate(),
                     changed_user_id = @as_userid
               WHERE bank_alias = @as_bankalias

            END
        END
    END
END
GO
