CREATE TABLE [dbo].[po_detail]
(
[po_number] [int] NOT NULL,
[vendor_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_of_measure] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_due] [datetime] NOT NULL,
[requisition_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_recvd_date] [datetime] NULL,
[last_recvd_amount] [numeric] (20, 6) NULL,
[cross_reference_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (20, 6) NULL,
[received] [numeric] (20, 6) NULL,
[balance] [numeric] (20, 6) NULL,
[active_release_cum] [numeric] (20, 6) NULL,
[received_cum] [numeric] (20, 6) NULL,
[price] [numeric] (20, 6) NULL,
[row_id] [numeric] (20, 0) NOT NULL,
[invoice_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_date] [datetime] NULL,
[invoice_qty] [numeric] (20, 6) NULL,
[invoice_unit_price] [numeric] (20, 6) NULL,
[release_no] [int] NULL,
[ship_to_destination] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terms] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[week_no] [int] NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[standard_qty] [numeric] (20, 6) NULL,
[sales_order] [int] NULL,
[dropship_oe_row_id] [int] NULL,
[ship_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dropship_shipper] [int] NULL,
[price_unit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[printed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selected_for_print] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_via] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dimension_qty_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_time] [datetime] NULL,
[truck_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirm_asn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_cost_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alternate_price] [decimal] (20, 6) NULL,
[requisition_id] [int] NULL,
[promise_date] [datetime] NULL,
[other_charge] [numeric] (20, 6) NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__po_detail__RowCr__4FF36807] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NULL CONSTRAINT [DF__po_detail__RowCr__50E78C40] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__po_detail__RowMo__51DBB079] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NULL CONSTRAINT [DF__po_detail__RowMo__52CFD4B2] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Insert_PODetailMonitor]
ON [dbo].[po_detail] FOR INSERT
AS

-- This trigger is executed whenever a new row is entered
-- for a Monitor PO. It inserts a PO Item row and the corresponding 
-- gl_cost_transaction row.

-- 07-Oct-2005 Use vendor_attributes.text_1 as the variance
--             account if it is nonblank and the ledger is
--             RENOSOL CORP.

-- 12-May-2005 Include po_release and blanket_line on po_items.

-- 30-Sep-2004 Right trim the account segment and plant segment.

-- 26-Feb-2004 Created from SQLAnywhere version.

BEGIN
  DECLARE @i_rowcount            INTEGER,
          @s_ponumber            VARCHAR(25),
          @s_part                VARCHAR(25),
          @s_plant               VARCHAR(25),
          @s_accountcode         VARCHAR(50),
          @s_vendor              VARCHAR(10),
          @s_description         VARCHAR(100),
          @s_crossrefpart        VARCHAR(25),
          @s_uom                 VARCHAR(2),
          @dt_datedue            DATETIME,
          @dt_podate             DATETIME,
          @s_fiscalyear          VARCHAR(5),
          @s_ledger              VARCHAR(25),
          @i_period              INTEGER,
          @i_poline              SMALLINT,
          @s_parttype            char(1),
          @s_productline         VARCHAR(25),
          @s_productlineaccount  VARCHAR(25),
          @s_plantaccount        VARCHAR(25),
          @s_draccount           VARCHAR(25),
          @s_varianceaccount     VARCHAR(25),
          @s_vendorname          VARCHAR(25),
          @s_currency            VARCHAR(25),
          @c_quantity            NUMERIC(18,6),
          @c_price               DEC(18,6),
          @c_amount              DEC(18,6),
          @s_draccounttable      VARCHAR(25),
          @s_accountstyle        VARCHAR(25),
          @s_itemledgeraccount   VARCHAR(50),
          @s_varianceledgeraccount VARCHAR(50),
          @s_vendorattrvariance VARCHAR(25)

-- Make sure that we have a row in the inserted table for processing
SELECT @i_rowcount = Count(*) FROM inserted

