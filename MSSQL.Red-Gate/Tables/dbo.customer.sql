CREATE TABLE [dbo].[customer]
(
[customer] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modem] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[salesrep] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terms] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[category] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_bitmap] [image] NULL,
[bitmap_filename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NULL,
[address_4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_currency_unit] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[show_euro_amount] [smallint] NULL,
[cs_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom4] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom5] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_manager_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[region_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[auto_profile] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_standard_pack] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[empower_flag] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_CustomerEmpower]
ON [dbo].[customer] FOR INSERT 
AS

-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 19-Apr-2006 When the ledger is ET (Elliot Tape), don't update the Empower
--             customer contact info with the Monitor customer contact info.
--             The Monitor contact is a purchasing agent.  The Empower contact
--             is someone in AR.

-- 10-May-2004 Use the customer.default_currency_unit as the ar_customers.
--             hdr_currency only if GLCurrencyExchangeEnabled is "Y".

-- 03-Mar-2004 Added invoice_notification.

-- 02-Oct-2001 Added Empower v6.0 customer columns and added script to 
--             insert into ar_customer_ship_locations.

BEGIN
  DECLARE @s_addressid varchar(25),
          @s_contactid varchar(25),
          @s_empowerflag varchar(8),
          @s_ledger   varchar(40),
          @s_customer varchar(25),
          @s_name varchar(100),
          @s_customerclass varchar(25),
          @s_address1 varchar(50),
          @s_address2 varchar(50),
          @s_address3 varchar(50),
          @s_phone varchar(25),
          @s_fax varchar(25),
          @s_contact varchar(35),
          @s_salesrep varchar(10),
          @s_terms varchar(20),
          @s_currency varchar(3),
          @s_status char(1),
          @s_intercompany char(1),
          @s_remitto varchar(25),
          @s_writeoffledgeraccount varchar(50),
          @s_hdrdocprinted char(1),
          @s_hdrshipunit varchar(25),
          @s_hdrbillunit varchar(25),
          @s_hdrsenddocto varchar(10),
          @s_hdrledger varchar(40),
          @s_hdrledgeraccountcode varchar(50),
          @s_hdrdiscledgeraccountcode varchar(50),
          @s_statementcycle varchar(25),
          @s_purgeoption varchar(25),
          @s_collectionagent varchar(25),
          @s_hdrcontractpo varchar(25),
          @s_hdrfreightterms varchar(25),
          @s_hdrpricegroup varchar(25),
          @s_hdrfinancecharge varchar(25),
          @s_hdrdocclass varchar(25),
          @s_hdrcurrency varchar(25),
          @s_hdrdocapproved char(1),
          @s_itemtax1 varchar(25),
          @s_itemtax2 varchar(25),
          @s_itemsalesanalysis varchar(25),
          @s_itemledgeraccountcode varchar(50),
          @s_itemcontractid varchar(25),
          @s_itemcontractaccountid varchar(25),
          @c_writeofflimit decimal(18,6),
          @c_delinquentdollars decimal(18,6),
          @i_delinquentdays integer,
          @c_creditlimit decimal(18,6),
          @s_underpayreceivablesaccount varchar(50),
          @s_overpaysalesaccount varchar(50),
          @s_overpayliabilityaccount varchar(50),
          @s_salesterms varchar(25),
          @c_discountpercent decimal(18,6),
          @s_allowbackorder char(1),
          @s_consolidator varchar(25),
          @s_salesagent varchar(25),
          @s_orderprocessor varchar(25),
          @s_territory varchar(25),
          @s_inventorylocation varchar(25),
          @s_paymentmethod varchar(5),
          @s_securitycompany varchar(25),
          @s_salestermslocation varchar(25),
          @s_sendorderto varchar(10),
          @s_ordernotification varchar(6),
          @s_portloading varchar(25),
          @s_portdischarge varchar(25),
          @s_shipvia varchar(25),
          @s_freightcarrier varchar(25),
          @s_invoicenotification varchar(6),
          @s_curexchenabled varchar(25),
          @s_value varchar(25),
          @i_rowcount integer

/* Is there a row in the inserted table? */
SELECT @i_rowcount = Count(*) from inserted

