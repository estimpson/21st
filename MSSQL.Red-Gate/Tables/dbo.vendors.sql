CREATE TABLE [dbo].[vendors]
(
[vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[intercompany] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_contract] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_separate_check] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_hold_payment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_invoice_limit] [decimal] (18, 6) NULL,
[hdr_ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_disc_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_expense_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_freight] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_remittance_advice] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_minimum_check_amount] [decimal] (18, 6) NULL,
[d1099_1099_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[d1099_1099_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[d1099_federal_tax_id] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[d1099_state_tax_id] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_buy_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_pay_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_contract_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_contract_account_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_costrevenue_type_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_rni_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_po_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_po_document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_buyer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_freight_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_po_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disadvantaged_business_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_check_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chk_check_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[d1099_1099_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_invoice_approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_po_approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transit_routing_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prenotes_required] [smallint] NULL,
[prenotes_given] [smallint] NULL,
[last_document_group_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_sales_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_sales_terms_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_notification_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_notification_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id_1099] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Insert_VendorMonitor]
ON [dbo].[vendors] FOR INSERT
AS

-- 06-Jul-2010 Shorten the vendor name to 35 characters when updating the Monitor vendor
--             table.

-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 13-Sep-2004 If the ledger is 'RENOSOL CORP', send the vendor to
--             Monitor regardless of the vendor class.

-- 10-May-2004 1. Use the vendors.hdr_currency to update the vendor.
--                default_currency_unit only if GLCurrencyExchangeEnabled
--                is "Y".
--             2. If the ledger is 'LEXAMAR', only process vendors with a
--                document_class of 'PRODUCTION VENDOR' and put address 4, 
--                5, and 6 into city, state, and zip.

BEGIN
  DECLARE @s_hdrfreightterms varchar(25),
          @s_hdrlocation varchar(25),
          @s_hdrbuyer varchar(25),
          @s_vendor varchar(25),
          @s_vendorname varchar(40),
          @s_addressid varchar(25),
          @s_contactid varchar(25),
          @s_vendorclass varchar(25),
          @s_hdrterms varchar(25),
          @s_itemfreight varchar(25),
          @s_hdrbuyunit varchar(25),
          @s_hdrcurrency varchar(25),
          @s_address1 varchar(50),
          @s_address2 varchar(50),
          @s_address3 varchar(50),
          @s_city varchar(25),
          @s_state varchar(25),
          @s_postalcode varchar(25),
          @s_country varchar(50),
          @s_lastname varchar(40),
          @s_firstname varchar(40),
          @s_contactname varchar(35),
          @s_phone varchar(25),
          @s_fax varchar(25),
          @s_ledger varchar(40),
          @s_monitorvendorclass varchar(25),
          @s_curexchenabled varchar(25),
          @s_userid varchar(25),
          @i_rowcount int

  /*  is there a row in the inserted table?  */
  SELECT @i_rowcount = Count(*) from inserted

  IF @i_rowcount > 0
    BEGIN

      /* select the appropriate columns from the inserted table */
      SELECT @s_hdrfreightterms = hdr_freight_terms, 
             @s_hdrlocation = hdr_location,
             @s_hdrbuyer = hdr_buyer,
             @s_vendor = vendor,
             @s_vendorname = substring(vendor_name,1,35),
             @s_vendorclass = IsNull(vendor_class,''),
             @s_addressid = address_id,
             @s_contactid = contact_id,
             @s_hdrterms = hdr_terms,
             @s_itemfreight = item_freight,
             @s_hdrbuyunit = hdr_buy_unit,
             @s_hdrcurrency = hdr_currency,
             @s_userid = changed_user_id
        FROM inserted

     /* if the inserted row was inserted by our Monitor-to-Empower trigger
        it will contain 'MONITOR' in the user id column.  Clear this column 
        and exit the trigger */
     IF @s_userid = 'MONITOR'
        BEGIN
          UPDATE vendors
             SET changed_user_id = ''
           WHERE vendor = @s_vendor
          RETURN
        END

      /* Get the default ledger. */
      SELECT @s_ledger = IsNull(value,'')
        FROM preferences_standard
       WHERE preference = 'GLLedger'

      IF @s_ledger = 'LEXAMAR'
        SELECT @s_monitorvendorclass = 'PRODUCTION VENDORS'
      ELSE
        SELECT @s_monitorvendorclass = 'MONITOR'

      IF @s_vendorclass <> @s_monitorvendorclass 
      AND @s_ledger <> 'RENOSOL CORP' RETURN

      /* get the address fields from the addresses table */
      SELECT @s_address1 = address_1,
             @s_address2 = address_2,
             @s_address3 = address_3,
             @s_city = IsNull(city,''),
             @s_state = IsNull(state,''),
             @s_postalcode = IsNull(postal_code,''),
             @s_country = country
        FROM addresses
       WHERE address_id = @s_addressid

      /* get the fields from the contacts table */
      SELECT @s_lastname = IsNull(last_name,''),
             @s_firstname = IsNull(first_name,''),
             @s_phone = phone,
             @s_fax = fax_phone
        FROM contacts
       WHERE contact_id = @s_contactid

      SELECT @s_contactname = RTrim(@s_firstname) + ' ' + @s_lastname
      IF @s_ledger <> 'LEXAMAR'
        SELECT @s_address3 = RTrim(@s_city) + ' ' + RTrim(@s_state) + '  ' + @s_postalcode

      /* Does the vendor exist in the Monitor vendor table? */
      SELECT @i_rowcount = Count(*)
        FROM vendor
        WHERE code = @s_vendor

      IF @i_rowcount = 0
        BEGIN 
          /* insert a row into the Monitor vendor table */
          IF @s_ledger = 'LEXAMAR'
            INSERT INTO VENDOR ( code, name, outside_processor, contact,
                                 phone, terms, ytd_sales, balance,
                                 frieght_type, fob, buyer, plant,
                                 ship_via, company, address_1, address_2,
                                 address_3, address_4, address_5, address_6,
                                 fax, flag, partial_release_update,
                                 default_currency_unit,
                                 empower_flag)
                        VALUES ( @s_vendor, @s_vendorname, '', @s_contactname,
                                 @s_phone, @s_hdrterms, 0, 0, 
                                 @s_hdrfreightterms, '', @s_hdrbuyer, @s_hdrlocation,
                                 @s_itemfreight, @s_hdrbuyunit, @s_address1, @s_address2,
                                 @s_address3, @s_city, @s_state, @s_postalcode, 
                                 @s_fax, 0, '', @s_hdrcurrency,
                                 'EMPOWER' )  
          ELSE
            INSERT INTO VENDOR ( code, name, outside_processor, contact,
                                 phone, terms, ytd_sales, balance,
                                 frieght_type, fob, buyer, plant,
                                 ship_via, company, address_1, address_2,
                                 address_3, address_4,
                                 fax, flag, partial_release_update,
                                 default_currency_unit,
                                 empower_flag)
                        VALUES ( @s_vendor, @s_vendorname, '', @s_contactname,
                                 @s_phone, @s_hdrterms, 0, 0, 
                                 @s_hdrfreightterms, '', @s_hdrbuyer, @s_hdrlocation,
                                 @s_itemfreight, @s_hdrbuyunit, @s_address1, @s_address2,
                                 @s_address3, @s_country, @s_fax, 0, '', @s_hdrcurrency,
                                 'EMPOWER' )  
        END
      ELSE
        BEGIN
          /* Vendor already exists in Monitor so update it */
          IF @s_ledger = 'LEXAMAR'
            UPDATE vendor SET name = @s_vendorname,
                              terms = @s_hdrterms,
                              frieght_type = @s_hdrfreightterms,
                              buyer = @s_hdrbuyer,
                              plant = @s_hdrlocation,
                              ship_via = @s_itemfreight,
                              company = @s_hdrbuyunit,
                              address_1 = @s_address1,
                              address_2 = @s_address2,
                              address_3 = @s_address3,
                              address_4 = @s_city,
                              address_5 = @s_state,
                              address_6 = @s_postalcode,
                              contact = @s_contactname,
                              phone = @s_phone,
                              fax = @s_fax,
                              empower_flag = 'EMPUPD'
                        WHERE code = @s_vendor
          ELSE
            BEGIN
              /* Get the preference that indicates if currency exchange 
                 is enabled. */
              SELECT @s_curexchenabled = IsNull(value,'')
                FROM preferences_standard
               WHERE preference = 'GLCurrencyExchangeEnabled'
              IF @@fetch_status <> 0 OR @s_curexchenabled = ''
                SELECT @s_curexchenabled = 'N'

              IF @s_curexchenabled = 'N'
                SELECT @s_hdrcurrency = default_currency_unit
                  FROM vendor
                 WHERE code = @s_vendor

              UPDATE vendor SET name = @s_vendorname,
                                terms = @s_hdrterms,
                                frieght_type = @s_hdrfreightterms,
                                buyer = @s_hdrbuyer,
                                plant = @s_hdrlocation,
                                ship_via = @s_itemfreight,
                                company = @s_hdrbuyunit,
                                address_1 = @s_address1,
                                address_2 = @s_address2,
                                address_3 = @s_address3,
                                address_4 = @s_country,
                                contact = @s_contactname,
                                phone = @s_phone,
                                fax = @s_fax,
                                default_currency_unit = @s_hdrcurrency,
                                empower_flag = 'EMPUPD'
                          WHERE code = @s_vendor
            END
       END
  END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Update_VendorMonitor]