IF @i_rowcount > 0
 BEGIN
  -- Get the preference that indicates where to get the DR account.
  SELECT @s_draccounttable = IsNull(value,'')
    FROM preferences_standard
   WHERE preference = 'MonitorReceivedDRAccountTable'
  IF @@rowcount = 0 OR @s_draccounttable = ''
    SELECT @s_draccounttable = 'Inventory Accounts'

  SELECT @s_accountstyle = IsNull(value,'')
    FROM preferences_standard
   WHERE preference = 'MonitorInventoryAccountsStyle'
  IF @@rowcount = 0 SELECT @s_accountstyle = 'Account'

  -- To eliminate duplicate code, use a cursor whether one or multiple
  -- rows are deleted.
  DECLARE inspodetcursor CURSOR FOR
    SELECT IsNull(quantity,0),
           IsNull(alternate_price,0),
           Convert(varchar(25),po_number),
           IsNull(part_number,''), 
           IsNull(plant,''),
           LTrim(RTrim(IsNull(account_code,''))),
           LTrim(RTrim(IsNull(vendor_code,''))), 
           LTrim(RTrim(IsNull(description,''))), 
           LTrim(RTrim(IsNull(cross_reference_part,''))), 
           unit_of_measure, 
           Convert(datetime,Convert(char(8),date_due,112)) 
      FROM inserted

  OPEN inspodetcursor
   WHILE 1 = 1
    BEGIN
     FETCH inspodetcursor 
      INTO @c_quantity, @c_price, @s_ponumber, @s_part, @s_plant, @s_accountcode, 
           @s_vendor, @s_description, @s_crossrefpart, @s_uom, @dt_datedue

     IF @@fetch_status <> 0 BREAK

     SELECT @c_amount = Round(@c_quantity * @c_price, 2)

     -- Empower groups all releases for a PO/part into one PO line.
     -- See if this part already exists on the Empower PO.
     SELECT @i_poline = po_line
       FROM po_items
      WHERE purchase_order = @s_ponumber
        AND item = @s_part

     IF @@rowcount = 0
      BEGIN
       -- This part is not already on the Empower PO so we'll need to
       -- add it.

       -- We need to get the fiscal year, ledger, period, po_date, and 
       -- currency from the PO header
       SELECT @s_fiscalyear = fiscal_year, 
              @s_ledger = ledger, 
              @i_period = period,
              @dt_podate = po_date, 
              @s_currency = currency 
         FROM po_headers 
        WHERE purchase_order = @s_ponumber

       IF @s_accountstyle = 'Account'
         BEGIN
          -- Need the GL Segment for the Plant
          SELECT @s_plantaccount = RTrim(IsNull(gl_segment,''))
            FROM destination
           WHERE destination = @s_plant
          IF @@rowcount = 0 SELECT @s_plantaccount = ''
         END
        ELSE
         BEGIN
          -- Don't need a plant GL segment
          SELECT @s_plantaccount = ''
         END

        -- Need the part type and the product line to do the lookup
        -- into monitor_inventory_accounts
        SELECT @s_parttype = IsNull(part.type,'R'),
               @s_productline = IsNull(product_line, '')
          FROM part
         WHERE part = @s_part
        IF @@rowcount = 0
         BEGIN
          -- didn't find the part. Assume its a raw material since
          -- that's what's most likely to be received.
          SELECT @s_parttype = 'R'
          SELECT @s_productline = ''
          SELECT @s_productlineaccount = ''
         END
        ELSE
         BEGIN
          -- found the part. Do we need the product line segment?
          IF @s_accountstyle = 'Account'
           BEGIN
            -- Need the GL Segment for the product line
            SELECT @s_productlineaccount = IsNull(gl_segment,'') 
              FROM product_line
             WHERE product_line.id = @s_productline
            IF @@rowcount = 0 SELECT @s_productlineaccount = ''
           END
          ELSE
           BEGIN
            -- Don't need a product line GL segment
            SELECT @s_productlineaccount = ''
           END
         -- end found the part
         END

        IF @s_draccounttable = 'Inventory Accounts'
         BEGIN
          -- Need the debit and variance accounts from Inventory Accounts
          SELECT @s_draccount = RTrim(IsNull(material_debit,'')), 
                 @s_varianceaccount = RTrim(IsNull(material_variance,''))
            FROM monitor_inventory_accounts
           WHERE fiscal_year = @s_fiscalyear 
             AND ledger = @s_ledger
             AND product_line = @s_productline
             AND audit_trail_type = 'R'
             AND part_type = @s_parttype
          IF @@rowcount = 0 
           BEGIN
            SELECT @s_draccount = ''
            SELECT @s_varianceaccount = ''
           END

          IF @s_ledger = 'RENOSOL CORP'
           BEGIN
             SELECT @s_vendorattrvariance = RTrim(IsNull(text_1,'')) 
               FROM vendor_attributes
              WHERE vendor = @s_vendor
             IF @@rowcount > 0 AND @s_vendorattrvariance <> ''
               SELECT @s_varianceaccount = @s_vendorattrvariance
           END

          SELECT @s_itemledgeraccount = @s_draccount + @s_plantaccount + @s_productlineaccount
          SELECT @s_varianceledgeraccount = @s_varianceaccount + @s_plantaccount + @s_productlineaccount

         END
        ELSE
         BEGIN
          -- We're to use the GL account from PO Detail. Make sure it's 
          -- not NULL.
          SELECT @s_itemledgeraccount = @s_accountcode + @s_plantaccount + @s_productlineaccount
          SELECT @s_varianceledgeraccount = @s_itemledgeraccount
         END

        -- We need to get the vendor name
        SELECT @s_vendorname = vendor_name 
          FROM vendors 
         WHERE vendor = @s_vendor

        -- We need to get the maximum PO line in use on this PO.
        SELECT @i_poline = MAX(po_line)
          FROM po_items
         WHERE purchase_order = @s_ponumber
        IF @i_poline IS NULL
          SELECT @i_poline = 1
        ELSE
          SELECT @i_poline = @i_poline + 1

        -- Insert a row into the po_items table        
        INSERT INTO po_items
            ( purchase_order, po_line, sort_line,
              line_type, item, item_description,
              vendors_item, status, status_reason,
              receiver, invoice, print_po_receiver,
              tax_1, tax_2, freight_carrier,
              expense_analysis, ledger_account_code, variance_ledger_account,
              encumber_ledger_account_code, requested_by, quantity_ordered,
              quantity_received,quantity_invoiced, quantity_cancelled,
              quantity_tolerance,purchasing_uom, po_pricing_uom,
              purchasing_to_po_pricing_conv, price, receiver_price,
              price_tolerance,extended_amount, invoiced_amount,
              cancelled_amount,required_date, ship_date,
              eta_date, last_expedite_date, changed_date, 
              changed_user_id, inventoried, po_quantity_uom_to_standard,
              po_release, blanket_line )
        VALUES (@s_ponumber,@i_poline,@i_poline,
              'IT',@s_part,@s_description,
               @s_crossrefpart,'O','',
               'Y','Y','B',
               '','','',
               '',@s_itemledgeraccount,@s_varianceledgeraccount,
               '','',@c_quantity,
               0,0,0,
               0,@s_uom, @s_uom,
               1.0,@c_price,@c_price,
               0.00,@c_amount,0.00,
               0.00,@dt_datedue,@dt_datedue,
               @dt_datedue,@dt_datedue,GetDate(),
               'MONITOR','N',1,
               '', 0)

        -- Now insert the corresponding gl_cost_transaction
        INSERT INTO gl_cost_transactions
            ( document_type, document_id1, document_id2,
              document_id3, document_line, ledger_account,
              contract_id, contract_account_id, costrevenue_type_id,
              fiscal_year, ledger, gl_entry,
              period, transaction_date, amount,
              document_amount, document_currency, exchange_date,
              exchange_rate, document_reference1, document_reference2,
              document_remarks, application, quantity,
              unit_of_measure, user_defined_text, user_defined_number,
              user_defined_date, changed_date, changed_user_id,
              update_balances)
        VALUES ('PO', @s_ponumber,'',
               '',@i_poline,@s_itemledgeraccount,
               '','','',
               @s_fiscalyear,@s_ledger,'',
               @i_period,@dt_podate,@c_amount,
               @c_amount,@s_currency,GetDate(),
               1,@s_vendor,@s_vendorname,
               @s_description,'PO',@c_quantity,
               '','',0,
               NULL,GetDate(),'MONITOR',
               'N')
      END
     ELSE
      BEGIN
       -- the PO/part already exists in PO items, so update it. We'll 
       -- update the price, with the price on this release. We'll update
       -- the extended amount with the amount of this release. As a result,
       -- quantity times price may not equal the extended amount, but the
       -- extended amount will reflect the amount the user expects to pay.
       UPDATE po_items 
          SET quantity_ordered = quantity_ordered + @c_quantity,
              extended_amount = extended_amount + @c_amount,
              price = @c_price,
              receiver_price = @c_price,
              required_date = @dt_datedue,
              changed_date = GetDate(), 
              changed_user_id = 'MONITOR'
        WHERE purchase_order = @s_ponumber
          AND po_line = @i_poline
       -- Also update it in GL cost
       UPDATE gl_cost_transactions
          SET amount = amount + @c_amount,
              document_amount = document_amount + @c_amount,
              quantity = quantity + @c_quantity,
              changed_date = GetDate(), 
              changed_user_id = 'MONITOR'
        WHERE document_type = 'PO'
          AND document_id1 = @s_ponumber
          AND document_id2 = ''
          AND document_id3 = ''
          AND document_line = @i_poline
      END

     -- Update the po_headers amount whether we inserted or updated a
     -- row in po_items.
     IF @c_amount <> 0
      UPDATE po_headers
         SET amount = IsNull(amount,0) + @c_amount,
             changed_date = GetDate(), 
             changed_user_id = 'MONITOR'
        WHERE purchase_order = @s_ponumber
    END

  CLOSE inspodetcursor
  DEALLOCATE inspodetcursor
 END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_po_detail_d] on [dbo].[po_detail] for delete
