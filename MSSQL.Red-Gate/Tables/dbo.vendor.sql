CREATE TABLE [dbo].[vendor]
(
[code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outside_processor] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terms] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ytd_sales] [numeric] (20, 6) NULL,
[balance] [numeric] (20, 6) NULL,
[frieght_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fob] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_via] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flag] [int] NULL,
[partial_release_update] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trusted] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kanban] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_currency_unit] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[show_euro_amount] [smallint] NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[empower_flag] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_VendorEmpower]
ON [dbo].[vendor] FOR INSERT 
AS

-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 10-May-2004 1. Use the vendor.default_currency_unit as the vendors.
--                hdr_currency only if GLCurrencyExchangeEnabled is "Y".
--             2. If the ledger is 'LEXAMAR', put address 4, 5, and 6 into
--                city, state, and zip.

-- 03-Mar-2004 Added payment_notification_method and 
--             po_notification_method. Trimmed and uppered vendor

-- 02-Oct-2001 Added the Empower v6.0 columns: hdr_sales_terms,
--             hdr_sales_terms_location, and security_company.

BEGIN
  DECLARE @s_addressid varchar(25),
          @s_contactid varchar(25),
          @s_vendor varchar(10),
          @s_name varchar(35),
          @s_address1 varchar(50),
          @s_address2 varchar(50),
          @s_address3 varchar(50),
          @s_address4 varchar(50),
          @s_address5 varchar(50),
          @s_address6 varchar(50),
          @s_phone varchar(14),
          @s_fax varchar(14),
          @s_contact varchar(35),
          @s_buyer varchar(30),
          @s_terms varchar(20),
          @s_currency varchar(3),
          @s_empowerflag varchar(40),
          @s_status char(1),
          @s_intercompany char(1),
          @s_vendorclass varchar(25),
          @s_hdrseparatecheck char(1),
          @s_hdrholdpayment char(1),
          @s_hdrbuyunit varchar(25),
          @s_hdrpayunit varchar(25),
          @s_hdrfreightterms varchar(25),
          @s_hdrsalesterms varchar(25),
          @s_hdrsalestermsloc varchar(25),
          @s_hdrlocation varchar(25),
          @c_hdrinvoicelimit decimal(18,6),
          @s_hdrledger varchar(40),
          @s_hdrcontract varchar(40),
          @s_hdrledgeraccountcode varchar(50),
          @s_hdrdiscledgeraccountcode varchar(50),
          @s_hdrpotype varchar(25),
          @s_hdrpodocumentclass varchar(25),
          @s_hdrinvoiceapprover varchar(25),
          @s_hdrpoapprover varchar(25),
          @s_hdrcurrency varchar(25),
          @s_itemfreight varchar(25),
          @s_itemtax1 varchar(25),
          @s_itemtax2 varchar(25),
          @s_itemexpenseanalysis varchar(25),
          @s_itemcontractid varchar(25),
          @s_itemcontractaccountid varchar(25),
          @s_itemcostrevenuetypeid varchar(25),
          @s_itemledgeraccountcode varchar(50),
          @s_itemrniledgeraccount varchar(50),
          @s_chkbankalias varchar(25),
          @s_chkremittanceadvice char(1),
          @c_chkminimumcheckamount decimal(18,6),
          @i_prenotesrequired smallint,
          @i_prenotesgiven smallint,
          @s_directdeposit char(1),
          @s_securitycompany varchar(25),
          @s_paymentnotificationmethod char(1),
          @s_ponotificationmethod char(1),
          @s_ledger varchar(40),
          @s_curexchenabled varchar(25),
          @s_value varchar(25),
          @i_rowcount integer

/* Is there a row in the inserted table? */
SELECT @i_rowcount = Count(*) from inserted