ON [dbo].[vendors] FOR UPDATE
AS

-- 06-Jul-2010 Shorten the vendor name to 35 characters when updating the Monitor vendor
--             table.


-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 13-Sep-2004 If the ledger is 'RENOSOL CORP', update the Monitor vendor
--             regardless of the vendor class.

-- 10-May-2004 1. Use the vendor.default_currency_unit as the vendors.
--                hdr_currency only if GLCurrencyExchangeEnabled is "Y".
--             2. If the ledger is 'LEXAMAR', only process vendors
--                with a class of 'PRODUCTION VENDORS' and put address 4, 
--                5, and 6 into city, state, and zip.

IF UPDATE(changed_user_id)
   BEGIN
     DECLARE @s_vendor varchar(25),
             @s_ledger varchar(40),
             @s_curexchenabled varchar(25),
             @s_vendorclass varchar(25),
             @s_monitorvendorclass varchar(25),
             @s_userid varchar(25)

        /* if the updated row was updated by our Monitor-to-Empower trigger
           it will contain 'MONUPD' in the user_id column.  Clear this column 
           and exit the trigger */
        SELECT @s_vendor = vendor,
               @s_userid = changed_user_id
          FROM inserted

        IF @s_userid = 'MONUPD'
           BEGIN
             UPDATE vendors
                SET changed_user_id = ''
              WHERE vendor = @s_vendor
             RETURN
           END
   END

