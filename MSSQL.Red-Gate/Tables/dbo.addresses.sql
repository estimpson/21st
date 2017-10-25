CREATE TABLE [dbo].[addresses]
(
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postal_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Update_AddressMonitor]
ON [dbo].[addresses] FOR UPDATE
AS

-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 23-May-2005 Only update the Monitor addresses if one of the address
--             column values changed.  Otherwise, we end up updating the
--             the Monitor address when we come back in after clearing
--             the changed_user_id.

-- 13-Sep-2004 If the ledger is 'RENOSOL CORP', update the address in
--             Monitor even if the vendor class isn't 'MONITOR'.

-- 10-May-2004 If the ledger is 'LEXAMAR', only update vendors with a
--             vendor_class of 'PRODUCTION VENDORS' and put address 4, 
--             5, and 6 into city, state, and zip for vendors.

IF UPDATE(changed_user_id)
   BEGIN
     DECLARE @s_addressid varchar(25),
             @s_userid varchar(25)

     /* if the updated row was updated by our Monitor-to-Empower trigger
        it will contain 'MONUPD' in the user id column.  Clear this column 
        and exit the trigger */
      SELECT @s_addressid = address_id, 
             @s_userid = changed_user_id
        FROM inserted

     IF @s_userid = 'MONUPD'
        BEGIN
          UPDATE addresses
             SET changed_user_id = ''
           WHERE address_id = @s_addressid
          RETURN
        END
   END

IF UPDATE(address_1) OR UPDATE(address_2) OR UPDATE (address_3) OR
   UPDATE(city) OR UPDATE(state) OR UPDATE(postal_code) OR 
   UPDATE(country)
   BEGIN

       DECLARE @s_address1 varchar(50), 
               @s_address2 varchar(50), 
               @s_address3 varchar(50),  
               @s_city varchar(25),   
               @s_state varchar(25),  
               @s_postalcode varchar(10),  
               @s_country varchar(50),  
               @s_vendor varchar(25),  
               @s_customer varchar(25),  
               @s_ledger varchar(40),
               @s_monitorvendorclass varchar(25), 
               @s_vendorclass varchar(25), 
               @i_rowcount int

       /*  Make sure that we have a row in the inserted table for processing */
       SELECT @i_rowcount = Count(*) FROM inserted

       IF @i_rowcount > 0
         BEGIN

           /*  Select appropriate columns from the inserted table */
           SELECT @s_addressid=address_id,
                  @s_address1=address_1, 
                  @s_address2=address_2, 
                  @s_address3=address_3, 
                  @s_city=IsNull(city,''),  
                  @s_state=IsNull(state,''), 
                  @s_postalcode=IsNull(postal_code,''),
                  @s_country = country
             FROM inserted

           /* Get the default ledger. */
           SELECT @s_ledger = IsNull(value,'')
             FROM preferences_standard
            WHERE preference = 'GLLedger'

           IF @s_ledger = 'LEXAMAR'
             SELECT @s_monitorvendorclass = 'PRODUCTION VENDORS'
           ELSE
             SELECT @s_monitorvendorclass = 'MONITOR'

           IF @s_ledger <> 'LEXAMAR'
             SELECT @s_address3 = RTrim(@s_city) + ' ' + 
                                  RTrim(@s_state) + '  ' + @s_postalcode

           /* See if this address is used in the vendors table */
           DECLARE vendorcursor CURSOR FOR
              SELECT vendor, vendor_class
                FROM vendors
               WHERE address_id = @s_addressid

           OPEN vendorcursor

           /* prime fetch */
           FETCH vendorcursor INTO @s_vendor, @s_vendorclass

           WHILE @@FETCH_STATUS = 0
             BEGIN
               IF @s_vendorclass = @s_monitorvendorclass
               OR @s_ledger = 'RENOSOL CORP'
                 BEGIN 
                   IF @s_ledger = 'LEXAMAR'
                     /*  Update the Monitor vendor table with the new address */
                     UPDATE vendor SET address_1 = @s_address1,
                                       address_2 = @s_address2,
                                       address_3 = @s_address3,
                                       address_4 = @s_city,
                                       address_5 = @s_state,
                                       address_6 = @s_postalcode,
                                       empower_flag = 'EMPUPD'
                                 WHERE code = @s_vendor
                   ELSE
                     /*  Update the Monitor vendor table with the new address */
                     UPDATE vendor SET address_1 = @s_address1,
                                       address_2 = @s_address2,
                                       address_3 = @s_address3,
                                       address_4 = @s_country,
                                       empower_flag = 'EMPUPD'
                                 WHERE code = @s_vendor
                 END
                 /* get the next record, if any */
                 FETCH vendorcursor INTO @s_vendor, @s_vendorclass
              END

           CLOSE vendorcursor
           DEALLOCATE vendorcursor
  
           /* See if this address is used in the ar_customers table */
           DECLARE customercursor CURSOR FOR
              SELECT customer
                FROM ar_customers
               WHERE bill_address_id = @s_addressid

           OPEN customercursor

           /* prime fetch */
           FETCH customercursor INTO @s_customer

           WHILE @@FETCH_STATUS = 0
              BEGIN
                 /*  Update the Monitor customer table with the new address */
                 UPDATE customer SET address_1 = @s_address1,
                                     address_2 = @s_address2,
                                     address_3 = @s_address3,
                                     address_4 = @s_country,
                                     empower_flag = 'EMPUPD'
                               WHERE customer = @s_customer
                 /* get the next record, if any */
                 FETCH customercursor INTO @s_customer
              END

           CLOSE customercursor
           DEALLOCATE customercursor

         END
   END
GO
ALTER TABLE [dbo].[addresses] ADD CONSTRAINT [pk_addresses] PRIMARY KEY CLUSTERED  ([address_id]) ON [PRIMARY]
GO