IF @i_rowcount > 0
   BEGIN

     /* select the appropriate columns from the inserted table */
     SELECT @s_vendor = code,
            @s_name = name,
            @s_address1 = address_1,
            @s_address2 = address_2,
            @s_address3 = address_3,
            @s_address4 = address_4,
            @s_address5 = address_5,
            @s_address6 = address_6,
            @s_phone = phone,
            @s_fax = fax,
            @s_contact = contact,
            @s_terms = Ltrim(Rtrim(Upper(terms))),
            @s_buyer = Ltrim(Rtrim(Upper(buyer))),
            @s_currency = Ltrim(Rtrim(Upper(default_currency_unit))),
            @s_empowerflag = empower_flag
       FROM inserted

     /* if the inserted row was inserted by our Empower-to-Monitor trigger
        it will contain 'EMPOWER' in the empower_flag column.  Clear this column 
        and exit the trigger */
     IF @s_empowerflag = 'EMPOWER'
        BEGIN
          UPDATE vendor
             SET empower_flag = ''
           WHERE code = @s_vendor
          RETURN
        END

     /* Get the default ledger. */
     SELECT @s_ledger = IsNull(value,'')
       FROM preferences_standard
      WHERE preference = 'GLLedger'

     SELECT @s_curexchenabled = IsNull(value,'')
       FROM preferences_standard
      WHERE preference = 'GLCurrencyExchangeEnabled'
     IF @@fetch_status <> 0 OR @s_curexchenabled = ''
       SELECT @s_curexchenabled = 'N'

     SELECT @s_vendor = Ltrim(Rtrim(Upper(@s_vendor)))

     /* See if this vendor already exists in Empower. */
     SELECT @i_rowcount = Count(*)
       FROM vendors
      WHERE vendor = @s_vendor

     IF @i_rowcount = 0
       BEGIN
         /* get a contact id and insert a row into contacts */
         EXECUTE GetNextIdentifier 'CONTACT', 'CONTACT', @s_contactid OUTPUT
         INSERT INTO CONTACTS ( contact_id, last_name, first_name, 
                                phone, fax_phone, changed_date, changed_user_id ) 
                       VALUES ( @s_contactid, 
                                SUBSTRING(@s_contact,CHARINDEX(' ', @s_contact) + 1,COL_LENGTH('vendor','contact')),
                                SUBSTRING(@s_contact,1,CHARINDEX(' ', @s_contact)),
                                @s_phone, @s_fax, GETDATE(), 'MONITOR' )

         /* get an address id and insert a row into addresses */
         EXECUTE GetNextIdentifier 'ADDRESS', 'ADDRESS', @s_addressid OUTPUT
         IF @s_ledger = 'LEXAMAR'
           BEGIN
             /* Put address 4, 5, and 6 into city, state, and postal code. */
             INSERT INTO ADDRESSES ( address_id, address_1, address_2, 
                                     address_3, city, state,
                                     postal_code,
                                     changed_date, changed_user_id ) 
                            VALUES ( @s_addressid, @s_address1, @s_address2, 
                                     @s_address3, @s_address4, @s_address5,
                                     @s_address6, 
                                     GETDATE(), 'MONITOR' )
           END
         ELSE
           BEGIN
             INSERT INTO ADDRESSES ( address_id, address_1, address_2, 
                                     address_3, changed_date, changed_user_id ) 
                            VALUES ( @s_addressid, @s_address1, @s_address2, 
                                     @s_address3, GETDATE(), 'MONITOR' )
           END
 
          /* Get the preference that indicates the vendor id of the default
             vendor. */
          SELECT @s_value = value
            FROM preferences_standard
           WHERE preference = 'APVendorDefault'

         /* Now get the vendors record for the default vendor */
          SELECT @s_status = status,
                 @s_intercompany = intercompany,
                 @s_vendorclass = vendor_class,
                 @s_hdrseparatecheck = hdr_separate_check,
                 @s_hdrholdpayment = hdr_hold_payment,
                 @c_hdrinvoicelimit = hdr_invoice_limit,
                 @s_hdrbuyunit = hdr_buy_unit,
                 @s_hdrpayunit = hdr_pay_unit,
                 @s_hdrlocation = hdr_location,
                 @s_hdrfreightterms = hdr_freight_terms,
                 @s_hdrledger = hdr_ledger,
                 @s_hdrcontract = hdr_contract,
                 @s_hdrledgeraccountcode = hdr_ledger_account_code,
                 @s_hdrdiscledgeraccountcode = hdr_disc_ledger_account_code,
                 @s_itemledgeraccountcode = item_ledger_account_code,
                 @s_itemrniledgeraccount = item_rni_ledger_account,
                 @s_hdrpotype = hdr_po_type, 
                 @s_hdrpodocumentclass = hdr_po_document_class,
                 @s_hdrinvoiceapprover = hdr_invoice_approver, 
                 @s_hdrpoapprover = hdr_po_approver,
                 @s_hdrcurrency = hdr_currency,
                 @s_itemfreight = item_freight, 
                 @s_itemtax1 = item_tax_1, 
                 @s_itemtax2 = item_tax_2, 
                 @s_itemexpenseanalysis = item_expense_analysis,
                 @s_itemcontractid = item_contract_id, 
                 @s_itemcontractaccountid = item_contract_account_id,
                 @s_itemcostrevenuetypeid = item_costrevenue_type_id, 
                 @s_chkbankalias = chk_bank_alias,
                 @s_chkremittanceadvice = chk_remittance_advice,
                 @c_chkminimumcheckamount = chk_minimum_check_amount,
                 @s_hdrsalesterms = hdr_sales_terms,
                 @s_hdrsalestermsloc = hdr_sales_terms_location,
                 @i_prenotesrequired = IsNull(prenotes_required,0),
                 @i_prenotesgiven = IsNull(prenotes_given,0),
                 @s_directdeposit = IsNull(direct_deposit,'N'),
                 @s_securitycompany = security_company,
                 @s_paymentnotificationmethod = 
                       IsNull(payment_notification_method,'P'),
                 @s_ponotificationmethod =
                       IsNull(po_notification_method,'P')
            FROM vendors
           WHERE vendor = @s_value

        /* Make sure that status, intercompany, and hold payment have values */
        IF @s_status IS NULL OR @s_status = ''
          SELECT @s_status = 'A'
        IF @s_intercompany IS NULL OR @s_intercompany = ''
          SELECT @s_intercompany = 'N'
        IF @s_hdrholdpayment IS NULL or @s_hdrholdpayment = ''
          SELECT @s_hdrholdpayment = 'N'
        IF @s_directdeposit = ''
          SELECT @s_directdeposit = 'N'
        IF @s_paymentnotificationmethod = ''
          SELECT @s_paymentnotificationmethod = 'P'
        IF @s_ponotificationmethod = ''
          SELECT @s_ponotificationmethod = 'P'
        IF @s_curexchenabled = 'Y'
          SELECT @s_hdrcurrency = @s_currency

         /* insert a row into the Empower vendors table  */
         INSERT INTO VENDORS ( vendor, pay_vendor, vendor_name, 
                               contact_id, pay_contact_id, 
                               address_id, pay_address_id,
                               hdr_terms, hdr_freight_terms, 
                               hdr_buyer, hdr_location, item_freight,
                               hdr_buy_unit, hdr_pay_unit, hdr_contract,
                               changed_date, changed_user_id, status,
                               intercompany, vendor_class,
                               hdr_separate_check, hdr_hold_payment,
                               hdr_currency, hdr_invoice_limit,
                               hdr_ledger, hdr_ledger_account_code, 
                               hdr_disc_ledger_account_code,
                               item_ledger_account_code,
                               item_rni_ledger_account,
                               hdr_po_type, hdr_po_document_class,
                               hdr_invoice_approver, hdr_po_approver,
                               item_tax_1, item_tax_2, 
                               item_expense_analysis,
                               item_contract_id, item_contract_account_id,
                               item_costrevenue_type_id, 
                               chk_bank_alias, chk_remittance_advice,
                               chk_minimum_check_amount,
                               hdr_sales_terms, hdr_sales_terms_location,
                               prenotes_required, prenotes_given, direct_deposit,
                               security_company,
                               payment_notification_method,
                               po_notification_method )
                      VALUES ( @s_vendor, @s_vendor, @s_name, 
                               @s_contactid, @s_contactid, 
                               @s_addressid, @s_addressid, 
                               @s_terms, @s_hdrfreightterms, 
                               @s_buyer, @s_hdrlocation, @s_itemfreight, 
                               @s_hdrbuyunit, @s_hdrpayunit, @s_hdrcontract,
                               GETDATE(), 'MONITOR', @s_status,
                               @s_intercompany, @s_vendorclass,
                               @s_hdrseparatecheck, @s_hdrholdpayment,
                               @s_hdrcurrency, @c_hdrinvoicelimit,
                               @s_hdrledger, @s_hdrledgeraccountcode,
                               @s_hdrdiscledgeraccountcode,
                               @s_itemledgeraccountcode,
                               @s_itemrniledgeraccount,
                               @s_hdrpotype, @s_hdrpodocumentclass,
                               @s_hdrinvoiceapprover, @s_hdrpoapprover,
                               @s_itemtax1, @s_itemtax2, 
                               @s_itemexpenseanalysis, @s_itemcontractid, 
                               @s_itemcontractaccountid, 
                               @s_itemcostrevenuetypeid,
                               @s_chkbankalias, @s_chkremittanceadvice,
                               @c_chkminimumcheckamount,
                               @s_hdrsalesterms, @s_hdrsalestermsloc,
                               @i_prenotesrequired, @i_prenotesgiven, @s_directdeposit,
                               @s_securitycompany,  
                               @s_paymentnotificationmethod,
                               @s_ponotificationmethod)
       END
     ELSE
       BEGIN
         /* vendor exists in the Empower database so update it. 
            first get the contact and address ids so contacts and addresses 
            can be updated. */
         SELECT @s_contactid = contact_id, 
                @s_addressid = address_id
           FROM vendors
          WHERE vendor = @s_vendor

         IF @s_ledger = 'LEXAMAR'
           BEGIN
             /* Put address 4, 5, and 6 into city, state, and postal code. */
             UPDATE addresses 
                SET address_1 = @s_address1,
                    address_2 = @s_address2,
                    address_3 = @s_address3,
                    city = @s_address4,
                    state = @s_address5,
                    postal_code = @s_address6,
                    changed_user_id = 'MONUPD',
                    changed_date = GETDATE()
              WHERE address_id = @s_addressid
           END
         ELSE
           BEGIN
             UPDATE addresses 
                SET address_1 = @s_address1,
                    address_2 = @s_address2,
                    address_3 = @s_address3,
                    changed_user_id = 'MONUPD',
                    changed_date = GETDATE()
              WHERE address_id = @s_addressid
           END
         UPDATE contacts SET last_name = SUBSTRING(@s_contact,CHARINDEX(' ', @s_contact) + 1,COL_LENGTH('vendor','contact')),
                             first_name = SUBSTRING(@s_contact,1,CHARINDEX(' ', @s_contact)),
                             phone = @s_phone,
                             fax_phone = @s_fax,
                             changed_user_id = 'MONUPD',
                             changed_date = GETDATE()
                       WHERE contact_id = @s_contactid
         IF @s_curexchenabled = 'Y'
           BEGIN
             UPDATE vendors SET vendor_name = @s_name,
                                hdr_terms = @s_terms,
                                hdr_buyer = @s_buyer,
                                hdr_currency = @s_currency,
                                changed_date = GETDATE(),
                                changed_user_id = 'MONUPD'
                          WHERE vendor = @s_vendor
           END
         ELSE
           BEGIN
             UPDATE vendors SET vendor_name = @s_name,
                                hdr_terms = @s_terms,
                                hdr_buyer = @s_buyer,
                                changed_date = GETDATE(),
                                changed_user_id = 'MONUPD'
                          WHERE vendor = @s_vendor
           END
       END 
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_vendor_u] on [dbo].[vendor] for update
as
begin
	--	declarations
	declare	@vendor varchar(10),
		@vs_status varchar(20),
		@deleted_status varchar(20)
	--	get first updated row

	select	@vendor=min(code)
	from	inserted

	--	loop through all updated records and if vs_status has been modified, 
	--	update destination with new status
	
	while	(isnull(@vendor,'-1')<>'-1')
	begin
		select	@vs_status=status
		from	inserted
		where	code=@vendor
		select	@deleted_status=status
		from	deleted
		where	code=@vendor
		select	@vs_status=isnull(@vs_status,'')
		select	@deleted_status=isnull(@deleted_status,'')
		if @vs_status<>@deleted_status
			update	destination 
			set	cs_status=@vs_status
			where	vendor=@vendor
		select @vendor=min(code)
		from	inserted
		where	code>@vendor
	end
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_VendorEmpower]
ON [dbo].[vendor] FOR UPDATE
AS