IF UPDATE(vendor_name) or UPDATE(hdr_terms) or UPDATE(hdr_freight_terms) or 
   UPDATE(hdr_buyer) or UPDATE(hdr_location) or 
   UPDATE(item_freight) or UPDATE(hdr_buy_unit) or UPDATE(hdr_currency)
     BEGIN

       DECLARE @s_vendorname varchar(40),
               @s_hdrterms varchar(25), 
               @s_hdrfreightterms varchar(25),  
               @s_hdrbuyer varchar(25),  
               @s_hdrlocation varchar(25),  
               @s_itemfreight varchar(25),  
               @s_hdrbuyunit varchar(25), 
               @s_hdrcurrency varchar(25), 
               @i_rowcount int

       /*  Make sure that we have a row in the inserted table for processing */
       SELECT @i_rowcount = Count(*) FROM inserted

       IF @i_rowcount > 0
         BEGIN

           /*  Select appropriate columns from the inserted table */
           SELECT @s_vendor=vendor,
                  @s_vendorname=substring(vendor_name,1,35), 
                  @s_vendorclass=IsNull(vendor_class,''), 
                  @s_hdrterms=hdr_terms, 
                  @s_hdrfreightterms=hdr_freight_terms, 
                  @s_hdrbuyer=hdr_buyer, 
                  @s_hdrlocation=hdr_location, 
                  @s_itemfreight=item_freight, 
                  @s_hdrbuyunit=hdr_buy_unit,
                  @s_hdrcurrency=hdr_currency
             FROM inserted

           /* Get the default ledger. */
           SELECT @s_ledger = IsNull(value,'')
             FROM preferences_standard
            WHERE preference = 'GLLedger'

           IF @s_ledger = 'LEXAMAR'
             SELECT @s_monitorvendorclass = 'PRODUCTION VENDORS'
           ELSE
             SELECT @s_monitorvendorclass = 'MONITOR'

           IF @s_vendorclass <> @s_monitorvendorclass 
           AND @s_ledger <> 'RENOSOL CORP' RETURN

           /* Get the preference that indicates if currency exchange 
              is enabled. */
           SELECT @s_curexchenabled = IsNull(value,'')
             FROM preferences_standard
            WHERE preference = 'GLCurrencyExchangeEnabled'
           IF @@fetch_status <> 0 OR @s_curexchenabled  = ''
             SELECT @s_curexchenabled = 'N'

           IF @s_curexchenabled = 'N'
             SELECT @s_hdrcurrency = default_currency_unit
               FROM vendor
              WHERE code = @s_vendor

           /*  Update the Monitor vendor table with the new values */
           UPDATE vendor SET name = @s_vendorname,
                             terms = @s_hdrterms,
                             frieght_type = @s_hdrfreightterms,
                             buyer = @s_hdrbuyer,
                             plant = @s_hdrlocation,
                             ship_via = @s_itemfreight,
                             company = @s_hdrbuyunit,
                             default_currency_unit = @s_hdrcurrency,
                             empower_flag = 'EMPUPD'
                       WHERE code = @s_vendor
  
         END
     END