IF @i_rowcount > 0
   BEGIN

     /* select the appropriate columns from the inserted table */
     SELECT @s_customer = customer,
            @s_name = name,
            @s_address1 = address_1,
            @s_address2 = address_2,
            @s_address3 = address_3,
            @s_phone = phone,
            @s_fax = fax,
            @s_contact = contact,
            @s_salesrep = Ltrim(Rtrim(Upper(salesrep))),
            @s_terms = Ltrim(Rtrim(Upper(terms))),
            @s_currency = Ltrim(Rtrim(Upper(default_currency_unit))),
            @s_empowerflag = empower_flag
       FROM inserted

     /* if the inserted row was inserted by our Empower-to-Monitor trigger
        it will contain 'EMPOWER' in the empower_flag column.  Clear this column 
        and exit the trigger */
     IF @s_empowerflag = 'EMPOWER'
        BEGIN
          UPDATE customer
             SET empower_flag = ''
           WHERE customer = @s_customer
          RETURN
        END

     /* Get the default ledger. */
     SELECT @s_ledger = IsNull(value,'')
       FROM preferences_standard
      WHERE preference = 'GLLedger'

     /* Get the preference that indicates if currency exchange is enabled. */
     SELECT @s_curexchenabled = IsNull(value,'')
       FROM preferences_standard
      WHERE preference = 'GLCurrencyExchangeEnabled'
     IF @@fetch_status <> 0 OR @s_curexchenabled  = ''
       SELECT @s_curexchenabled = 'N'

     SELECT @s_customer = Rtrim(LTrim(Upper(@s_customer)))

     /* See if this customer already exists in Empower. */
     SELECT @i_rowcount = Count(*)
       FROM ar_customers
      WHERE customer = @s_customer

     IF @i_rowcount = 0
       BEGIN
          /* get a contact id and insert a row into contacts */
          EXECUTE GetNextIdentifier 'CONTACT', 'CONTACT', @s_contactid OUTPUT

          INSERT INTO CONTACTS ( contact_id, last_name, first_name, 
                                 phone, fax_phone, changed_date, changed_user_id ) 
                        VALUES ( @s_contactid, 
                                 SUBSTRING(@s_contact,CHARINDEX(' ', @s_contact) + 1,COL_LENGTH('customer','contact')),
                                 SUBSTRING(@s_contact,1,CHARINDEX(' ', @s_contact)),
                                 @s_phone, @s_fax, GETDATE(), 'MONITOR' )

          /* get an address id and insert a row into addresses */
          EXECUTE GetNextIdentifier 'ADDRESS', 'ADDRESS', @s_addressid OUTPUT

          INSERT INTO ADDRESSES ( address_id, address_1, address_2, 
                                  address_3, changed_date, changed_user_id ) 
                         VALUES ( @s_addressid, @s_address1, 
                                  @s_address2, @s_address3, GETDATE(), 'MONITOR' )

          /* Get the preference that indicates the customer id of the default
             customer. */
          SELECT @s_value = value
            FROM preferences_standard
           WHERE preference = 'ARCustomerDefault'

          /* Now get the ar_customer record for the default customer */
          SELECT @s_status = status,
                 @s_intercompany = intercompany,
                 @s_customerclass = customer_class,
                 @s_remitto = remit_to,
                 @s_writeoffledgeraccount = writeoff_ledger_account,
                 @s_hdrdocprinted = hdr_doc_printed,
                 @s_hdrsenddocto = hdr_send_doc_to,
                 @s_hdrledger = hdr_ledger,
                 @s_hdrledgeraccountcode = hdr_ledger_account_code,
                 @s_hdrdiscledgeraccountcode = hdr_disc_ledger_account_code,
                 @s_statementcycle = statement_cycle,
                 @s_purgeoption = purge_option,
                 @s_collectionagent = collection_agent,
                 @s_hdrcontractpo = hdr_contract_po,
                 @s_hdrfreightterms = hdr_freight_terms,
                 @s_hdrpricegroup = hdr_price_group,
                 @s_hdrfinancecharge = hdr_finance_charge,
                 @s_hdrdocclass = hdr_doc_class,
                 @s_hdrcurrency = hdr_currency,
                 @s_hdrdocapproved = hdr_doc_approved,
                 @s_itemtax1 = item_tax_1,
                 @s_itemtax2 = item_tax_2,
                 @s_itemsalesanalysis = item_sales_analysis,
                 @s_itemledgeraccountcode = item_ledger_account_code,
                 @s_itemcontractid = item_contract_id,
                 @s_itemcontractaccountid = item_contract_account_id,
                 @c_writeofflimit = writeoff_limit,
                 @c_delinquentdollars = delinquent_dollars,
                 @i_delinquentdays = delinquent_days,
                 @s_hdrshipunit = hdr_ship_unit,
                 @s_hdrbillunit = hdr_bill_unit,
                 @c_creditlimit = credit_limit,
                 @s_underpayreceivablesaccount = underpay_receivables_account,
                 @s_overpaysalesaccount = overpay_sales_account,
                 @s_overpayliabilityaccount = overpay_liability_account,
                 @s_salesterms = sales_terms, 
                 @c_discountpercent = discount_percent,
                 @s_allowbackorder = allow_backorder,
                 @s_consolidator = consolidator, 
                 @s_salesagent = sales_agent, 
                 @s_orderprocessor = order_processor,
                 @s_territory = territory, 
                 @s_inventorylocation = inventory_location, 
                 @s_paymentmethod = payment_method,
                 @s_securitycompany = security_company,
                 @s_salestermslocation = sales_terms_location, 
                 @s_sendorderto = send_order_to,
                 @s_ordernotification = order_notification,
                 @s_portloading = port_loading, 
                 @s_portdischarge = port_discharge, 
                 @s_shipvia = ship_via, 
                 @s_freightcarrier = freight_carrier,
                 @s_invoicenotification = invoice_notification

            FROM ar_customers
           WHERE customer = @s_value

          /* Make sure that status and intercompany have values */
        IF @s_status IS NULL OR @s_status = ''
          SELECT @s_status = 'A'
        IF @s_intercompany IS NULL OR @s_intercompany = ''
          SELECT @s_intercompany = 'N'
        IF @s_sendorderto IS NULL or @s_sendorderto = ''
          SELECT @s_sendorderto = 'SHIP-TO'
        IF @s_ordernotification IS NULL or @s_ordernotification = ''
          SELECT @s_ordernotification = 'PRINT'
        IF @s_invoicenotification IS NULL or @s_invoicenotification = ''
          SELECT @s_invoicenotification = 'PRINT'
        IF @s_curexchenabled = 'Y'
          SELECT @s_hdrcurrency = @s_currency

        /* insert a row into the Empower ar_customers table for the new customer*/
        INSERT INTO AR_CUSTOMERS 
              ( customer, bill_customer, customer_name, customer_class, 
                hdr_ship_unit, hdr_bill_unit, hdr_account_manager, 
                hdr_terms, bill_address_id, bill_contact_id, 
                changed_date, changed_user_id, status,
                intercompany, remit_to, writeoff_ledger_account,
                hdr_doc_printed, hdr_currency,
                hdr_send_doc_to, hdr_ledger,
                hdr_ledger_account_code,
                hdr_disc_ledger_account_code,
                statement_cycle, purge_option,
                collection_agent, hdr_contract_po,
                hdr_freight_terms, hdr_price_group,
                hdr_finance_charge, hdr_doc_class,
                hdr_doc_approved, item_tax_1,
                item_tax_2, item_sales_analysis,
                item_ledger_account_code, item_contract_id, 
                item_contract_account_id,
                writeoff_limit, delinquent_days,
                delinquent_dollars, credit_limit,
                underpay_receivables_account,
                overpay_sales_account,overpay_liability_account,
                sales_terms, discount_percent, allow_backorder,
                consolidator, sales_agent, order_processor,
                territory, inventory_location, payment_method,
                security_company,
                sales_terms_location, send_order_to, order_notification,
                port_loading, port_discharge, ship_via, freight_carrier,
                invoice_notification ) 
       VALUES ( @s_customer, @s_customer, @s_name, @s_customerclass, 
                @s_hdrshipunit, @s_hdrbillunit, @s_salesrep, 
                @s_terms, @s_addressid,@s_contactid, 
                GETDATE(), 'MONITOR', @s_status,
                @s_intercompany, @s_remitto, @s_writeoffledgeraccount,
                @s_hdrdocprinted, @s_hdrcurrency,
                @s_hdrsenddocto, @s_hdrledger,
                @s_hdrledgeraccountcode,
                @s_hdrdiscledgeraccountcode,
                @s_statementcycle, @s_purgeoption,
                @s_collectionagent, @s_hdrcontractpo,
                @s_hdrfreightterms, @s_hdrpricegroup,
                @s_hdrfinancecharge, @s_hdrdocclass,
                @s_hdrdocapproved, @s_itemtax1,
                @s_itemtax2, @s_itemsalesanalysis,
                @s_itemledgeraccountcode, @s_itemcontractid, 
                @s_itemcontractaccountid,
                @c_writeofflimit, @i_delinquentdays,
                @c_delinquentdollars, @c_creditlimit,
                @s_underpayreceivablesaccount,
                @s_overpaysalesaccount,
                @s_overpayliabilityaccount,
                @s_salesterms, @c_discountpercent, @s_allowbackorder,
                @s_consolidator, @s_salesagent, @s_orderprocessor,
                @s_territory, @s_inventorylocation, @s_paymentmethod,
                @s_securitycompany,
                @s_salestermslocation, @s_sendorderto, @s_ordernotification,
                @s_portloading, @s_portdischarge, @s_shipvia,
                @s_freightcarrier, @s_invoicenotification )
        /* insert a row into the Empower ar_customer_ship_locations table
           for the new customer */
        INSERT INTO ar_customer_ship_locations
              ( customer, ship_location, ship_name,
                ship_address_id, ship_contact_id,
                changed_date, changed_user_id, primary_ship_location ) 
        VALUES ( @s_customer, @s_customer, @s_name,
                 @s_addressid, @s_contactid, GetDate(), 'MONITOR', 'Y' )
       END
     ELSE
       BEGIN
         /* customer already exists in Empower database so update it. 
            first get the contact and address ids so contacts and 
            addresses can be updated. */
         SELECT @s_contactid = bill_contact_id, 
                @s_addressid = bill_address_id
           FROM ar_customers
          WHERE customer = @s_customer

         IF @s_curexchenabled = 'Y'
           BEGIN
             UPDATE ar_customers SET customer_name = @s_name,
                                     hdr_account_manager = @s_salesrep,
                                     hdr_terms = @s_terms,
                                     hdr_currency = @s_currency,
                                     changed_date = GETDATE(),
                                     changed_user_id = 'MONUPD'
                               WHERE customer = @s_customer
           END
         ELSE
           BEGIN
             UPDATE ar_customers SET customer_name = @s_name,
                                     hdr_account_manager = @s_salesrep,
                                     hdr_terms = @s_terms,
                                     changed_date = GETDATE(),
                                     changed_user_id = 'MONUPD'
                               WHERE customer = @s_customer
           END
         UPDATE addresses SET address_1 = @s_address1,
                              address_2 = @s_address2,
                              address_3 = @s_address3,
                              changed_user_id = 'MONUPD',
                              changed_date = GETDATE()
                        WHERE address_id = @s_addressid
         IF @s_ledger <> 'ET'
           BEGIN
             UPDATE contacts 
                SET last_name = SUBSTRING(@s_contact,CHARINDEX(' ', @s_contact) + 1,COL_LENGTH('customer','contact')),
                    first_name = SUBSTRING(@s_contact,1,CHARINDEX(' ', @s_contact)),
                    phone = @s_phone,
                    fax_phone = @s_fax,
                    changed_user_id = 'MONUPD',
                    changed_date = GETDATE()
              WHERE contact_id = @s_contactid
           END
       END
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_customer_u] on [dbo].[customer] for update
as
begin
	-- declarations
	declare @customer varchar(10),
			@cs_status varchar(20),
			@deleted_status varchar(20)

	-- get first updated row
	select	@customer = min(customer)
	from 	inserted

	-- loop through all updated records and if cs_status has been modified, update 
	-- destination with new status
	while(isnull(@customer,'-1')<>'-1')
	begin

		select	@cs_status = cs_status
		from	inserted
		where	customer = @customer

		select	@deleted_status = cs_status
		from	deleted
		where	customer = @customer

		select @cs_status = isnull(@cs_status,'')
		select @deleted_status = isnull(@deleted_status,'')

		if @cs_status <> @deleted_status
		begin
			update 	destination
			set	cs_status = @cs_status
			where 	customer = @customer

			update 	shipper
			set	cs_status = @cs_status
			where 	customer = @customer
		end 
		select	@customer = min(customer)
		from 	inserted
		where	customer > @customer

	end

