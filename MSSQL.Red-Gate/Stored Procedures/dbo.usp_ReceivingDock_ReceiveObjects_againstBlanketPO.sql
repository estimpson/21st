SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_ReceivingDock_ReceiveObjects_againstBlanketPO]
(	@User varchar(5)
,	@PONumber integer
,	@PartCode varchar(25)
,	@PackageType varchar(20)
,	@PerBoxQty numeric(20,6)
,	@NewObjects integer
,	@Shipper varchar(20)
,	@LotNumber varchar(20)
,	@Location varchar(10) = null
,	@SerialNumber integer out
,	@TranDT datetime out
,	@Result integer out)
as
/*
Example:
Initial queries {
select
	*
from
	employee
where
	operator_code = 'ES'

select
	po_detail.po_number, po_detail.part_number, po_detail.balance, PerBoxQty = (select standard_pack from part_inventory where part = part_number)
,	po_detail.date_due, row_id
from
	po_detail
	join po_header on po_header.po_number = po_detail.po_number
where
	po_header.release_control = 'A' and
	po_detail.status = 'A' and
	po_detail.balance > 0 and
	po_detail.po_number = 6913 and
	po_detail.part_number = 'KSI0015-HC02'
order by
	po_detail.date_due
}

Test syntax {
declare
	@User varchar(5)
,	@PONumber integer
,	@PartCode varchar(25)
,	@PackageType varchar(20)
,	@PerBoxQty numeric(20,6)
,	@NewObjects integer
,	@Shipper varchar(20)
,	@LotNumber varchar(20)
,	@FirstNewSerial int
,	@TranDT datetime

set	@User = 'ES'
set	@PONumber = 6913
set	@PartCode = 'KSI0015-HC02'
set	@PackageType = null
set	@PerBoxQty = 200
set	@NewObjects = 25
set	@Shipper = 'Test123'
set	@LotNumber = '123'

select
	po_detail.po_number, po_detail.part_number, po_detail.balance, PerBoxQty = (select standard_pack from part_inventory where part = part_number)
,	po_detail.date_due, row_id
,	received
,	standard_qty
,	last_recvd_date
,	last_recvd_amount
from
	po_detail
where
	po_number = @PONumber
order by
	date_due

begin transaction ReceiveObjects_againstBlanketPO

declare
	@ProcReturn integer
,	@ProcResult integer
,	@Error integer

execute	@ProcReturn = dbo.usp_ReceivingDock_ReceiveObjects_againstBlanketPO
	@User = @User
,	@PONumber = @PONumber
,	@PartCode = @PartCode
,	@PackageType = @PackageType
,	@PerBoxQty = @PerBoxQty
,	@NewObjects = @NewObjects
,	@Shipper = @Shipper
,	@LotNumber = @LotNumber
,	@SerialNumber = @FirstNewSerial out
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	ProcReturn = @ProcReturn, ProcResult = @ProcResult, Error = @Error, Serials = @NewObjects, NewSerial = @FirstNewSerial, TranDateTime = @TranDT, NextSerial = next_serial
from
	parameters

select
	*
from
	object
where
	serial between @FirstNewSerial and @FirstNewSerial + @NewObjects - 1

select
	*
from
	audit_trail
where
	serial between @FirstNewSerial and @FirstNewSerial + @NewObjects - 1
	and
		type = 'R'

select
	po_detail.po_number, po_detail.part_number, po_detail.balance, PerBoxQty = (select standard_pack from part_inventory where part = part_number)
,	po_detail.date_due, row_id
,	received
,	standard_qty
,	last_recvd_date
,	last_recvd_amount
from
	po_detail
where
	po_number = @PONumber
order by
	date_due

rollback
}

Results {
See below...
}
*/
set nocount on
set	@Result = 999999

--- <Error Handling>
declare
	@CallProcName sysname
,	@TableName sysname
,	@ProcName sysname
,	@ProcReturn integer
,	@ProcResult integer
,	@Error integer
,	@RowCount integer

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid) -- e.g.  dbo.usp_Test
--- </Error Handling>

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
declare
	@TranCount smallint

set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

--	I.	Initializations.
--		A.	Get the line item's row id.
declare
	@RowID integer

select
	@RowID = min(row_id)
from
	po_detail pd
where
	pd.po_number = @PONumber
	and
		pd.part_number = @PartCode
	and
		pd.status = 'A'
	and
		pd.date_due = coalesce(
	(	select
			min(date_due)
		from
			po_detail
		where
			po_number = @PONumber
			and
				part_number = @PartCode and
			status = 'A'
			and
				balance > 0), pd.date_due)