-- 17-Apr-2008 Get the ledger from preferences_standard rather than preferences_site
--             because preferences_site is no longer being used.  Removed references
--             to preferences_site.

-- 19-Jul-2005 Check for an empty string in the contact_id to see if we need to
--             add a new contact.  Previously the script checked only for a null.

-- 10-May-2004 1. Use the vendor.default_currency_unit as the vendors.
--                hdr_currency only if GLCurrencyExchangeEnabled is "Y".
--             2. If the ledger is 'LEXAMAR', put address 4, 5, and 6 into
--                city, state, and zip.

IF UPDATE(empower_flag)
   BEGIN
     DECLARE @s_vendor varchar(10),
             @s_empowerflag varchar(40)

        /* if the updated row was updated by our Empower-to-Monitor trigger
           it will contain 'EMPUPD' in the empower_flag column.  Clear this column 
           and exit the trigger */
        SELECT @s_vendor = code,
               @s_empowerflag = empower_flag
          FROM inserted

        IF @s_empowerflag = 'EMPUPD'
           BEGIN
             UPDATE vendor
                SET empower_flag = ''
              WHERE code = @s_vendor
             RETURN
           END
   END

IF UPDATE(name) OR UPDATE(terms) OR UPDATE(buyer) or UPDATE(default_currency_unit)
  BEGIN
    DECLARE @s_name varchar(35),
            @s_buyer varchar(30),
            @s_terms varchar(20),
            @s_currency varchar(3),
            @s_curexchenabled varchar(25),
            @i_rowcount integer

    /* Make sure that there is a row in the inserted table */
    SELECT @i_rowcount = Count(*) from inserted

    IF @i_rowcount > 0
      BEGIN

        /* select the appropriate columns from the inserted table */
        SELECT @s_vendor = Ltrim(Rtrim(Upper(code))),
               @s_name = name,
               @s_terms = Ltrim(Rtrim(Upper(terms))),
               @s_buyer = Ltrim(Rtrim(Upper(buyer))),
               @s_currency = Ltrim(Rtrim(Upper(default_currency_unit)))
          FROM inserted

        /* Get the preference that indicates if currency exchange is enabled. */
        SELECT @s_curexchenabled = IsNull(value,'')
          FROM preferences_standard
         WHERE preference = 'GLCurrencyExchangeEnabled'
        IF @@fetch_status <> 0 OR @s_curexchenabled = ''
          SELECT @s_curexchenabled = 'N'
  
        IF @s_curexchenabled = 'Y'
          BEGIN
            /*  Update the Empower vendors table with the new values */
            UPDATE vendors SET vendor_name = @s_name,
                               hdr_terms = @s_terms,
                               hdr_buyer = @s_buyer,
                               hdr_currency = @s_currency,
                               changed_date = GETDATE(),
                               changed_user_id = 'MONUPD'
                         WHERE vendor = @s_vendor
          END
        ELSE
          BEGIN
            /*  Update the Empower vendors table with the new values */
            UPDATE vendors SET vendor_name = @s_name,
                               hdr_terms = @s_terms,
                               hdr_buyer = @s_buyer,
                               changed_date = GETDATE(),
                               changed_user_id = 'MONUPD'
                         WHERE vendor = @s_vendor
          END
      END
  END