as
begin
	declare @requisition_id integer,
		@quantity   	numeric (20,6),
		@received   	numeric (20,6),
		@total_rows 	integer,
		@count      	integer,
		@row_id     	integer,
		@po_number  	integer,
		@part		varchar(25),
		@date_due	datetime,
		@today		datetime
	
	select	@today = GetDate()

	-- get first updated row
	select	@po_number = min(po_number)
	from 	deleted

	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@row_id = min(row_id)
		from	deleted
		where	po_number = @po_number

		while ( isnull(@row_id,-1) <> -1 )
		begin
		
			select	@part = min(part_number)
			from	deleted
			where	po_number = @po_number and
				row_id = @row_id

			while ( isnull(@part,'') > '' )
			begin

				select	@date_due = min(date_due)
				from	deleted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part

				while ( isnull(@date_due,@today) <> @today )
				begin

					select	@requisition_id = requisition_id,
						@quantity = quantity,
						@received = received
					from	deleted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due
						
					if @requisition_id > 0 
					begin
					
						if @received <= 0 
						begin
							update 	requisition_detail
							set 	po_number = null,
								status = 'Modified',
							    	status_notes = 'Deleted from PO: ' + convert ( varchar(15), po_number ) + ' on ' + convert ( varchar (20), getdate( ) )
							where	requisition_number = @requisition_id and
								po_rowid = @row_id and
								po_number = @po_number 
						
							update	requisition_header
							set	status = '8'
							where 	requisition_number = @requisition_id
						end
						else if @received >= @quantity
						begin
							update	requisition_detail
							set	status = 'Completed',
								status_notes = 'Completed on ' + + convert ( varchar (20), getdate( ) )
							where	requisition_number = @requisition_id and
								po_rowid = @row_id and
								po_number = @po_number 
						
							select	@total_rows = count(*)
							from	requisition_detail
							where	requisition_number = @requisition_id
						
							select	@count = count(*)
							from	requisition_detail
							where	requisition_number = @requisition_id and
								status = 'Completed'
								
							if @total_rows = @count 
							begin
								update	requisition_header
								set	status = '7',
									status_notes = 'Completed on ' + + convert ( varchar (20), getdate( ) )
								where	requisition_number = @requisition_id
							end
						
						end
					end
					
					select	@date_due = min(date_due)
					from	deleted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due > @date_due

				end

				select	@part = min(part_number)
				from	deleted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number > @part

			end

			select	@row_id = min(row_id)
			from	deleted
			where	po_number = @po_number and
				row_id > @row_id

		end

		select	@po_number = min(po_number)
		from 	deleted
		where	po_number > @po_number

	end