--		B.	Initalize conversion factor.
declare
	@Conversion numeric(20,14)

set
	@Conversion = coalesce(
	(	select
			unit_conversion.conversion
		from
			po_detail
			join part_inventory on
				part_inventory.part = @PartCode
			left outer join part_unit_conversion on
				po_detail.part_number = part_unit_conversion.part
			left outer join unit_conversion on
				part_unit_conversion.code = unit_conversion.code and
				unit_conversion.unit1 = part_inventory.standard_unit and
				unit_conversion.unit2 = po_detail.unit_of_measure
		where
			po_detail.po_number = @PONumber and
			po_detail.part_number = @PartCode and
			po_detail.row_id = @RowID), 1)

--		C.	Part class.
declare
	@PartClass char(1)

select
	@PartClass = class
from
	part
where
	part = @PartCode

--	II.	Generate Inventory.
--		A.	Get serial numbers.
--- <Call>
declare
	@NewSerial int

set	@CallProcName = 'monitor.usp_NewSerialBlock'
execute
	@ProcReturn = monitor.usp_NewSerialBlock
	@SerialBlockSize = @NewObjects
,	@FirstNewSerial = @NewSerial out
,	@Result = @ProcResult out

set	@Error = @@Error
if	@Error != 0 begin
	set	@Result = 900501
	RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
	rollback tran @ProcName
	return	@Result
end
if	@ProcReturn != 0 begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	rollback tran @ProcName
	return	@Result
end
if	@ProcResult != 0 begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	rollback tran @ProcName
	return	@Result
end
--- </Call>

--		B.	Create inventory.
select
	Serial = @NewSerial + RowNumber - 1
into
	#NewSerials
from
	dbo.udf_Rows (@NewObjects)

--			1.	New object records.
--- <Insert>
set	@TableName = 'dbo.object'

insert
	object
(	serial, part, lot, location
,	last_date, unit_measure, operator
,	status
,	origin, cost, note, po_number
,	name, plant, quantity, last_time
,	package_type, std_quantity
,	custom1, custom2, custom3, custom4, custom5
,	user_defined_status
,	std_cost, field1)
select
	ns.Serial, pd.part_number, @LotNumber, l.code
,	@TranDT, pd.unit_of_measure, @User
,	(	case
			when coalesce(p.quality_alert, 'N') = 'Y' then 'H'
			else 'A'
		end)
,	@Shipper, pd.price / @Conversion, null /*note*/, convert(varchar, @PONumber)
,	p.name, l.plant, @PerBoxQty * @Conversion, @TranDT
,	@PackageType, @PerBoxQty
,	null /*custom1*/, null /*custom2*/, null /*custom3*/, null /*custom4*/, null /*custom5*/
,	(	case
			when coalesce(p.quality_alert, 'N') = 'Y' then 'On Hold'
			else 'Approved'
		end)
,	pd.price / @Conversion, '' /*field1*/
from
	#NewSerials ns
	join po_detail pd on
		pd.po_number = @PONumber
		and pd.row_id = @RowID
	join part p on
		pd.part_number = p.part
	join part_inventory pi on
		pd.part_number = pi.part
	join location l on
		coalesce (@Location, pi.primary_location) = l.code
where
	@PartClass != 'N'

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
if	@RowCount != @NewObjects
	and
		@PartClass != 'N' begin
	set	@Result = 900102
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: %d.', 16, 1, @TableName, @ProcName, @RowCount, @NewObjects)
	rollback tran @ProcName
	return @Result
end
--- </Insert>

--			2.	New audit trail records.
--- <Insert>
set	@TableName = 'dbo.audit_trail'

insert
	audit_trail
(	serial, date_stamp, type, part
,	quantity, remarks, price, vendor
,	po_number, operator, from_loc, to_loc
,	on_hand, lot
,	weight
,	status
,	shipper, unit, std_quantity, cost, control_number
,	custom1, custom2, custom3, custom4, custom5
,	plant, notes, gl_account, package_type
,	release_no, std_cost
,	user_defined_status
,	part_name, tare_weight, field1)
select
	ns.Serial, @TranDT, 'R', pd.part_number