IF UPDATE(address_1) OR UPDATE(address_2) OR UPDATE(address_3)
  OR UPDATE(address_4) OR UPDATE(address_5) OR UPDATE(address_6)

   BEGIN
     DECLARE @s_addressid varchar(25),
             @s_address1 varchar(50),
             @s_address2 varchar(50),
             @s_address3 varchar(50),
             @s_address4 varchar(50),
             @s_address5 varchar(50),
             @s_address6 varchar(50),
             @s_ledger   varchar(40)

   /* Make sure that we have a row in the inserted table for processing */
   SELECT @i_rowcount = Count(*) FROM inserted

   IF @i_rowcount > 0
      BEGIN

        /* select the appropriate columns from the inserted table */
        SELECT @s_vendor = Ltrim(Rtrim(Upper(code))),
               @s_address1 = address_1,
               @s_address2 = address_2,
               @s_address3 = address_3,
               @s_address4 = address_4,
               @s_address5 = address_5,
               @s_address6 = address_6
          FROM inserted

        /* Get the default ledger. */
        SELECT @s_ledger = IsNull(value,'')
          FROM preferences_standard
         WHERE preference = 'GLLedger'

        /*  Vendor has been given a new address, get the address 
            identifier and update the addresses table */
        SELECT @s_addressid = address_id
          FROM vendors
         WHERE vendor = @s_vendor

        IF @s_ledger = 'LEXAMAR'
          BEGIN
            UPDATE addresses SET address_1 = @s_address1,
                                 address_2 = @s_address2,
                                 address_3 = @s_address3,
                                 city = @s_address4,
                                 state = @s_address5,
                                 postal_code = @s_address6,
                                 changed_user_id = 'MONUPD',
                                 changed_date = GETDATE()
                           WHERE address_id = @s_addressid
          END
        ELSE
          BEGIN
            UPDATE addresses SET address_1 = @s_address1,
                                 address_2 = @s_address2,
                                 address_3 = @s_address3,
                                 changed_user_id = 'MONUPD',
                                 changed_date = GETDATE()
                           WHERE address_id = @s_addressid
          END
      END
   END