end
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_po_detail_i] on [dbo].[po_detail] for insert
as
begin
	-- declarations
	declare	@po_number		integer,
		@row_id			numeric(20),
		@part			varchar(25),
		@date_due		datetime,
		@today			datetime

	select	@today = GetDate()

	-- get first updated row
	select	@po_number = min(po_number)
	from 	inserted

	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@row_id = min(row_id)
		from	inserted
		where	po_number = @po_number

		while ( isnull(@row_id,-1) <> -1 )
		begin
		
			select	@part = min(part_number)
			from	inserted
			where	po_number = @po_number and
				row_id = @row_id

			while ( isnull(@part,'') > '' )
			begin

				select	@date_due = min(date_due)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part

				while ( isnull(@date_due,@today) <> @today )
				begin

					exec msp_calc_po_currency @po_number, null, null, @row_id, @part, @date_due, null

					select	@date_due = min(date_due)
					from	inserted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due > @date_due

				end

				select	@part = min(part_number)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number > @part

			end

			select	@row_id = min(row_id)
			from	inserted
			where	po_number = @po_number and
				row_id > @row_id

		end

		select	@po_number = min(po_number)
		from 	inserted
		where	po_number > @po_number

	end

end
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_po_detail_u] on [dbo].[po_detail] for update
as
begin
	-- declarations
	declare	@po_number	integer,
		@row_id		integer,
		@part		varchar(25),
		@date_due	datetime,
		@inserted_ap	numeric(20,6),
		@deleted_ap	numeric(20,6),
		@today		datetime, 
		@release_no	integer,
		@uom		char(2),
		@type		char(1)

	declare	@requisition_id	integer,
		@quantity_old	numeric (20,6),
		@received	numeric (20,6),
		@total_rows	integer,
		@count		integer,
		@received_new	numeric (20,6),
		@part_old	varchar (25),
		@name		varchar (50),
		@quantity_new	numeric (20,6),
		@deleted	varchar (1),
		@vendor_old	varchar (10),
		@vendor_new	varchar (10),
		@price_new	numeric (20,6),
		@price_old	numeric (20,6)

	select	@today = GetDate()

	-- get first updated row
	select	@po_number = min(po_number)
	from 	inserted

	-- loop through all updated records
	while ( isnull(@po_number,-1) <> -1 )
	begin

		select	@row_id = min(row_id)
		from	inserted
		where	po_number = @po_number

		while ( isnull(@row_id,-1) <> -1 )
		begin
		
			select	@part = min(part_number)
			from	inserted
			where	po_number = @po_number and
				row_id = @row_id

			while ( isnull(@part,'') > '' )
			begin

				select	@date_due = min(date_due)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part

