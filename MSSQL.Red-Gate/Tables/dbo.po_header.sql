CREATE TABLE [dbo].[po_header]
(
[po_number] [int] NOT NULL,
[vendor_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[po_date] [datetime] NULL,
[date_due] [datetime] NULL,
[terms] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fob] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_via] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to_destination] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[printed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_amount] [numeric] (20, 6) NULL,
[shipping_fee] [numeric] (20, 6) NULL,
[sales_tax] [numeric] (20, 6) NULL,
[blanket_orderded_qty] [numeric] (20, 6) NULL,
[blanket_frequency] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket_duration] [numeric] (5, 0) NULL,
[blanket_qty_per_release] [numeric] (20, 6) NULL,
[blanket_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket_vendor_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price] [numeric] (20, 6) NULL,
[std_unit] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flag] [int] NULL,
[release_no] [int] NULL,
[release_control] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_rate] [numeric] (4, 2) NULL,
[scheduled_time] [datetime] NULL,
[trusted] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency_unit] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[show_euro_amount] [smallint] NULL,
[next_seqno] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Insert_POHeaderMonitor]
ON [dbo].[po_header] FOR INSERT
AS

-- 16-Apr-08 Get the default fiscal year from preferences_standard 
--           rather than preferences_site because preferences_site is no 
--           longer being used. Removed references to preferences_site.

-- 13-Oct-2006 Set po_headers.invoice_approver based on vendors.hdr_approver
--             and po_types.invoice_approver_source.

-- 12-May-2005 Put 'N' into po_headers.blanket. Decided not to use the 
--             po_types.blanket value in case a user accidentally set it to
--             'Y' on the Monitor PO type. Inserted a row into po_releases.

-- 01-Mar-2004 Created from SQLAnywhere version.

BEGIN
        
  DECLARE @s_ponumber      varchar(25),
          @s_buyer         varchar(25),
          @s_terms         varchar(25),
          @s_plant         varchar(25),
          @s_currency      varchar(25),
          @c_totalamount   DECIMAL(18,6),
          @c_salestax      DECIMAL(18,6),
          @c_shippingfee   DECIMAL(18,6),
          @s_buyvendor     varchar(10),
          @s_payvendor     varchar(25),
          @s_buyunit       varchar(25),
          @s_payunit       varchar(25),
          @s_potype        varchar(25),
          @dt_podate       DATETIME,
          @i_rowcount      INTEGER,
          @i_poitemrows    INTEGER,
          @s_fiscalyear    varchar(5),
          @s_ledger        varchar(25),
          @i_empowerperiod INTEGER,
          @s_exponreceipt  char(1),
          @s_approvetax    char(1),
          @s_approvefreight char(1),
          @s_invoiceapproversource varchar(20),
          @s_invoiceapprover varchar(25)

-- Make sure that we have a row in the inserted table for processing
SELECT @i_rowcount = Count(*) FROM inserted