end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_CustomerEmpower]
ON [dbo].[customer] FOR UPDATE
AS

-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 19-Apr-2006 When the ledger is ET (Elliot Tape), don't update the Empower
--             customer contact info with the Monitor customer contact info.
--             The Monitor contact is a purchasing agent.  The Empower contact
--             is someone in AR.

-- 19-Jul-2005 Check for an empty string in the contact_id to see if we need to
--             add a new contact.  Previously the script checked only for a null.

-- 10-May-2004 Use the customer.default_currency_unit as the ar_customers.
--             hdr_currency only if GLCurrencyExchangeEnabled is "Y".

IF UPDATE(empower_flag)
   BEGIN
     DECLARE @s_customer varchar(10),
             @s_empowerflag varchar(8),
             @cs_status varchar(20),
             @deleted_status varchar(20)

        /* if the updated row was updated by our Empower-to-Monitor trigger
           it will contain 'EMPUPD' in the empower_flag column.  Clear this 
           column and exit the trigger */
        SELECT @s_customer = customer,
               @s_empowerflag = empower_flag
          FROM inserted

        IF @s_empowerflag = 'EMPUPD'
           BEGIN
             UPDATE customer
                SET empower_flag = ''
              WHERE customer = @s_customer
             RETURN
           END
   END