,	@PerBoxQty * @Conversion, 'Receiving', pd.price / @Conversion, ph.vendor_code
,	convert(varchar, @PONumber), @User, ph.vendor_code, coalesce(l.code, 'NONINV')
,	coalesce(po.on_hand, 0) + ((ns.Serial - @NewSerial + 1) * @PerBoxQty), @LotNumber
,	coalesce (o.weight, pi.unit_weight * @PerBoxQty)
,	(	case
			when coalesce(pv.outside_process, 'N') = 'Y' then 'P'
			else coalesce(o.status, 'A')
		end)
,	@Shipper, pd.unit_of_measure, @PerBoxQty, pd.price / @Conversion, convert(varchar, pd.requisition_id)
,	null /*custom1*/, null /*custom2*/, null /*custom3*/, null /*custom4*/, null /*custom5*/
,	l.plant, null /*note*/, pp.gl_account_code, @PackageType
,	convert(varchar, pd.release_no), pd.price / @Conversion
,	(	case
			when coalesce(p.quality_alert, 'N') = 'Y' then 'On Hold'
			else coalesce(o.user_defined_status, 'A', 'Approved')
		end)
,	coalesce(o.name, pd.description), coalesce(o.tare_weight, pm.weight), '' /*field1*/
from
	#NewSerials ns
	left join object o on
		ns.Serial = o.serial
	join po_detail pd on
		pd.po_number = @PONumber
		and
			pd.row_id = @RowID
	join po_header ph on
		pd.po_number = ph.po_number
	left join part p on
		pd.part_number = p.part
	left join part_inventory pi on
		pd.part_number = pi.part
	left join location l on
		coalesce (@Location, pi.primary_location) = l.code
	left outer join part_online po on
		pd.part_number = po.part
	left outer join part_purchasing pp on
		pd.part_number = pp.part
	left outer join part_vendor pv on
		pd.part_number = pv.part
	and
		ph.vendor_code = pv.vendor
	left join dbo.package_materials pm on
		pm.code = @PackageType
	cross join parameters

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
if	@RowCount != @NewObjects begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: %d.', 16, 1, @TableName, @ProcName, @RowCount, @NewObjects)
	rollback tran @ProcName
	return @Result
end
--- </Insert>

--			3.	Update part online.
--- <Update>
set	@TableName = 'dbo.part_online'

update
	part_online
set	on_hand =
	(	select
			Sum(std_quantity)
		from
			object
		where
			part = part_online.part and
			status = 'A')
where
	part = @PartCode

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

--	III.	Update Purchase Order and Part-Vendor relationship.
select
	ID = identity(int, 1, 1)
,	RowID = row_id
,	RequiredQty = standard_qty
,	RequiredAccum = convert (numeric(20,6), null)
into
	#POLines
from
	po_detail
where
	po_number = @PONumber and
	part_number = @PartCode and
	balance > 0
order by
	date_due

update
	#POLines