IF @i_rowcount > 0
 BEGIN
  -- To eliminate duplicate code, use a cursor whether one or multiple
  -- rows are deleted.
  DECLARE insmonpohdrcursor CURSOR FOR
    SELECT LTrim(RTrim(IsNull(vendor_code,''))), 
           Convert(varchar(25),po_number),
           LTrim(RTrim(Upper(IsNull(buyer,'')))),
           Convert(datetime,Convert(char(8),po_date,112)), 
           LTrim(RTrim(Upper(IsNull(terms,'')))), 
           IsNull(plant,''),
           LTrim(RTrim(Upper(IsNull(currency_unit,'')))),
           IsNull(total_amount,0),
           IsNull(sales_tax,0),
           IsNull(shipping_fee,0)
      FROM inserted

  OPEN insmonpohdrcursor
   WHILE 1 = 1
    BEGIN
     FETCH insmonpohdrcursor 
      INTO @s_buyvendor, @s_ponumber, @s_buyer, @dt_podate, @s_terms, 
           @s_plant, @s_currency, @c_totalamount, @c_salestax, @c_shippingfee

     IF @@fetch_status <> 0 BREAK

     -- We need to get the pay vendor, buy unit, and pay unit
     SELECT @s_payvendor = IsNull(pay_vendor,vendor), 
            @s_buyunit = IsNull(hdr_buy_unit,'1'),
            @s_payunit = IsNull(hdr_pay_unit,''),
            @s_invoiceapprover = IsNull(hdr_invoice_approver,'') 
       FROM vendors 
      WHERE vendor = @s_buyvendor

     IF @@rowcount = 0
      BEGIN
       SELECT @s_payvendor = @s_buyvendor
       SELECT @s_buyunit = '1'
       SELECT @s_payunit = '1'
      END
     ELSE
      BEGIN
       IF @s_payvendor = '' SELECT @s_payvendor = @s_buyvendor
       IF @s_buyunit = '' SELECT @s_buyunit = '1'
       IF @s_payunit = '' SELECT @s_payunit = @s_buyunit
      END

     -- We need to establish the fiscal year, ledger 
     -- and period for the PO
     SELECT @s_fiscalyear = value 
       FROM preferences_standard 
      WHERE preference = 'GLFiscalYear'

     SELECT @s_ledger = ledger
       FROM units_payables_purchasing
      WHERE unit = @s_buyunit

     -- Now get the GL Period 
     SELECT @i_empowerperiod = period
       FROM ledger_definition, calendar_periods 
      WHERE ledger_definition.ledger = @s_ledger
        AND ledger_definition.fiscal_year = @s_fiscalyear
        AND ledger_definition.calendar = calendar_periods.calendar
        AND calendar_periods.fiscal_year = @s_fiscalyear
        AND calendar_periods.period_start_date <= @dt_podate
        AND calendar_periods.period_end_date >= @dt_podate
        AND Charindex('close', Lower(calendar_periods.period_name)) = 0 
        AND Charindex('closing', Lower(calendar_periods.period_name)) = 0
        AND Charindex('begin', Lower(calendar_periods.period_name)) = 0 
        AND Charindex('open', Lower(calendar_periods.period_name)) = 0

     -- Get columns specific to the MONITOR PO type
     SELECT @s_approvefreight = IsNull(approve_freight,'N'), 
            @s_approvetax = IsNull(approve_tax,'N'), 
            @s_exponreceipt = IsNull(expense_on_receipt,'Y'),
            @s_invoiceapproversource = IsNull(invoice_approver_source,'')
       FROM po_types
      WHERE po_type = 'MONITOR'

     IF @@rowcount = 0
      BEGIN
       SELECT s_approvefreight = 'N'
       SELECT s_approvetax = 'N'
       SELECT s_exponreceipt = 'Y'
      END
     ELSE
      BEGIN
       IF @s_invoiceapproversource = 'BUYER'
       AND @s_buyer <> ''
         SELECT @s_invoiceapprover = @s_buyer
      END
	
     -- Insert a row into the po_headers table. 
     INSERT INTO po_headers
         ( purchase_order, buy_vendor, buy_unit,
           pay_vendor, pay_unit, buyer,
           batch, entered_datetime, po_type,
           po_date, status, status_reason,
           requester, confirmed_by, confirmed_date,
           approved, printed, approve_freight,
           pay_on_receipt, expense_on_receipt, 
           terms, freight_terms, location,
           currency, document_comments, amount,
           tax_amount, freight_amount, fiscal_year,
           ledger, gl_entry, period,
           gl_date, changed_date, changed_user_id,
           document_class, approve_tax, approver,
           commit_to_gl, buy_contact, pay_contact,
           invoice_approver, sales_terms, sales_terms_location,
           blanket) 
     VALUES (@s_ponumber, @s_buyvendor, @s_buyunit,
            @s_payvendor, @s_payunit, @s_buyer,
            'MONITOR', GetDate(), 'MONITOR',
            @dt_podate, 'O', '',
            '', '', NULL,
            'Y', 'Y', @s_approvefreight,
            'N', @s_exponreceipt, 
            @s_terms, '', @s_plant,
            @s_currency, '', @c_totalamount,
            @c_salestax, @c_shippingfee, @s_fiscalyear,
            @s_ledger, '', @i_empowerperiod,
            @dt_podate, GetDate(), 'MONITOR',
            '', @s_approvetax, '',
            'N', '', '',
            @s_invoiceapprover, 'FOB', 'Shipper',
            'N')

        -- Insert a row into the po_releases table.  Every po_header row
        -- also has a po_releases row. 
        INSERT INTO po_releases
            ( purchase_order, po_release, po_release_id,
              release_date, printed, status,
              changed_date, changed_user_id )
        VALUES (@s_ponumber, '', @s_ponumber,
              @dt_podate, 'Y', 'O',
              GetDate(), 'MONITOR')

    END
  CLOSE insmonpohdrcursor
  DEALLOCATE insmonpohdrcursor
 END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_po_header_u] on [dbo].[po_header] for update
