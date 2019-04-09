SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ARCustomerCredit] @as_customer VARCHAR(25),

                                 @ad_asofdate datetime,

                                 @as_agingcolumn VARCHAR(25),

                                 @as_contactname VARCHAR(50) OUTPUT,

                                 @as_phone VARCHAR(25) OUTPUT,

                                 @as_dbnumber VARCHAR(25) OUTPUT,

                                 @as_creditrating VARCHAR(25) OUTPUT,

                                 @ac_current decimal(18,6) OUTPUT,

                                 @ac_over1 decimal(18,6) OUTPUT,

                                 @ac_over30 decimal(18,6) OUTPUT,

                                 @ac_over60 decimal(18,6) OUTPUT,

                                 @ac_over90 decimal(18,6) OUTPUT,

                                 @ac_over120 decimal(18,6) OUTPUT,

                                 @ac_unappliedcrm decimal(18,6) OUTPUT,

                                 @ac_unappliedcash decimal(18,6) OUTPUT,

                                 @ai_mtdcount int OUTPUT,

                                 @ac_mtdsales decimal(18,6) OUTPUT,

                                 @ai_ytdcount int OUTPUT,

                                 @ac_ytdsales decimal(18,6) OUTPUT,

                                 @ai_lyrcount int OUTPUT,

                                 @ac_lyrsales decimal(18,6) OUTPUT,

                                 @ai_ltdcount int OUTPUT,

                                 @ac_ltdsales decimal(18,6) OUTPUT,

                                 @ai_mtdmax int OUTPUT,

                                 @ac_mtdavg decimal(18,6) OUTPUT,

                                 @ai_ytdmax int OUTPUT,

                                 @ac_ytdavg decimal(18,6) OUTPUT,

                                 @ai_lyrmax int OUTPUT,

                                 @ac_lyravg decimal(18,6) OUTPUT,

                                 @ai_ltdmax int OUTPUT,

                                 @ac_ltdavg decimal(18,6) OUTPUT



-- 15-Jun-13  Don't select intercompany or POS invoices or credit memos.

-- 05-Oct-07 Modified to no longer reference ar_customers.contact_id.

-- 07-Sep-06 Changed *= syntax to LEFT OUTER JOIN syntax.



-- NOTE: The average and maximum days to pay calculations can result in

--       confusing numbers when there are partial payments. If a customer

--       has only one invoice, and that invoice is partially paid by one

--       check after 10 days and the remainder is paid after 90 days,

--       the Max Days to Pay will show as 90 and the Avg Days to Pay

--       will show as (10 + 90)/2 = 50. Steve Katz discovered this. I'm

--       not sure whether or not this is correct, but Steve is okay with

--       it. TAH 23-Oct-02.



-- 31-Jul-02 Fixed the month to date, year to date and life to date

--           calculations for # of invoices, sales, max days to pay

--           and ave days to pay.  Month to date was including the

--           entire month, year to date was including the entire year

--           and life to date was including everything (i.e. documents

--           beyond the as of date).  Also fixed a bug that was causing

--           ave days to pay to always be negative when aging by

--           document date.



-- 09-Nov-01 When selecting from the bank_register, use the new

--           columns application_check_amount and application_applied_

--           amount rather than document_amount and applied_amount.

--           Application_check_amount is in the currency of the

--           applications, whereas document_amount may no longer be in

--           the currency of the applications.



-- 05-Apr-2001 Added argument @as_agingcolumn which will contain either

--             document_date or due_date.



AS