-- from here 11/13/02					
				select	@quantity_new = quantity,
				  	@received_new = received,
					@price_new = price,
					@vendor_new = vendor_code,
					@release_no = release_no,
					@uom = unit_of_measure,
					@type = type
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part and
					date_due = @date_due

				select  @received	= received,
				   	@quantity_old   = quantity
				from	deleted 
				where	po_number = @po_number and
					row_id = @row_id and
					part_number = @part and
					date_due = @date_due

				if (update(received) or update(quantity)) and (@received_new-@received) <> 0 and @quantity_new > 0 
				begin
					insert into cdipohistory 
						(po_number, vendor, part, uom, date_due, type, last_recvd_date, 
						last_recvd_amount, quantity, received, balance,	price, row_id, 
						release_no)
					values	(@po_number, @vendor_new, @part, @uom, @date_due, @type, 
						GetDate(), (@received_new-@received),@quantity_new, @received_new, 
						(@quantity_new - @received_new),@price_new, @row_id, @release_no)
				end
-- till here 11/13/02
					

				while ( isnull(@date_due,@today) <> @today )
				begin

					select	@deleted_ap = alternate_price
					from	deleted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due

					select	@inserted_ap = alternate_price,
						@name	     = description,
						@quantity_new = quantity,
					  	@received_new = received,
						@deleted  = deleted,
						@price_new = price
					from	inserted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due

					select @deleted_ap = isnull(@deleted_ap,0)
					select @inserted_ap = isnull(@inserted_ap,0)

					if @inserted_ap <> @deleted_ap
						exec msp_calc_po_currency @po_number, null, null, @row_id, @part, @date_due, null

					select  @part_old = part_number,
						@requisition_id = requisition_id,
						@received	= received,
					   	@quantity_old   = quantity,
						@price_old	= price
					from	deleted 
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due = @date_due

					if @requisition_id > 0 
					begin
						if @part_old <> @part
						begin
							update requisition_detail
							set part_number = @part,
							    description = @name,
							    status = 'Modified',	
							    status_notes = 'Modified part number from ' + @part_old  + ' to new part number: ' + @part + ' on ' + convert ( varchar (20), getdate( ) )
							where requisition_number = @requisition_id
							and   po_rowid = @row_id 	
							and   po_number = @po_number 

							update requisition_header
							set status = '8',
							    status_notes = 'Modified part number on detail item on :' + convert ( varchar (20), getdate( ) )
							where requisition_number = @requisition_id
						end
						else if @part_old = @part
						begin

							-- check if received quantity was changed or not 
							if @received_new > 0 and @received_new >= @quantity_new
							begin
								update requisition_detail
								set status = 'Completed',
							        status_notes = 'Completed on ' + convert ( varchar (20), getdate( ) )
								where requisition_number = @requisition_id
								and   po_rowid = @row_id 
								and   po_number = @po_number 

								select @total_rows = count(*)
								from  requisition_detail
								where requisition_number = @requisition_id 

								select @count = count(*)
								from  requisition_detail
								where requisition_number = @requisition_id
								and status = 'Completed'
			
								if @total_rows = @count 
								begin
									update requisition_header
									set status = '7',
									    status_notes = 'Completed on ' + + convert ( varchar (20), getdate( ) )
									where requisition_number = @requisition_id
						    		end	
							end

							-- check if quantity was changed or not 
							else if @quantity_old <> @quantity_new
								update requisition_detail
								set quantity = @quantity_new,
								    status = 'Modified',	
								    status_notes = 'Modified quantity from ' + convert ( varchar (20), @quantity_old)  + ' to quantity: ' + convert ( varchar (20), @quantity_new ) + ' on ' + convert ( varchar (20), getdate( ) )
								where requisition_number = @requisition_id
								and   po_rowid = @row_id 
								and   po_number = @po_number 

							-- check if item marked for deletion 
							else if @deleted = 'Y' 	
							begin
								update requisition_detail
								set po_number = null,
								    status = 'Modified',
								    status_notes = 'Deleted from PO: ' + convert ( varchar(15), po_number ) + ' on ' + convert ( varchar (20), getdate( ) )
							        where requisition_number = @requisition_id
								and   po_rowid = @row_id 
								and   po_number = @po_number 

								update requisition_header
								set status = '8',
							        status_notes = 'Modified part number on detail item on :' + convert ( varchar (20), getdate( ) )
								where requisition_number = @requisition_id
							end
						end
						else if @price_old <> @price_new
							update requisition_detail
							set unit_cost = @price_new
						        where requisition_number = @requisition_id
							and   po_rowid = @row_id 
							and   po_number = @po_number 
					end
					
					select	@date_due = min(date_due)
					from	inserted
					where	po_number = @po_number and
						row_id = @row_id and
						part_number = @part and
						date_due > @date_due

				end

				select	@part = min(part_number)
				from	inserted
				where	po_number = @po_number and
					row_id = @row_id and
					part_number > @part

			end

			select	@row_id = min(row_id)
			from	inserted
			where	po_number = @po_number and
				row_id > @row_id

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

