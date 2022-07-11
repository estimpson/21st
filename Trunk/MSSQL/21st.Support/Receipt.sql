select
	*
from
	dbo.audit_trail at
where
	at.serial = 3416923

begin transaction
go

declare
	@i_rowcount integer
,	@s_type varchar(2)
,	@s_shipper varchar(25)
,	@s_invoice varchar(25)
,	@s_ponumber varchar(25)
,	@s_vendor varchar(25)
,	@s_part varchar(25)
,	@s_plant varchar(25)
,	@s_remarks varchar(25)
,	@i_serial integer
,	@dt_datestamp datetime
,	@s_exponreceipt char(1)
,	@s_usestdcost char(1)
,	@s_fiscalyear varchar(5)
,	@s_ledger varchar(25)
,	@i_period integer
,	@s_parttype char(1)
,	@s_partdesc varchar(250)
,	@s_productline varchar(25)
,	@s_plantaccount varchar(25)
,	@s_productlineaccount varchar(25)
,	@s_itemledgeraccount varchar(50)
,	@s_rniaccount varchar(25)
,	@s_rniledgeraccount varchar(50)
,	@s_currency varchar(25)
,	@s_receiver varchar(25)
,	@c_cost numeric(18, 6)
,	@c_quantity numeric(18, 6)
,	@c_stdquantity numeric(18, 6)
,	@c_amount numeric(18, 6)
,	@i_count integer
,	@i_bolline smallint
,	@s_havehdr char(1)
,	@dt_recvddate datetime
,	@s_draccounttable varchar(25)
,	@s_accountstyle varchar(25)
,	@s_appenddate char(1)
,	@s_prevtype varchar(2)
,	@s_prevponumber varchar(25)
,	@s_prevshipper varchar(25)
,	@s_prevpart varchar(25)
,	@c_prevquantity numeric(18, 6)
,	@c_prevstdquantity numeric(18, 6)
,	@dt_prevdatestamp datetime
,	@c_quantitychg numeric(18, 6)
,	@s_vendorname varchar(40)
,	@s_deletecorrectreceipts char(1)