IF UPDATE(name) OR UPDATE(terms) OR UPDATE(salesrep) OR
   UPDATE(default_currency_unit)
   BEGIN
     DECLARE @s_name varchar(50),
             @s_salesrep varchar(10),
             @s_terms varchar(20),
             @s_currency varchar(3),
             @s_curexchenabled varchar(25),
             @i_rowcount int

   /* Make sure that we have a row in the inserted table for processing */
   SELECT @i_rowcount = Count(*) FROM inserted

   IF @i_rowcount > 0
      BEGIN

        /* select the appropriate columns from the inserted table */
        SELECT @s_customer = Ltrim(Rtrim(Upper(customer))),
               @s_name = name,
               @s_salesrep = Ltrim(Rtrim(Upper(salesrep))),
               @s_terms = Ltrim(Rtrim(Upper(terms))),
               @s_currency = Ltrim(Rtrim(Upper(default_currency_unit)))
          FROM inserted

        /* Get the preference that indicates if currency exchange is 
           enabled. */
        SELECT @s_curexchenabled = IsNull(value,'')
          FROM preferences_standard
         WHERE preference = 'GLCurrencyExchangeEnabled'
        IF @@fetch_status <> 0 OR @s_curexchenabled = ''
          SELECT @s_curexchenabled = 'N'

        IF @s_curexchenabled = 'Y'
          UPDATE ar_customers SET customer_name = @s_name,
                                  hdr_terms = @s_terms,
                                  hdr_account_manager = @s_salesrep,
                                  hdr_currency = @s_currency,
                                  changed_user_id = 'MONUPD',
                                  changed_date = GETDATE()
                            WHERE customer = @s_customer
        ELSE
          UPDATE ar_customers SET customer_name = @s_name,
                                  hdr_terms = @s_terms,
                                  hdr_account_manager = @s_salesrep,
                                  changed_user_id = 'MONUPD',
                                  changed_date = GETDATE()
                            WHERE customer = @s_customer
      END
   END