create trigger [dbo].[tr_employee_uRowModified] on [dbo].[po_detail] after update
as
declare
	@TranDT datetime
,	@Result int

set xact_abort off
set nocount on
set ansi_warnings off
set	@Result = 999999

--- <Error Handling>
declare
	@CallProcName sysname,
	@TableName sysname,
	@ProcName sysname,
	@ProcReturn integer,
	@ProcResult integer,
	@Error integer,
	@RowCount integer

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. dbo.usp_Test
--- </Error Handling>

begin try
	--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
	declare
		@TranCount smallint

	set	@TranCount = @@TranCount
	set	@TranDT = coalesce(@TranDT, GetDate())
	save tran @ProcName
	--- </Tran>

	---	<ArgumentValidation>

	---	</ArgumentValidation>
	
	--- <Body>
	if	not update(RowModifiedDT) begin
		--- <Update rows="*">
		set	@TableName = 'dbo.po_detail'
		
		update
			pd
		set	RowModifiedDT = getdate()
		,	RowModifiedUser = suser_name()
		from
			dbo.po_detail pd
			join inserted i
				on i.RowID = pd.RowID
		
		select
			@Error = @@Error,
			@RowCount = @@Rowcount
		
		if	@Error != 0 begin
			set	@Result = 999999
			RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
			rollback tran @ProcName
			return
		end
		--- </Update>
		
		--- </Body>
	end
