CREATE TABLE [dbo].[contacts]
(
[contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Update_ContactMonitor]
ON [dbo].[contacts] FOR UPDATE
AS

-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 19-Apr-2006 When the ledger is ET (Elliot Tape), don't update the Monitor
--             customer contact info with the Empower customer contact info.
--             The Monitor contact is a purchasing agent.  The Empower contact
--             is someone in AR.

-- 23-May-2005 Only update the Monitor contact info if a name or phone
--             number changed.  Otherwise, we end up updating the
--             the Monitor contact info when we come back in after clearing
--             the changed_user_id.

-- 13-Sep-2004 If the ledger is 'RENOSOL CORP', update the address in
--             Monitor even if the vendor class isn't 'MONITOR'.

IF UPDATE(changed_user_id)
   BEGIN
     DECLARE @s_contactid varchar(25),
             @s_userid varchar(25)

     SELECT @s_contactid = contact_id, 
            @s_userid = changed_user_id
       FROM inserted

     /* if the updated row was updated by our Monitor-to-Empower trigger
        it will contain 'MONITOR' in the user id column.  Clear this column 
        and exit the trigger. */
     IF @s_userid = 'MONUPD'
        BEGIN
          UPDATE contacts
             SET changed_user_id = ''
           WHERE contact_id = @s_contactid
          RETURN
        END

   END

IF UPDATE(first_name) OR UPDATE(last_name) OR UPDATE(phone) OR UPDATE(fax_phone)
   BEGIN

       DECLARE    @s_firstname varchar(40), 
                  @s_lastname varchar(40), 
                  @s_contactname varchar(50),  
                  @s_phone varchar(25),
                  @s_fax varchar(25),  
                  @s_vendor varchar(25),  
                  @s_customer varchar(25),
                  @s_ledger varchar(40),
                  @s_monitorvendorclass varchar(40),
                  @s_vendorclass varchar(25),
                  @i_rowcount int

       /*  Make sure that we have a row in the inserted table for processing */
       SELECT @i_rowcount = Count(*) FROM inserted

       IF @i_rowcount > 0
         BEGIN

           /*  Select appropriate columns from the inserted table */
           SELECT @s_contactid=contact_id,
                  @s_firstname=IsNull(first_name,''), 
                  @s_lastname=IsNull(last_name,''), 
                  @s_phone=phone, 
                  @s_fax=fax_phone
             FROM inserted

           /* Get the default ledger. */
           SELECT @s_ledger = IsNull(value,'')
             FROM preferences_standard
            WHERE preference = 'GLLedger'

           IF @s_ledger = 'LEXAMAR'
             SELECT @s_monitorvendorclass = 'PRODUCTION VENDORS'
           ELSE
             SELECT @s_monitorvendorclass = 'MONITOR'

           /* See if this contact is used in the vendors table */
           DECLARE vendcursor CURSOR FOR
              SELECT vendor, vendor_class
                FROM vendors
               WHERE contact_id = @s_contactid

           OPEN vendcursor

           /* prime fetch */
           FETCH vendcursor INTO @s_vendor, @s_vendorclass

           WHILE @@FETCH_STATUS = 0
              BEGIN
                 IF @s_vendorclass = @s_monitorvendorclass
                 OR @s_ledger = 'RENOSOL CORP'
                   BEGIN
                     /*  Update the Monitor vendor table with the new 
                         contact info */
                     SELECT @s_contactname = RTrim(@s_firstname) + ' ' 
                                           + @s_lastname
                     UPDATE vendor SET contact = @s_contactname,
                                   phone = @s_phone,
                                   fax = @s_fax,
                                   empower_flag = 'EMPUPD'
                             WHERE code = @s_vendor
                   END
                 /* get the next record, if any */   
                 FETCH vendcursor INTO @s_vendor, @s_vendorclass
              END
  
           CLOSE vendcursor
	   DEALLOCATE vendcursor

           IF @s_ledger <> 'ET'
             BEGIN
               /* See if this address is used in the ar_customers table */
               DECLARE custcursor CURSOR FOR
                  SELECT customer
                    FROM ar_customers
                   WHERE bill_contact_id = @s_contactid

               OPEN custcursor

               /* prime fetch */
               FETCH custcursor INTO @s_customer

               WHILE @@FETCH_STATUS = 0
                  BEGIN
                     /*  Update the Monitor customer table with the new contact info */
                     SELECT @s_contactname = RTrim(@s_firstname) + ' ' + @s_lastname
                     UPDATE customer 
                        SET contact = @s_contactname,
                            phone = @s_phone,
                            fax = @s_fax,
                            empower_flag = 'EMPUPD'
                      WHERE customer = @s_customer
                     /* get the next record, if any */
                     FETCH custcursor INTO @s_customer
                  END

               CLOSE custcursor
               DEALLOCATE custcursor
             END
    END
END
GO
ALTER TABLE [dbo].[contacts] ADD CONSTRAINT [pk_contacts] PRIMARY KEY CLUSTERED  ([contact_id]) ON [PRIMARY]
GO