IF UPDATE(address_1) OR UPDATE(address_2) OR UPDATE( address_3) 
   BEGIN
     DECLARE @s_addressid varchar(25),
             @s_address1 varchar(50),
             @s_address2 varchar(50),
             @s_address3 varchar(50)

   /* Make sure that we have a row in the inserted table for processing */
   SELECT @i_rowcount = Count(*) FROM inserted

   IF @i_rowcount > 0
      BEGIN

        /* select the appropriate columns from the inserted table */
        SELECT @s_customer = Ltrim(Rtrim(Upper(customer))),
               @s_address1 = address_1,
               @s_address2 = address_2,
               @s_address3 = address_3
          FROM inserted

        /*  Customer has been given a new address, get the address identifier 
            and update the addresses table. */
        SELECT @s_addressid = bill_address_id
          FROM ar_customers
         WHERE customer = @s_customer

        UPDATE addresses
           SET address_1 = @s_address1,
               address_2 = @s_address2,
               address_3 = @s_address3,
               changed_user_id = 'MONUPD',
               changed_date = GETDATE()
         WHERE address_id = @s_addressid
      END
   END
  
IF UPDATE(contact) OR UPDATE(phone) OR UPDATE(fax) 
   BEGIN
     DECLARE @s_contactid varchar(25),
             @s_contact varchar(35),
             @s_phone varchar(20),
             @s_fax varchar(15),
             @s_ledger varchar(40)

     /* Get the default ledger. */
     SELECT @s_ledger = IsNull(value,'')
       FROM preferences_standard
      WHERE preference = 'GLLedger'

     /* Make sure that we have a row in the inserted table for processing */
     SELECT @i_rowcount = Count(*) FROM inserted

     IF @i_rowcount > 0 AND @s_ledger <> 'ET'
        BEGIN

          /* select the appropriate columns from the inserted table */
          SELECT @s_customer = Ltrim(Rtrim(Upper(customer))),
                 @s_contact = contact,
                 @s_phone = phone,
                 @s_fax = fax
            FROM inserted

          /*  Customer has been given new contact information, get the contact identifier 
              and update the contacts table */
          SELECT @s_contactid = bill_contact_id
            FROM ar_customers
           WHERE customer = @s_customer

          IF @s_contactid IS NULL OR @s_contactid = ''
             BEGIN
               /* This customer does not have a contact id, generate one,
                  insert a row into contacts, and update ar_customers
                  with the contact id. */
                  EXECUTE GetNextIdentifier 'CONTACT', 'CONTACT', @s_contactid OUTPUT

                  INSERT INTO CONTACTS ( contact_id, last_name, first_name, 
                                         phone, fax_phone, changed_date, changed_user_id ) 
                                VALUES ( @s_contactid, 
                                         SUBSTRING(@s_contact,CHARINDEX(' ', @s_contact) + 1,COL_LENGTH('customer','contact')),
                                         SUBSTRING(@s_contact,1,CHARINDEX(' ', @s_contact)),
                                         @s_phone, @s_fax, GETDATE(), 'MONITOR' )

                  UPDATE ar_customers SET bill_contact_id = @s_contactid,
                                          changed_date = GETDATE(),
                                          changed_user_id = 'MONUPD'
                                    WHERE customer = @s_customer
             END
          ELSE
            BEGIN
              /* update the existing contact */
              UPDATE contacts SET last_name = SUBSTRING(@s_contact,CHARINDEX(' ', @s_contact) + 1,COL_LENGTH('customer','contact')),
                                  first_name = SUBSTRING(@s_contact,1,CHARINDEX(' ', @s_contact)),
                                  phone = @s_phone,
                                  fax_phone = @s_fax,
                                  changed_user_id = 'MONUPD',
                                  changed_date = GETDATE()
                            WHERE contact_id = @s_contactid
            END
        END
   END

-- 11/22/99 This portion of the trigger is Monitor's trigger that we had to include in ours 
--          because SQL Server only lets you have one trigger per table.

-- get first updated row
SELECT @s_customer = min(customer)
  FROM inserted

-- loop through all updated records and if cs_status has been modified, update
-- destination with new status
WHILE (IsNull(@s_customer, '-1') <> '-1')
  BEGIN

      SELECT @cs_status = cs_status
        FROM inserted
       WHERE customer = @s_customer

      SELECT @deleted_status = cs_status
        FROM deleted
       WHERE customer = @s_customer

      SELECT @cs_status = IsNull(@cs_status, '')
      SELECT @deleted_status = IsNull(@deleted_status, '')

      IF @cs_status <> @deleted_status
         UPDATE destination
            SET cs_status = @cs_status
          WHERE customer = @s_customer

      SELECT @s_customer = min(customer)
        FROM inserted
       WHERE customer > @s_customer

  END

GO
ALTER TABLE [dbo].[customer] ADD CONSTRAINT [PK__customer__390515B7] PRIMARY KEY CLUSTERED  ([customer]) ON [PRIMARY]
GO