end try
begin catch
	declare
		@errorName int
	,	@errorSeverity int
	,	@errorState int
	,	@errorLine int
	,	@errorProcedures sysname
	,	@errorMessage nvarchar(2048)
	,	@xact_state int
	
	select
		@errorName = error_number()
	,	@errorSeverity = error_severity()
	,	@errorState = error_state ()
	,	@errorLine = error_line()
	,	@errorProcedures = error_procedure()
	,	@errorMessage = error_message()
	,	@xact_state = xact_state()

	if	xact_state() = -1 begin
		print 'Error number: ' + convert(varchar, @errorName)
		print 'Error severity: ' + convert(varchar, @errorSeverity)
		print 'Error state: ' + convert(varchar, @errorState)
		print 'Error line: ' + convert(varchar, @errorLine)
		print 'Error procedure: ' + @errorProcedures
		print 'Error message: ' + @errorMessage
		print 'xact_state: ' + convert(varchar, @xact_state)
		
		rollback transaction
	end
	else begin
		/*	Capture any errors in SP Logging. */
		rollback tran @ProcName
	end
end catch

---	<Return>
set	@Result = 0
return
--- </Return>
/*
Example:
Initial queries
{

}

Test syntax
{

set statistics io on
set statistics time on
go

begin transaction Test
go

insert
	dbo.po_detail
...

update
	...
from
	dbo.po_detail
...

delete
	...
from
	dbo.po_detail
...
go

if	@@trancount > 0 begin
	rollback
end
go

set statistics io off
set statistics time off
go

}

Results {
}
*/
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[Update_PODetailMonitor]
ON [dbo].[po_detail] FOR UPDATE
AS

-- 07-Oct-2016 Added part_number, due_date and row_id to join of inserted and deleted.

-- 25-Mar-2010 Incorporated Eric Stimpson's mods to update po_items
--             with the received quantity when it is greater than
--             the ordered quantity.  This should eliminate the
--             problem of receipts not coming up to be invoiced
--             because more has been received than was ordered.

-- 02-Mar-2004 Created from SQLAnywhere version.