IF UPDATE(contact) OR UPDATE(phone) OR UPDATE(fax) 
   BEGIN
     DECLARE @s_contactid varchar(25),
             @s_contact varchar(35),
             @s_phone varchar(20),
             @s_fax varchar(15)

   /* Make sure that we have a row in the inserted table for processing */
   SELECT @i_rowcount = Count(*) FROM inserted

   IF @i_rowcount > 0
      BEGIN

        /* select the appropriate columns from the inserted table */
        SELECT @s_vendor = Ltrim(Rtrim(Upper(code))),
               @s_contact = contact,
               @s_phone = phone,
               @s_fax = fax
          FROM inserted

        /*  Vendor has been given a new contact information, get the contact 
            identifier and update the contacts table */
        SELECT @s_contactid = contact_id
          FROM vendors
         WHERE vendor = @s_vendor

        IF @s_contactid IS NULL OR @s_contactid = ''
           BEGIN
             /* This vendor does not have a contact id, generate one,
                insert a row into contacts, and update the vendors 
                table with the contact id. */
                EXECUTE GetNextIdentifier 'CONTACT', 'CONTACT', @s_contactid OUTPUT

                INSERT INTO CONTACTS ( contact_id, last_name, first_name, 
                                       phone, fax_phone, changed_date, changed_user_id ) 
                              VALUES ( @s_contactid, 
                                       SUBSTRING(@s_contact,CHARINDEX(' ', @s_contact) + 1,COL_LENGTH('customer','contact')),
                                       SUBSTRING(@s_contact,1,CHARINDEX(' ', @s_contact)),
                                       @s_phone, @s_fax, GETDATE(), 'MONITOR' )

                UPDATE vendors SET contact_id = @s_contactid,
                                   changed_date = GETDATE(),
                                   changed_user_id = 'MONUPD'
                             WHERE vendor = @s_vendor
           END
        ELSE
          BEGIN
            /* update the existing contact */
            UPDATE contacts SET last_name = SUBSTRING(@s_contact,CHARINDEX(' ', @s_contact) + 1,COL_LENGTH('vendor','contact')),
                                first_name = SUBSTRING(@s_contact,1,CHARINDEX(' ', @s_contact)),
                                phone = @s_phone,
                                fax_phone = @s_fax,
                                changed_user_id = 'MONUPD',
                                changed_date = GETDATE()
                         WHERE contact_id = @s_contactid
          END
      END
  END
GO
ALTER TABLE [dbo].[vendor] ADD CONSTRAINT [PK__vendor__167AF389] PRIMARY KEY CLUSTERED  ([code]) ON [PRIMARY]
GO
