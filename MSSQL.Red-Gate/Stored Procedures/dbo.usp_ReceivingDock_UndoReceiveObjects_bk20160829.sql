SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_ReceivingDock_UndoReceiveObjects_bk20160829]
(	@User varchar(5),
	@PONumber int,
	@POLineNo int,
	@PartCode varchar(25),
	@SerialNumber int,
	@TranDT datetime out,
	@Result int out)
as
/*
Example:
Initial queries {
select	*
from	employee
where	operator_code = 'ES'

select	po_detail.po_number, po_detail.part_number, po_detail.balance, PerBoxQty = (select standard_pack from part_inventory where part = part_number),
	po_detail.date_due, row_id
from	po_detail
	join po_header on po_header.po_number = po_detail.po_number
where	po_header.release_control != 'A' and
	po_detail.status = 'A' and
	po_detail.balance > 0 and
	po_detail.po_number = 3217 and
	po_detail.part_number = 'KSR0018-HB01'
order by
	po_detail.date_due
}

Test syntax {
begin transaction ReceiveObjects_againstLineItem
go

declare
	@User varchar(5)
,	@PONumber int
,	@POLineNo int
,	@PartCode varchar(25)
,	@SerialNumber int
,	@TranDT datetime --out
,	@Result int --out

set	@User = '01956'
set	@PONumber = 42
set @POLineNo = 0
set	@PartCode = 'HD6601.29'
set @SerialNumber = 1485697

select	po_detail.po_number, po_detail.part_number, po_detail.balance, PerBoxQty = (select standard_pack from part_inventory where part = part_number),
	po_detail.date_due, row_id,
	received,
	standard_qty,
	last_recvd_date,
	last_recvd_amount
from	po_detail
where	po_number = @PONumber
order by
	date_due

declare	@ProcReturn int,
	@ProcResult int,
	@Error int

execute	@ProcReturn = dbo.usp_ReceivingDock_UndoReceiveObjects
	@User = @User,
	@PONumber = @PONumber,
	@POLineNo = @POLineNo,
	@PartCode = @PartCode,
	@SerialNumber = @SerialNumber,
	@TranDT = @TranDT out,
	@Result = @ProcResult out

set	@Error = @@error

select	ProcReturn = @ProcReturn, ProcResult = @ProcResult, Error = @Error, Serial = @SerialNumber, TranDateTime = @TranDT

select	*
from	object
where	serial = @SerialNumber

select	*
from	audit_trail
where	serial = @SerialNumber

select	po_detail.po_number, po_detail.part_number, po_detail.balance, PerBoxQty = (select standard_pack from part_inventory where part = part_number),
	po_detail.date_due, row_id,
	received,
	standard_qty,
	last_recvd_date,
	last_recvd_amount
from	po_detail
where	po_number = @PONumber
order by
	date_due
go

rollback
go
}

Results {
See below...
}
*/
set nocount on
set	@Result = 999999

--- <Error Handling>
declare	@CallProcName sysname,
	@TableName sysname,
	@ProcName sysname,
	@ProcReturn int,
	@ProcResult int,
	@Error int,
	@RowCount int

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. dbo.usp_Test
--- </Error Handling>

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
declare	@TranCount smallint

set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

--	Initializations.
--		Verify the receipt has not already been invoiced.
if	exists
	(
		select
			*
		from
			dbo.audit_trail at
			join dbo.po_receiver_items pri on
				at.po_number = pri.purchase_order
				and
					at.part = pri.item
				and
					at.shipper + 
					case
						when (select IsNull(value,'') from dbo.preferences_standard where preference = 'MonitorAppendDateToShipper') = 'Y' then '_' + Convert(char(6), at.date_stamp, 12)
						else ''
					end = pri.bill_of_lading
		where
			at.serial = @SerialNumber
			and
				at.type = 'R'
			and
				pri.invoice > ''
	) begin
	set	@Result = 999999
	RAISERROR ('The receipt for serial %d has already been invoiced in Empower and cannot be undone.', 16, 1, @SerialNumber)
	rollback tran @ProcName
	return @Result
end

--		Get object quantity and standard quantity.
declare
	@ObjectQty numeric(20,6)
,	@ObjectStdQty numeric(20,6)

select
	@ObjectQty = at.quantity
,	@ObjectStdQty = at.std_quantity
from
	audit_trail at
where
	at.serial = @SerialNumber
	and
		at.type = 'R'
	and
		at.date_stamp =
		(	select
				max(date_stamp)
			from
				dbo.audit_trail
			where
				serial = @SerialNumber)

if	@ObjectQty is null begin
	set	@Result = 999999
	RAISERROR ('Error reading receipt quantity for serial %d in procedure %s.', 16, 1, @SerialNumber, @ProcName)
	rollback tran @ProcName
	return @Result
end

--	Remove inventory.
--			New audit trail record for reversal.
--- <Insert Rows="1">
set	@TableName = 'dbo.audit_trail'

insert	audit_trail
(	serial, date_stamp, type, part,
	quantity, remarks, price, vendor,
	po_number, operator, from_loc, to_loc,
	on_hand, lot, weight, status,
	shipper, unit, std_quantity, cost, control_number,
	custom1, custom2, custom3, custom4, custom5,
	plant, notes, gl_account, package_type,
	release_no, std_cost,
	user_defined_status,
	part_name, tare_weight, field1)
