
if	objectproperty(object_id('dbo.usp_MES_BackFlush'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_BackFlush
end
go

create procedure dbo.usp_MES_BackFlush
	@Operator varchar(10)
,	@BackflushNumber varchar(50)
,	@TranDT datetime out
,	@Result int out
as
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

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
declare
	@TranCount smallint

set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
else begin
	save tran @ProcName
end
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
--	I.	Calculate quantity to issue.
declare
	@WOID int
,	@WODID int
,	@PartProduced varchar(25)
,	@QtyRequested numeric(20, 6)
,	@Machine varchar(10)
,	@Shift char(1)
,	@ConstrainedPart varchar(25)

--select
--	@WOID = WOHeaders.ID
--,	@WODID = WODetails.ID
--,	@TranDT = BackFlushHeaders.TranDT
--,	@PartProduced = BackFlushHeaders.PartProduced
--,	@QtyRequested = BackFlushHeaders.QtyProduced
--,	@Machine = WOHeaders.Machine
--,	@Shift = WOShift.Shift
--from
--	BackFlushHeaders
--	left join WODetails
--		on	BackFlushHeaders.WODID = WODetails.ID
--	left join WOHeaders
--		on	WODetails.WOID = WOHeaders.ID
--	left join WOShift
--		on	WODetails.WOID = WOShift.WOID
--where
--	BackFlushHeaders.ID = @BackflushNumber

select
	@Machine = coalesce(@Machine, machine)
from
	part_machine
where
	part = @PartProduced
	and sequence = 1

declare @Inventory table
(	Serial int
,	Part varchar(25)
,	BOMLevel tinyint
,	Sequence tinyint
,	Suffix tinyint
,	BOMID int
,	AllocationDT datetime
,	QtyPer float
,	QtyAvailable float
,	QtyRequired float
,	QtyIssue float
,	QtyOverage float
)

--insert  @Inventory
--select
--	*
--from
--	FT.fn_GetBackflushDetailsMachine(@WODID, @QtyRequested)
	
select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush')		
	return	@Result
end
if	@RowCount !> 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush')
	return	@Result
end

--	Look for product which does not allow over-consumption.
if	exists
	(	select
			*
		from
			@Inventory
		where
			QtyOverage > 0
	) begin
	
	set @Result = 999999
	rollback tran @ProcName
	raiserror ('Error during Back Flush.  Allocate additional material to continue.', 16, 1)
	return
		@Result
end

--	Write negative scrap for overage quantity.
declare
	@Serial int
,	@Part varchar(25)

declare CreateSerial cursor local for
select
	Part
from
	@Inventory
where
	Serial < 0
	and QtyOverage > 0

open
	CreateSerial

while
	1 = 1 begin

	fetch
		CreateSerial
	into
		@Part
	
	if	@@FETCH_STATUS != 0 begin
		break
	end
	
	--- <Call>	
	set	@CallProcName = 'monitor.usp_NewSerialBlock'
	execute
		@ProcReturn = monitor.usp_NewSerialBlock
		@SerialBlockSize = 1
	,	@FirstNewSerial = @Serial out
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
	
	insert
		object
	(	serial
	,	part
	,	quantity
	,	std_quantity
	,	location
	,	last_date
	,	unit_measure
	,	operator
	,	status
	,	plant
	,	name
	,	last_time
	,	user_defined_status
	,	cost
	,	std_cost
	,	note
	)
	select
		Serial = @Serial
	,	Part = @Part
	,	quantity = QtyOverage
	,	std_quantity = QtyOverage
	,	location = @Machine
	,	last_date = getdate()
	,	unit_measure = standard_unit
	,	operator = @Operator
	,	status = 'A'
	,	location.plant
	,	part.name
	,	last_time = getdate()
	,	user_defined_status = 'Approved'
	,	part_standard.cost_cum
	,	part_standard.cost_cum
	,	Note = 'Create During Automatic Excess'
	from
		@Inventory Inventory
		join Location
			on	Location.code = @Machine
		join part
			on	part.part = Inventory.Part
		join part_inventory
			on	part_inventory.part = Part.Part
		join part_standard
			on	part_standard.part = Part.PArt
	where
		Inventory.serial < 0
		and Inventory.Part = @Part
		and QtyOverage > 0
	
	select
		@Error = @@Error
	,	@RowCount = @@ROWCOUNT

	if	@Error != 0 begin
		set @Result = 60111
		rollback tran @ProcName
		raiserror (@Result, 16, 1, @Serial)

		return	@Result
	end

	if	@RowCount != 1 begin
		set @Result = 60111
		rollback tran @ProcName
		raiserror (@Result, 16, 1, @Serial)
		return	@Result
	end

	update
		@Inventory
	set 
		Serial = @Serial
	where
		part = @Part
end

insert
	audit_trail
(	serial
,	date_stamp
,	type
,	part
,	quantity
,	remarks
,	po_number
,	operator
,	from_loc
,	to_loc
,	on_hand
,	lot
,	weight
,	status
,	shipper
,	unit
,	workorder
,	std_quantity
,	cost
,	custom1
,	custom2
,	custom3
,	custom4
,	custom5
,	plant
,	notes
,	package_type
,	suffix
,	due_date
,	group_no
,	std_cost
,	user_defined_status
,	engineering_level
,	parent_serial
,	origin
,	destination
,	sequence
,	object_type
,	part_name
,	start_date
,	field1
,	field2
,	show_on_shipper
,	tare_weight
,	kanban_number
,	dimension_qty_string
,	dim_qty_string_other
,	varying_dimension_code
)
select
	serial = object.serial
,	date_stamp = @TranDT
,	type = 'E'
,	part = object.part
,	quantity = -Inventory.QtyOverage
,	remarks = 'Qty Ex Aut'
,	po_number = object.po_number
,	operator = @Operator
,	from_loc = left(object.user_defined_status, 10)
,	to_loc = 'Scrap'
,	on_hand = part_online.on_hand
,	lot = object.lot
,	weight = object.weight
,	status = 'S'
,	shipper = object.shipper
,	unit = object.unit_measure
,	workorder = convert (varchar, @WOID)
,	std_quantity = -Inventory.QtyOverage
,	cost = object.cost
,	custom1 = object.custom1
,	custom2 = object.custom2
,	custom3 = object.custom3
,	custom4 = object.custom4
,	custom5 = object.custom5
,	plant = object.plant
,	notes = 'Quantity Excess during backflush'
,	package_type = object.package_type
,	suffix = object.suffix
,	due_date = object.date_due
,	gruop_no = @BackflushNumber
,	std_cost = object.std_cost
,	user_defined_status = 'Scrap'
,	engineering_level = object.engineering_level
,	parent_serial = object.parent_serial
,	origin = object.origin
,	destination = object.destination
,	sequence = object.sequence
,	object_type = object.type
,	part_name = object.name
,	start_date = object.start_date
,	field1 = object.field1
,	field2 = object.field2
,	show_on_shipper = object.show_on_shipper
,	tare_weight = object.tare_weight
,	kanban_number = object.kanban_number
,	dimension_qty_string = object.dimension_qty_string
,	dim_qty_string_other = object.dim_qty_string_other
,	varying_dimension_code = object.varying_dimension_code
from
	(	select
			Part
		,	Serial
		,	QtyOverage = sum(QtyOverage)
		from
			@Inventory
		group by
			Part
		,	Serial
	) Inventory
	join object
		on	Inventory.Serial = object.serial
	join part_online
		on	Inventory.part = part_online.part
where
	Inventory.QtyOverage > 0
	and Inventory.Serial > 0

select
	@Error = @@Error

if	@Error != 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush')

	return	@Result
end

--insert
--	FT.Defects
--(	TransactionDT
--,	Machine
--,	Part
--,	DefectCode
--,	QtyScrapped
--,	Operator
--,	Shift
--,	WODID
--,	DefectSerial
--)
--select
--	TransactionDT = @TranDT
--,	Machine = @Machine
--,	Part = object.part
--,	DefectCode = 'Qty Ex Aut'
--,	QtyScrapped = -Inventory.QtyOverage
--,	Operator = @Operator
--,	Shift = @Shift
--,	WODID = @WODID
--,	DefectSerial = object.serial
--from
--	(	select
--			Part
--		,	Serial
--		,	QtyOverage = sum(QtyOverage)
--		from
--			@Inventory
--		group by
--			Part
--		,	Serial
--	) Inventory
--	join object
--		on	Inventory.Serial = object.serial
--	join part_online
--		on	Inventory.part = part_online.part
--where
--	Inventory.QtyOverage > 0

select
	@Error = @@Error

if	@Error != 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush')

	return	@Result
end

--	Write material issue.
insert
	audit_trail
(	serial
,	date_stamp
,	type
,	part
,	quantity
,	remarks
,	po_number
,	operator
,	from_loc
,	to_loc
,	on_hand
,	lot
,	weight
,	status
,	shipper
,	unit
,	workorder
,	std_quantity
,	cost
,	custom1
,	custom2
,	custom3
,	custom4
,	custom5
,	plant
,	notes
,	package_type
,	suffix
,	due_date
,	group_no
,	std_cost
,	user_defined_status
,	engineering_level
,	parent_serial
,	origin
,	destination
,	sequence
,	object_type
,	part_name
,	start_date
,	field1
,	field2
,	show_on_shipper
,	tare_weight
,	kanban_number
,	dimension_qty_string
,	dim_qty_string_other
,	varying_dimension_code
)
select
	serial = object.serial
,	date_stamp = @TranDT
,	type = 'M'
,	part = object.part
,	quantity = Inventory.QtyIssue + Inventory.QtyOverage
,	remarks = 'Mat Issue'
,	po_number = object.po_number
,	operator = @Operator
,	from_loc = object.location
,	to_loc = @Machine
,	on_hand = part_online.on_hand - (Inventory.QtyIssue + Inventory.QtyOverage)
,	lot = object.lot
,	weight = object.weight
,	status = object.status
,	shipper = object.shipper
,	unit = object.unit_measure
,	workorder = convert (varchar, @WOID)
,	std_quantity = Inventory.QtyIssue + Inventory.QtyOverage
,	cost = object.cost
,	custom1 = object.custom1
,	custom2 = object.custom2
,	custom3 = object.custom3
,	custom4 = object.custom4
,	custom5 = object.custom5
,	plant = isnull(object.plant, 'EEH')
,	notes = ''
,	package_type = object.package_type
,	suffix = object.suffix
,	due_date = object.date_due
,	group_no = @BackflushNumber
,	std_cost = object.std_cost
,	user_defined_status = object.user_defined_status
,	engineering_level = object.engineering_level
,	parent_serial = object.parent_serial
,	origin = object.origin
,	destination = object.destination
,	sequence = object.sequence
,	object_type = object.type
,	part_name = object.name
,	start_date = object.start_date
,	field1 = object.field1
,	field2 = object.field2
,	show_on_shipper = object.show_on_shipper
,	tare_weight = object.tare_weight
,	kanban_number = object.kanban_number
,	dimension_qty_string = object.dimension_qty_string
,	dim_qty_string_other = object.dim_qty_string_other
,	varying_dimension_code = object.varying_dimension_code
from
	(	select
			Part
		,	Serial
		,	QtyIssue = sum(isnull(QtyIssue, 0))
		,	QtyOverage = sum(isnull(QtyOverage, 0))
		from
			@Inventory
		group by
			Part
		,	Serial
	) Inventory
	join object
		on Inventory.Serial = object.serial
	join part_online
		on Inventory.part = part_online.part
where
	Inventory.QtyIssue + Inventory.QtyOverage > 0
	and Inventory.Serial > 0

select
	@Error = @@Error

if	@Error != 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush')

	return	@Result
end

--	Write intercompany transactions for material that moves from one company to another.

insert
	EEA.IntercompanyAuditTrail
(	ID
,	Serial
,	TranDT
,	Part
,	PartIntercompany
,	Operator
,	QtyTransfer
,	WOID
,	Plant
,	ToProductLine
,	Notes
,	BFID
)
select
	ID = -1
,	Serial = Inventory.Serial
,	TranDT = @TranDT
,	Part = Inventory.Part
,	PartIntercompany = '' -- calculated in trigger
,	Operator = @Operator
,	QtyTransfer = QtyIssue + QtyOverage
,	WOID = @WOID
,	Plant = o.plant
,	ToProductLine = plTo.id
,	Notes = 'Intercompany transaction from backflush.'
,	BFID = @BackflushNumber
from
	(	select
			Part
		,	Serial
		,	QtyIssue = sum(isnull(QtyIssue, 0))
		,	QtyOverage = sum(isnull(QtyOverage, 0))
		from
			@Inventory
		group by
			Part
		,	Serial
	) Inventory
	join dbo.object o
		on o.serial = Inventory.Serial
	join dbo.part pTo
		join product_line plTo
			on plTo.id = pTo.product_line
		on pTo.part = @PartProduced
	join dbo.part pFrom
		join product_line plFrom
			on plFrom.id = pFrom.product_line
		on pFrom.part = Inventory.part
where
	plTo.gl_segment != plFrom.gl_segment

--	Adjust inventory
--		Update objects.
update
	object
set 
	quantity = object.quantity - Inventory.QtyIssue
,	std_quantity = object.std_quantity - Inventory.QtyIssue
,	last_date = getdate()
,	last_time = getdate()
,	operator = @Operator
from
	object
	join
	(	select
			Serial
		,	QtyIssue = sum(QtyIssue)
		,	QtyOverage = sum(QtyOverage)
		from
			@Inventory
		group by
			Serial
	) Inventory
		on	object.serial = Inventory.Serial
where
	Inventory.QtyOverage = 0

select
	@Error = @@Error

if	@Error != 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush')

	return	@Result
end

--		Set depleted objects to empty (they will be deleted when the allocation is ended if	operator quantity is 0).
update
	object
set 
	quantity = 0
,	std_quantity = 0
,	last_date = getdate()
,	last_time = getdate()
,	operator = @Operator
from
	object
	join
	(	select
			Serial
		,	QtyOverage = sum(QtyOverage)
		from
			@Inventory
		group by
			Serial
	) Inventory
		on	object.serial = Inventory.Serial
where
	Inventory.QtyOverage > 0

select
	@Error = @@Error

if	@Error != 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush')

	return	@Result
end

--	Update on hand for part.
update
	part_online
set 
	on_hand = (select sum(std_quantity) from object where part = part_online.part and status = 'A')
where
	part in (select Part from @Inventory)

select
	@Error = @@Error

if	@Error != 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush')

	return	@Result
end

--	Record back flush details.
insert
	BackFlushDetails
(
	BackflushNumber
,	BillOfMaterialID
,	PartConsumed
,	SerialConsumed
,	QtyAvailable
,	QtyRequired
,	QtyIssue
,	QtyOverage
)
select
	BackflushNumber = @BackflushNumber
,	BillOfMaterialID = Inventory.BOMID
,	PartConsumed = Inventory.Part
,	SerialConsumed = Inventory.Serial
,	QtyAvailable = Inventory.QtyAvailable
,	QtyRequired = Inventory.QtyRequired
,	QtyIssue = Inventory.QtyIssue
,	QtyOverage = Inventory.QtyOverage
from
	@Inventory Inventory

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush:BackflushDetails')

	return	@Result
end
if	@RowCount !> 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush:BackflushDetails')

	return	@Result
end

--		Update material allocation.
update
	WODMaterialAllocations
set 
	WODMaterialAllocations.QtyIssued = WODMaterialAllocations.QtyIssued + isnull(Inventory.QtyIssue, 0)
,	WODMaterialAllocations.QtyOverage = WODMaterialAllocations.QtyOverage + isnull(Inventory.QtyOverage, 0)
from
	WODMaterialAllocations
	join @Inventory Inventory
		on	coalesce(WODMaterialAllocations.BOMID, -1) = Inventory.BOMID
			and coalesce(WODMaterialAllocations.Suffix, 0) = Inventory.Suffix
where
	WODMaterialAllocations.WODID = @WODID
	and WODMaterialAllocations.QtyEnd is null

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set @Result = 999999
	rollback tran @ProcName
	raiserror (@Result, 16, 1, 'BackFlush')

	return	@Result
end
--- </Body>

---<CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit transaction BackFlush
end
---</CloseTran Required=Yes AutoCreate=Yes>

---	<Return>
set	@Result = 0
return
	@Result
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

declare
	@Param1 scalar_data_type

set	@Param1 = test_value

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_NewProcedure
	@Param1 = @Param1
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
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
/*
begin transaction
declare	@ProcResult int,
	@ProcReturn int,
	@Operator varchar (10),
	@WODID int,
	@QtyRequested numeric (20,6),
	@Override int,
	@NewSerial int

set	@Operator = 'Mon'
set	@WODID = 270400
set	@QtyRequested = 12
set	@Override = 1

--		A.	Get a serial number.
select	@NewSerial = next_serial
from	parameters with (TABLOCKX)

while	exists
	(	select	serial
		from	object
		where	serial = @NewSerial) or
	exists
	(	select	serial
		from	audit_trail
		where	serial = @NewSerial) begin

	set	@NewSerial = @NewSerial + 1
end

update	parameters
set	next_serial = @NewSerial + 1

declare	@NewBFID int

--		A.	Create back flush header.
insert	BackFlushHeaders
(	WODID,
	PartProduced,
	SerialProduced,
	QtyProduced)
select	ID,
	Part,
	@NewSerial,
	@QtyRequested
from	WODetails
where	ID = @WODID

set	@NewBFID = SCOPE_IDENTITY ()

--		B.	Execute back flush details.
execute	@ProcReturn = dbo.usp_MES_BackFlush
	@Operator = @Operator,
	@BackflushNumber = @NewBFID,
	@Result = @ProcResult

select	@ProcResult,
	@NewSerial,
	@ProcReturn

select	*
from	BackFlushHeaders
where	ID = @NewBFID

select	*
from	BackFlushDetails
Where	BFID = @NewBFID

select	*
from	audit_trail
where	date_stamp >= DateAdd (n, -1, getdate()) and
	serial in
	(	select	SerialConsumed
		from	BackFlushDetails
		where	BFID = @NewBFID)

select	*
from	object
where	serial in
	(	select	SerialConsumed
		from	BackFlushDetails
		where	BFID = @NewBFID)

rollback
*/
go
