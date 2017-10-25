CREATE TABLE [dbo].[ar_customers]
(
[customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[intercompany] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[remit_to] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statement_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purge_option] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[collection_agent] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[db_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[credit_rating] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_exempt_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[writeoff_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[writeoff_limit] [decimal] (18, 6) NULL,
[delinquent_days] [smallint] NULL,
[delinquent_dollars] [decimal] (18, 6) NULL,
[hdr_ship_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_bill_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_contract_po] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_freight_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_price_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_finance_charge] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_doc_printed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_doc_approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_doc_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_account_manager] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_send_doc_to] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_disc_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_sales_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_contract_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_contract_account_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lock_box_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[credit_limit] [decimal] (18, 6) NULL,
[underpay_receivables_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[overpay_sales_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[overpay_liability_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_percent] [decimal] (18, 6) NULL,
[allow_backorder] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_agent] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_processor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[territory] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventory_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_method] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_draft_bank_name_address] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_terms_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[send_order_to] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_notification] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[port_loading] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[port_discharge] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_via] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_carrier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_notification] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_card] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_expiration_month] [smallint] NULL,
[cc_expiration_year] [smallint] NULL,
[cc_member] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailing_list] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Insert_CustomerMonitor]
ON [dbo].[ar_customers] FOR INSERT
AS

-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 19-Apr-2006 When the ledger is ET (Elliot Tape), don't update the Monitor
--             customer contact info with the Empower customer contact info.
--             The Monitor contact is a purchasing agent.  The Empower contact
--             is someone in AR.

-- 11-May-2004 When the customer already exists in Monitor, use the 
--             ar_customers.hdr_currency as the vendor.default_currency_unit 
--             only if GLCurrencyExchangeEnabled is "Y".

BEGIN
  DECLARE @s_customer varchar(25),
          @s_userid varchar(25),
          @s_customername varchar(100),
          @s_addressid varchar(25),
          @s_contactid varchar(25),
          @s_ledger varchar(40),
          @s_hdrterms varchar(25),
          @s_hdrshipunit varchar(25),
          @s_hdraccountmanager varchar(25),
          @s_hdrcurrency varchar(25),
          @s_address1 varchar(50),
          @s_address2 varchar(50),
          @s_address3 varchar(50),
          @s_city varchar(25),
          @s_state varchar(25),
          @s_postalcode varchar(10),
          @s_country varchar(50),
          @s_lastname varchar(40),
          @s_firstname varchar(40),
          @s_contactname varchar(35),
          @s_phone varchar(25),
          @s_fax varchar(25),
          @s_currency varchar(25),
          @s_curexchenabled varchar(25),
          @i_rowcount int

  /*  is there a row in the inserted table?  */
  SELECT @i_rowcount = Count(*) from inserted

  IF @i_rowcount > 0
    BEGIN

      /* select the appropriate columns from the inserted table */
      SELECT @s_customer = customer, 
             @s_customername = customer_name,
             @s_addressid = bill_address_id,
             @s_contactid = bill_contact_id,
             @s_hdrterms = hdr_terms,
             @s_hdrshipunit = hdr_ship_unit,
             @s_hdraccountmanager = hdr_account_manager,
             @s_hdrcurrency = hdr_currency,
             @s_userid = changed_user_id
        FROM inserted

     /* if the inserted row was inserted by our Monitor-to-Empower trigger
        it will contain 'MONITOR' in the user id column.  Clear this column 
        and exit the trigger. */
     IF @s_userid = 'MONITOR'
        BEGIN
          UPDATE ar_customers
             SET changed_user_id = ''
           WHERE customer = @s_customer
          RETURN
        END

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
      SELECT @s_address3 = RTrim(@s_city) + ' ' + RTrim(@s_state) + '  ' + @s_postalcode 

      /* Does the customer exist in the Monitor customer table? */
      SELECT @i_rowcount = Count(*)
        FROM customer
        WHERE customer = @s_customer

      IF @i_rowcount = 0
        BEGIN 
          /* insert a row into the Monitor customer table */
          INSERT INTO CUSTOMER ( customer, name, address_1, address_2, 
                                 address_3, address_4,
                                 phone, fax, modem, contact, 
                                 profile, company, salesrep,
                                 terms, category, bitmap_filename,
                                 default_currency_unit,  
                                 empower_flag, cs_status )
                        VALUES ( @s_customer, @s_customername, @s_address1, 
                                 @s_address2, @s_address3, @s_country,
                                 @s_phone, @s_fax, 
                                 '', @s_contactname, '', @s_hdrshipunit, 
                                 @s_hdraccountmanager, @s_hdrterms, '', '', 
                                 @s_hdrcurrency,'EMPOWER', 'Approved' )  
        END
      ELSE
        BEGIN
            /* Customer already exists in Monitor, so update the Monitor 
               customer table with the new values. Only update the
               currency if currency exchange is enabled; otherwise, we
               may overwrite the Monitor currency with an empty string. */


            /* Get the default ledger. */
           SELECT @s_ledger = IsNull(value,'')
             FROM preferences_standard
            WHERE preference = 'GLLedger'

           IF @s_ledger = 'ET'
             SELECT @s_contactname = contact,
                    @s_phone = phone,
                    @s_fax = fax
               FROM customer
              WHERE customer = @s_customer

           /* Get the preference that indicates if currency exchange is
               enabled. */
           SELECT @s_curexchenabled = IsNull(value,'')
             FROM preferences_standard
            WHERE preference = 'GLCurrencyExchangeEnabled'
           IF @@fetch_status <> 0 OR @s_curexchenabled = ''
             SELECT @s_curexchenabled = 'N'

           IF @s_curexchenabled = 'N'
             SELECT @s_hdrcurrency = default_currency_unit
               FROM customer
              WHERE customer = @s_customer

           UPDATE customer SET name = @s_customername,
                               address_1 = @s_address1,
                               address_2 = @s_address2,
                               address_3 = @s_address3,
                               contact = @s_contactname,
                               phone = @s_phone,
                               fax = @s_fax,
                               company = @s_hdrshipunit,
                               salesrep = @s_hdraccountmanager,
                               terms = @s_hdrterms,
                               default_currency_unit = @s_hdrcurrency,
                               empower_flag = 'EMPUPD'
                         WHERE customer = @s_customer
       END
  END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Update_CustomerMonitor]