begin
	select
		@s_appenddate	= isnull(value, '')
	from
		dbo.preferences_standard
	where
		preference	= 'MonitorAppendDateToShipper'
	if @@ROWCOUNT = 0
	or @s_appenddate = ''
		select
			@s_appenddate	= 'Y'

	-- Get the preference that indicates if standard or actual cost
	-- should be used.
	select
		@s_usestdcost	= isnull(value, '')
	from
		dbo.preferences_standard
	where
		preference	= 'MonitorStandardCost'
	if @@ROWCOUNT = 0
	or @s_usestdcost = ''
		select
			@s_usestdcost	= 'Y'

	-- Get the preference that indicates where to get the RNI account.
	select
		@s_draccounttable	= isnull(value, '')
	from
		dbo.preferences_standard
	where
		preference	= 'MonitorReceivedDRAccountTable'
	if @@ROWCOUNT = 0
	or @s_draccounttable = ''
		select
			@s_draccounttable	= 'Inventory Accounts'

	-- Get the preference that indicates if we need to append segments.
	select
		@s_accountstyle = isnull(value, '')
	from
		dbo.preferences_standard
	where
		preference	= 'MonitorInventoryAccountsStyle'
	if @@ROWCOUNT = 0
	or @s_accountstyle = ''
		select
			@s_accountstyle = 'Account'

	-- Get the preference that indicates if we need to process D and X types.
	select
		@s_deletecorrectreceipts = isnull(value, '')
	from
		dbo.preferences_standard
	where
		preference	= 'MonitorDeleteAndCorrectReceipts'
	if @@ROWCOUNT = 0
	or @s_deletecorrectreceipts = ''
		select
			@s_deletecorrectreceipts = 'Y'

	-- To eliminate duplicate code, use a cursor whether one or multiple
	-- rows are deleted.
	declare insauditcursor cursor local for
	select
		at	.serial
	,	at.date_stamp
	,	isnull(at.type, '')
	,	ltrim(rtrim(upper(isnull(at.shipper, ''))))
	,	ltrim(rtrim(isnull(at.po_number, '')))
	,	isnull(at.part, '')
	,	isnull(at.plant, '')
	,	ltrim(rtrim(isnull(at.vendor, '')))
	,	isnull(at.quantity, 0)
	,	isnull(at.std_quantity, 0)
	,	isnull(at.price, 0)
	,	ltrim(rtrim(isnull(at.remarks, '')))
	from
		dbo.audit_trail at
	where
		at.serial = 3416923

	open insauditcursor

	while 1 = 1
	begin

		fetch insauditcursor
		into
			@i_serial
		,	@dt_datestamp
		,	@s_type
		,	@s_shipper
		,	@s_ponumber
		,	@s_part
		,	@s_plant
		,	@s_vendor
		,	@c_quantity
		,	@c_stdquantity
		,	@c_cost
		,	@s_remarks

		if @@FETCH_STATUS <> 0
			break

		-- Only process this audit trail row if it's a receipt.
		if @s_type = 'R'
		begin

			-- When using the standard cost, we're to use the standard quantity
			if @s_usestdcost = 'Y'
				select
					@c_quantity = @c_stdquantity

			if @c_quantity > 0
			begin

				-- Get the date portion of the date/time stamp
				select
					@dt_recvddate	= convert(datetime, convert(char(8), @dt_datestamp, 112))

				if @s_appenddate = 'Y'
					select
						@s_shipper	= @s_shipper + '_' + convert(char(6), @dt_datestamp, 12)

				-- If necessary, get the standard cost for the part. When we're
				-- using the standard cost, we should also use the standard quantity.
				if @s_usestdcost = 'Y'
				begin
					select
						@c_cost = isnull(cost_cum, 0)
					from
						dbo.part_standard
					where
						part = @s_part
				end

				if	@c_cost is null
					select
						@c_cost = 0
				if @c_quantity is null
					select
						@c_quantity = 0

				-- Calculate an amount for this item based on the received 
				-- quantity and the cost (standard or actual PO price).
				select
					@c_amount	= round(@c_quantity * @c_cost, 2)

				-- Was this Monitor PO expensed on receipt?
				select
					@s_exponreceipt = isnull(expense_on_receipt, 'N')
				from
					dbo.po_headers
				where
					purchase_order	= @s_ponumber

				if @@ROWCOUNT = 0
					select
						@s_exponreceipt = 'N'

				-- Is this shipper/part already in the po_receiver_items 
				-- table? If it is, has it been invoiced?
				select
					@i_bolline	= bol_line
				,	@s_invoice = isnull(invoice, '')
				from
					dbo.po_receiver_items
				where
					purchase_order	= @s_ponumber
					and bill_of_lading = @s_shipper
					and item = @s_part

				select
					@@ROWCOUNT
				,	@i_bolline
				,	@s_ponumber
				,	@s_shipper
				,	@s_part

				select
					*
				from
					dbo.po_receivers pr
				where
					pr.purchase_order = @s_ponumber
					and pr.bill_of_lading = @s_shipper


				select
					*
				from
					dbo.po_receiver_items pri
				where
					pri.purchase_order = @s_ponumber
					and pri.bill_of_lading = @s_shipper
					and item = @s_part
			end
		end
	end
	close
		insauditcursor
	deallocate
		insauditcursor
end
go

rollback
go

select
	purchase_order
,	po_line
,	item
,	item_description
,	quantity_ordered
,	quantity_received
,	quantity_invoiced
,	quantity_cancelled
from
	po_items
where
	purchase_order	= '37545'

select
	purchase_order
,	bill_of_lading
,	bol_line
,	item
,	item_description
,	quantity_received
,	invoice
from
	dbo.po_receiver_items
where
	purchase_order	= '37545'