select	at.serial, @TranDT, 'R', at.part,
	-at.quantity, 'Receiving', at.price, at.vendor,
	at.po_number, @User, at.from_loc, at.to_loc,
	IsNull(po.on_hand, 0) - at.std_quantity, at.lot, at.weight, at.status,
	at.shipper, at.unit, -at.std_quantity, at.cost, at.control_number,
	at.custom1, at.custom2, at.custom3, at.custom4, at.custom5,
	at.plant, at.notes, at.gl_account, at.package_type,
	at.release_no, at.std_cost, at.user_defined_status,
	at.part_name, at.tare_weight, at.field1
from
	audit_trail at
	left join dbo.part_online po on
		at.part = po.part
where
	at.serial = @SerialNumber and
	at.type = 'R' and
	at.date_stamp =
	(	select
			max(date_stamp)
		from
			dbo.audit_trail
		where
			serial = @SerialNumber)

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: %d.', 16, 1, @TableName, @ProcName, @RowCount, 1)
	rollback tran @ProcName
	return @Result
end
--- </Insert>

--			Remove object records.
declare
	@PartClass char(1)

select
	@PartClass = coalesce(class, 'N')
from
	part
where
	part = @PartCode

--- <Delete Rows="1">
set	@TableName = 'dbo.object'
delete
	dbo.object
where
	serial = @SerialNumber
		
select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error deleting from table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
if	@RowCount != 1 
	and
		@PartClass != 'N' begin
	set	@Result = 900102
	RAISERROR ('Error deleting from table %s in procedure %s.  Rows deleted: %d.  Expected rows: %d.', 16, 1, @TableName, @ProcName, @RowCount, 1)
	rollback tran @ProcName
	return @Result
end
--- </Delete>
	
--			Update part online.
--- <Update>
set	@TableName = 'dbo.part_online'

update
	dbo.part_online
set
	on_hand =
	(	select
			Sum(std_quantity)
		from
			dbo.object
		where
			part = part_online.part and
			status = 'A')
where
	part = @PartCode

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
--- </Update>

--	Update Purchase Order and Part-Vendor relationship.
--		Update the Line Item with receipt quantities and date.
--- <Update>
set	@TableName = 'dbo.po_detail'

update
	dbo.po_detail
set
	received = received - @ObjectQty,
	balance = balance + @ObjectQty,
	standard_qty = standard_qty + @ObjectStdQty,
	last_recvd_date = @TranDT,
	last_recvd_amount = - @ObjectQty
from
	dbo.po_detail pd
where
	pd.po_number = @PONumber
and
	pd.part_number = @PartCode
and
	pd.row_id = @POLineNo

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
--- </Update>

--		Create undo-receipt history.
--- <Upsert>
set	@TableName = 'dbo.po_detail_history'

if	exists
	(	select
			*
		from
			dbo.po_detail_history pdh
		where
			po_number = @PONumber and
			part_number = @PartCode and
			row_id = @POLineNo) begin
	update
		dbo.po_detail_history
	set
		received = pd.received,
		balance = pd.balance,
		standard_qty = pd.standard_qty,
		last_recvd_date = pd.last_recvd_date,
		last_recvd_amount = pd.last_recvd_amount
	from
		dbo.po_detail_history pdh
		join dbo.po_detail pd on
			pd.po_number = @PONumber and
			pd.part_number = @PartCode and
			pd.row_id = @POLineNo
	where
		pdh.po_number = @PONumber and
		pdh.part_number = @PartCode and
		pdh.row_id = @POLineNo

	select
		@Error = @@Error,
		@RowCount = @@Rowcount
end
else
begin
	insert
		po_detail_history
	(	po_number, vendor_code, part_number, description, unit_of_measure,
		date_due, requisition_number, status, type, last_recvd_date,
		last_recvd_amount, cross_reference_part, account_code, notes, quantity,
		received, balance, active_release_cum, received_cum, price,
		row_id, invoice_status, invoice_date, invoice_qty, invoice_unit_price,
		release_no, ship_to_destination, terms, week_no, plant,
		invoice_number, standard_qty, sales_order, dropship_oe_row_id, ship_type,
		dropship_shipper, price_unit, ship_via, release_type, alternate_price)
	select
		po_number, vendor_code, part_number, description, unit_of_measure,
		date_due, requisition_number, 'C', type, @TranDT,
		pd.last_recvd_amount, cross_reference_part, account_code, null /*Note*/, quantity,
		received, balance, active_release_cum, received_cum, price,
		row_id, invoice_status, invoice_date, invoice_qty, invoice_unit_price,
		release_no, ship_to_destination, terms, week_no, plant,
		invoice_number, standard_qty, sales_order, dropship_oe_row_id, ship_type,
		dropship_shipper, price_unit, ship_via, release_type, alternate_price
	from
		dbo.po_detail pd
	where
		po_number = @PONumber and
		part_number = @PartCode and
		row_id = @POLineNo

	select
		@Error = @@Error,
		@RowCount = @@Rowcount
end

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into / updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
--- </Upsert>

--		C.	Update Part-Vendor relationship.
--- <Update>
set	@TableName = 'dbo.part_vendor'

update
	part_vendor
set
	accum_received = coalesce(accum_received, 0) - @ObjectStdQty
where
	part = @PartCode and
	vendor =
	(	select
			vendor_code
		from
			dbo.po_detail
		where
			po_number = @PONumber and
			part_number = @PartCode and
			row_id = @POLineNo)

select
	@Error = @@Error
,	@RowCount = @@Rowcount


if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
--- </Update>

--<CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit transaction @ProcName
end
--</CloseTran Required=Yes AutoCreate=Yes>

--	IV.	Return.
set	@Result = 0
return @Result
GO