IF UPDATE(address_id)
   /* Address id has been changed, therefore we need to update the
      Monitor vendor table with the new address information.       */
   BEGIN
       DECLARE @s_addressid varchar(25),
               @s_address1 varchar(50), 
               @s_address2 varchar(50), 
               @s_address3 varchar(50),  
               @s_city varchar(25),   
               @s_state varchar(25),  
               @s_postalcode varchar(10),
               @s_country varchar(50)

       /*  Make sure that we have a row in the inserted table for processing */
       SELECT @i_rowcount = Count(*) FROM inserted

       IF @i_rowcount > 0
         BEGIN

           /*  Select address id from the inserted table */
           SELECT @s_vendor=vendor,
                  @s_vendorclass=vendor_class,
                  @s_addressid=address_id
             FROM inserted

           /* Get the default ledger. */
           SELECT @s_ledger = IsNull(value,'')
             FROM preferences_standard
            WHERE preference = 'GLLedger'

           IF @s_ledger = 'LEXAMAR'
             SELECT @s_monitorvendorclass = 'PRODUCTION VENDORS'
           ELSE
             SELECT @s_monitorvendorclass = 'MONITOR'

           IF @s_vendorclass <> @s_monitorvendorclass 
           AND @s_ledger <> 'RENOSOL CORP' RETURN
  
           /*  Select address fields from the address table */
           SELECT @s_address1 = address_1,
                  @s_address2 = address_2,
                  @s_address3 = address_3,
                  @s_city = IsNull(city,''),
                  @s_state = IsNull(state,''),
                  @s_postalcode = IsNull(postal_code,''),
                  @s_country = country
            FROM addresses
           WHERE address_id = @s_addressid
 
           /*  Update the Monitor vendor table with the new address */
           IF @s_ledger = 'LEXAMAR'
             UPDATE vendor SET address_1 = @s_address1,
                               address_2 = @s_address2,
                               address_3 = @s_address3,
                               address_4 = @s_city,
                               address_5 = @s_state,
                               address_6 = @s_postalcode,
                               empower_flag = 'EMPUPD'
                         WHERE code = @s_vendor
           ELSE
             BEGIN
               SELECT @s_address3 = RTrim(@s_city) + ' ' + 
                                    RTrim(@s_state) + '  ' + @s_postalcode

               UPDATE vendor SET address_1 = @s_address1,
                                 address_2 = @s_address2,
                                 address_3 = @s_address3,
                                 address_4 = @s_country,
                                 empower_flag = 'EMPUPD'
                           WHERE code = @s_vendor
             END
         END
     END

IF UPDATE(contact_id)
   /* Contact id has been changed, therefore we need to update the
      Monitor vendor table with the new contact information.       */
   BEGIN
       DECLARE @s_contactid varchar(25),
               @s_firstname varchar(40), 
               @s_lastname varchar(40), 
               @s_contactname varchar(50),  
               @s_phone varchar(25),   
               @s_fax varchar(25)

       /*  Make sure that we have a row in the inserted table for processing */
       SELECT @i_rowcount = Count(*) FROM inserted

       IF @i_rowcount > 0
         BEGIN

           /*  Select contact id from the inserted table */
           SELECT @s_vendor=vendor,
                  @s_vendorclass=vendor_class,
                  @s_contactid=contact_id
             FROM inserted

           /* Get the default ledger. */
           SELECT @s_ledger = IsNull(value,'')
             FROM preferences_standard
            WHERE preference = 'GLLedger'

           IF @s_ledger = 'LEXAMAR'
             SELECT @s_monitorvendorclass = 'PRODUCTION VENDORS'
           ELSE
             SELECT @s_monitorvendorclass = 'MONITOR'

           IF @s_vendorclass <> @s_monitorvendorclass 
           AND @s_ledger <> 'RENOSOL CORP' RETURN

          /*  Select contact fields from the contacts table */
           SELECT @s_firstname = IsNull(first_name,''),
                  @s_lastname = IsNull(last_name,''),
                  @s_phone = phone,
                  @s_fax = fax_phone
             FROM contacts
            WHERE contact_id = @s_contactid

           SELECT @s_contactname = RTrim(@s_firstname) + ' ' + @s_lastname

           /*  Update the Monitor vendor table with the new contact info */
           UPDATE vendor SET contact = @s_contactname,
                             phone = @s_phone,
                             fax = @s_fax,
                             empower_flag = 'EMPUPD'
                       WHERE code = @s_vendor
  
         END
     END
GO
ALTER TABLE [dbo].[vendors] ADD CONSTRAINT [pk_vendors] PRIMARY KEY NONCLUSTERED  ([vendor]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [vendors_vendor_name] ON [dbo].[vendors] ([vendor_name]) ON [PRIMARY]
GO