ON [dbo].[ar_customers] FOR UPDATE
AS

-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 19-Apr-2006 When the ledger is ET (Elliot Tape), don't update the Monitor
--             customer contact info with the Empower customer contact info.
--             The Monitor contact is a purchasing agent.  The Empower contact
--             is someone in AR.

-- 11-May-2004 Only update customer.default_currency_unit with ar_customers.
--             hdr_currency if currency exchange is enabled; otherwise,
--             we may update the default_currency_unit with an empty string.

IF UPDATE(changed_user_id)
   BEGIN
     DECLARE @s_customer varchar(25),
             @s_currency varchar(25),
             @s_curexchenabled varchar(25),
             @s_userid varchar(25)

     /* if the updated row was updated by our Monitor-to-Empower trigger
        it will contain 'MONUPD' in the user id column.  Clear this column 
        and exit the trigger */
      SELECT @s_customer = customer, 
             @s_userid = changed_user_id
        FROM inserted

     IF @s_userid = 'MONUPD'
        BEGIN
          UPDATE ar_customers
             SET changed_user_id = ''
           WHERE customer = @s_customer
          RETURN
        END
   END

IF UPDATE(customer_name) or UPDATE(hdr_terms) or  
   UPDATE(hdr_account_manager) or UPDATE(hdr_ship_unit) or
   UPDATE(hdr_currency)
     BEGIN

       DECLARE    @s_customername varchar(40), 
                  @s_hdrterms varchar(25), 
                  @s_hdraccountmanager varchar(25),  
                  @s_hdrshipunit varchar(25), 
                  @s_hdrcurrency varchar(25), 
                  @i_rowcount int

       /*  Make sure that we have a row in the inserted table for processing */
       SELECT @i_rowcount = Count(*) FROM inserted

       IF @i_rowcount > 0
         BEGIN

           /*  Select appropriate columns from the inserted table */
           SELECT @s_customer=customer,
                  @s_customername=customer_name, 
                  @s_hdrterms=hdr_terms, 
                  @s_hdraccountmanager=hdr_account_manager, 
                  @s_hdrshipunit=hdr_ship_unit,
                  @s_hdrcurrency=hdr_currency
             FROM inserted

           /*  Update the Monitor customer table with the new values.
               Only update the currency if currency exchange is enabled; 
               otherwise, we may overwrite the Monitor currency with an 
               empty string. */
           /* Get the preference that indicates if currency exchange is
               enabled. */
           SELECT @s_curexchenabled = IsNull(value,'')
             FROM preferences_standard
            WHERE preference = 'GLCurrencyExchangeEnabled'
           IF @@fetch_status <> 0 OR @s_curexchenabled = ''
             SELECT @s_curexchenabled = 'N'

           IF @s_curexchenabled = 'N'
             SELECT @s_hdrcurrency = default_currency_unit
               FROM customer
              WHERE customer = @s_customer

           UPDATE customer SET name = @s_customername,
                               terms = @s_hdrterms,
                               salesrep = @s_hdraccountmanager,
                               company = @s_hdrshipunit,
                               default_currency_unit = @s_hdrcurrency,
                               empower_flag = 'EMPUPD'
                         WHERE customer = @s_customer
  
         END
     END