IF update(date_due) OR update(quantity) OR update(alternate_price) OR 
   update(deleted) OR update(received)

 BEGIN
  DECLARE @s_ponumber       VARCHAR(25),
          @s_part           VARCHAR(25),
          @dt_datedue       DATETIME,
          @s_deleted        char(1),
          @i_poline         SMALLINT,
          @c_oldqty         DECIMAL(18,6),
          @c_oldprice       DECIMAL(18,6),
          @c_oldreceived	DECIMAL(18,6),
          @c_newqty         DECIMAL(18,6),
          @c_newprice       DECIMAL(18,6),
          @c_newreceived	DECIMAL(18,6),
          @c_qtychg         DECIMAL(18,6),
          @c_amtchg         DECIMAL(18,6),
          @i_rowcount       INTEGER

  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
   BEGIN
    DECLARE updpodetcursor CURSOR FOR
     SELECT Convert(Char(25),deleted.po_number),
            IsNull(inserted.part_number,''), 
            Convert(datetime,Convert(char(8),inserted.date_due,112)), 
            IsNull(deleted.quantity,0),
            IsNull(inserted.quantity,0),
            IsNull(deleted.alternate_price,0),
            IsNull(inserted.alternate_price,0),
            IsNull(deleted.received,0),
            IsNull(inserted.received,0),
            IsNull(inserted.deleted,'')
       FROM inserted, deleted
      WHERE inserted.po_number = deleted.po_number
	    AND inserted.part_number = deleted.part_number
		AND inserted.date_due = deleted.date_due
		AND inserted.row_id = deleted.row_id

    OPEN updpodetcursor

    WHILE 1 = 1
     BEGIN
      FETCH updpodetcursor
       INTO @s_ponumber,
            @s_part,
            @dt_datedue,
            @c_oldqty,
            @c_newqty,
            @c_oldprice,
            @c_newprice,
            @c_oldreceived,
            @c_newreceived,           
            @s_deleted

      IF @@fetch_status <> 0 BREAK

      -- Make sure that this PO detail row exists as a PO item row
      -- before trying to update it. 

      SELECT @i_poline = po_line 
        FROM po_items
       WHERE purchase_order = @s_ponumber
         AND item = @s_part 

      IF @@rowcount > 0 
       BEGIN
        -- the PO/part already exists in PO items, so update it. If this 
        -- isn't a delete, we'll update the price, with the price on this 
        -- release. In all cases, we'll update the extended amount with the 
        -- amount of this release. As a result, quantity times price may 
        -- not equal the extended amount, but the extended amount will 
        -- reflect the amount the user expects to pay. (Note: Inserted
        -- quantity and price are both zero in the case of a delete.)
        --
        -- Because over-receipt is possible, we will use received quantity
        -- if it is more than the quantity ordered.  As a result, Empower
        -- will always allow the full amount received.
		if	@c_newreceived > @c_newqty begin
			if	@c_oldreceived > @c_oldqty begin
				SELECT @c_qtychg = @c_newreceived - @c_oldreceived
				SELECT @c_amtchg = Round(@c_newreceived * @c_newprice, 2) -
								   Round(@c_oldreceived * @c_oldprice, 2)
			end else begin
				SELECT @c_qtychg = @c_newreceived - @c_oldqty
				SELECT @c_amtchg = Round(@c_newreceived * @c_newprice, 2) -
								   Round(@c_oldqty * @c_oldprice, 2)
			end
		end else begin
			SELECT @c_qtychg = @c_newqty - @c_oldqty
			SELECT @c_amtchg = Round(@c_newqty * @c_newprice, 2) -
							   Round(@c_oldqty * @c_oldprice, 2)
		end

        UPDATE po_items
           SET required_date = @dt_datedue,
               quantity_ordered = quantity_ordered + @c_qtychg,
               extended_amount = extended_amount + @c_amtchg,
               changed_date = GetDate(), 
               changed_user_id = 'MONITOR'
         WHERE purchase_order = @s_ponumber
           AND po_line = @i_poline

        IF @s_deleted <> 'Y' 
          UPDATE po_items
             SET price = @c_newprice,
                 receiver_price = @c_newprice,
                 changed_date = GetDate(), 
                 changed_user_id = 'MONITOR'
           WHERE purchase_order = @s_ponumber
             AND po_line = @i_poline

        -- If the amount changed, update po_headers.
        IF @c_amtchg <> 0
          UPDATE po_headers
             SET amount = IsNull(amount,0) + @c_amtchg,
                 changed_date = GetDate(), 
                 changed_user_id = 'MONITOR'
           WHERE purchase_order = @s_ponumber

        -- Now update the GL cost transactions row. If there's not an
        -- existing row, nothing will be updated.
        UPDATE gl_cost_transactions
           SET amount = amount + @c_amtchg,
               document_amount = document_amount + @c_amtchg,
               quantity = quantity + @c_qtychg,
               changed_date = GetDate(), 
               changed_user_id = 'MONITOR'
         WHERE document_type = 'PO' AND
               document_id1 = @s_ponumber AND
               document_id2 = '' AND
               document_id3 = '' AND
               document_line = @i_poline
       END
     END
    CLOSE updpodetcursor
    DEALLOCATE updpodetcursor
   END
 END

GO
ALTER TABLE [dbo].[po_detail] ADD CONSTRAINT [PK__po_detail__47127295] PRIMARY KEY CLUSTERED  ([po_number], [part_number], [date_due], [row_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_po_detail_1] ON [dbo].[po_detail] ([part_number], [quantity], [received]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[po_detail] ADD CONSTRAINT [fk_po_detail1] FOREIGN KEY ([po_number]) REFERENCES [dbo].[po_header] ([po_number])
GO