BEGIN

  DECLARE @c_amount decimal(18,6),

          @c_appliedamount decimal(18,6),

          @d_documentdate datetime,

          @d_duedate datetime,

          @d_applieddate datetime,

          @s_duedate varchar(10),

          @i_days int,

          @i_mtdapps int,

          @i_mtddays int,

          @i_ytdapps int,

          @i_ytddays int,

          @i_lyrapps int,

          @i_lyrdays int,

          @i_ltdapps int,

          @i_ltddays int



  DECLARE agingcursor CURSOR FOR

    SELECT amount, IsNull(applied_amount,0), document_date, due_date

      FROM ar_headers

     WHERE bill_customer = @as_customer AND document_type = 'I'
       AND intercompany <> 'Y' AND IsNull(ar_headers.pos_paid,'N') <> 'Y'


  -- MSS and ASE would let us put an if around the cursor declaration and declare
  -- maxavgcursor to either select due_date or document_date.  ASA doesn't let us
  -- do that so we will declare two cursors and use only one of the two.
  DECLARE maxavgcursor CURSOR FOR

    SELECT ar_headers.due_date, ar_applications.applied_date

      FROM ar_applications, ar_headers

     WHERE ar_applications.document_type = ar_headers.document_type AND

           ar_applications.document = ar_headers.document AND

           ar_applications.document_type = 'I' AND

           ar_applications.bill_customer = @as_customer AND

           Convert(char(10),ar_applications.applied_date,111) <=

               Convert(char(10),@ad_asofdate,111) AND

           Convert(char(10),ar_headers.due_date,111) <=

               Convert(char(10),@ad_asofdate,111)


  DECLARE maxavgcursor2 CURSOR FOR

    SELECT ar_headers.document_date, ar_applications.applied_date

      FROM ar_applications, ar_headers

     WHERE ar_applications.document_type = ar_headers.document_type AND

           ar_applications.document = ar_headers.document AND

           ar_applications.document_type = 'I' AND

           ar_applications.bill_customer = @as_customer AND

           Convert(char(10),ar_applications.applied_date,111) <=

               Convert(char(10),@ad_asofdate,111) AND

               Convert(char(10),ar_headers.document_date,111) <=

                   Convert(char(10),@ad_asofdate,111)



  /*  Set all accumulators to zero  */

  SELECT @ac_current = 0

  SELECT @ac_over1 = 0

  SELECT @ac_over30 = 0

  SELECT @ac_over60 = 0

  SELECT @ac_over90 = 0

  SELECT @ac_over120 = 0

  SELECT @ac_unappliedcrm = 0

  SELECT @ac_unappliedcash = 0



  SELECT @ai_mtdcount = 0

  SELECT @ac_mtdsales = 0

  SELECT @ai_ytdcount = 0

  SELECT @ac_ytdsales = 0

  SELECT @ai_lyrcount = 0

  SELECT @ac_lyrsales = 0

  SELECT @ai_ltdcount = 0

  SELECT @ac_ltdsales = 0

  SELECT @ai_mtdmax = 0

  SELECT @ac_mtdavg = 0

  SELECT @ai_ytdmax = 0

  SELECT @ac_ytdavg = 0

  SELECT @ai_lyrmax = 0

  SELECT @ac_lyravg = 0

  SELECT @ai_ltdmax = 0

  SELECT @ac_ltdavg = 0



  SELECT @i_mtdapps = 0

  SELECT @i_mtddays = 0

  SELECT @i_ytdapps = 0

  SELECT @i_ytddays = 0

  SELECT @i_lyrapps = 0

  SELECT @i_lyrdays = 0

  SELECT @i_ltdapps = 0

  SELECT @i_ltddays = 0



  /* Start with the easy work ... lookup customer contact and credit info */

  SELECT @as_contactname = RTrim(contacts.first_name) + ' ' +

                           contacts.last_name,

         @as_phone = contacts.phone,

         @as_dbnumber = ar_customers.db_number,

         @as_creditrating = ar_customers.credit_rating

    FROM ar_customers LEFT OUTER JOIN contacts ON

         ar_customers.bill_contact_id = contacts.contact_id

   WHERE ar_customers.customer = @as_customer



  OPEN agingcursor



  /*  prime fetch  */

  FETCH agingcursor INTO @c_amount, @c_appliedamount, @d_documentdate,

                         @d_duedate



  WHILE @@fetch_status = 0

  BEGIN



    /*  determine how old this document is and store the remaining balance

        in the appropriate accumulator. First strip the time, if any, off

        the due date/document date. */

    IF @as_agingcolumn = 'due_date'

      BEGIN

        SELECT @s_duedate = Convert(char(10),@d_duedate,111)

      END

    ELSE

      BEGIN

        SELECT @s_duedate = Convert(char(10),@d_documentdate,111)

      END



    IF @s_duedate >= Convert(char(10),@ad_asofdate,111)

      SELECT @ac_current = @ac_current + (@c_amount - @c_appliedamount)

    ELSE

      BEGIN

        IF @s_duedate >= Convert(char(10),

                            DateAdd(day, -30, @ad_asofdate),111)

          SELECT @ac_over1 = @ac_over1 + (@c_amount - @c_appliedamount)

        ELSE

          BEGIN

            IF @s_duedate >= Convert(char(10),

                                DateAdd(day, -60, @ad_asofdate),111)

              SELECT @ac_over30 = @ac_over30 + (@c_amount - @c_appliedamount)

            ELSE

              BEGIN

                IF @s_duedate >= Convert(char(10),

                                    DateAdd(day, -90, @ad_asofdate),111)

                  SELECT @ac_over60 = @ac_over60 +

                                     (@c_amount - @c_appliedamount)

                ELSE

                  BEGIN

                    IF @s_duedate >= Convert(char(10),

                                       DateAdd(day, -120, @ad_asofdate),111)

                      SELECT @ac_over90 = @ac_over90 +

                                         (@c_amount - @c_appliedamount)

                    ELSE

                      SELECT @ac_over120 = @ac_over120 +

                                          (@c_amount - @c_appliedamount)

                  END

              END

          END

      END



    /*  month totals  */

    IF DatePart(month, @d_documentdate) = DatePart(month, @ad_asofdate) AND

       DatePart(year, @d_documentdate) = DatePart(year, @ad_asofdate) AND

       DatePart(day, @d_documentdate) <= DatePart(day, @ad_asofdate)

      BEGIN

        SELECT @ai_mtdcount = @ai_mtdcount + 1

        SELECT @ac_mtdsales = @ac_mtdsales + @c_amount

      END



    /*  this year totals  */

    IF DatePart(year, @d_documentdate) = DatePart(year, @ad_asofdate) AND

       (DatePart(month, @d_documentdate) < DatePart(month, @ad_asofdate) OR

       (DatePart(month, @d_documentdate) = DatePart(month, @ad_asofdate) AND

       DatePart(day, @d_documentdate) <= DatePart(day, @ad_asofdate)))

      BEGIN

        SELECT @ai_ytdcount = @ai_ytdcount + 1

        SELECT @ac_ytdsales = @ac_ytdsales + @c_amount

      END



    /*  last year totals  */

    IF DatePart(year, @d_documentdate) = DatePart(year, @ad_asofdate) - 1

      BEGIN

        SELECT @ai_lyrcount = @ai_lyrcount + 1

        SELECT @ac_lyrsales = @ac_lyrsales + @c_amount

      END



    /*  life to date totals  */

    IF @d_documentdate <= @ad_asofdate

      BEGIN

        SELECT @ai_ltdcount = @ai_ltdcount + 1

        SELECT @ac_ltdsales = @ac_ltdsales + @c_amount

      END



    /*  get the next document for this customer  */

    FETCH agingcursor INTO @c_amount, @c_appliedamount, @d_documentdate,

                           @d_duedate

  END



  /*  don't need this cursor any longer  */

  CLOSE agingcursor

  DEALLOCATE agingcursor



  /*  now compute the max/avg days to pay for this customer  */

  IF @as_agingcolumn = 'due_date'
    BEGIN
      OPEN maxavgcursor
     /*  prime fetch  */
      /*  note: @d_duedate will contain either due_date or document_date depending
            on what as_agingcolumn is set to */
      FETCH maxavgcursor INTO @d_duedate, @d_applieddate
    END
  ELSE
    BEGIN
      OPEN maxavgcursor2
      FETCH maxavgcursor2 INTO @d_duedate, @d_applieddate
    END

  WHILE @@fetch_status = 0

  BEGIN



    /*  How many days from due date/document date to app date for this document? */

    SELECT @i_days = DateDiff(day, @d_duedate, @d_applieddate)



    IF DatePart(month, @d_applieddate) = DatePart(month, @ad_asofdate) AND

       DatePart(year, @d_applieddate) = DatePart(year, @ad_asofdate) AND

       DatePart(day, @d_applieddate) <= DatePart(day, @ad_asofdate)

      BEGIN

        /*  Application is in the same month as the specified as of date */



        /*  accumulate monthly running totals  */

        SELECT @i_mtdapps = @i_mtdapps + 1

        SELECT @i_mtddays = @i_mtddays + @i_days

        /*  save maximum days to pay for the month  */

        IF @i_days > @ai_mtdmax  SELECT @ai_mtdmax = @i_days

      END



    IF DatePart(year, @d_applieddate) = DatePart(year, @ad_asofdate) AND

       (DatePart(month, @d_applieddate) < DatePart(month, @ad_asofdate) OR

       (DatePart(month, @d_applieddate) = DatePart(month, @ad_asofdate) AND

       DatePart(day, @d_applieddate) <= DatePart(day, @ad_asofdate)))

      BEGIN

        /*  Application is in the same year as the specified as of date */



        /*  accumulate year running totals  */

        SELECT @i_ytdapps = @i_ytdapps + 1

        SELECT @i_ytddays = @i_ytddays + @i_days

        /*  save maximum days to pay for the year  */

        IF @i_days > @ai_ytdmax  SELECT @ai_ytdmax = @i_days

      END



    IF DatePart(year, @d_applieddate) = DatePart(year, @ad_asofdate) - 1

      BEGIN

        /*  Application is in the year prior to the specified as of date */



        /*  accumulate last year running totals  */

        SELECT @i_lyrapps = @i_lyrapps + 1

        SELECT @i_lyrdays = @i_lyrdays + @i_days

        /*  save maximum days to pay for the year  */

        IF @i_days > @ai_lyrmax  SELECT @ai_lyrmax = @i_days

      END



    IF @d_applieddate <= @ad_asofdate

       BEGIN

         /*  accumulate life to date running totals */

         SELECT @i_ltdapps = @i_ltdapps + 1

         SELECT @i_ltddays = @i_ltddays + @i_days

         /*  save maximum days to pay for the life to date  */

         IF @i_days > @ai_ltdmax  SELECT @ai_ltdmax = @i_days

       END



    /*  get the next application for this customer  */

    IF @as_agingcolumn = 'due_date'
      FETCH maxavgcursor INTO @d_duedate, @d_applieddate
    ELSE
      FETCH maxavgcursor2 INTO @d_duedate, @d_applieddate
  END



  /*  don't need this cursor any longer  */
  IF @as_agingcolumn = 'due_date'
      CLOSE maxavgcursor

  ELSE
      CLOSE maxavgcursor2


  DEALLOCATE maxavgcursor

  DEALLOCATE maxavgcursor2

  /*  Compute the averages for the accumulated totals.

      Watch out for divide by zero errors!  */

  IF @i_mtdapps <> 0  SELECT @ac_mtdavg = @i_mtddays / @i_mtdapps

  IF @i_ytdapps <> 0  SELECT @ac_ytdavg = @i_ytddays / @i_ytdapps

  IF @i_lyrapps <> 0  SELECT @ac_lyravg = @i_lyrdays / @i_lyrapps

  IF @i_ltdapps <> 0  SELECT @ac_ltdavg = @i_ltddays / @i_ltdapps



  /*  Now retrieve the unapplied cash and credit memos  */

  SELECT @ac_unappliedcash = SUM( application_check_amount - IsNull(application_applied_amount, 0) )

    FROM bank_register

   WHERE document_class = 'AR' AND document_id2 = @as_customer

  IF @ac_unappliedcash IS NULL  SELECT @ac_unappliedcash = 0



  SELECT @ac_unappliedcrm = SUM( amount - IsNull(applied_amount, 0) )

    FROM ar_headers

   WHERE bill_customer = @as_customer AND document_type = 'C'
     AND intercompany <> 'Y' AND IsNull(ar_headers.pos_paid,'N') <> 'Y'

  IF @ac_unappliedcrm IS NULL  SELECT @ac_unappliedcrm = 0


END
GO