as
begin
	-- declarations
	declare	@po_number		integer,
		@deleted_cu		varchar(3),
		@inserted_cu		varchar(3),
		@vendor_old		varchar(10),
		@vendor_new		varchar(10)

	-- get first updated row
	select	@po_number = min(po_number)
	from 	inserted


	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@deleted_cu = currency_unit,
			@vendor_old = vendor_code
		from	deleted
		where	po_number = @po_number

		select	@inserted_cu = currency_unit,
			@vendor_new = vendor_code
		from	inserted
		where	po_number = @po_number

		select @deleted_cu = isnull(@deleted_cu,'')
		select @inserted_cu = isnull(@inserted_cu,'')

		if @deleted_cu <> @inserted_cu
			exec msp_calc_po_currency @po_number, null, null, null, null, null, null

		-- included this block to check if user changed vendor code and update necessary tables 
		if @vendor_old <> @vendor_new
		begin
			update po_detail
			set vendor_code = @vendor_new
			where po_number = @po_number

			update requisition_detail
			set vendor_code = @vendor_new,
		        status = 'Modified',	
		        status_notes = 'Modified Vendor Code from ' + @vendor_old  + ' to different Vendor: ' + @vendor_new + ' on ' + convert ( varchar (20), getdate( ) )
			where po_number = @po_number 

			update requisition_header
			set status = '8',
		 	status_notes = 'Modified Vendor Code on detail item on : '  + convert ( varchar (20), getdate( ) )
			where requisition_number in (	select distinct (requisition_id)
							from po_detail
							where po_detail.po_number = @po_number )	
		end

		select	@po_number = min(po_number)
		from 	inserted
		where	po_number > @po_number

	end

end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Update_POHeaderMonitor]
ON [dbo].[po_header] FOR UPDATE
AS

-- 13-Oct-2006 Set po_headers.invoice_approver to the buyer
--             if po_types.invoice_approver_source = 'BUYER'.

-- 01-Mar-2004 Created from SQLAnywhere version.