set
	RequiredAccum = (select sum(RequiredQty) from #POLines PO1 where ID <= #POLines.ID)

--		A.	Update the Line Item with receipt quantities and date.
--- <Update>
set	@TableName = 'dbo.po_detail'

update
	po_detail
set	received = coalesce(received, 0) + (@PerBoxQty * @NewObjects - (#POLines.RequiredAccum - #POLines.RequiredQty)) * @Conversion
,	balance = coalesce(balance, quantity) - (@PerBoxQty * @NewObjects - (#POLines.RequiredAccum - #POLines.RequiredQty)) * @Conversion
,	standard_qty = standard_qty - (@PerBoxQty * @NewObjects - (#POLines.RequiredAccum - #POLines.RequiredQty))
,	last_recvd_date = @TranDT
,	last_recvd_amount = (@PerBoxQty * @NewObjects - (#POLines.RequiredAccum - #POLines.RequiredQty)) * @Conversion
from
	po_detail
	join #POLines on
		#POLines.RequiredAccum - #POLines.RequiredQty < @PerBoxQty * @NewObjects
		and
			#POLines.RequiredAccum > @PerBoxQty * @NewObjects
where
	po_detail.po_number = @PONumber
	and
		po_detail.part_number = @PartCode
	and
		po_detail.row_id = #POLines.RowID

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

--- <Update>
set	@TableName = 'dbo.po_detail'

update
	po_detail
set
	received = received + standard_qty * @Conversion
,	balance = 0
,	standard_qty = 0
,	last_recvd_date = @TranDT
,	last_recvd_amount = standard_qty * @Conversion
from
	po_detail
	join #POLines on
		#POLines.RequiredAccum - #POLines.RequiredQty < @PerBoxQty * @NewObjects
		and
			#POLines.RequiredAccum <= @PerBoxQty * @NewObjects
		and
			po_detail.row_id = #POLines.RowID
where
	po_detail.po_number = @PONumber
	and
		po_detail.part_number = @PartCode

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

--		B.	Create or update receipt history.
--- <Update>
set	@TableName = 'dbo.po_detail_history'

update
	po_detail_history
set	po_detail_history.received = po_detail.received
,	po_detail_history.balance = po_detail.balance
,	po_detail_history.standard_qty = po_detail.standard_qty
,	po_detail_history.last_recvd_date = po_detail.last_recvd_date
,	po_detail_history.last_recvd_amount = po_detail.last_recvd_amount
from
	po_detail_history
	join po_detail on
		po_detail.po_number = @PONumber
		and
			po_detail.part_number = @PartCode
		and
			po_detail.row_id = po_detail_history.row_id
	join #POLines on
		#POLines.RequiredAccum - #POLines.RequiredQty < @PerBoxQty * @NewObjects
		and
			po_detail.row_id = #POLines.RowID
where
	po_detail_history.po_number = @PONumber
	and
		po_Detail_history.part_number = @PartCode

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

--- <Insert>
set	@TableName = 'po_detail_history'

insert
	po_detail_history
(	po_number, vendor_code, part_number, description, unit_of_measure
, 	date_due, requisition_number, status, type, last_recvd_date
,	last_recvd_amount, cross_reference_part, account_code, notes, quantity
,	received, balance, active_release_cum, received_cum, price
,	row_id, invoice_status, invoice_date, invoice_qty, invoice_unit_price
,	release_no, ship_to_destination, terms, week_no, plant
,	invoice_number, standard_qty, sales_order, dropship_oe_row_id, ship_type
,	dropship_shipper, price_unit, ship_via, release_type, alternate_price)
select
	po_detail.po_number, po_detail.vendor_code, po_detail.part_number, po_detail.description, po_detail.unit_of_measure
,	po_detail.date_due, po_detail.requisition_number, 'C', po_detail.type, @TranDT
,	po_detail.last_recvd_amount, po_detail.cross_reference_part, po_detail.account_code, null /*Note*/, po_detail.quantity
,	po_detail.received, po_detail.balance, po_detail.active_release_cum, po_detail.received_cum, po_detail.price
,	po_detail.row_id, po_detail.invoice_status, po_detail.invoice_date, po_detail.invoice_qty, po_detail.invoice_unit_price
,	po_detail.release_no, po_detail.ship_to_destination, po_detail.terms, po_detail.week_no, po_detail.plant
,	po_detail.invoice_number, po_detail.standard_qty, po_detail.sales_order, po_detail.dropship_oe_row_id, po_detail.ship_type
,	po_detail.dropship_shipper, po_detail.price_unit, po_detail.ship_via, po_detail.release_type, po_detail.alternate_price
from
	po_detail
	join #POLines on
		#POLines.RequiredAccum - #POLines.RequiredQty < @PerBoxQty * @NewObjects
		and
			po_detail.row_id = #POLines.RowID
where
	po_detail.po_number = @PONumber
	and
		po_detail.part_number = @PartCode
	and
		not exists
		(	select
				*
			from
				po_detail_history
			where
				po_number = @PONumber
				and
					part_number = @PartCode
				and
					row_id = po_detail.row_id)

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
--- </Insert>

--		C.	Remove releases which have been fully met.
--- <Delete>
set	@TableName = 'dbo.po_detail'

delete
	dbo.po_detail
where
	po_number = @PONumber
	and
		part_number = @PartCode
	and
		balance = 0

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error deleting from table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end
--- </Delete>

--		D.	Update Part-Vendor relationship.
--- <Update>
set	@TableName = 'dbo.part_vendor'

update
	part_vendor
set
	accum_received = coalesce(accum_received, 0) + (@PerBoxQty * @NewObjects)
where
	part = @PartCode
	and
		vendor =
		(	select
				max(vendor_code)
			from
				po_detail
			where
				po_number = @PONumber
				and
					po_detail.part_number = @PartCode)

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

set	@SerialNumber = @NewSerial
--<CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit transaction @ProcName
end
--</CloseTran Required=Yes AutoCreate=Yes>

--	IV.	Return.
set	@Result = 0
return
	@Result
GO