IF UPDATE(bill_address_id)
   /* Address id has been changed, therefore we need to update the
      Monitor customer table with the new address information.      */
   BEGIN
       DECLARE    @s_addressid varchar(25),
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
           SELECT @s_customer=customer,
                  @s_addressid=bill_address_id
             FROM inserted

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

          SELECT @s_address3 = RTrim(@s_city) + ' ' + 
                                RTrim(@s_state) + '  ' + @s_postalcode

           /*  Update the Monitor customer table with the new address */
           UPDATE customer SET address_1 = @s_address1,
                               address_2 = @s_address2,
                               address_3 = @s_address3,
                               address_4 = @s_country,
                               empower_flag = 'EMPUPD'
                         WHERE customer = @s_customer
  
         END
     END

IF UPDATE(bill_contact_id)
   /* Contact id has been changed, therefore we need to update the
      Monitor customer table with the new contact information. */
   BEGIN
       DECLARE    @s_contactid varchar(25),
                  @s_firstname varchar(40), 
                  @s_lastname varchar(40), 
                  @s_contactname varchar(50),  
                  @s_phone varchar(25),   
                  @s_fax varchar(25),
                  @s_ledger varchar(40)

       /* Get the default ledger. */
       SELECT @s_ledger = IsNull(value,'')
         FROM preferences_standard
        WHERE preference = 'GLLedger'

       /*  Make sure that we have a row in the inserted table for processing */
       SELECT @i_rowcount = Count(*) FROM inserted

       IF @i_rowcount > 0 AND @s_ledger <> 'ET'
         BEGIN

           /*  Select contact id from the inserted table */
           SELECT @s_customer=customer,
                  @s_contactid=bill_contact_id
             FROM inserted

           /*  Select contact fields from the contacts table */
           SELECT @s_firstname = IsNull(first_name,''),
                  @s_lastname = IsNull(last_name,''),
                  @s_phone = phone,
                  @s_fax= fax_phone
            FROM contacts
           WHERE contact_id = @s_contactid

           SELECT @s_contactname = RTrim(@s_firstname) + ' ' + @s_lastname

           /*  Update the Monitor customer table with the new contact info */
           UPDATE customer SET contact = @s_contactname,
                               phone = @s_phone,
                               fax = @s_fax,
                               empower_flag = 'EMPUPD'
                         WHERE customer = @s_customer
  
         END
   END
GO
ALTER TABLE [dbo].[ar_customers] ADD CONSTRAINT [pk_ar_customers] PRIMARY KEY NONCLUSTERED  ([customer]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [customer_name] ON [dbo].[ar_customers] ([customer_name]) ON [PRIMARY]
GO