IF update(vendor_code) OR update(buyer) OR update(terms) OR 
   update(plant) OR update(currency_unit) OR update(po_date)

 BEGIN
  DECLARE @s_ponumber       varchar(25),
          @s_oldvendor      varchar(10),
          @s_newvendor      varchar(10),
          @s_oldbuyer       varchar(25),
          @s_newbuyer       varchar(25),
          @s_newterms       varchar(25),
          @s_newplant       varchar(25),
          @s_newcurrency    varchar(25),
          @dt_newpodate	    DATETIME,
          @s_payvendor      varchar(25),
          @s_buyunit        varchar(25),
          @s_payunit        varchar(25),
          @s_invoiceapproversource varchar(20),
          @i_rowcount       INTEGER

  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
   BEGIN
    DECLARE updmonpohdrcursor CURSOR FOR
     SELECT Convert(Char(25),deleted.po_number),
            LTrim(RTrim(IsNull(deleted.vendor_code,''))),
            LTrim(RTrim(IsNull(inserted.vendor_code,''))),
            LTrim(RTrim(Upper(IsNull(deleted.buyer,'')))),
            LTrim(RTrim(Upper(IsNull(inserted.buyer,'')))),
            LTrim(RTrim(Upper(IsNull(inserted.terms,'')))),
            IsNull(inserted.plant,''),
            LTrim(RTrim(Upper(IsNull(inserted.currency_unit,'')))),
            Convert(datetime,Convert(char(8),inserted.po_date,112))
       FROM inserted, deleted
      WHERE inserted.po_number = deleted.po_number

    OPEN updmonpohdrcursor

    WHILE 1 = 1
     BEGIN
      FETCH updmonpohdrcursor
       INTO @s_ponumber,
            @s_oldvendor,
            @s_newvendor,
            @s_oldbuyer,
            @s_newbuyer,
            @s_newterms,
            @s_newplant,
            @s_newcurrency,
            @dt_newpodate

      IF @@fetch_status <> 0 BREAK
      
      IF @s_newvendor <> @s_oldvendor
       BEGIN
        -- Can only change the vendor on an Empower PO if the
        -- PO has no invoices against it.
        SELECT @i_rowcount = Count(*) 
          FROM po_receiver_items
         WHERE purchase_order = @s_ponumber
           AND IsNull(invoice,'') <> ''
        IF @i_rowcount = 0
         BEGIN
          -- This PO has no invoices. Get the pay vendor, buy unit, and 
          -- pay unit for the new vendor.
          SELECT @s_payvendor = IsNull(pay_vendor,vendor), 
                 @s_buyunit = IsNull(hdr_buy_unit,'1'), 
                 @s_payunit = IsNull(hdr_pay_unit ,'')
            FROM vendors 
           WHERE vendor = @s_newvendor

          IF @@rowcount = 0
           BEGIN
            SELECT @s_payvendor = @s_newvendor
            SELECT @s_buyunit = '1'
            SELECT @s_payunit = '1'
           END
          ELSE
           BEGIN
            IF @s_payvendor = '' SELECT @s_payvendor = @s_newvendor
            IF @s_buyunit = '' SELECT @s_buyunit = '1'
            IF @s_payunit = '' SELECT @s_payunit = @s_buyunit
           END

          -- update the PO header with the new vendor
          UPDATE po_headers
             SET buy_vendor = @s_newvendor,
                 buy_unit = @s_buyunit,
                 pay_unit = @s_payunit,
                 pay_vendor = @s_payvendor,
                 changed_date = GetDate(),
                 changed_user_id = 'MONITOR'
           WHERE purchase_order = @s_ponumber
         END
       END

      -- The following columns can always be changed. We will go ahead and
      -- update them with the newheader values rather than checking each to
      -- see if it has changed and only updating the ones that have changed.
      UPDATE po_headers
         SET buyer = @s_newbuyer,
             terms = @s_newterms,
             location = @s_newplant,
             currency = @s_newcurrency,
             po_date = @dt_newpodate,
             changed_date = GetDate(),
             changed_user_id = 'MONITOR'
       WHERE purchase_order = @s_ponumber


      IF @s_oldbuyer <> @s_newbuyer
        BEGIN
          -- Buyer changed. Is the buyer also the invoice approver?
          SELECT @s_invoiceapproversource = IsNull(invoice_approver_source,'')
            FROM po_types
           WHERE po_type = 'MONITOR'
          IF @s_invoiceapproversource = 'BUYER'
            BEGIN
              UPDATE po_headers
                 SET invoice_approver = @s_newbuyer,
                     changed_date = GetDate(),
                     changed_user_id = 'MONITOR'
               WHERE purchase_order = @s_ponumber
            END
        END

      END

    CLOSE updmonpohdrcursor
    DEALLOCATE updmonpohdrcursor
   END
 END
GO
ALTER TABLE [dbo].[po_header] ADD CONSTRAINT [PK__po_header__2414E5C9] PRIMARY KEY CLUSTERED  ([po_number]) ON [PRIMARY]
GO
