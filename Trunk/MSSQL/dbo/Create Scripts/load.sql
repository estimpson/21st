create index ix_part_machine_1 on dbo.part_machine (part, machine, sequence)
create index ix_part_machine_2 on dbo.part_machine (machine, part, sequence)

create index XRt_3 on FT.XRt (ChildPart, Sequence, TopPart) include (BOMLevel)
create index XRt_4 on FT.XRt (Sequence, TopPart, ChildPart) include (BOMLevel)
go

if	objectproperty(object_id('dbo.usp_InventoryControl_Breakout'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_InventoryControl_Breakout
end
go

create procedure dbo.usp_InventoryControl_Breakout
	@Operator varchar(5)
,	@Serial int
,	@QtyBreakout numeric(20,6)
,	@BreakoutSerial int out
,	@TranDT datetime out
,	@Result integer out
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
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
/*	Get object serial. (monitor.usp_SerialBlock) */
--- <Call>	
set	@CallProcName = 'monitor.usp_NewSerialBlock'
execute
	@ProcReturn = monitor.usp_NewSerialBlock
	@SerialBlockSize = 1
,	@FirstNewSerial = @BreakoutSerial out
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

/*	Create new object for breakout quantity. (i1) */
--- <Insert rows="1">
set	@TableName = 'dbo.object'

insert
	dbo.object
(
	serial
,   part
,   location
,   last_date
,   unit_measure
,   operator
,   status
,   destination
,   station
,   origin
,   cost
,   weight
,   parent_serial
,   note
,   quantity
,   last_time
,   date_due
,   customer
,   sequence
,   shipper
,   lot
,   type
,   po_number
,   name
,   plant
,   start_date
,   std_quantity
,   package_type
,   field1
,   field2
,   custom1
,   custom2
,   custom3
,   custom4
,   custom5
,   show_on_shipper
,   tare_weight
,   suffix
,   std_cost
,   user_defined_status
,   workorder
,   engineering_level
,   kanban_number
,   dimension_qty_string
,   dim_qty_string_other
,   varying_dimension_code
,   posted
)
select
	serial = @BreakoutSerial
,   part = o.part
,   location = o.location
,   last_date = @TranDT
,   unit_measure = o.unit_measure
,   operator = @Operator
,   status = o.status
,   destination = o.destination
,   station = o.station
,   origin = o.origin
,   cost = o.cost
,   weight = null
,   parent_serial = null
,   note = o.note
,   quantity = dbo.udf_GetQtyFromStdQty(o.part, @QtyBreakout, o.unit_measure)
,   last_time = @TranDT
,   date_due = o.date_due
,   customer = o.customer
,   sequence = o.sequence
,   shipper = o.shipper
,   lot = o.lot
,   type = o.type
,   po_number = o.po_number
,   name = o.name
,   plant = o.plant
,   start_date = o.start_date
,   std_quantity = @QtyBreakout
,   package_type = o.package_type
,   field1 = o.field1
,   field2 = o.field2
,   custom1 = o.custom1
,   custom2 = o.custom2
,   custom3 = o.custom3
,   custom4 = o.custom4
,   custom5 = o.custom5
,   show_on_shipper = o.show_on_shipper
,   tare_weight = o.tare_weight
,   suffix = o.suffix
,   std_cost = o.std_cost
,   user_defined_status = o.user_defined_status
,   workorder = o.workorder
,   engineering_level = o.engineering_level
,   kanban_number = o.kanban_number
,   dimension_qty_string = o.dimension_qty_string
,   dim_qty_string_other = o.dim_qty_string_other
,   varying_dimension_code = o.varying_dimension_code
,   posted = o.posted
from
	dbo.object o
where
	serial = @Serial	

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Adjust quantity of broken object. (u1) */
--- <Update rows="1">
set	@TableName = 'dbo.object'

update
	o
set
	std_quantity = std_quantity - @QtyBreakout
,	quantity = quantity - dbo.udf_GetQtyFromStdQty(o.part, @QtyBreakout, o.unit_measure)
from
	dbo.object o
where
	serial = @Serial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error updating %s in procedure %s.  Rows Updated: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Update>

/*	Create breakout audit trail. (i1) */
declare
	@BreakoutATType char(1)
,	@BreakoutATRemarks char(1)

set	@BreakoutATType = 'B'
set @BreakoutATRemarks = 'Break Out'

--- <Insert rows="1">
set	@TableName = 'dbo.audit_trail'

insert
	dbo.audit_trail
(
	serial
,   date_stamp
,   type
,   part
,   quantity
,   remarks
,   price
,   salesman
,   customer
,   vendor
,   po_number
,   operator
,   from_loc
,   to_loc
,   on_hand
,   lot
,   weight
,   status
,   shipper
,   flag
,   activity
,   unit
,   workorder
,   std_quantity
,   cost
,   control_number
,   custom1
,   custom2
,   custom3
,   custom4
,   custom5
,   plant
,   invoice_number
,   notes
,   gl_account
,   package_type
,   suffix
,   due_date
,   group_no
,   sales_order
,   release_no
,   dropship_shipper
,   std_cost
,   user_defined_status
,   engineering_level
,   posted
,   parent_serial
,   origin
,   destination
,   sequence
,   object_type
,   part_name
,   start_date
,   field1
,   field2
,   show_on_shipper
,   tare_weight
,   kanban_number
,   dimension_qty_string
,   dim_qty_string_other
,   varying_dimension_code
)
select
	serial = o.serial
,   date_stamp = @TranDT
,   type = @BreakoutATType
,   part = o.part
,   quantity = o.quantity
,   remarks = @BreakoutATRemarks
,   price = 0
,   salesman = ''
,   customer = o.customer
,   vendor = ''
,   po_number = o.po_number
,   operator = @Operator
,   from_loc = convert(varchar, @Serial)
,   to_loc = o.location
,   on_hand = dbo.udf_GetPartQtyOnHand(o.part)
,   lot = o.lot
,   weight = o.weight
,   status = o.status
,   shipper = o.shipper
,   flag = ''
,   activity = ''
,   unit = o.unit_measure
,   workorder = o.workorder
,   std_quantity = o.std_quantity
,   cost = o.cost
,   control_number = ''
,   custom1 = o.custom1
,   custom2 = o.custom2
,   custom3 = o.custom3
,   custom4 = o.custom4
,   custom5 = o.custom5
,   plant = o.plant
,   invoice_number = ''
,   notes = o.note
,   gl_account = ''
,   package_type = o.package_type
,   suffix = o.suffix
,   due_date = o.date_due
,   group_no = ''
,   sales_order = ''
,   release_no = ''
,   dropship_shipper = 0
,   std_cost = o.std_cost
,   user_defined_status = o.user_defined_status
,   engineering_level = o.engineering_level
,   posted = o.posted
,   parent_serial = o.parent_serial
,   origin = o.origin
,   destination = o.destination
,   sequence = o.sequence
,   object_type = o.type
,   part_name = (select name from part where part = o.part)
,   start_date = o.start_date
,   field1 = o.field1
,   field2 = o.field2
,   show_on_shipper = o.show_on_shipper
,   tare_weight = o.tare_weight
,   kanban_number = o.kanban_number
,   dimension_qty_string = o.dimension_qty_string
,   dim_qty_string_other = o.dim_qty_string_other
,   varying_dimension_code = o.varying_dimension_code
from
	dbo.object o
where
	serial = @BreakoutSerial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Create 2nd breakout audit trail. (i1) */
--- <Insert rows="1">
set	@TableName = 'dbo.audit_trail'

insert
	dbo.audit_trail
(
	serial
,   date_stamp
,   type
,   part
,   quantity
,   remarks
,   price
,   salesman
,   customer
,   vendor
,   po_number
,   operator
,   from_loc
,   to_loc
,   on_hand
,   lot
,   weight
,   status
,   shipper
,   flag
,   activity
,   unit
,   workorder
,   std_quantity
,   cost
,   control_number
,   custom1
,   custom2
,   custom3
,   custom4
,   custom5
,   plant
,   invoice_number
,   notes
,   gl_account
,   package_type
,   suffix
,   due_date
,   group_no
,   sales_order
,   release_no
,   dropship_shipper
,   std_cost
,   user_defined_status
,   engineering_level
,   posted
,   parent_serial
,   origin
,   destination
,   sequence
,   object_type
,   part_name
,   start_date
,   field1
,   field2
,   show_on_shipper
,   tare_weight
,   kanban_number
,   dimension_qty_string
,   dim_qty_string_other
,   varying_dimension_code
)
select
	serial = o.serial
,   date_stamp = @TranDT
,   type = @BreakoutATType
,   part = o.part
,   quantity = o.quantity
,   remarks = @BreakoutATRemarks
,   price = 0
,   salesman = ''
,   customer = o.customer
,   vendor = ''
,   po_number = o.po_number
,   operator = @Operator
,   from_loc = o.location
,   to_loc = o.location
,   on_hand = dbo.udf_GetPartQtyOnHand(o.part)
,   lot = o.lot
,   weight = o.weight
,   status = o.status
,   shipper = o.shipper
,   flag = ''
,   activity = ''
,   unit = o.unit_measure
,   workorder = o.workorder
,   std_quantity = o.std_quantity
,   cost = o.cost
,   control_number = ''
,   custom1 = o.custom1
,   custom2 = o.custom2
,   custom3 = o.custom3
,   custom4 = o.custom4
,   custom5 = o.custom5
,   plant = o.plant
,   invoice_number = ''
,   notes = o.note
,   gl_account = ''
,   package_type = o.package_type
,   suffix = o.suffix
,   due_date = o.date_due
,   group_no = ''
,   sales_order = ''
,   release_no = ''
,   dropship_shipper = 0
,   std_cost = o.std_cost
,   user_defined_status = o.user_defined_status
,   engineering_level = o.engineering_level
,   posted = o.posted
,   parent_serial = o.parent_serial
,   origin = o.origin
,   destination = o.destination
,   sequence = o.sequence
,   object_type = o.type
,   part_name = (select name from part where part = o.part)
,   start_date = o.start_date
,   field1 = o.field1
,   field2 = o.field2
,   show_on_shipper = o.show_on_shipper
,   tare_weight = o.tare_weight
,   kanban_number = o.kanban_number
,   dimension_qty_string = o.dimension_qty_string
,   dim_qty_string_other = o.dim_qty_string_other
,   varying_dimension_code = o.varying_dimension_code
from
	dbo.object o
where
	serial = @Serial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

--- </Body>

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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_InventoryControl_Breakout
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
go


/*
Create procedure fx21stPilot.dbo.usp_MES_JCPreObject
*/

--use fx21stPilot
--go

if	objectproperty(object_id('dbo.usp_MES_JCPreObject'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_JCPreObject
end
go

create procedure dbo.usp_MES_JCPreObject
	@Operator varchar (10)
,	@PreObjectSerial int
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
/*	Operator required:  */
if	not exists
	(	select
			1
		from
			employee
		where
			operator_code = @Operator
	) begin

	set @Result = 60001
	RAISERROR ('Invalid operator code %s in procedure %s.  Error: %d', 16, 1, @Operator, @ProcName, @Error)
	rollback tran @ProcName
	return
end

if	coalesce
	(	(	select
				max(part)
			from
				audit_trail
			where
				serial = @PreObjectSerial
			)
	,	''
	) = 'PALLET' begin
	set @Result = 0
	rollback tran @ProcName
	return	@Result
end

/*	Serial must be a Pre-Object:  */
if	not exists
	(	select
			*
		from
			dbo.WorkOrderObjects
		where
			Serial = @PreObjectSerial
	) begin
	set @Result = 100101
	RAISERROR ('Invalid pre-object serial %d in procedure %s.  Error: %d', 16, 1, @PreObjectSerial, @ProcName, @Error)
	rollback tran @ProcName
	return
end

/*	If PreObject has already been Job Completed, do nothing:  */
if	exists
	(	select
			*
		from
			audit_trail
		where
			type = 'J'
			and serial = @PreObjectSerial
	) begin
	set	@Result = 100100
	RAISERROR ('Serial %d already job completed in procedure %s.  Warning: %d', 10, 1, @PreObjectSerial, @ProcName, @Error)
	rollback tran @ProcName
	return
end

/*	Quantity must be valid:  */
declare
	@QtyRequested numeric(20,6)

select
	@QtyRequested = woo.Quantity
from
	dbo.WorkOrderObjects woo
where
	woo.Serial = @PreObjectSerial

if	not coalesce(@QtyRequested, 0) > 0 begin
	set @Result = 202001
	RAISERROR ('Invalid quantity requested %d in procedure %s.  Error: %d', 16, 1, @QtyRequested, @ProcName, @Error)
	rollback tran @ProcName
	return
end

/*	WOD ID must be valid:  */
declare
	@WODID int
,	@Part varchar(25)

select
	@WODID = wod.RowID
,	@Part = woo.PartCode
from
	dbo.WorkOrderObjects woo
	join dbo.WorkOrderDetails wod
		on wod.WorkOrderNumber = woo.WorkOrderNumber
		and wod.Line = woo.WorkOrderDetailLine
where
	woo.Serial = @PreObjectSerial

if	not exists
	(	select
			*
		from
			dbo.WorkOrderDetails wod
		where
			wod.RowID = @WODID
	) begin

	set @Result = 200101
	RAISERROR ('Invalid job id %d in procedure %s.  Error: %d', 16, 1, @WODID, @ProcName, @Error)
	rollback tran @ProcName
	return
end

declare
	@Machine varchar(10)

select
	@Machine = woh.MachineCode
from
	dbo.WorkOrderDetails wod
	join dbo.WorkOrderHeaders woh
		on woh.WorkOrderNumber = wod.WorkOrderNumber
where
	wod.RowID = @WODID
---	</ArgumentValidation>

--- <Body>
/*	If this box has been deleted, recreate it.  */
if	not exists
	(	select
			*
		from
			dbo.object o
		where
			o.serial = @PreObjectSerial
	) begin

	--- <Insert rows="1">
	set	@TableName = 'dbo.object'
	
		insert 
			dbo.object
		(	serial
		,	part
		,	location
		,	last_date
		,	unit_measure
		,	operator
		,	status
		,	quantity
		,	plant
		,	std_quantity
		,	last_time
		,	user_defined_status
		,	type
		,	po_number 
		)
		select
			woo.Serial
		,	woo.PartCode
		,	location = @Machine
		,	last_date = @TranDT
		,	(	select
					pi.standard_unit
				from
					dbo.part_inventory pi
				where
					pi.part = woo.PartCode
			)
		,	@Operator
		,	'H'
		,	woo.Quantity
		,	(	select
					l.plant
				from
					dbo.location l
				where
					l.code = @Machine
			)
		,	woo.Quantity
		,	last_time = @TranDT
		,	'PRESTOCK'
		,	null
		,	null
		from
			dbo.WorkOrderObjects woo
		where
			woo.Serial = @PreObjectSerial
	
	select
		@Error = @@Error,
		@RowCount = @@Rowcount
	
	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount != 1 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Insert>
end

/*	Write job complete.  */
/*		Update object status, location, plant, operator, work order, cost, and completion date.  */
--- <Update rows="1">
set	@TableName = 'dbo.object'

update
	o
set 
	status = 'A'
,	user_defined_status = 'Approved'
,	last_date = @TranDT
,	last_time = @TranDT
,	location = @Machine
,	plant = (
			 select
				plant
			 from
				location
			 where
				code = @Machine
			)
,	operator = @Operator
,	workorder = @WODID
,	cost = (
			select
				cost_cum
			from
				dbo.part_standard
			where
				part = o.part
			)
,	std_cost = (
				select
					cost_cum
				from
					dbo.part_standard
				where
					part = o.part
				)
from
	dbo.object o
where
	o.serial = @PreObjectSerial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error updating %s in procedure %s.  Rows Updated: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Update>

/*		Update part on hand quantity.  */
--- <Update rows="1">
set	@TableName = 'dbo.part_online'

update
	po
set 
	on_hand =
	(	select
			sum(o2.std_quantity)
		from
			object o2
		where
			o2.part = po.part
			and o2.status = 'A'
	)
from
	dbo.part_online po
	join dbo.object o
		on o.part = po.part
where
	o.serial = @PreObjectSerial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	--- <Insert rows="1">
	set	@TableName = 'dbo.part_online'
	
	insert
		dbo.part_online
	(	part
	,	on_hand
	)
	select
		part = o.part
	,	on_hand = sum(o.std_quantity)
	from
		dbo.object o
	where
		o.part =
		(	select
				o2.part
			from
				dbo.object o2
			where
				o2.serial = @PreObjectSerial
		)
		and status = 'A'
	group by
		o.part
	
	select
		@Error = @@Error,
		@RowCount = @@Rowcount
	
	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount != 1 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Insert>
end
--- </Update>

/*		Create back flush header.  */
--- <Insert rows="1">
set	@TableName = 'dbo.BackflushHeaders'

insert
	dbo.BackflushHeaders
(	TranDT
,	WorkOrderNumber
,	WorkOrderDetailLine
,	MachineCode
,	PartProduced
,	SerialProduced
,	QtyProduced
)
select
	@TranDT
,	wod.WorkOrderNumber
,	wod.Line
,	woh.MachineCode
,	wod.PartCode
,	@PreObjectSerial
,	@QtyRequested
from
	dbo.WorkOrderDetails wod
	join dbo.WorkOrderHeaders woh
		on woh.WorkOrderNumber = wod.WorkOrderNumber
where
	wod.RowID = @WODID

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

declare
	@NewBackflushNumber varchar(50)

set	@NewBackflushNumber =
	(	select
	 		bh.BackflushNumber
	 	from
	 		dbo.BackflushHeaders bh
	 	where
	 		bh.RowID = scope_identity()
	 )

/*		Insert audit_trail.  */
--- <Insert rows="1">
set	@TableName = 'dbo.audit_trail'

insert
	dbo.audit_trail
(	serial
,	date_stamp
,	type
,	part
,	quantity
,	remarks
,	price
,	operator
,	from_loc
,	to_loc
,	on_hand
,	lot
,	weight
,	status
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
,	gl_account
,	std_cost
,	group_no
,	user_defined_status
,	part_name
,	tare_weight
)
select
	serial = o.serial
,	date_stamp = @TranDT
,	type = 'J'
,	part = o.part
,	quantity = o.quantity
,	remarks = 'Job comp'
,	price = 0
,	operator = o.operator
,	from_loc = o.location
,	to_loc = o.location
,	on_hand = coalesce(po.on_hand, 0) +
		case	when o.status = 'A' then o.std_quantity
				else 0
		end
,	lot = o.lot
,	weight = o.weight
,	status = o.status
,	unit = o.unit_measure
,	workorder = o.workorder
,	std_quantity = o.std_quantity
,	cost = o.cost
,	custom1 = o.custom1
,	custom2 = o.custom2
,	custom3 = o.custom3
,	custom4 = o.custom4
,	custom5 = o.custom5
,	plant = o.plant
,	notes = ''
,	gl_account = ''
,	std_cost = o.cost
,	group_no = right(@NewBackflushNumber, 10)
,	user_defined_status = o.user_defined_status
,	part_name = o.name
,	tare_weight = o.tare_weight
from
	dbo.object o
	left join dbo.part_online po
		on po.part = o.part
	join dbo.part p
		on p.part = o.part
where
	o.serial = @PreObjectSerial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Perform back flush.  */
--execute @ProcReturn = dbo.usp_MES_Backflush
--	@Operator = @Operator
--,	@BFID = @NewBFID
--,	@TranDT = @TranDT out
--,	@Result = @ProcResult out

set @Error = @@Error
if @ProcResult != 0 
	begin
		set @Result = 999999
		raiserror ('An error result was returned from the procedure %s', 16, 1, 'ProdControl_BackFlush')
		rollback tran @ProcName
		return	@Result
	end
if @ProcReturn != 0 
	begin
		set @Result = 999999
		raiserror ('An error was returned from the procedure %s', 16, 1, 'ProdControl_BackFlush')
		rollback tran @ProcName
		return	@Result
	end
if @Error != 0 
	begin
		set @Result = 999999
		raiserror ('An error occurred during the execution of the procedure %s', 16, 1, 'ProdControl_BackFlush')
		rollback tran @ProcName
		return	@Result
	end

/*	Update Work Order.  */
--- <Update rows="1">
set	@TableName = 'dbo.WorkOrderObjects'

update
	woo
set 
	Status = 2 -- Change to a constant.
,	CompletionDT = @TranDT
,	BackflushNumber = @NewBackflushNumber
,	UndoBackflushNumber = null
from
	dbo.WorkOrderObjects woo
where
	woo.Serial = @PreObjectSerial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error updating %s in procedure %s.  Rows Updated: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Update>

--- <Update rows="*">
set	@TableName = 'dbo.WorkOrderDetails'

update
	wod
set 
	QtyCompleted = QtyCompleted + @QtyRequested
from
	dbo.WorkOrderDetails wod
where
	RowID = @WODID

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

--- <CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
--- </CloseTran Required=Yes AutoCreate=Yes>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries
{
select
	*
from
	dbo.WorkOrderObjects woo
}

Test syntax
{

set statistics io on
set statistics time on
go

declare
	@Operator varchar(10)
,	@PreObjectSerial int

set	@Operator = 'ES'
set	@PreObjectSerial = 791622

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_JCPreObject
	@Operator = @Operator
,	@PreObjectSerial = @PreObjectSerial
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

select
	*
from
	BackFlushHeaders
where
	SerialProduced = @PreObjectSerial

select
	BackFlushDetails.*
from
	BackFlushDetails
	join BackFlushHeaders
		on BackFlushHeaders.ID = BackFlushDetails.BFID
where
	SerialProduced = @PreObjectSerial

select
	*
from
	audit_trail
where
	date_stamp = @TranDT

select	*
from	audit_trail
where	date_stamp >= DateAdd (n, -1, getdate()) and
	serial in
	(	select	SerialConsumed
		from	BackFlushDetails
			join BackFlushHeaders on BackFlushHeaders.ID = BackFlushDetails.BFID
		where	SerialProduced = @PreObjectSerial)

select
	*
from
	object
where
	serial = @PreObjectSerial

select
	*
from
	object
where
	serial in
	(	select
			SerialConsumed
		from
			BackFlushDetails
			join BackFlushHeaders
				on BackFlushHeaders.ID = BackFlushDetails.BFID
		where
			SerialProduced = @PreObjectSerial
	)
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
go


/*
Create procedure fx21stPilot.dbo.usp_MES_AllocateSerial
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_AllocateSerial'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_AllocateSerial
end
go

create procedure dbo.usp_MES_AllocateSerial
	@Operator varchar(5)
,	@Serial int
,	@WODID int = null
,	@WorkOrderNumber varchar(50) = null
,	@WorkOrderDetailSequence int = null
,	@Plant varchar(10) = null
,	@MachineCode varchar(10) = null
,	@Suffix int = null
,	@QtyBreakout numeric(20,6) = null
,	@BreakoutSerial int = null out
,	@TranDT datetime out
,	@Result integer out
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
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
/*	Perform breakout if necessary. */
if	@QtyBreakout > 0 begin
/*		Perform breakout (dbo.usp_InventoryControl_Breakout) */
	--- <Call>	
	set	@CallProcName = 'dbo.usp_InventoryControl_Breakout'
	execute
		@ProcReturn = dbo.usp_InventoryControl_Breakout
		@Operator = @Operator
	,	@Serial = @Serial
	,	@QtyBreakout = @QtyBreakout
	,	@BreakoutSerial = @BreakoutSerial out
	,	@TranDT = @TranDT out
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
	
/*		Use breakout serial for remainder of transaction. */
	set @Serial = @BreakoutSerial
end

/*	Create material allocation record(s). (i1+) */
--- <Insert rows="*">
set	@TableName = 'dbo.object'

insert
	dbo.WorkOrderDetailMaterialAllocations
(
	WorkOrderNumber
,	WorkOrderDetailLine
,	WorkOrderDetailBillOfMaterialLine
,	AllocationDT
,	Serial
,	Status
,	Type
,	QtyOriginal
,	QtyBegin
,	QtyIssued
,	QtyPer
,	AllowablePercentOverage
)
select
	WorkOrderNumber = wodbom.WorkOrderNumber
,	WorkOrderDetailLine = wodbom.WorkOrderDetailLine
,	WorkOrderDetailBillOfMaterialLine = wodbom.Line
,	AllocationDT = @TranDT
,	Serial = @Serial
,	Status = dbo.udf_StatusValue('dbo.WorkOrderDetailMaterialAllocations', 'New')
,	Type = dbo.udf_TypeValue('dbo.WorkOrderDetailMaterialAllocations', 'Serial')
,	QtyOriginal = (select max(std_quantity) from audit_trail where serial = @Serial and date_stamp = (select min(date_stamp) from dbo.audit_trail where serial = @Serial))
,	QtyBegin = 
	case
		when not exists (select * from dbo.WorkOrderDetailMaterialAllocations where Status = dbo.udf_TypeValue('dbo.WorkOrderDetailMaterialAllocations', 'Serial') and Serial = @Serial and AllocationEndDT is null)
			then o.std_quantity
	end
,	QtyIssued = 0
,	QtyPer = wodbom.QtyPer
,	AllowablePercentOverage = null
from
	dbo.WorkOrderDetails wod
	join dbo.WorkOrderDetailBillOfMaterials wodbom on
		wod.WorkOrderNumber = wodbom.WorkOrderNumber
		and
			wod.Line = wodbom.WorkOrderDetailLine
		and
			coalesce(wodbom.Suffix, -1) = coalesce(@Suffix, -1)
	join dbo.object o on
		o.serial = @Serial
		and
			o.status = 'A'
		and
			wodbom.ChildPart = o.part
where
	wod.WorkOrderNumber = @WorkOrderNumber
	and
		wod.Sequence = @WorkOrderDetailSequence
	and
		not exists
		(	select
				*
			from
				dbo.WorkOrderDetailMaterialAllocations wodma
				join dbo.WorkOrderDetailBillOfMaterials wodbom2 on
					wodma.WorkOrderNumber = wodbom2.WorkOrderNumber
					and
						wodma.WorkOrderDetailLine = wodbom2.WorkOrderDetailLine
					and
						wodma.WorkOrderDetailBillOfMaterialLine = wodbom2.Line
				join dbo.WorkOrderDetails wod2 on
					wodma.WorkOrderNumber = wod2.WorkOrderNumber
					and
						wodma.WorkOrderDetailLine = wod2.Line
			where
				wod2.WorkOrderNumber = @WorkOrderNumber
				and
					wod2.Sequence = @WorkOrderDetailSequence
				and
					coalesce(wodbom2.Suffix, -1) = coalesce(@Suffix, -1)
				and
					wodma.Serial = @Serial
		)

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Read material location. */
declare
	@materialLocation varchar(10)

set
	@materialLocation = (select location from dbo.object where serial = @Serial)

/*	Transfer object to department, staging location, or machine. (u1) */
--- <Update rows="1">
set	@TableName = 'dbo.object'

update
	o
set
	o.location = l.code
,	o.plant = l.plant
from
	dbo.object o
	join dbo.location l on
		l.code = coalesce
		(	(	select
					MachineCode
				from
					dbo.WorkOrderHeaders woh
				where
					WorkOrderNumber = @WorkOrderNumber
			)
		,	@Plant
		)
where
	o.serial = @Serial
	and
		o.status = 'A'

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error updating %s in procedure %s.  Rows Updated: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Update>

/*	Create allocation audit trail. (i1)*/
declare
	@tranType char(1)
,	@remarks varchar(10)

set	@tranType = 'T'
set	@remarks = 'ALLOCATE'

--- <Insert rows="1">
set	@TableName = 'dbo.audit_trail'

insert
	dbo.audit_trail
(
	serial, date_stamp, type, part, quantity
,	remarks, operator, from_loc, to_loc, on_hand
,	lot, weight, status, unit, workorder
,	std_quantity, cost
,	custom1, custom2, custom3, custom4, custom5
,	plant, package_type, suffix, std_cost
,	user_defined_status, engineering_level, parent_serial, origin
,	object_type, part_name, field1, field2, tare_weight
)
select
	serial = o.serial, date_stamp = @TranDT, type = @tranType, part = o.part, quantity = o.quantity
,	remarks = @remarks, operator = @Operator, from_loc = @materialLocation, to_loc = o.location, on_hand = (select on_hand from dbo.part_online where part = o.part)
,	lot = o.lot, weight = o.weight, status = o.status, unit = o.unit_measure, workorder = @WorkOrderNumber
,	std_quantity = o.std_quantity, cost = o.cost
,	custom1 = o.custom1, custom2 = o.custom2, custom3 = o.custom3, custom4 = o.custom4, custom5 = o.custom5
,	plant = o.plant, package_type = o.package_type, suffix = @Suffix, std_cost = ps.cost_cum
,	user_defined_status = o.user_defined_status, engineering_level = o.engineering_level, parent_serial = o.parent_serial, origin = o.origin
,	object_type = o.type, part_name = p.name, field1 = o.field1, field2 = o.field2, tare_weight = o.tare_weight
from
	dbo.object o
	left join dbo.part p on
		o.part = p.part
	left join dbo.part_standard ps on
		o.part = ps.part
where
	serial = @Serial
	and
		status = 'A'
	
select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

--- </Body>

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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_AllocateSerial
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
go



/*
Create procedure fx21st.dbo.usp_MES_AllocateSerial_toDepartment
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_AllocateSerial_toDepartment'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_AllocateSerial_toDepartment
end
go

create procedure dbo.usp_MES_AllocateSerial_toDepartment
	@Operator varchar(5)
,	@Serial int
,	@Department varchar(10)
,	@QtyBreakout numeric(20,6) = null
,	@BreakoutSerial int = null out
,	@TranDT datetime out
,	@Result integer out
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
--- <Call>	
set	@CallProcName = 'dbo.usp_MES_AllocateSerial'
execute
	@ProcReturn = dbo.usp_MES_AllocateSerial
	@Operator = @Operator
,	@Serial = @Serial
,	@Plant = @Department
,	@QtyBreakout = @QtyBreakout
,	@BreakoutSerial = @BreakoutSerial out
,	@TranDT = @TranDT out
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

--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_AllocateSerial_toDepartment
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
go


/*
Create procedure fx21st.dbo.usp_MES_AllocateSerial_toJobID
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_AllocateSerial_toJobID'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_AllocateSerial_toJobID
end
go

create procedure dbo.usp_MES_AllocateSerial_toJobID
	@Operator varchar(5)
,	@Serial int
,	@JobID varchar(10)
,	@QtyBreakout numeric(20,6) = null
,	@BreakoutSerial int = null out
,	@TranDT datetime out
,	@Result integer out
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
--- <Call>	
set	@CallProcName = 'dbo.usp_MES_AllocateSerial'
execute
	@ProcReturn = dbo.usp_MES_AllocateSerial
	@Operator = @Operator
,	@Serial = @Serial
,	@WODID = @JobID
,	@QtyBreakout = @QtyBreakout
,	@BreakoutSerial = @BreakoutSerial out
,	@TranDT = @TranDT out
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

--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_AllocateSerial_toJobID
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
go


/*
Create procedure fx21st.dbo.usp_MES_AllocateSerial_toMachine
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_AllocateSerial_toMachine'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_AllocateSerial_toMachine
end
go

create procedure dbo.usp_MES_AllocateSerial_toMachine
	@Operator varchar(5)
,	@Serial int
,	@MachineCode varchar(10)
,	@QtyBreakout numeric(20,6) = null
,	@BreakoutSerial int = null out
,	@TranDT datetime out
,	@Result integer out
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
--- <Call>	
set	@CallProcName = 'dbo.usp_MES_AllocateSerial'
execute
	@ProcReturn = dbo.usp_MES_AllocateSerial
	@Operator = @Operator
,	@Serial = @Serial
,	@MachineCode = @MachineCode
,	@QtyBreakout = @QtyBreakout
,	@BreakoutSerial = @BreakoutSerial out
,	@TranDT = @TranDT out
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

--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_AllocateSerial_toMachine
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
go


/*
Create procedure fx21st.dbo.usp_MES_AllocateSerial_toStagingLocation
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_AllocateSerial_toStagingLocation'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_AllocateSerial_toStagingLocation
end
go

create procedure dbo.usp_MES_AllocateSerial_toStagingLocation
	@Operator varchar(5)
,	@Serial int
,	@StagingLocation varchar(10)
,	@QtyBreakout numeric(20,6) = null
,	@BreakoutSerial int = null out
,	@TranDT datetime out
,	@Result integer out
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
--- <Call>	
set	@CallProcName = 'dbo.usp_MES_AllocateSerial'
execute
	@ProcReturn = dbo.usp_MES_AllocateSerial
	@Operator = @Operator
,	@Serial = @Serial
,	@MachineCode = @StagingLocation
,	@QtyBreakout = @QtyBreakout
,	@BreakoutSerial = @BreakoutSerial out
,	@TranDT = @TranDT out
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

--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_AllocateSerial_toStagingLocation
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
go


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

/*
Create procedure fx21st.dbo.usp_MES_GetAllocationDepartmentList_byComponentPart
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_GetAllocationDepartmentList_byComponentPart'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_GetAllocationDepartmentList_byComponentPart
end
go

create procedure dbo.usp_MES_GetAllocationDepartmentList_byComponentPart
	@ComponentPart varchar(25)
,	@TranDT datetime = null out
,	@Result integer = null out
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
set	@TranDT = coalesce(@TranDT, getdate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
select distinct
	Department = coalesce(l.group_no, l.plant)
from
	dbo.MES_PickList mpl
	join dbo.location l
		on l.code = mpl.MachineCode
where
	mpl.ChildPart = @ComponentPart

--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@ComponentPart varchar(25)
	
set	@ComponentPart = 'PPC4GF2.5 NAT'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_GetAllocationDepartmentList_byComponentPart
	@ComponentPart = @ComponentPart
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
go


/*
Create procedure fx21st.dbo.usp_MES_GetAllocationMachineList_byComponentPart
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_GetAllocationMachineList_byComponentPart'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_GetAllocationMachineList_byComponentPart
end
go

create procedure dbo.usp_MES_GetAllocationMachineList_byComponentPart
	@ComponentPart varchar(25)
,	@TranDT datetime = null out
,	@Result integer = null out
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
set	@TranDT = coalesce(@TranDT, getdate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
select distinct
	Machine = l.code
from
	dbo.MES_PickList mpl
	join dbo.location l
		on l.code = mpl.MachineCode
where
	mpl.ChildPart = @ComponentPart

--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@ComponentPart varchar(25)
	
set	@ComponentPart = 'PPC4GF2.5 NAT'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_GetAllocationMachineList_byComponentPart
	@ComponentPart = @ComponentPart
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
go


/*
Create procedure fx21st.dbo.usp_MES_GetAllocationStagingLocationList_byComponentPart
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_GetAllocationStagingLocationList_byComponentPart'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_GetAllocationStagingLocationList_byComponentPart
end
go

create procedure dbo.usp_MES_GetAllocationStagingLocationList_byComponentPart
	@ComponentPart varchar(25)
,	@TranDT datetime = null out
,	@Result integer = null out
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
set	@TranDT = coalesce(@TranDT, getdate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
select distinct
	StagingLocation = l.code
from
	dbo.MES_PickList mpl
	join dbo.location l
		on l.code = mpl.MachineCode
where
	mpl.ChildPart = @ComponentPart

--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@ComponentPart varchar(25)
	
set	@ComponentPart = 'PPC4GF2.5 NAT'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_GetAllocationStagingLocationList_byComponentPart
	@ComponentPart = @ComponentPart
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
go


/*
Create procedure fx21st.dbo.usp_MES_GetBackflushingDetails_bySerial
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_GetBackflushingDetails_bySerial'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_GetBackflushingDetails_bySerial
end
go

create procedure dbo.usp_MES_GetBackflushingDetails_bySerial
	@PickSerial int
,	@TranDT datetime = null out
,	@Result integer = null out
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
select
	Part = o.part
,	BackflushingPrinciple = 'Department'
,	QtyRequired = (select sum(mcs.QtyRequired) from dbo.MES_PickList mcs where mcs.ChildPart = o.part)
,	QtyAvailable = o.std_quantity
from
	dbo.object o
where
	o.serial = @PickSerial
union
select
	Part = at.part
,	BackflushingPrinciple = 'Department'
,	QtyRequired = (select sum(mcs.QtyRequired) from dbo.MES_PickList mcs where mcs.ChildPart = at.part)
,	QtyAvailable = at.std_quantity
from
	dbo.audit_trail at
where
	at.serial = @PickSerial
	and at.type = 'R'
	
--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@PickSerial int

set	@PickSerial = 1760004

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_GetBackflushingDetails_bySerial
	@PickSerial = @PickSerial
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
go


/*
Create procedure fx21st.dbo.usp_MES_GetJobDetails
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_GetJobDetails'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_GetJobDetails
end
go

create procedure dbo.usp_MES_GetJobDetails
	@WODID int
,	@TranDT datetime = null out
,	@Result integer = null out
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
select
	mjl.WODID
,	mjl.PartCode
,	BoxesRequired = mjl.NewBoxesRequired + mjl.BoxesLabelled
,	mjl.BoxesLabelled
,	mjl.BoxesCompleted
from
	dbo.MES_JobList mjl
where
	mjl.WODID = @WODID

--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_GetJobDetails
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
go


/*
Create procedure fx21st.dbo.usp_MES_GetJobList
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_GetJobList'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_GetJobList
end
go

create procedure dbo.usp_MES_GetJobList
	@TranDT datetime = null out
,	@Result integer = null out
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
select
	mjl.WODID
,	mjl.PartCode
,	BoxesRequired = mjl.NewBoxesRequired + mjl.BoxesLabelled
,	mjl.BoxesLabelled
,	mjl.BoxesCompleted
from
	dbo.MES_JobList mjl

--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_GetJobList
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
go


/*
Create procedure fx21st.dbo.usp_MES_GetPickList
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_GetPickList'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_GetPickList
end
go

create procedure dbo.usp_MES_GetPickList
	@TranDT datetime = null out
,	@Result integer = null out
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
select
	WODID
,	MachineCode
,	PartCode
,	ChildPart
,	QtyRequired
,	QtyAvailable
,	QtyToPull
,	FIFOLocation
,	ProductLine
,	Commodity
,	PartName
from
	dbo.MES_PickList pl
order by
	Commodity
--- </Body>

---	<Return>
if	@TranCount = 0 begin
	commit tran @ProcName
end
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
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_GetPickList
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
go


/*
Create procedure fx21st.dbo.usp_MES_GetScrapEntries_byWODID
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_GetScrapEntries_byWODID'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_GetScrapEntries_byWODID
end
go

create procedure dbo.usp_MES_GetScrapEntries_byWODID
	@WODID int
,	@TranDT datetime = null out
,	@Result integer = null out
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
select
	d.WODID
,	d.DefectSerial
,	d.Part
,	d.DefectCode
,	QtyScrapped = sum(d.QtyScrapped)
from
	dbo.Defects d
where
	d.WODID = @WODID
group by
	d.WODID
,	d.DefectSerial
,	d.Part
,	d.DefectCode

--- <CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
--- </CloseTran Required=Yes AutoCreate=Yes>

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
	@WODID int

set	@WODID = 6

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_GetScrapEntries_byWODID
	@WODID = @WODID
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
go


/*
Create procedure fx21st.dbo.usp_MES_NewExcessQty
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_NewExcessQty'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_NewExcessQty
end
go

create procedure dbo.usp_MES_NewExcessQty
	@Operator varchar(5)
,	@WODID int
,	@Serial int
,	@QtyExcess numeric (20,6)
,	@ExcessReason varchar(255)
,	@TranDT datetime out
,	@Result integer out
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
/*	Recreate object if necessary. */
if	not exists
	(	select
			*
		from
			dbo.object o
		where
			serial = @Serial
	) begin

	--- <Insert rows="1">
	set	@TableName = 'dbo.object'
	
	insert
		dbo.object
	(	serial
	,	part
	,	location
	,	last_date
	,	quantity
	,	po_number
	,	operator
	,	lot
	,	weight
	,	status
	,	shipper
	,	unit_measure
	,	workorder
	,	std_quantity
	,	cost
	,	custom1
	,	custom2
	,	custom3
	,	custom4
	,	custom5
	,	plant
	,	package_type
	,	suffix
	,	date_due
	,	std_cost
	,	user_defined_status
	,	engineering_level
	,	parent_serial
	,	origin
	,	destination
	,	sequence
	,	type
	,	name
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
		serial = atLasttrans.serial
	,	part = atLasttrans.part
	,	location = 'Qty Excess'
	,	last_date = @TranDT
	,	quantity = @QtyExcess
	,	po_number = atLasttrans.po_number
	,	operator = @Operator
	,	lot = atLasttrans.lot
	,	weight = atLasttrans.weight
	,	status = 'S'
	,	shipper = atLasttrans.shipper
	,	unit = atLasttrans.unit
	,	workorder = convert (varchar, @WODID)
	,	std_quantity = @QtyExcess
	,	cost = atLasttrans.cost
	,	custom1 = atLasttrans.custom1
	,	custom2 = atLasttrans.custom2
	,	custom3 = atLasttrans.custom3
	,	custom4 = atLasttrans.custom4
	,	custom5 = atLasttrans.custom5
	,	plant = atLasttrans.plant
	,	package_type = atLasttrans.package_type
	,	suffix = atLasttrans.suffix
	,	date_due = atLasttrans.due_date
	,	std_cost = atLasttrans.std_cost
	,	user_defined_status = 'Scrap'
	,	engineering_level = atLasttrans.engineering_level
	,	parent_serial = atLasttrans.parent_serial
	,	origin = atLasttrans.origin
	,	destination = atLasttrans.destination
	,	sequence = atLasttrans.sequence
	,	type = atLasttrans.object_type
	,	name = atLasttrans.part_name
	,	start_date = atLasttrans.start_date
	,	field1 = atLasttrans.field1
	,	field2 = atLasttrans.field2
	,	show_on_shipper = atLasttrans.show_on_shipper
	,	tare_weight = atLasttrans.tare_weight
	,	kanban_number = atLasttrans.kanban_number
	,	dimension_qty_string = atLasttrans.dimension_qty_string
	,	dim_qty_string_other = atLasttrans.dim_qty_string_other
	,	varying_dimension_code = atLasttrans.varying_dimension_code
	from
		audit_trail atLasttrans
		join part_online
			on atLasttrans.part = part_online.part
	where
		atLasttrans.serial = @Serial
		and atLasttrans.id =
		(	select
				max(id)
			from
				dbo.audit_trail at
			where
				serial = @Serial
		)
	
	select
		@Error = @@Error,
		@RowCount = @@Rowcount
	
	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount != 1 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Insert>
else
	--- <Update rows="1">
	set	@TableName = 'dbo.object'
	
	update
		o
	set
		quantity = o.quantity + @QtyExcess
	,	std_quantity = o.std_quantity + @QtyExcess
	from
		dbo.object o
	where
		serial = @Serial
	
	select
		@Error = @@Error,
		@RowCount = @@Rowcount
	
	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount != 1 begin
		set	@Result = 999999
		RAISERROR ('Error updating %s in procedure %s.  Rows Updated: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Update>
end

/*	Create excess audit trail.*/
--- <Insert rows="1">
set	@TableName = 'dbo.audit_trail'

insert
	dbo.audit_trail
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
,	quantity = @QtyExcess
,	remarks = 'Qty Excess'
,	po_number = object.po_number
,	operator = @Operator
,	from_loc = object.location
,	to_loc = 'Scrap'
,	on_hand = part_online.on_hand + @QtyExcess
,	lot = object.lot
,	weight = object.weight
,	status = 'S'
,	shipper = object.shipper
,	unit = object.unit_measure
,	workorder = convert (varchar, @WODID)
,	std_quantity = @QtyExcess
,	cost = object.cost
,	custom1 = object.custom1
,	custom2 = object.custom2
,	custom3 = object.custom3
,	custom4 = object.custom4
,	custom5 = object.custom5
,	plant = object.plant
,	notes = @ExcessReason
,	package_type = object.package_type
,	suffix = object.suffix
,	due_date = object.date_due
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
    object
    join part_online
        on object.part = part_online.part
where
    object.serial = @Serial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>
declare
	@excessAuditTrailID int

set	@excessAuditTrailID = SCOPE_IDENTITY() 

/*	Create excess defect (negative).  */
--- <Insert rows="1">
set	@TableName = 'dbo.Defects'

insert
	dbo.Defects
(	TransactionDT
,	Machine
,	Part
,	DefectCode
,	QtyScrapped
,	Operator
,	Shift
,	WODID
,	DefectSerial
,	AuditTrailID
)
select
	TransactionDT = @TranDT
,	Machine = woh.MachineCode
,	Part = o.part
,	DefectCode = 'Qty Excess'
,	QtyScrapped = -@QtyExcess
,	Operator = @Operator
,	Shift = 0 --Refactor
,	WODID = @WODID
,	DefectSerial = @Serial
,	@excessAuditTrailID
from
    dbo.object o
    join dbo.WorkOrderHeaders woh
		join dbo.WorkOrderDetails wod
			on wod.WorkOrderNumber = woh.WorkOrderNumber
		on wod.RowID = @WODID
where
    o.serial = @Serial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>
--- </Body>

--- <CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
--- </CloseTran Required=Yes AutoCreate=Yes>

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
	@Operator varchar(5)
,	@WODID int
,	@Serial int
,	@QtyExcess numeric (20,6)
,	@ExcessReason varchar(255)

set	@Operator = 'mon'
set	@WODID = '6'
set	@Serial = -1
set	@QtyExcess = 100
set	@ExcessReason = 'Excess due to backflush.'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_NewExcessQty
	@Operator = @Operator
,	@WODID = @WODID
,	@Serial = @Serial
,	@QtyExcess = @QtyExcess
,	@ExcessReason = @ExcessReason
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
go


/*
Create procedure fx21stPilot.dbo.usp_MES_NewPreObject
*/

--use fx21stPilot
--go

if	objectproperty(object_id('dbo.usp_MES_NewPreObject'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_NewPreObject
end
go

create procedure dbo.usp_MES_NewPreObject
	@Operator varchar (10)
,	@WODID int
,	@Boxes int
,	@QtyBox int = null
,	@FirstNewSerial int out
,	@TranDT datetime out
,	@Result integer out
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
/*	Operator required:  */
if	not exists
	(	select
			1
		from
			employee
		where
			operator_code = @Operator
	) begin

	set @Result = 60001
	RAISERROR ('Invalid operator code %s in procedure %s.  Error: %d', 16, 1, @Operator, @ProcName, @Error)
	rollback tran @ProcName
	return
end

/*	WOD ID must be valid:  */
declare	@Part varchar (25)
select
	@Part =	PartCode
from
	dbo.WorkOrderDetails wod
where
	RowID = @WODID

if	@@RowCount != 1 or @@Error != 0 begin
	
	set	@Result = 200101
	RAISERROR ('Invalid job id %d in procedure %s.  Error: %d', 16, 1, @WODID, @ProcName, @Error)
	rollback tran @ProcName
	return
end

/*	Part valid:  */
if	not exists
	(	select	1
		from	part
		where	part = @Part) begin

	set	@Result = 70001
	RAISERROR ('Invalid part %s for job id %d in procedure %s.  Error: %d', 16, 1, @Part, @WODID, @ProcName, @Error)
	rollback tran @ProcName
	return
end
---	</ArgumentValidation>

--- <Body>
declare
	@Status char(1)
,	@UserStatus varchar(10)
,	@ObjectType char(1)
,	@TranType char(1)
,	@Remark varchar(10)
,	@Notes varchar(50)
,	@AssemblyPreObjectLocation varchar(10)

set	@Status = 'H'
set	@UserStatus = 'PRESTOCK'
set	@ObjectType = null
set	@TranType = 'P'
set	@Remark = 'PRE-OBJECT'
set	@Notes = 'Pre-object.'
set	@AssemblyPreObjectLocation = 'PRE-OBJECT'

/*	Get block of serial numbers for pre-objects. */
--- <Call>	
set	@CallProcName = 'monitor.usp_NewSerialBlock'
execute
	@ProcReturn = monitor.usp_NewSerialBlock
		@SerialBlockSize = @Boxes
	,	@FirstNewSerial = @FirstNewSerial out
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

/*	Create new object(s). */
--- <Insert rows="n">
set	@TableName = 'dbo.object'

insert
	dbo.object
(	serial
,	part
,	location
,	last_date
,	unit_measure
,	operator
,	status
,	quantity
,	plant
,	std_quantity
,	last_time
,	user_defined_status
,	type
,	workorder
)
select
	@FirstNewSerial + r.RowNumber - 1
,	@Part
,	l.code
,	@TranDT
,	pi.standard_unit
,	@Operator
,	@Status
,	@QtyBox
,	l.plant
,	@QtyBox
,	@TranDT
,	@UserStatus
,	@ObjectType
,	@WODID
from
	dbo.part_inventory pi
	join dbo.location l
		on l.code = @AssemblyPreObjectLocation
	cross join dbo.udf_Rows(@Boxes) r
where
	pi.part = @Part

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != @Boxes begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: %d.', 16, 1, @TableName, @ProcName, @RowCount, @Boxes)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Create new audit trail.  */
--- <Insert rows="n">
set	@TableName = 'dbo.audit_trail'

insert
	dbo.audit_trail
(	serial
,	date_stamp
,	type
,	part
,	quantity
,	remarks
,	operator
,	from_loc
,	to_loc
,	lot
,	weight
,	status
,	unit
,	std_quantity
,	plant
,	notes
,	package_type
,	std_cost
,	user_defined_status
,	tare_weight
,	workorder
)	
select
	o.serial
,	o.last_date
,	@TranType
,	o.part
,	o.quantity
,	@Remark
,	o.operator
,	o.location
,	o.location
,	o.lot
,	o.weight
,	o.status
,	o.unit_measure
,	o.std_quantity
,	o.plant
,	@Notes
,	o.package_type
,	o.cost
,	o.user_defined_status
,	o.tare_weight
,	o.workorder
from
	dbo.object o
where
	o.serial between @FirstNewSerial and @FirstNewSerial + @Boxes - 1

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != @Boxes begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: %d.', 16, 1, @TableName, @ProcName, @RowCount, @Boxes)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Create new pre-object history.  */
--- <Insert rows="n">
set	@TableName = 'dbo.WorkOrderObjects'

insert
	dbo.WorkOrderObjects
(	WorkOrderNumber
,	WorkOrderDetailLine
,	Serial
,	PartCode
,	OperatorCode
,	Quantity
)
select
	WorkOrderNumber = wod.WorkOrderNumber
,	WorkOrderDetailLine = wod.Line
,	Serial = o.serial
,	PartCode = o.part
,	OperatorCode = o.operator
,	Quantity = o.std_quantity
from
    dbo.object o
    join dbo.WorkOrderDetails wod
		on wod.RowID = @WODID
where
    o.serial between @FirstNewSerial and @FirstNewSerial + @Boxes - 1

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != @Boxes begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: %d.', 16, 1, @TableName, @ProcName, @RowCount, @Boxes)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Update quantity printed.  */
--- <Update rows="1">
set	@TableName = 'dbo.WorkOrderDetails'

update
	wod
set	QtyLabelled = QtyLabelled + @QtyBox * @Boxes
from
	dbo.WorkOrderDetails wod
where
	RowID = @WODID

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error updating %s in procedure %s.  Rows Updated: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Update>
--- </Body>

--- <CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
--- </CloseTran Required=Yes AutoCreate=Yes>

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
	@Operator varchar (10)
,	@WODID int
,	@Boxes int
,	@QtyBox int
,	@FirstNewSerial int

set	@Operator = 'mon'
set @WODID = 6
set @Boxes = 20
set @QtyBox = 100

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_NewPreObject
	@Operator = @Operator
,	@WODID = @WODID
,	@Boxes = @Boxes
,	@QtyBox = @QtyBox
,	@FirstNewSerial = @FirstNewSerial out
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@FirstNewSerial, @Error, @ProcReturn, @TranDT, @ProcResult

select
	o.*
from
	dbo.object o
where
	o.serial between @FirstNewSerial and @FirstNewSerial + @Boxes - 1

select
	at.*
from
	dbo.audit_trail at
where
	at.serial between @FirstNewSerial and @FirstNewSerial + @Boxes - 1

select
	p.next_serial
from
	dbo.parameters p

exec dbo.usp_MES_GetJobList
go

--commit
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
go


/*
Create procedure fx21st.dbo.usp_MES_NewScrapEntry
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_NewScrapEntry'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_NewScrapEntry
end
go

create procedure dbo.usp_MES_NewScrapEntry
	@Operator varchar(5)
,	@WODID int
,	@Serial int
,	@QtyScrap numeric(20, 6)
,	@DefectCode varchar(10)
,	@TranDT datetime out
,	@Result integer out
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
/*	Operator required:  */
if	not exists
	(	select
			1
		from
			employee
		where
			operator_code = @Operator
	) begin

	set @Result = 60001
	RAISERROR ('Invalid operator code %s in procedure %s.  Error: %d', 16, 1, @Operator, @ProcName, @Error)
	rollback tran @ProcName
	return
end

/*	WOD ID must be valid:  */
if	not exists
	(	select
			*
		from
			dbo.WorkOrderDetails wod
		where
			RowID = @WODID
	) begin

	set	@Result = 200101
	RAISERROR ('Invalid job id %d in procedure %s.  Error: %d', 16, 1, @WODID, @ProcName, @Error)
	rollback tran @ProcName
	return
end

/*	Defect code must be valid:  */
if	not exists
	(	select
			*
		from
			dbo.defect_codes dc
		where
			dc.code = @DefectCode
	) begin

	set	@Result = 200101
	RAISERROR ('Invalid defect code %s in procedure %s.  Error: %d', 16, 1, @DefectCode, @ProcName, @Error)
	rollback tran @ProcName
	return
end

/*	Quantity must be valid:  */
if	not coalesce(@QtyScrap, 0) > 0 begin

	set	@Result = 200101
	RAISERROR ('Invalid defect quantity %d in procedure %s.  Error: %d', 16, 1, @QtyScrap, @ProcName, @Error)
	rollback tran @ProcName
	return
end
---	</ArgumentValidation>

--- <Body>
/*	Report overage for scrap in excess of material. */
declare
	@qtyExcess numeric(20,6)

set	@qtyExcess = @QtyScrap - coalesce
	(	(	select
	 			std_quantity
	 		from
	 			dbo.object o
	 		where
	 			o.serial = @Serial
	 	)
	,	0
	)
set	@qtyExcess = case when @qtyExcess < 0 then 0 end

if	@qtyExcess > 0 begin
	--- <Call>	
	set	@CallProcName = 'dbo.usp_MES_NewExcessQty'
	execute
		@ProcReturn = dbo.usp_MES_NewExcessQty
			@Operator = @Operator
		,	@WODID = @WODID
		,	@Serial = @Serial
		,	@QtyExcess = @qtyExcess
		,	@ExcessReason = 'Excess due to scrap.'
		,	@TranDT = @TranDT
		,	@Result = @Result
	
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
end

/*	Adjust object quantity for scrap. */
--- <Update rows="1">
set	@TableName = '[tableName]'

update
	o
set
	quantity = o.quantity - @QtyScrap
,	std_quantity = o.std_quantity - @QtyScrap
from
	dbo.object o
where
	o.serial = @Serial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error updating %s in procedure %s.  Rows Updated: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Update>

/*	Create quality audit trail. */
--- <Insert rows="1">
set	@TableName = 'dbo.audit_trail'

insert  dbo.audit_trail
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
,	type = 'Q'
,	part = object.part
,	quantity = @QtyScrap
,	remarks = 'Quality'
,	po_number = object.po_number
,	operator = @Operator
,	from_loc = object.status
,	to_loc = 'S'
,	on_hand = part_online.on_hand - @QtyScrap
,	lot = object.lot
,	weight = object.weight
,	status = object.status
,	shipper = object.shipper
,	unit = object.unit_measure
,	workorder = convert (varchar,@WODID)
,	std_quantity = @QtyScrap
,	cost = object.cost
,	custom1 = object.custom1
,	custom2 = object.custom2
,	custom3 = object.custom3
,	custom4 = object.custom4
,	custom5 = object.custom5
,	plant = object.plant
,	notes = ''
,	package_type = object.package_type
,	suffix = object.suffix
,	due_date = object.date_due
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
	object
	join part_online
		on object.part = part_online.part
where
	object.serial = @Serial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end

declare
	@qualityAuditTrailID int

set	@qualityAuditTrailID = SCOPE_IDENTITY() 

--- </Insert>

/*	Create defect entry. */ 
--- <Insert rows="1">
set	@TableName = 'dbo.Defects'

insert
	dbo.Defects
(	TransactionDT
,	Machine
,	Part
,	DefectCode
,	QtyScrapped
,	Operator
,	Shift
,	WODID
,	DefectSerial
,	AuditTrailID 
)
select
	TransactionDT = @TranDT
,	Machine = woh.MachineCode
,	Part = o.part
,	DefectCode = @DefectCode
,	QtyScrapped = @QtyScrap
,	Operator = @Operator
,	Shift = 0 --Refactor
,	WODID = @WODID
,	DefectSerial = @Serial
,	AuditTrailID = @qualityAuditTrailID
from
	dbo.object o
	join dbo.WorkOrderHeaders woh
		join dbo.WorkOrderDetails wod
			on wod.WorkOrderNumber = woh.WorkOrderNumber
		on wod.RowID = @WODID
where
	o.serial = @Serial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Delete object if quantity remaining is zero. */
if	exists
	(	select
 			*
 		from
 			dbo.object o
 		where
 			serial = @serial
 			and o.std_quantity <= 0
	) begin
	
	--- <Delete rows="1">
	set	@TableName = 'dbo.object'
	 
	delete
		o
	from
		dbo.object o
	where
		serial = @serial	 

	select
		@Error = @@Error,
		@RowCount = @@Rowcount

	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error deleting from table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount != 1 begin
		set	@Result = 999999
		RAISERROR ('Error deleting from table %s in procedure %s.  Rows deleted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Delete>
end

/*	Adjust part on hand qty.*/
/*		Update part on hand quantity.  */
--- <Update rows="1">
set	@TableName = 'dbo.part_online'

update
	po
set 
	on_hand =
	(	select
			sum(o2.std_quantity)
		from
			object o2
		where
			o2.part = po.part
			and o2.status = 'A'
	)
from
	dbo.part_online po
	join dbo.object o
		on o.part = po.part
where
	o.serial = @Serial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	--- <Insert rows="1">
	set	@TableName = 'dbo.part_online'
	
	insert
		dbo.part_online
	(	part
	,	on_hand
	)
	select
		part = o.part
	,	on_hand = sum(o.std_quantity)
	from
		dbo.object o
	where
		o.part =
		(	select
				o2.part
			from
				dbo.object o2
			where
				o2.serial = @Serial
		)
		and status = 'A'
	group by
		o.part
	
	select
		@Error = @@Error,
		@RowCount = @@Rowcount
	
	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount != 1 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Insert>
	
end
--- </Update>
--- </Body>

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
	@Operator varchar(5)
,	@WODID int
,	@Serial int
,	@QtyScrap numeric(20, 6)
,	@DefectCode varchar(10)

set	@Operator = 'mon'
set @WODID = 6
set @Serial = -1
set @QtyScrap = 100
set @DefectCode = ''

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_NewScrapEntry
	@Operator = @Operator
,	@WODID = @WODID
,	@Serial = @Serial
,	@QtyScrap = @QtyScrap
,	@DefectCode = @DefectCode
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
go


if	objectproperty(object_id('dbo.usp_MES_ReportAsFinishedPreObject'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_ReportAsFinishedPreObject
end
go

create procedure dbo.usp_MES_ReportAsFinishedPreObject
	@Operator varchar (10)
,	@PreObjectSerial int
,	@TranDT datetime out
,	@Result int out
as
set nocount on
set	@Result = 999999

----<Tran Required=Yes AutoCreate=Yes>
--declare	@TranCount smallint
--set	@TranCount = @@TranCount
--if	@TranCount = 0 begin
--	begin transaction JCPreObject
--end
--else begin
--	save transaction JCPreObject
--end
--set @TranDT = coalesce(@TranDT, getdate())
----</Tran>

----<Error Handling>
--declare
--	@ProcReturn integer,
--	@ProcResult integer,
--	@Error integer,
--	@RowCount integer
----</Error Handling>

----	Argument Validation:
----		Operator required:
--if	not exists
--	(	select	1
--		from	employee
--		where	operator_code = @Operator) begin

--	set	@Result = 60001
--	rollback tran JCPreObject
--	RAISERROR (@Result, 16, 1, @Operator)
--	return	@Result
--end

--if	coalesce (
--	(	select	max (part)
--		from	audit_trail
--		where	serial = @PreObjectSerial), '') = 'PALLET' begin
--		set	@Result = 0
--	rollback tran JCPreObject
--	return	@Result
--end

----		WOD ID must be valid:
--declare	@WODID int, @Part varchar(25)
--select	@WODID = WODID, @Part = Part
--from	FT.PreObjectHistory
--where	Serial = @PreObjectSerial
----if	not exists
----	(	select	1
----		from	WODetails
----		where	ID = @WODID) begin
	
----	set	@Result = 200101
----	rollback tran JCPreObject
----	RAISERROR (@Result, 16, 1, @WODID)
----	return	@Result
----end

----if	not exists
----	(	select	1
----		from	WODetails
----		where	ID = @WODID) begin
			
----	set	@Result = 200101
----	rollback tran JCPreObject
----	RAISERROR (@Result, 16, 1, @WODID)
----	return	@Result
----end

--update	FT.PreObjectHistory
--set		WODID = @WODID
--where	Serial = @PreObjectSerial

--declare	@Machine varchar (10)
----select	@Machine = WOHeaders.Machine
----from	WODetails
----	join WOHeaders on WODetails.WOID = WOHeaders.ID
----where	WODetails.ID = @WODID

----		Quantity must be valid:
--declare	@QtyRequested numeric (20,6)
--select	@QtyRequested = Quantity
--from	FT.PreObjectHistory
--where	Serial = @PreObjectSerial
--if	not coalesce (@QtyRequested, 0) > 0 begin
--	set	@Result = 202001
--	rollback tran JCPreObject
--	RAISERROR (@Result, 16, 1, @QtyRequested)
--	return	@Result
--end

--if	exists
--	(	select	1
--		from	location
--		where	code = @Machine and
--			group_no = 'INVENTARIO') begin
--	set	@Result = 100033
--	rollback tran JCPreObject
--	RAISERROR (@Result, 16, 1, @PreObjectSerial)
--	return	@Result
--end


----		Serial must be a Pre-Object:
--if	not exists
--	(	select	1
--		from	FT.PreObjectHistory
--		where	Serial = @PreObjectSerial) begin
--	set	@Result = 100101
--	rollback tran JCPreObject
--	RAISERROR (@Result, 16, 1, @PreObjectSerial)
--	return	@Result
--end

----		If PreObject has already been Job Completed, do nothing:
--if	exists
--	(	select	1
--		from	audit_trail
--		where	type = 'J' and
--			serial = @PreObjectSerial) begin
----	set	@Result = 100100
--	set	@Result = 0
--	rollback tran JCPreObject
----	RAISERROR (@Result, 10, 1, @PreObjectSerial)
--	return	@Result
--end

----	I.	If this box has been deleted, recreate it.
----if	not exists
----	(	select	1
----		from	object
----		where	serial = @PreObjectSerial) begin

--	--insert
--	--	dbo.object
--	--(	serial
--	--,	part
--	--,	location
--	--,	last_date
--	--,	unit_measure
--	--,	operator
--	--,	status
--	--,	quantity
--	--,	plant
--	--,	std_quantity
--	--,	last_time
--	--,	user_defined_status
--	--,	type
--	--,	po_number 
--	--)
--	--select
--	--	poh.Serial
--	--,   poh.part
--	--,   location = FT.fn_VarcharGlobal ('AssemblyPreObject')
--	--,   poh.CreateDT
--	--,   (select standard_unit from part_inventory where part = poh.Part)
--	--,   @Operator
--	--,   'H'
--	--,   poh.Quantity
--	--,   (select plant from location where code = FT.fn_VarcharGlobal ('AssemblyPreObject'))
--	--,   poh.Quantity
--	--,   poh.CreateDT
--	--,   'PRESTOCK'
--	--,   null
--	--,   null
--	--from
--	--	FT.PreObjectHistory poh
--	--where
--	--	poh.Serial = @PreObjectSerial
----end

--select	@Part = part
--from	object
--where	serial = @PreObjectSerial 

----	    bom of the part must be complete
--if	not exists (select	1
--		from	part
--		where	class = 'M'
--			and part = @Part) begin
--	set	@Result = 70102
--	rollback tran JCPreObject
--	RAISERROR (@Result, 16, 1, @Part)
--	return	@Result			                          	
--end


----	II.	Write job complete.
----		A.	Set status on Pre-Object History.
--update	FT.PreObjectHistory
--set	Status = Status | 2 -- Change to a constant.
--where	Serial = @PreObjectSerial

--set	@Error = @@Error
--set	@RowCount = @@Rowcount

--if	@Error != 0 begin
--	set	@Result = 999999
--	RAISERROR (@Result, 16, 1, 'ProdControl_JCPreObject')
--	rollback tran JCPreObject
--	return	@Result
--end
--if	@RowCount != 1 begin
--	set	@Result = 999999
--	rollback tran JCPreObject
--	RAISERROR (@Result, 16, 1, 'ProdControl_JCPreObject')
--	return	@Result
--end

----		B.	Update object.
--update	object
--set	status = 'A',
--	user_defined_status = 'Approved',
--	last_date = @TranDT,
--	last_time = @TranDT,
--	location = @Machine,
--	plant = (select plant from location where code = @Machine),
--	operator = @Operator,
--	workorder = @WODID,
--	cost = (select cost_cum from dbo.part_standard where part = object.part),
--	std_cost = (select cost_cum from dbo.part_standard where part = object.part)
--where	serial = @PreObjectSerial

--set	@Error = @@Error
--set	@RowCount = @@Rowcount

--if	@Error != 0 begin
--	set	@Result = 999999
--	RAISERROR (@Result, 16, 1, 'ProdControl_JCPreObject')
--	rollback tran JCPreObject
--	return	@Result
--end
--if	@RowCount != 1 begin
--	set	@Result = 999999
--	rollback tran JCPreObject
--	RAISERROR (@Result, 16, 1, 'ProdControl_JCPreObject')
--	return	@Result
--end

----		C.	Update part_online.
--update	part_online
--set	on_hand =
--	(	select	sum (std_quantity)
--		from	object
--		where	part = part_online.part and
--			status = 'A')
--from	part_online
--	join object on part_online.part = object.part
--where	object.serial = @PreObjectSerial

--set	@Error = @@Error
--set	@RowCount = @@Rowcount

--if	@Error != 0 begin
--	set	@Result = 999999
--	RAISERROR (@Result, 16, 1, 'ProdControl_JCPreObject')
--	rollback tran JCPreObject
--	return	@Result
--end
--if	@RowCount != 1 begin
--	insert	part_online
--	(	part, on_hand)
--	select	part = part,
--		on_hand = sum (std_quantity)
--	from	object
--	where	part =
--		(	select	part
--			from	object
--			where	serial = @PreObjectSerial) and
--		status = 'A'
--	group by
--		part
	
--	set	@Error = @@Error
--	set	@RowCount = @@Rowcount
	
--	if	@Error != 0 begin
--		set	@Result = 999999
--		RAISERROR (@Result, 16, 1, 'ProdControl_JCPreObject')
--		rollback tran JCPreObject
--		return	@Result
--	end
--	if	@RowCount != 1 begin
--		set	@Result = 999999
--		rollback tran JCPreObject
--		RAISERROR (@Result, 16, 1, 'ProdControl_JCPreObject')
--		return	@Result
--	end
--end

----		D.	Create back flush header.
--declare	@NewBackflushNumber varchar(50)

----insert
----	BackFlushHeaders
----(	TranDT,
----	WODID,
----	PartProduced,
----	SerialProduced,
----	QtyProduced)
----select
----	@TranDT,
----	ID,
----	Part,
----	@PreObjectSerial,
----	@QtyRequested
----from	WODetails
----where	ID = @WODID

--set	@NewBackflushNumber =
--	(	select
--			bh.BackflushNumber
--		from
--			dbo.BackflushHeaders bh
--		where
--			bh.RowID = SCOPE_IDENTITY ()
--	)

----		E.	Insert audit_trail.
--insert	audit_trail
--(	serial, date_stamp, type, part, quantity, remarks, price,
--	operator, from_loc, to_loc, on_hand, lot, weight, status, unit,
--	workorder, std_quantity, cost, custom1, custom2, custom3,
--	custom4, custom5, plant, notes, gl_account, std_cost,
--	group_no, user_defined_status, part_name, tare_weight)
--select	serial = object.serial, date_stamp = @TranDT, type = 'J', part = object.part,
--	quantity = object.quantity, remarks = 'Job comp', price = 0,
--	operator = object.operator, from_loc = object.location, to_loc = object.location,
--	on_hand = IsNull (part_online.on_hand, 0) +
--	(	case	when object.status = 'A' then object.std_quantity
--			else 0
--		end), lot = object.lot, weight = object.weight,
--	status = object.status, unit = object.unit_measure,
--	workorder = object.workorder, std_quantity = object.std_quantity, cost = object.cost,
--	custom1 = object.custom1, custom2 = object.custom2, custom3 = object.custom3,
--	custom4 = object.custom4, custom5 = object.custom5, plant = object.plant,
--	notes = '', gl_account = '', std_cost = object.cost,
--	group_no = @NewBackflushNumber, user_defined_status = object.user_defined_status, part_name = object.name, tare_weight = object.tare_weight
--from	object
--	left outer join part_online on object.part = part_online.part
--	join part on object.part = part.part
--where	object.serial = @PreObjectSerial

--set	@Error = @@Error
--set	@RowCount = @@Rowcount

--if	@Error != 0 begin
--	set	@Result = 999999
--	RAISERROR (@Result, 16, 1, 'ProdControl_JCPreObject')
--	rollback tran JCPreObject
--	return	@Result
--end
--if	@RowCount != 1 begin
--	set	@Result = 999999
--	rollback tran JCPreObject
--	RAISERROR (@Result, 16, 1, 'ProdControl_JCPreObject')
--	return	@Result
--end

----	III.	Perform back flush.
----		B.	Execute back flush details.
--execute @ProcReturn = dbo.usp_MES_BackFlush
--	@Operator = @Operator
--,	@BackflushNumber = @NewBackflushNumber
--,	@TranDT = @TranDT out
--,	@Result = @ProcResult out

--set	@Error = @@Error
--if	@ProcResult != 0 begin
--	set	@Result = 999999
--	RAISERROR ('An error result was returned from the procedure %s', 16, 1, 'ProdControl_BackFlush')
--	rollback tran JCPreObject
--	return	@Result
--end
--if	@ProcReturn != 0 begin
--	set	@Result = 999999
--	RAISERROR ('An error was returned from the procedure %s', 16, 1, 'ProdControl_BackFlush')
--	rollback tran JCPreObject
--	return	@Result
--end
--if	@Error != 0 begin
--	set	@Result = 999999
--	RAISERROR ('An error occurred during the execution of the procedure %s', 16, 1, 'ProdControl_BackFlush')
--	rollback tran JCPreObject
--	return	@Result
--end

----	IV.	Update workorder.
----update	WODetails
----set	QtyCompleted = QtyCompleted + @QtyRequested
----where	ID = @WODID

----<CloseTran Required=Yes AutoCreate=Yes>
--if	@TranCount = 0 begin
--	commit transaction JCPreObject
--end
----</CloseTran Required=Yes AutoCreate=Yes>

--	V.	Success.
set	@Result = 0
return	@Result

/*
select
	*
from
	FT.PreObjectHistory poh
where
	WODID = 7

begin transaction
go

declare
    @ProcResult int
,   @ProcReturn int
,   @Operator varchar(10)
,   @PreObjectSerial int
,	@TranDT datetime

set	@Operator = 'ES'
set	@PreObjectSerial = 791622

execute @ProcReturn = dbo.usp_MES_ReportAsFinishedPreObject 
    @Operator = @Operator
,   @PreObjectSerial = @PreObjectSerial
,	@TranDT = @TranDT out
,   @Result = @ProcResult out

select
    @ProcResult
,   @PreObjectSerial
,   @ProcReturn
,	@TranDT

select
    *
from
    BackFlushHeaders
where
    SerialProduced = @PreObjectSerial

select
    BackFlushDetails.*
from
    BackFlushDetails
    join BackFlushHeaders
        on BackFlushHeaders.ID = BackFlushDetails.BFID
where
    SerialProduced = @PreObjectSerial

select
    *
from
    audit_trail
where
    date_stamp = @TranDT

select	*
from	audit_trail
where	date_stamp >= DateAdd (n, -1, getdate()) and
	serial in
	(	select	SerialConsumed
		from	BackFlushDetails
			join BackFlushHeaders on BackFlushHeaders.ID = BackFlushDetails.BFID
		where	SerialProduced = @PreObjectSerial)

select
    *
from
    object
where
    serial = @PreObjectSerial

select
    *
from
    object
where
    serial in
    (	select
			SerialConsumed
		from
			BackFlushDetails
			join BackFlushHeaders
				on BackFlushHeaders.ID = BackFlushDetails.BFID
		where
			SerialProduced = @PreObjectSerial
	)
go

rollback
go

*/
go


/*
Create procedure fx21st.dbo.usp_MES_SchedulePlanningJobs
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_MES_SchedulePlanningJobs'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_SchedulePlanningJobs
end
go

create procedure dbo.usp_MES_SchedulePlanningJobs
	@HorizonEndDT datetime
,	@TranDT datetime out
,	@Result integer out
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
--- <Body>
set	@HorizonEndDT = coalesce(@HorizonEndDT, getdate() + 7)

declare
	@requirements table
(	ID int not null IDENTITY(1, 1) primary key
,	PartCode varchar(25) not null
,	BillToCode varchar(10) null
,	RequiredDT datetime not null
,	QtyRequired numeric(20,6) not null
,	AccumRequired numeric(20,6)	null
)

declare
	@NOBILLTO char(4)

set	@NOBILLTO = '~~~~'

insert
	@requirements
(	PartCode
,	BillToCode
,	RequiredDT
,	QtyRequired
)
select
	PartCode = fmnm.Part
,	BillToCode = coalesce(oh.customer, @NOBILLTO)
,	RequiredDT = fmnm.RequiredDT
,	QtyRequired = fmnm.Balance
from
	dbo.fn_MES_NetMPS() fmnm
	left join dbo.order_header oh
		on oh.order_no = fmnm.OrderNo
		and oh.blanket_part = fmnm.Part
where
	fmnm.Balance > 0
	and fmnm.RequiredDT <= @HorizonEndDT
order by
	fmnm.Part
,	oh.customer
,	fmnm.RequiredDT

update
	r
set
	AccumRequired =
	(	select
			sum(QtyRequired)
		from
			@requirements r1
		where
			r1.PartCode = r.PartCode
			and r1.BillToCode = r.BillToCode
			and r1.ID <= r.ID
	)
from
	@requirements r

declare
	@netPlanningRequirements table
(	PartCode varchar(25)
,	BillToCode varchar(10)
,	PrimaryMachineCode varchar(10)
,	RunningMachineCode varchar(10)
,	NewPlanningQty numeric(20,6)
,	NewPlanningDueDT datetime
,	CurrentPlanningWODID integer
,	CurrentPlanningQty numeric(20,6)
)

insert
	@netPlanningRequirements
select
	PartCode = coalesce(requirements.PartCode, jobsRunning.PartCode, jobsPlanning.PartCode)
,	BillToCode = nullif(coalesce(requirements.BillToCode, jobsRunning.BilltoCode, jobsPlanning.BilltoCode), @NOBILLTO)
,	PrimaryMachineCode = min(pmPrimary.machine)
,	RunningMachineCode = min(jobsRunning.RunningMachineCode)
,	NewPlanningQty = case when min(coalesce(jobsRunning.QtyScheduled, 0)) < sum(requirements.QtyRequired) then sum(requirements.QtyRequired) - min(coalesce(jobsRunning.QtyScheduled, 0)) else 0 end
,	NewPlanningDueDT = min(case when coalesce(jobsRunning.QtyScheduled, 0) < requirements.AccumRequired then requirements.RequiredDT end)
,	CurrentPlanningWODID = min(jobsPlanning.WODID)
,   CurrentPlanningQty = min(jobsPlanning.QtyScheduled)
from
	@requirements requirements
	full join
	(	select
			wod.PartCode
		,	BillToCode = coalesce(wod.CustomerCode, @NOBILLTO)
		,	RunningMachineCode = coalesce(min(case when woh.MachineCode = pmPrimary.machine then woh.MachineCode end), min(case when woh.MachineCode != pmPrimary.machine then woh.MachineCode end))
		,	QtyScheduled = sum(case when wod.QtyLabelled > wod.QtyRequired then wod.QtyLabelled else wod.QtyRequired end - wod.QtyCompleted)
		from
			dbo.WorkOrderHeaders woh
			join dbo.WorkOrderDetails wod
				on wod.WorkOrderNumber = woh.WorkOrderNumber
			join dbo.part_machine pmPrimary
				on pmPrimary.part = wod.PartCode
				and pmPrimary.sequence = 1
		where
			woh.Status in
			(	select
	 				sd.StatusCode
	 			from
	 				FT.StatusDefn sd
	 			where
	 				sd.StatusTable = 'dbo.WorkOrderHeaders'
	 				and sd.StatusName = 'Running'
			)
		group by
			wod.PartCode
		,	wod.CustomerCode
	) jobsRunning
	on jobsRunning.PartCode = requirements.PartCode
		and jobsRunning.BillToCode = requirements.BillToCode
	full join
	(	select
			wod.PartCode
		,	BillToCode = coalesce(wod.CustomerCode, @NOBILLTO)
		,	WODID = max(wod.RowID)
		,	QtyScheduled = sum(wod.QtyRequired - wod.QtyCompleted)
		from
			dbo.WorkOrderHeaders woh
			join dbo.WorkOrderDetails wod
				on wod.WorkOrderNumber = woh.WorkOrderNumber
		where
			woh.Status in
			(	select
	 				sd.StatusCode
	 			from
	 				FT.StatusDefn sd
	 			where
	 				sd.StatusTable = 'dbo.WorkOrderHeaders'
	 				and sd.StatusName = 'New'
			)
		group by
			wod.PartCode
		,	wod.CustomerCode
	) jobsPlanning
	on jobsPlanning.PartCode = coalesce(requirements.PartCode, jobsRunning.PartCode)
		and jobsPlanning.BillToCode = coalesce(requirements.BillToCode, jobsRunning.BillToCode)
	join dbo.part_machine pmPrimary
		on pmPrimary.part = coalesce(requirements.PartCode, jobsRunning.PartCode, jobsPlanning.PartCode)
		and pmPrimary.sequence = 1
group by
	coalesce(requirements.PartCode, jobsRunning.PartCode, jobsPlanning.PartCode)
,	coalesce(requirements.BillToCode, jobsRunning.BilltoCode, jobsPlanning.BillToCode)

if	exists
	(	select
			*
		from
			@netPlanningRequirements npr
		where
			npr.CurrentPlanningWODID is not null
			and npr.NewPlanningQty = 0
	) begin
	
	--- <Update rows="1+">
	set	@TableName = 'dbo.WorkOrderDetails'
		
	update
		wod
	set
		Status = dbo.udf_StatusValue('dbo.WorkOrderDetails', 'Deleted')
	from
		dbo.WorkOrderDetails wod
		join @netPlanningRequirements npr
			on npr.CurrentPlanningWODID = wod.RowID
	where
		npr.CurrentPlanningWODID is not null
		and npr.NewPlanningQty = 0
	
	select
		@Error = @@Error,
		@RowCount = @@Rowcount
	
	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount <= 0 begin
		set	@Result = 999999
		RAISERROR ('Error updating into %s in procedure %s.  Rows Updated: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Update>
		
	--- <Update rows="1+">
	set	@TableName = 'dbo.WorkOrderHeaders'
	
	update
		woh
	set
		Status = dbo.udf_StatusValue('dbo.WorkOrderHeaders', 'Deleted')
	from
		dbo.WorkOrderHeaders woh
		join dbo.WorkOrderDetails wod
			on woh.WorkOrderNumber = wod.WorkOrderNumber
		join @netPlanningRequirements npr
			on npr.CurrentPlanningWODID = wod.RowID
	where
		npr.CurrentPlanningWODID is not null
		and npr.NewPlanningQty = 0
	
	select
		@Error = @@Error,
		@RowCount = @@Rowcount
	
	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount <= 0 begin
		set	@Result = 999999
		RAISERROR ('Error updating into %s in procedure %s.  Rows Updated: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Update>
end

declare newPlanning cursor local for
select
	npr.PartCode
,   npr.BillToCode
,   npr.PrimaryMachineCode
,   npr.NewPlanningQty
,   npr.NewPlanningDueDT
from
	@netPlanningRequirements npr
where
	npr.CurrentPlanningWODID is null
	and npr.NewPlanningQty > 0 

open
	newPlanning

while
	1 = 1 begin
	declare
		@newPlanningWorkOrderNumber varchar(50)
	,	@newPlanningPartCode varchar(25)
	,	@newPlanningBillToCode varchar(10)
	,	@newPlanningMachineCode varchar(25)
	,	@newPlanningPlanningQty numeric(20,6)
	,	@newPlanningDueDT datetime
	
	fetch
		newPlanning
	into
		@newPlanningPartCode
	,	@newPlanningBillToCode
	,	@newPlanningMachineCode
	,	@newPlanningPlanningQty
	,	@newPlanningDueDT
	
	if	@@FETCH_STATUS != 0 begin
		break
	end
	
	set	@newPlanningWorkOrderNumber = null
	--- <Call>
	set	@CallProcName = 'dbo.usp_Scheduling_ScheduleJob'
	execute
		@ProcReturn = dbo.usp_Scheduling_ScheduleJob
		@WorkOrderNumber = @newPlanningWorkOrderNumber out
	,	@Operator = 'mon'
	,	@MachineCode = @newPlanningMachineCode
	,	@ToolCode = null
	,	@ProcessCode = null
	,	@PartCode = @newPlanningPartCode
	,	@NewFirmQty = @newPlanningPlanningQty
	,	@DueDT = @newPlanningDueDT
	,	@TopPart = null
	,	@SalesOrderNo = null
	,	@ShipToCode = null
	,	@BillToCode = @newPlanningBillToCode
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out
	
	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		rollback tran @ProcName
		return
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		rollback tran @ProcName
		return
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return
	end
	--- </Call>
	
end

if	exists
	(	select
			*
		from
			@netPlanningRequirements npr
		where
			npr.CurrentPlanningWODID is not null
			and npr.NewPlanningQty > 0
	) begin
	
	--- <Update rows="1+">
	set	@TableName = '[tableName]'
	
	update
		wod
	set
		QtyRequired = npr.NewPlanningQty
	,	DueDT = npr.NewPlanningDueDT
	from
		dbo.WorkOrderDetails wod
		join @netPlanningRequirements npr
			on npr.CurrentPlanningWODID = wod.RowID
	where
		npr.CurrentPlanningWODID is not null
		and npr.NewPlanningQty > 0
	
	select
		@Error = @@Error,
		@RowCount = @@Rowcount
	
	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount <= 0 begin
		set	@Result = 999999
		RAISERROR ('Error updating into %s in procedure %s.  Rows Updated: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Update>
end
--- </Body>

--- <CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
--- </CloseTran Required=Yes AutoCreate=Yes>
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
	@HorizonEndDT datetime

set	@HorizonEndDT = '2011-09-13'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_MES_SchedulePlanningJobs
	@HorizonEndDT = @HorizonEndDT
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
go


/*
Create procedure fx21st.dbo.usp_Scheduling_BuildXRt
*/

--use fx21st
--go

if	objectproperty(object_id('dbo.usp_Scheduling_BuildXRt'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_Scheduling_BuildXRt
end
go

create procedure dbo.usp_Scheduling_BuildXRt
	@TranDT datetime = null out
,	@Result integer = null out
---<Debug>
,	@Debug integer = 0
---</Debug>
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

---<Debug>
declare
	@StartDT datetime

set	@StartDT = @TranDT
---</Debug>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
--	I.	Create an empty copy of eXpanded Router table.
--<Debug>
if @Debug & 1 = 1 begin
	print	'I.	Create an empty copy of eXpanded Router table.'
end--</Debug>
create table #XRt
(	ID int identity primary key
,	TopPart varchar(25) not null
,	ChildPart varchar(25) not null
,	BOMID int null
,	Sequence smallint null
,	BOMLevel smallint default (0) not null
,	XQty float default (1) not null
,	XScrap float default (1) not null
,	XBufferTime float default (0) not null
,	XRunRate float default (0) not null
,	Hierarchy varchar(500) not null
,	Infinite smallint default (0) not null
,	unique (BOMLevel,Infinite,ID)
,	unique (BOMID,TopPart,BOMLevel,Hierarchy,Infinite,ID)
,	unique (TopPart,Hierarchy,ID)
)

--	II.	Populate #eXpanded Router datastructure.
--<Debug>
if @Debug & 1 = 1 begin
	print	'II.	Populate #eXpanded Router datastructure...'
end--</Debug>
--		A.	Load all missing parts.
--<Debug>
if @Debug & 1 = 1 begin
	print	'	A.	Load all missing parts.'
end--</Debug>
insert
	#XRt
(	TopPart
,	ChildPart
,	Hierarchy
)
select
	Part
,	Part
,	Part
from
	FT.PartRouter PartRouter
where
	not exists
	(	select
			*
		from
			FT.XRt XRt
		where
			PartRouter.Part = XRt.TopPart
	)

while
	@@RowCount > 0 begin
--		B.	Loading children.
--<Debug>
	if @Debug & 1 = 1 begin
		print	'	B.	Loading children.'
	end
--</Debug>
--			1.	Mark infinites.
--<Debug>
	if @Debug & 1 = 1 begin
		print	'		1.	Mark infinites.'
	end
--</Debug>
	update
		xr
	set 
		Infinite = 1
	from
		#XRt xr
	where
		exists
		(	select
				*
			from
				#XRt xr1
			where
				xr.TopPart = xr1.TopPart
				and xr.BOMLevel > xr1.BOMLevel
				and left(xr.Hierarchy, len(xr1.Hierarchy)) = xr1.Hierarchy
				and xr.BOMID = xr1.BOMID
		)

--			2.	Insert children.
--<Debug>
	if @Debug & 1 = 1 begin
		print	'		2.	Insert children.'
	end
---</Debug>
	insert
		#XRt
	(	TopPart, ChildPart, BOMID, BOMLevel, XQty, XScrap, XBufferTime, XRunRate, Hierarchy)
	select
		xr.TopPart
	,   BOM.ChildPart
	,   BOM.BOMID
	,   BOMLevel + 1
	,   XQty * StdQty
	,   XScrap * ScrapFactor
	,   XBufferTime + isnull(PartRouter.BufferTime,0)
	,   XRunRate + isnull(PartRouter.RunRate,0)
	,   Hierarchy + '/' + convert
		(	varchar
		,	row_number() over (partition by xr.TopPart, BOM.ParentPart order by BOM.ChildPart)
		)
	from
		#XRt xr
		join FT.BOM BOM
			on xr.ChildPart = BOM.ParentPart
			   and BOM.SubstitutePart = 0
		left outer join FT.PartRouter PartRouter
			on BOM.ChildPart = PartRouter.Part
	where
		Infinite = 0
		and BOMLevel =
		(	select
				max(BOMLevel)
			from
				#XRt
		)
end

--<Debug>
if @Debug & 1 = 1 begin
	print	'...@XRt populated.   ' + Convert (varchar, DateDiff (ms, @StartDT, GetDate ())) + ' ms'
end--</Debug>

--	II.	Set sequence on #eXpanded Routers.
--<Debug>
if @Debug & 1 = 1 begin
	print	'II.	Set sequence on #eXpanded Routers...'
	select	@StartDT = GetDate ()
end--</Debug>
update
    xr
set 
    Sequence =
	(	select
			count(1)
		from
			#XRt xrC
		where
			xrC.TopPart = xr.TopPart
			and xrC.Hierarchy < xr.Hierarchy
	)
from
    #XRt xr

--<Debug>
if @Debug & 1 = 1 begin
	print	'...Sequence set.   ' + Convert (varchar, DateDiff (ms, @StartDT, GetDate ())) + ' ms'
end--</Debug>

--	III.	Write new #eXpanded Routers to permanent table.
--<Debug>
if @Debug & 1 = 1 begin
	print	'III.	Write new #eXpanded Routers to permanent table...'
	select	@StartDT = GetDate ()
end--</Debug>
--- <Insert rows="*">
set	@TableName = 'FT.XRt'

insert
	FT.XRt
(	TopPart
,   ChildPart
,   BOMID
,   Sequence
,   BOMLevel
,   XQty
,   XScrap
,   XBufferTime
,   XRunRate
,   Hierarchy
,   Infinite
)
select
	xr.TopPart
,   xr.ChildPart
,   xr.BOMID
,   xr.Sequence
,   xr.BOMLevel
,   xr.XQty
,   xr.XScrap
,   xr.XBufferTime
,   xr.XRunRate
,   xr.Hierarchy
,   xr.Infinite
from
	#XRt xr
order by
	xr.TopPart
,	xr.Sequence
select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
--- </Insert>
--<Debug>
if @Debug & 1 = 1 begin
	print	'...Written.   ' + Convert (varchar, DateDiff (ms, @StartDT, GetDate ())) + ' ms'
end--</Debug>
--<Debug>
if @Debug & 1 = 1 begin
	print	'Finished.   ' + Convert (varchar, DateDiff (ms, @TranDT, GetDate ())) + ' ms'
end--</Debug>

drop table #XRt
--- </Body>

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

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_Scheduling_BuildXRt
	@TranDT = @TranDT out
,	@Result = @ProcResult out
,	@Debug = 1

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
go

--commit
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
go


if	objectproperty(object_id('dbo.usp_Scheduling_ScheduleJob'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_Scheduling_ScheduleJob
end
go

create procedure dbo.usp_Scheduling_ScheduleJob
	@WorkOrderNumber varchar(50) = null out
,	@Operator varchar(5)
,	@MachineCode varchar(15)
,	@ToolCode varchar(60)
,	@ProcessCode varchar(25) = null
,	@PartCode varchar(25)
,	@NewFirmQty numeric(20,6)
,	@DueDT datetime
,	@TopPart varchar(25)
,	@SalesOrderNo int = null
,	@ShipToCode varchar(20) = null
,	@BillToCode varchar(20) = null
,	@TranDT datetime out
,	@Result integer out
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
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>
/*	Validate WorkOrderNumber if specified. */
if	@WorkOrderNumber is not null 
	and
		exists
		(	select
				*
			from
				dbo.WorkOrderHeaders woh
			where
				WorkOrderNumber = @WorkOrderNumber
		) begin
	
/*		Status must not be reconciled or deleted. */
	declare
		@WorkOrderStatusName varchar(25)
	set @WorkOrderStatusName =
		(	select
				dbo.udf_StatusValue('WorkOrderHeaders', Status)
			from
				dbo.WorkOrderHeaders woh
			where
				WorkOrderNumber = @WorkOrderNumber
		)
	
	if	@WorkOrderStatusName in
		(
			'Reconciled'
		,	'Deleted'
		) begin
	
		set	@Result = 999999
		RAISERROR ('Error validing @WorkOrderNumber(%d) in procedure %s.  Work order status is %s', 16, 1, @WorkOrderNumber, @ProcName, @WorkOrderStatusName)
		rollback tran @ProcName
		return @Result
	end
end

---	</ArgumentValidation>

--- <Body>
/*	If WorkOrderNumber not specified or specified WorkOrderNumber does not exist... */
if	@WorkOrderNumber is null
	or
		not exists
		(	select
				*
			from
				dbo.WorkOrderHeaders woh
			where
				WorkOrderNumber = @WorkOrderNumber
		) begin

/*		Create a new work order header. */
	--- <Call>	
	set	@CallProcName = 'dbo.usp_WorkOrders_CreateFirmWorkOrderHeader'
	execute
		@ProcReturn = dbo.usp_WorkOrders_CreateFirmWorkOrderHeader
			@WorkOrderNumber = @WorkOrderNumber out
		,	@Operator = @Operator
		,	@MachineCode = @MachineCode
		,	@ToolCode = @ToolCode
		,	@ProcessCode = @ProcessCode
		,	@TranDT = @TranDT out
		,	@Result = @ProcResult out
	
	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@WorkOrderNumber is null begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	--- </Call>
end

/*	Create work order details. */
--- <Call>	
set	@CallProcName = 'dbo.usp_WorkOrders_CreateWorkOrderDetails'
execute
	@ProcReturn = dbo.usp_WorkOrders_CreateWorkOrderDetails
		@WorkOrderNumber = @WorkOrderNumber
	,	@Status = null
	,	@Type = null
	,	@User = @Operator
	,	@ProcessCode = @ProcessCode
	,	@PartCode = @PartCode
	,	@NextBuildQty = @NewFirmQty
	,	@DueDT = @DueDT
	,	@TopPart = @TopPart
	,	@SalesOrderNo = @SalesOrderNo
	,	@ShipToCode = @ShipToCode
	,	@BillToCode = @BillToCode
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

set	@Error = @@Error
if	@Error != 0 begin
	set	@Result = 900501
	RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
	rollback tran @ProcName
	return @Result
end
if	@ProcReturn != 0 begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	rollback tran @ProcName
	return @Result
end
if	@ProcResult != 0 begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	rollback tran @ProcName
	return @Result
end
if	@WorkOrderNumber is null begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	rollback tran @ProcName
	return @Result
end
--- </Call>
--- </Body>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries {
}
Test queries
{

select
	*
	,	TopPart = (select max(part_number) from order_detail where part_number in (select TopPart from FT.XRt where ChildPart = wd.part) and order_no = coalesce(wo.order_no, order_no))
from
	dbo.work_order wo
	join dbo.workorder_detail wd on
		wo.work_order = wd.workorder

}

Test syntax
{

set statistics io on
set statistics time on
go

declare
	@NewWorkOrderNumber varchar(50)
,	@Operator varchar(5)
,	@MachineCode varchar(15)
,	@ToolCode varchar(60)
,	@ProcessCode varchar(25)
,	@PartCode varchar(25)
,	@NewFirmQty numeric(20,6)
,	@DueDT datetime
,	@TopPart varchar(25)
,	@SalesOrderNo int
,	@ShipToCode varchar(20)
,	@BillToCode varchar(20)

set	@NewWorkOrderNumber = null
set	@Operator = 'mon'
set	@MachineCode = 'PRESS 28A'
set	@ToolCode = '1367 CAVITY | 1372 MOLDBASE'
set	@ProcessCode = null
set	@PartCode = '1-534035-6M_1367_1'
set	@NewFirmQty = 1010
set	@DueDT = '2010-05-03 00:00:00.000'
set	@TopPart = '1-534035-6_1367_1'
set	@SalesOrderNo = 10747
set	@ShipToCode = 'AMP'
set	@BillToCode = '909/SC'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_Scheduling_ScheduleJob
	@WorkOrderNumber = @NewWorkOrderNumber out
,	@Operator = @Operator
,	@MachineCode = @MachineCode
,	@ToolCode = @ToolCode
,	@ProcessCode = @ProcessCode
,	@PartCode = @PartCode
,	@NewFirmQty = @NewFirmQty 
,	@DueDT = @DueDT
,	@TopPart = @TopPart
,	@SalesOrderNo = @SalesOrderNo
,	@ShipToCode = @ShipToCode
,	@BillToCode = @BillToCode
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	[@Error] = @Error, [@ProcReturn] = @ProcReturn, [@TranDT] = @TranDT, [@ProcResult] = @ProcResult, [@NewWorkOrderNumber] = @NewWorkOrderNumber

select
	*
from
	dbo.WorkOrderHeaders woh
where
	WorkOrderNumber = @NewWorkOrderNumber

select
	*
from
	dbo.WorkOrderDetails wod
where
	WorkOrderNumber = @NewWorkOrderNumber

select
	*
from
	dbo.WorkOrderDetailBillOfMaterials wodbom
where
	WorkOrderNumber = @NewWorkOrderNumber

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
go


if	objectproperty(object_id('dbo.usp_Scheduling_ScheduleNextBuild'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_Scheduling_ScheduleNextBuild
end
go

create procedure dbo.usp_Scheduling_ScheduleNextBuild
	@WorkOrderNumber varchar(50) = null out
,	@User varchar(5)
,	@MachineCode varchar(15)
,	@ToolCode varchar(60)
,	@ProcessCode varchar(25) = null
,	@PartCode varchar(25)
,	@NextBuildQty numeric(20,6)
,	@DueDT datetime
,	@TopPart varchar(25)
,	@SalesOrderNo int = null
,	@ShipToCode varchar(20) = null
,	@BillToCode varchar(20) = null
,	@TranDT datetime out
,	@Result integer out
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
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>
/*	Validate WorkOrderNumber if specified. */
if	@WorkOrderNumber is not null 
	and
		exists
		(	select
				*
			from
				dbo.WorkOrderHeaders woh
			where
				WorkOrderNumber = @WorkOrderNumber
		) begin
	
/*		Status must not be reconciled or deleted. */
	declare
		@WorkOrderStatusName varchar(25)
	set @WorkOrderStatusName =
		(	select
				dbo.udf_StatusValue('WorkOrderHeaders', Status)
			from
				dbo.WorkOrderHeaders woh
			where
				WorkOrderNumber = @WorkOrderNumber
		)
	
	if	@WorkOrderStatusName in
		(
			'Reconciled'
		,	'Deleted'
		) begin
	
		set	@Result = 999999
		RAISERROR ('Error validing @WorkOrderNumber(%d) in procedure %s.  Work order status is %s', 16, 1, @WorkOrderNumber, @ProcName, @WorkOrderStatusName)
		rollback tran @ProcName
		return @Result
	end
end

---	</ArgumentValidation>

--- <Body>
/*	If WorkOrderNumber not specified or specified WorkOrderNumber does not exist... */
if	@WorkOrderNumber is null
	or
		not exists
		(	select
				*
			from
				dbo.WorkOrderHeaders woh
			where
				WorkOrderNumber = @WorkOrderNumber
		) begin

/*		Create a new work order header. */
	--- <Call>	
	set	@CallProcName = 'dbo.usp_WorkOrders_CreateNextBuildWorkOrderHeader'
	execute
		@ProcReturn = dbo.usp_WorkOrders_CreateNextBuildWorkOrderHeader
		@WorkOrderNumber = @WorkOrderNumber out
	,	@User = @User
	,	@MachineCode = @MachineCode
	,	@ToolCode = @ToolCode
	,	@ProcessCode = @ProcessCode
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out
	
	set	@Error = @@Error
	if	@Error != 0 begin
		set	@Result = 900501
		RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcReturn != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@ProcResult != 0 begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	if	@WorkOrderNumber is null begin
		set	@Result = 900502
		RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
		rollback tran @ProcName
		return @Result
	end
	--- </Call>
end

/*	Create work order details. */
--- <Call>	
set	@CallProcName = 'dbo.usp_WorkOrders_CreateWorkOrderDetails'
execute
	@ProcReturn = dbo.usp_WorkOrders_CreateWorkOrderDetails
		@WorkOrderNumber = @WorkOrderNumber
	,	@User = @User
	,	@ProcessCode = @ProcessCode
	,	@PartCode = @PartCode
	,	@NextBuildQty = @NextBuildQty
	,	@DueDT = @DueDT
	,	@TopPart = @TopPart
	,	@SalesOrderNo = @SalesOrderNo
	,	@ShipToCode = @ShipToCode
	,	@BillToCode = @BillToCode
	,	@TranDT = @TranDT out
	,	@Result = @ProcResult out

set	@Error = @@Error
if	@Error != 0 begin
	set	@Result = 900501
	RAISERROR ('Error encountered in %s.  Error: %d while calling %s', 16, 1, @ProcName, @Error, @CallProcName)
	rollback tran @ProcName
	return @Result
end
if	@ProcReturn != 0 begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcReturn: %d while calling %s', 16, 1, @ProcName, @ProcReturn, @CallProcName)
	rollback tran @ProcName
	return @Result
end
if	@ProcResult != 0 begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	rollback tran @ProcName
	return @Result
end
if	@WorkOrderNumber is null begin
	set	@Result = 900502
	RAISERROR ('Error encountered in %s.  ProcResult: %d while calling %s', 16, 1, @ProcName, @ProcResult, @CallProcName)
	rollback tran @ProcName
	return @Result
end
--- </Call>
--- </Body>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries {
}
Test queries
{

select
	*
	,	TopPart = (select max(part_number) from order_detail where part_number in (select TopPart from FT.XRt where ChildPart = wd.part) and order_no = coalesce(wo.order_no, order_no))
from
	dbo.work_order wo
	join dbo.workorder_detail wd on
		wo.work_order = wd.workorder

}

Test syntax
{

set statistics io on
set statistics time on
go

declare
	@NewWorkOrderNumber varchar(50)
,	@User varchar(5)
,	@MachineCode varchar(15)
,	@ToolCode varchar(60)
,	@ProcessCode varchar(25)
,	@PartCode varchar(25)
,	@NextBuildQty numeric(20,6)
,	@DueDT datetime
,	@TopPart varchar(25)
,	@SalesOrderNo int
,	@ShipToCode varchar(20)
,	@BillToCode varchar(20)

set	@NewWorkOrderNumber = null
set	@User = 'mon'
set	@MachineCode = '3'
set	@ToolCode = null
set	@ProcessCode = null
set	@PartCode = '1217SW19B'
set	@NextBuildQty = 16
set	@DueDT = '8/4/2011 00:00:00.000'
set	@TopPart = '1217SW19B'
set	@SalesOrderNo = 3774
set	@ShipToCode = 'IRWIN-GRAN'
set	@BillToCode = 'IRWIN-GRAN'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_Scheduling_ScheduleNextBuild
	@WorkOrderNumber = @NewWorkOrderNumber out
,	@User = @User
,	@MachineCode = @MachineCode
,	@ToolCode = @ToolCode
,	@ProcessCode = @ProcessCode
,	@PartCode = @PartCode
,	@NextBuildQty = @NextBuildQty 
,	@DueDT = @DueDT
,	@TopPart = @TopPart
,	@SalesOrderNo = @SalesOrderNo
,	@ShipToCode = @ShipToCode
,	@BillToCode = @BillToCode
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	[@Error] = @Error, [@ProcReturn] = @ProcReturn, [@TranDT] = @TranDT, [@ProcResult] = @ProcResult, [@NewWorkOrderNumber] = @NewWorkOrderNumber

select
	*
from
	dbo.WorkOrderHeaders woh
where
	WorkOrderNumber = @NewWorkOrderNumber

select
	*
from
	dbo.WorkOrderDetails wod
where
	WorkOrderNumber = @NewWorkOrderNumber

select
	*
from
	dbo.WorkOrderDetailBillOfMaterials wodbom
where
	WorkOrderNumber = @NewWorkOrderNumber

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
go


if	objectproperty(object_id('dbo.usp_WorkOrders_CreateFirmWorkOrderHeader'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_WorkOrders_CreateFirmWorkOrderHeader
end
go

create procedure dbo.usp_WorkOrders_CreateFirmWorkOrderHeader
	@WorkOrderNumber varchar(50) out
,	@Operator varchar(5)
,	@MachineCode varchar(15)
,	@ToolCode varchar(60)
,	@ProcessCode varchar(25) = null
,	@TranDT datetime out
,	@Result integer out
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
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
/*	Create work order header. */
--- <Insert rows="1">
set	@TableName = 'dbo.WorkOrderHeaders'

insert
	dbo.WorkOrderHeaders
(
	WorkOrderNumber
,	Status
,	Type
,	MachineCode
,	ToolCode
,	Sequence
)
select
	WorkOrderNumber = coalesce(@WorkOrderNumber, 0)
,	Status = dbo.udf_StatusValue('dbo.WorkOrderHeaders', 'New')
,	Type = dbo.udf_TypeValue('dbo.WorkOrderHeaders', 'Firm')
,	MachineCode = @MachineCode
,	ToolCode = @ToolCode
,	Sequence = coalesce
	(
		(
			select
				max(Sequence)
			from
				dbo.WorkOrderHeaders
			where
				MachineCode = @MachineCode
		) + 1
	,	1
	)

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Get new WorkOrderNumber. */
select
	@WorkOrderNumber = WorkOrderNumber
from
	dbo.WorkOrderHeaders woh
where
	RowID = scope_identity()

--- </Body>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries {
}

Test syntax {
declare
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_WorkOrders_CreateFirmWorkOrderHeader
	@Param1 = @Param1
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
go

rollback
go

}

Results {
}
*/
go


if	objectproperty(object_id('dbo.usp_WorkOrders_CreateNextBuildWorkOrderHeader'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_WorkOrders_CreateNextBuildWorkOrderHeader
end
go

create procedure dbo.usp_WorkOrders_CreateNextBuildWorkOrderHeader
	@WorkOrderNumber varchar(50) out
,	@User varchar(5)
,	@MachineCode varchar(15)
,	@ToolCode varchar(60)
,	@ProcessCode varchar(25) = null
,	@TranDT datetime out
,	@Result integer out
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
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
/*	Create work order header. */
--- <Insert rows="1">
set	@TableName = 'dbo.WorkOrderHeaders'

insert
	dbo.WorkOrderHeaders
(
	WorkOrderNumber
,	Status
,	Type
,	MachineCode
,	ToolCode
,	Sequence
)
select
	WorkOrderNumber = coalesce(@WorkOrderNumber, 0)
,	Status = dbo.udf_StatusValue('dbo.WorkOrderHeaders', 'New')
,	Type = dbo.udf_TypeValue('dbo.WorkOrderHeaders', 'Planning')
,	MachineCode = @MachineCode
,	ToolCode = @ToolCode
,	Sequence = coalesce
	(
		(
			select
				max(Sequence)
			from
				dbo.WorkOrderHeaders
			where
				MachineCode = @MachineCode
		) + 1
	,	1
	)

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Get new WorkOrderNumber. */
select
	@WorkOrderNumber = WorkOrderNumber
from
	dbo.WorkOrderHeaders woh
where
	RowID = scope_identity()

--- </Body>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries {
}

Test syntax {

declare
	@WorkOrderNumber varchar(50)
,	@User varchar(5)
,	@MachineCode varchar(15)
,	@ToolCode varchar(60)
,	@ProcessCode varchar(25)

set	@User = 'mon'
set	@MachineCode = '3'
set	@ToolCode = null
set	@ProcessCode = null

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_WorkOrders_CreateNextBuildWorkOrderHeader
	@WorkOrderNumber = @WorkOrderNumber out
,	@User = @User
,	@MachineCode = @MachineCode
,	@ToolCode = @ToolCode
,	@ProcessCode = @ProcessCode
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@WorkOrderNumber, @Error, @ProcReturn, @TranDT, @ProcResult
select
	*
from
	dbo.WorkOrderHeaders woh
where
	woh.WorkOrderNumber = @WorkOrderNumber
go

rollback
go

}

Results {
}
*/
go


if	objectproperty(object_id('dbo.usp_WorkOrders_CreateWODBillOfMaterials'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_WorkOrders_CreateWODBillOfMaterials
end
go

create procedure dbo.usp_WorkOrders_CreateWODBillOfMaterials
	@WorkOrderNumber varchar(50)
,	@WorkOrderDetailLine float
,	@TranDT datetime out
,	@Result integer out
as
--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
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
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
/*	Create bill of materials for work order detail.  */
--- <Insert rows="1+">
set	@TableName = 'dbo.WorkOrderDetailBillOfMaterials'

insert
	dbo.WorkOrderDetailBillOfMaterials
(
	WorkOrderNumber
,	WorkOrderDetailLine
,	Line
,	Status
,	Type
,	ChildPart
,	ChildPartSequence
,	ChildPartBOMLevel
,	BillOfMaterialID
,	Suffix
,	QtyPer
,	XQty
,	XScrap
)
select
	wod.WorkOrderNumber
,	wod.Line
,	Line = row_number() over (order by vb.ChildPart)
,	Status = dbo.udf_StatusValue('dbo.WorkOrderDetailBillOfMaterials', 'Used')
,	Type = dbo.udf_TypeValue('dbo.WorkOrderDetailBillOfMaterials', 'Material')
,	ChildPart = vb.ChildPart
,	ChildPartSequence = row_number() over (order by vb.ChildPart)
,	ChildPartBOMLevel = 0
,	BillOfMaterialID = vb.BOMID
,	Suffix = null
,	QtyPer = null
,	XQty = vb.StdQty
,	XScrap = vb.ScrapFactor
from
	dbo.WorkOrderDetails wod
	join FT.vwBOM vb on
		wod.PartCode = vb.ParentPart
where
	WorkOrderNumber = @WorkOrderNumber
	and
		Line = @WorkOrderDetailLine
	and
		vb.SubstitutePart = 0

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount <= 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>


--- </Body>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries {
}

Test syntax {
declare
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_WorkOrders_CreateWODBillOfMaterials
	@Param1 = @Param1
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
go

rollback
go

}

Results {
}
*/
go


if	objectproperty(object_id('dbo.usp_WorkOrders_CreateWorkOrderDetails'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_WorkOrders_CreateWorkOrderDetails
end
go

create procedure dbo.usp_WorkOrders_CreateWorkOrderDetails
	@WorkOrderNumber varchar(50)
,	@Status int = null
,	@Type int = null
,	@User varchar(5)
,	@ProcessCode varchar(25) = null
,	@PartCode varchar(25) = null
,	@NextBuildQty numeric(20,6)
,	@DueDT datetime
,	@TopPart varchar(25)
,	@SalesOrderNo int = null
,	@ShipToCode varchar(20) = null
,	@BillToCode varchar(20) = null
,	@TranDT datetime out
,	@Result integer out
as
/*
Example:
Initial queries {
}

Test syntax {
declare
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_WorkOrders_CreateWorkOrderDetails
	@Param1 = @Param1
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
go

rollback
go

}

Results {
}
*/
--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
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
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>

---	</ArgumentValidation>

--- <Body>
/*	Get next sequence.  Next sequence depends on whether another line has the same process code. */
declare
	@NextSequence int

set
	@NextSequence = coalesce
	(
		(
			select
				max(Sequence)
			from
				dbo.WorkOrderDetails
			where
				WorkOrderNumber = @WorkOrderNumber
				and
					ProcessCode = @ProcessCode
				and
					PartCode != @PartCode
		)
	,	(
			select
				max(Sequence) + 1
			from
				dbo.WorkOrderDetails
			where
				WorkOrderNumber = @WorkOrderNumber
		)
	,	1
	)

/*	Get next line.  Next line is sequence or a number within a sequence when a process code is use. */
declare
	@NextLine float

set
	@NextLine = coalesce
	(
		(
			select
				max(Line + (floor(Line + 1) - Line) / 2)
			from
				dbo.WorkOrderDetails
			where
				WorkOrderNumber = @WorkOrderNumber
				and
					Sequence = @NextSequence
		)
	,	@NextSequence
	)		

/*	Create work order detail. */
--- <Insert rows="1">
set	@TableName = 'dbo.WorkOrderDetails'

insert
	dbo.WorkOrderDetails
(
	WorkOrderNumber
,	Line
,	Status
,	Type
,	ProcessCode
,	TopPartCode
,	PartCode
,	Sequence
,	DueDT
,	QtyRequired
,	SetupHours
,	PartsPerHour
,	PartsPerCycle
,	CycleSeconds
,	SalesOrderNumber
,	DestinationCode
,	CustomerCode
)
select
	WorkOrderNumber = @WorkOrderNumber
,	Line = @NextLine
,	Status = coalesce(@Status, dbo.udf_StatusValue('dbo.WorkOrderDetails', 'New'))
,	Type = coalesce(@Type, dbo.udf_TypeValue('dbo.WorkOrderDetails', 'Firm'))
,	ProcessCode = @ProcessCode
,	TopPartCode = @TopPart
,	PartCode = @PartCode
,	Sequence = @NextSequence
,	DueDT = @DueDT
,	QtyRequired = @NextBuildQty
,	SetupHours = coalesce
	(
		(select setup_time from dbo.part_machine where part = @PartCode and machine = (select MachineCode from dbo.WorkOrderHeaders where WorkOrderNumber = @WorkOrderNumber))
	,	0
	)
,	PartsPerHour = coalesce
	(
		(select parts_per_hour from dbo.part_machine where part = @PartCode and machine = (select MachineCode from dbo.WorkOrderHeaders where WorkOrderNumber = @WorkOrderNumber))
	,	1
	)
,	PartsPerCycle = coalesce
	(
		(select parts_per_cycle from dbo.part_machine where part = @PartCode and machine = (select MachineCode from dbo.WorkOrderHeaders where WorkOrderNumber = @WorkOrderNumber))
	,	1
	)
,	CycleSeconds = coalesce
	(
		(select 3600.0 * parts_per_cycle / nullif(parts_per_hour, 0) from dbo.part_machine where part = @PartCode and machine = (select MachineCode from dbo.WorkOrderHeaders where WorkOrderNumber = @WorkOrderNumber))
	,	1
	)
,	SalesOrderNumber = @SalesOrderNo
,	DestinationCode = @ShipToCode
,	CustomerCode = @BillToCode

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	Create BOM for this work order detail. */
--- <Call>	
set	@CallProcName = 'dbo.usp_WorkOrders_CreateWODBillOfMaterials'
execute
	@ProcReturn = dbo.usp_WorkOrders_CreateWODBillOfMaterials
	@WorkOrderNumber = @WorkOrderNumber
,	@WorkOrderDetailLine = @NextLine
,	@TranDT = @TranDT out
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

--- </Body>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries {
}

Test syntax {
declare
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_WorkOrders_CreateWorkOrderDetails
	@Param1 = @Param1
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
go

rollback
go

}

Results {
}
*/
go


if	objectproperty(object_id('dbo.fn_MES_GetFIFOLocation_forPart'), 'IsScalarFunction') = 1 begin
	drop function dbo.fn_MES_GetFIFOLocation_forPart
end
go

create function dbo.fn_MES_GetFIFOLocation_forPart
(	@Part varchar(25)
,	@Status varchar(1) = 'A'
,	@Plant varchar(10) = null
,	@Location varchar(10) = null
,	@GroupNo varchar(25) = null 
,	@Secured char(1) = 'N'
)
returns varchar(10)
as 
begin
	declare @Objects table
	(	ID int not null IDENTITY(1, 1) primary key
	,	Serial int
	,	Location varchar(10)
	,	Quantity numeric(20, 6)
	,	BreakoutSerial int null
	,	FirstDT datetime null
	,	IsInFifo char(1)
	)

	insert
		@Objects
	(	Serial
	,	Location
	,	Quantity
	,	BreakoutSerial
	,	FirstDT
	,	IsInFifo
	)
	select
		Serial
	,	Location
	,	Quantity
	,	BreakoutSerial
	,	FirstDT
	,	IsInFifo
	from
		dbo.fn_MES_GetPartFIFO(@Part, @Status, @Plant, @Location, @GroupNo, @Secured)
	
	declare
		@FIFOLocation varchar(10)
	
	select
		@FIFOLocation = Location
	from
		@Objects
	where
		ID = 1
	
	return
		@FIFOLocation
end
go


select
	*
from
	dbo.fn_MES_GetPartFIFO('5420300', 'A', 'PLANT 1', null, null, 'N')

select
	dbo.fn_MES_GetFIFOLocation_forPart('5420300', 'A', 'PLANT 1', null, null, 'N')

select
	(select plant from location where code = location),
	*
from
	dbo.object o
if	objectproperty(object_id('dbo.udf_GetPartQtyOnHand'), 'IsScalarFunction') = 1 begin
	drop function dbo.udf_GetPartQtyOnHand
end
go

create function dbo.udf_GetPartQtyOnHand
(
	@Part varchar(25)
)
returns numeric(20,6)
as
begin
--- <Body>
/*	Get the on hand quantity for a part number. */
	declare
		@QtyOnHand numeric(20,6)
	
	set
		@QtyOnHand = coalesce
		(
			(
				select
					sum(std_quantity)
				from
					dbo.object o
				where
					o.part = @Part
					and
						O.status = 'A'
			)
		,	0
		)

--- </Body>

---	<Return>
	return
		@QtyOnHand
end
go


if	objectproperty(object_id('dbo.udf_GetQtyFromStdQty'), 'IsScalarFunction') = 1 begin
	drop function dbo.udf_GetQtyFromStdQty
end
go

create function dbo.udf_GetQtyFromStdQty
(
	@Part varchar(25)
,	@StdQty numeric(20,6)
,	@Unit char(2)
)
returns numeric(20,6)
as
begin
--- <Body>
	/*	Convert standard to unit quantity. */
	declare
		@Qty numeric(20,6)
	
	set
		@Qty = @StdQty * coalesce
		(
			(
				select
					conversion
				from
					dbo.unit_conversion uc
					join dbo.part_unit_conversion puc on
						uc.code = puc.code
					join dbo.part_inventory pi on
						pi.part = @Part
				where
					puc.part = @Part
					and
						uc.unit1 = pi.standard_unit
					and
						uc.unit2 = @Unit
			)
		,	1
		)

--- </Body>

---	<Return>
	return
		@Qty
end
go


/*
Create table fx21st.dbo.Scheduling_InLineProcess
*/

--use fx21st
--go

--drop table dbo.Scheduling_InLineProcess
if	objectproperty(object_id('dbo.Scheduling_InLineProcess'), 'IsView') = 1 begin
	drop view dbo.Scheduling_InLineProcess
end
go

create view dbo.Scheduling_InLineProcess
as
select
	TopPartCode
,	DefaultOutputPartCode = coalesce
	(	(	select
				min(pm1.ChildPartCode)
			from
				(	select
						TopPartCode = xr.TopPart
					,   ChildPartCode = xr.ChildPart
					,	xr.Sequence
					,   xr.Hierarchy
					,   MachineCode = pm.machine
					from
						FT.XRt xr
						join dbo.part_machine pm
							on pm.part = xr.ChildPart
				) pm1
			where
				pm1.TopPartCode = pm.TopPartCode
				and pm1.Sequence =
				(	select
						max(pm2.Sequence)
					from
						(	select
								TopPartCode = xr.TopPart
							,   ChildPartCode = xr.ChildPart
							,	xr.Sequence
							,   xr.Hierarchy
							,   MachineCode = pm.machine
							from
								FT.XRt xr
								join dbo.part_machine pm
									on pm.part = xr.ChildPart
						) pm2
					where
						pm2.TopPartCode = pm.TopPartCode
						and pm.MachineCode in (pm2.MachineCode)
						and pm.Sequence > pm2.Sequence
						and pm.Hierarchy like pm2.Hierarchy + '%'
				)
				and not exists
				(	select
						*
					from
						(	select
								TopPartCode = xr.TopPart
							,   ChildPartCode = xr.ChildPart
							,	xr.Sequence
							,   xr.Hierarchy
							,   MachineCode = pm.machine
							from
								FT.XRt xr
								join dbo.part_machine pm
									on pm.part = xr.ChildPart
						) pm3
					where
						pm3.TopPartCode = pm.TopPartCode
						and pm3.Hierarchy like pm1.Hierarchy + '%'
						and pm.Hierarchy like pm3.Hierarchy + '%'
						and pm3.Sequence > pm1.Sequence
						and pm3.Sequence < pm.Sequence
						and not exists
						(	select
								*
							from
								(	select
										TopPartCode = xr.TopPart
									,   ChildPartCode = xr.ChildPart
									,	xr.Sequence
									,   xr.Hierarchy
									,   MachineCode = pm.machine
									from
										FT.XRt xr
										join dbo.part_machine pm
											on pm.part = xr.ChildPart
								) pm4
							where
								pm4.TopPartCode = pm.TopPartCode
								and pm4.Sequence = pm3.Sequence
								and pm4.MachineCode = pm.MachineCode
						)
				)
		)
	,	ChildPartCode
	)
,	OutputPartCode = ChildPartCode
,	Sequence
,	MachineCode
,	Hierarchy
from
	(	select
			TopPartCode = xr.TopPart
		,   ChildPartCode = xr.ChildPart
		,	xr.Sequence
		,   xr.Hierarchy
		,   MachineCode = pm.machine
		from
			FT.XRt xr
			join dbo.part_machine pm
				on pm.part = xr.ChildPart
	) pm
go

/*
Create table fx21st.custom.MoldingColorLetdown
*/


/*
Create schema fx.custom
*/

--use fx
--go

-- Create the database schema
if	schema_id('custom') is null begin
	exec sys.sp_executesql N'create schema custom authorization dbo'
end
go



--use fx21st
--go

--drop table custom.MoldingColorLetdown
if	objectproperty(object_id('custom.MoldingColorLetdown'), 'IsTable') is null begin

	create table custom.MoldingColorLetdown
	(	MoldApplication varchar(50)
	,	BaseMaterialCode varchar(25)
	,	ColorCode varchar(5)
	,	ColorName varchar(30)
	,	ColorantCode varchar(25)
	,	LetDownRate numeric(4,2)
	,	Status int not null default(0)
	,	Type int not null default(0)
	,	RowID int identity(1,1) primary key clustered
	,	RowCreateDT datetime default(getdate())
	,	RowCreateUser sysname default(suser_name())
	,	RowModifiedDT datetime default(getdate())
	,	RowModifiedUser sysname default(suser_name())
	,	unique nonclustered
		(	MoldApplication
		,	BaseMaterialCode
		,	ColorCode
		)
	)
end
go


--drop table dbo.Defects
if	object_id ('dbo.Defects') is null begin

	create table dbo.Defects
	(	ID int not null IDENTITY(1, 1) primary key
	,	TransactionDT datetime not null
	,	Machine varchar(10) not null
	,	Part varchar(25) not null
	,	DefectCode varchar(20) null
	,	QtyScrapped numeric(20, 6) null
	,	Operator varchar(10) null
	,	Shift char(1) null
	,	WODID int null
	,	DefectSerial int null
	,	Comments varchar(150) null
	,	AuditTrailID int null
	,	AreaToCharge varchar(25) null
	)
end
go

if	not exists
	(	select
			*
		from
			dbo.sysindexes
		where
			id = object_id(N'dbo.Defects')
			and name = N'idx_Defects_1'
	) begin
	
    create nonclustered index idx_Defects_1 on dbo.Defects 
    (	DefectSerial asc
    ,	ID asc
    )
end
go

if	not exists
	(	select
			*
		from
			dbo.sysindexes
		where
			id = object_id(N'dbo.Defects')
			and name = N'idx_Defects_2'
	) begin
	
    create nonclustered index idx_Defects_2 on dbo.Defects 
    (	TransactionDT asc
    ,	DefectCode asc
    ,	Part asc
    ,	DefectSerial asc
    )
end
go

select
	*
from
	dbo.Defects d

/*
Create table fx21st.dbo.WorkOrderObjects
*/

--use fx21st
--go

--drop table dbo.WorkOrderObjects
if	objectproperty(object_id('dbo.WorkOrderObjects'), 'IsTable') is null begin

	create table dbo.WorkOrderObjects
	(	Serial int unique
	,	WorkOrderNumber varchar(50) not null
	,	WorkOrderDetailLine float not null default (0)
	,	Status int not null default(0)
	,	Type int not null default(0)
	,	PartCode varchar(25) not null
	,	PackageType varchar(25) null
	,	OperatorCode varchar(5) not null
	,	Quantity numeric(20,6) not null
	,	CompletionDT datetime null
	,	BackflushNumber varchar(50) null references dbo.BackflushHeaders(BackflushNumber)
	,	UndoBackflushNumber varchar(50) null references dbo.BackflushHeaders(BackflushNumber)
	,	RowID int identity(1,1) primary key clustered
	,	RowCreateDT datetime default(getdate())
	,	RowCreateUser sysname default(suser_name())
	,	RowModifiedDT datetime default(getdate())
	,	RowModifiedUser sysname default(suser_name())
	,	foreign key
		(
			WorkOrderNumber
		,	WorkOrderDetailLine
		) references dbo.WorkOrderDetails
		(
			WorkOrderNumber
		,	Line
		)
	)
end
go


--drop table FT.XRt
if	object_id ('FT.XRt') is null begin

	create table FT.XRt
	(
		ID int not null identity(1,1) primary key
	,	TopPart varchar (25) null
	,	ChildPart varchar (25) null
	,	BOMID int null
	,	Sequence smallint null
	,	BOMLevel smallint not null default (0)
	,	XQty float null default (1)
	,	XScrap float null default (1)
	,	XBufferTime float not null default (0)
	,	XRunRate float not null default (0)
	,	Hierarchy varchar(500)
	,	Infinite smallint not null default (0)
	,	unique
		(	TopPart
		,	Sequence
		)
	)

	create index XRt_1 on FT.XRt
	(
		TopPart
	,	ChildPart
	,	Sequence
	,	XQty
	,	XScrap
	,	XBufferTime
	,	ID
	)

	create index XRt_2 on FT.XRt
	(
		ChildPart
	,	BOMLevel
	)
end
go

if not exists ( select
                    *
                from
                    dbo.sysindexes
                where
                    id = object_id(N'FT.XRt')
                    and name = N'idx_XRt_1' ) 
    create nonclustered index idx_XRt_1 on FT.XRt 
    (
    BOMLevel asc,
    ChildPart asc,
    ID asc
    )
go
if not exists ( select
                    *
                from
                    dbo.sysindexes
                where
                    id = object_id(N'FT.XRt')
                    and name = N'idx_XRt_2' ) 
    create nonclustered index idx_XRt_2 on FT.XRt 
    (
    TopPart asc,
    Hierarchy asc,
    ID asc
    )
go
if not exists ( select
                    *
                from
                    dbo.sysindexes
                where
                    id = object_id(N'FT.XRt')
                    and name = N'idx_XRt_3' ) 
    create nonclustered index idx_XRt_3 on FT.XRt 
    (
    ChildPart asc,
    BOMLevel asc,
    ID asc
    )
go
if not exists ( select
                    *
                from
                    dbo.sysindexes
                where
                    id = object_id(N'FT.XRt')
                    and name = N'idx_XRt_4' ) 
    create nonclustered index idx_XRt_4 on FT.XRt 
    (
    ChildPart asc,
    TopPart asc,
    ID asc
    )
go
if not exists ( select
                    *
                from
                    dbo.sysindexes
                where
                    id = object_id(N'FT.XRt')
                    and name = N'idx_XRt_5' ) 
    create nonclustered index idx_XRt_5 on FT.XRt 
    (
    TopPart asc,
    ChildPart asc,
    XQty asc,
    ID asc
    )
go

if	objectproperty(object_id('dbo.fn_GetNetout'), 'IsTableFunction') = 1 begin
	drop function dbo.fn_GetNetout
end
go

create function dbo.fn_GetNetout
()
returns @NetMPS table
(	ID int identity primary key
,	OrderNo int default (-1) not null
,	LineID int not null
,	Part varchar(25) not null
,	RequiredDT datetime not null
,	GrossDemand numeric(30,12) not null
,	Balance numeric(30,12) not null
,	OnHandQty numeric(30,12) default (0) not null
,	InTransitQty numeric(30,12) default (0) not null
,	WIPQty numeric(30,12) default (0) not null
,	LowLevel int not null
,	Sequence int not null
)
as
begin
--- <Body>
	declare
		@CurrentDatetime datetime
	
	set @CurrentDatetime = (select CurrentDatetime from dbo.vwGetDate vgd)
	
	--create index idx_#NetMPS_1 on #NetMPS (LowLevel, Part)
	--create index idx_#NetMPS_2 on #NetMPS (Part, RequiredDT, Balance)
	
	insert
		@NetMPS
	(	OrderNo
	,	LineID
	,	Part
	,	RequiredDT
	,	GrossDemand
	,	Balance
	,	LowLevel
	,	Sequence)
	select
		OrderNo
	,	LineID
	,	Part = XRt.ChildPart
	,	RequiredDT = ShipDT
	,	GrossDemand = StdQty * XQty
	,	Balance = StdQty * XQty
	,	LowLevel =
		(	select
				max(XRT1.BOMLevel)
			from
				FT.XRt XRT1
			where
				XRT1.ChildPart = XRt.ChildPart
		)
	,	Sequence
	from
		dbo.vwSOD SOD
		join FT.XRt XRt
			on SOD.Part = XRt.TopPart

	--select
	--	*
	--from
	--	@NetMPS

	declare @Inventory table
	(	Part varchar(25)
	,	OnHand numeric(30,12)
	,	InTransit numeric(30,12)
	,	LowLevel int
	)

	--create index idx_#OnHand_1 on #OnHand (LowLevel, Part, OnHand)

	insert
		@Inventory
	(	Part
	,	OnHand
	,	InTransit
	,	LowLevel
	)
	select
		Part = part
	,	OnHand = sum(o.std_quantity)
	,	InTransit = 0
	,	LowLevel =
		(	select
				max(LowLevel)
			from
				@NetMPS
			where
				Part = o.part
		)
	from
		dbo.object o
	where
		status in ('A', 'H')
		and type is null
	group by
		part

	--select
	--	*
	--from
	--	@Inventory

	declare @X table
	(	Part varchar(25)
	,	OnhandQty numeric(20,6)
	,	InTransitQty numeric(20,6)
	,	OrderNo int
	,	LineID int
	,	Sequence int
	,	WIPQty numeric(30,12)
	)

	--create index idx_#X_1 on #X (OrderNo, LineID, Sequence)

	declare
		@LowLevel int
	,	@MaxLowLevel int

	set	@MaxLowLevel =
		(	select
				max(LowLevel)
			from
				@NetMPS
		)

	set	@LowLevel = 0
	while
		@LowLevel <= @MaxLowLevel begin

		declare	PartsOnHand cursor local for
		select
			Part
		,	OnHand
		,	InTransit
		from
			@Inventory
		where
			OnHand + InTransit > 0
			and LowLevel = @LowLevel
		order by
			Part
		
		open
			PartsOnHand
			
		declare
			@Part varchar(25)
		,	@OnHandQty numeric(30,12)
		,	@InTransitQty numeric(30,12)
		
		while
			1 = 1 begin
			
			fetch
				PartsOnHand
			into
				@Part
			,	@OnHandQty
			,	@InTransitQty
			
			if	@@FETCH_STATUS != 0 begin
				break
			end
			
			declare	Requirements cursor local for
			select
				ID
			,	Balance
			,	OrderNo
			,	LineID
			,	Sequence
			from
				@NetMPS
			where
				Part = @Part
				and Balance > 0
			order by
				RequiredDT asc
			
			open
				Requirements
			
			declare
				@ReqID integer
			,   @Balance numeric(30,12)
			,   @OrderNo integer
			,   @LineID integer
			,   @Sequence integer
			
			while
				1 = 1
				and @OnHandQty + @InTransitQty > 0 begin
				
				fetch
					Requirements
				into
					@ReqID
				,	@Balance
				,	@OrderNo
				,	@LineID
				,	@Sequence
				
				if	@@FETCH_STATUS != 0 begin
					break
				end
				
				if	@Balance > @OnHandQty and @OnHandQty > 0 begin
					update
						@NetMPS
					set
						Balance = @Balance - @OnHandQty
					,	OnHandQty = OnHandQty + @OnHandQty
					where
						ID = @ReqID
					
					insert
						@X
					(	Part
					,	OnhandQty
					,	OrderNo
					,	LineID
					,	Sequence
					,	WIPQty
					)
					select
						Part = @Part
					,	OnhandQty = @OnHandQty
					,	OrderNo = @OrderNo
					,	LineID = @LineID
					,	Sequence = @Sequence + Sequence
					,	WIPQty = @OnHandQty * XQty
					from
						FT.XRt xr
					where
						TopPart = @Part
						and Sequence > 0
					
					set	@Balance = @Balance - @OnHandQty
					set	@OnHandQty = 0
				end
				else if @OnHandQty > 0 begin
					update
						@NetMPS
					set
						Balance = 0
					,	OnHandQty = OnHandQty + @Balance
					where
						ID = @ReqID
					
					insert
						@X
					(	Part
					,	OnhandQty
					,	OrderNo
					,	LineID
					,	Sequence
					,	WIPQty
					)
					select
						Part = @Part
					,	OnhandQty = @Balance
					,	OrderNo = @OrderNo
					,	LineID = @LineID
					,	Sequence = @Sequence + Sequence
					,	WIPQty = @Balance * XQty
					from
						FT.XRt xr
					where
						TopPart = @Part
						and Sequence > 0
					
					set	@OnHandQty = @OnHandQty - @Balance
					set @Balance = 0
				end
				
				if	@Balance > @InTransitQty and @Balance > 0 and @InTransitQty > 0 begin
					update
						@NetMPS
					set
						Balance = @Balance - @InTransitQty
					,	InTransitQty = InTransitQty + @InTransitQty
					where
						ID = @ReqID
					
					insert
						@X
					(	Part
					,	InTransitQty
					,	OrderNo
					,	LineID
					,	Sequence
					,	WIPQty
					)
					select
						Part = @Part
					,	InTransitQty = @InTransitQty
					,	OrderNo = @OrderNo
					,	LineID = @LineID
					,	Sequence = @Sequence + Sequence
					,	WIPQty = @InTransitQty * XQty
					from
						FT.XRt xr
					where
						TopPart = @Part
						and Sequence > 0
					
					set	@InTransitQty = 0
				end
				else if @Balance > 0 and @InTransitQty > 0 begin
					update
						@NetMPS
					set
						Balance = 0
					,	InTransitQty = InTransitQty + @Balance
					where
						ID = @ReqID
					
					insert
						@X
					(	Part
					,	InTransitQty
					,	OrderNo
					,	LineID
					,	Sequence
					,	WIPQty
					)
					select
						Part = @Part
					,	InTransitQty = @Balance
					,	OrderNo = @OrderNo
					,	LineID = @LineID
					,	Sequence = @Sequence + Sequence
					,	WIPQty = @Balance * XQty
					from
						FT.XRt xr
					where
						TopPart = @Part
						and Sequence > 0
					
					set	@InTransitQty = @InTransitQty - @Balance
				end
			end
			close
				Requirements
			deallocate
				Requirements
		end
		close
			PartsOnHand
		deallocate
			PartsOnHand

		set	@LowLevel = @LowLevel + 1
		
		update
			nmps
		set	WIPQty = coalesce(
			(	select
					sum(WIPQty)
				from
					@X
				where
					OrderNo = nmps.OrderNo
					and LineID = nmps.LineID
					and Sequence = nmps.Sequence
			), 0)
		from
			@NetMPS nmps
		where
			LowLevel = @LowLevel

		update
			nmps
		set	Balance = Balance - WIPQty
		from
			@NetMPS nmps
		where
			LowLevel = @LowLevel
	end
--- </Body>

---	<Return>
	return
end
go

select
	*
from
	dbo.fn_GetNetout() fgn
order by
	Part
,	RequiredDT
go


if objectproperty(object_id('dbo.fn_MES_GetPartFIFO'), 'IsTableFunction') = 1 
	begin
		drop function dbo.fn_MES_GetPartFIFO
	end
go

create function dbo.fn_MES_GetPartFIFO
(	@Part varchar(25)
,	@Status varchar(1) = 'A'
,	@Plant varchar(10) = null
,	@Location varchar(10) = null
,	@GroupNo varchar(25) = null 
,	@Secured char(1) = 'N'
)
returns @Objects table
(	Serial int primary key
,	Location varchar(10)
,	Quantity numeric(20, 6)
,	BreakoutSerial int null
,	FirstDT datetime null
,	IsInFifo char(1)
)
as 
begin

	insert
		@Objects
	(	Serial
	,	Location
	,	Quantity
	,	BreakoutSerial
	)
	select
		Serial = object.serial
	,	Location = min(object.location)
	,	Quantity = min(object.quantity)
	,	BreakoutSerial = min(convert (int, Breakout.from_loc))
	from
		object
		join location
			on	location.code = object.location
		left join audit_trail BreakOut
			on	object.serial = BreakOut.serial
				and Breakout.type = 'B'
				and isnumeric(replace(replace(Breakout.from_loc, 'D', 'X'), 'E', 'Z')) = 1 -- I think this is to prevent locations with like X000 or D000 from being incorrectly idefintied as numbers.  Perhaps a not like '%[^0-9]%' would be better?
	where
		object.part = @Part
		and object.status = 'A'
		and coalesce(location.plant, 'X') = coalesce(@Plant, location.plant, 'X')
		and object.location = coalesce(@Location, object.location)
		and coalesce(location.group_no, 'X') = coalesce(@GroupNo, location.group_no, 'X')
		and coalesce(location.secured_location, 'N') = coalesce(@Secured, location.secured_location, 'N')
	group by
		object.serial

	while @@rowcount > 0 begin
		update
			@Objects
		set 
			BreakoutSerial = Breakout.BreakoutSerial
		from
			@Objects Objects
			join
			(	select
					Serial
				,	BreakoutSerial = min(convert (int, Breakout.from_loc))
				from
					audit_trail BreakOut
				where
					type = 'B'
					and serial in
					(	select
							BreakoutSerial
						from
							@Objects
						where
							BreakoutSerial > 0
					)
					and isnumeric(replace(replace(Breakout.from_loc, 'D', 'X'), 'E', 'Z')) = 1
				group by
					serial
			) Breakout
				on Objects.BreakoutSerial = Breakout.Serial
	end
	
	update
		@Objects
	set 
		FirstDT =
		(	select
				coalesce(min(case when type in ('A', 'R', 'J', 'E') then date_stamp end), min(date_stamp))
			from
				audit_trail with (index = audit_trail_serial_datestamp_ix)
			where
				type in ('A', 'R', 'J', 'E')
				and serial = coalesce(Objects.BreakoutSerial, Objects.Serial)
		)
	from
		@Objects Objects
	
	declare @FifoPart datetime
	
	select
		@FifoPart = min(FirstDT)
	from
		@Objects
	
	update
		@Objects
	set 
		IsInFifo = '*'
	where
		abs(datediff(day, FirstDT, @FifoPart)) = 0
	
	return
end
go

if	objectproperty(object_id('dbo.fn_MES_NetMPS'), 'IsTableFunction') = 1 begin
	drop function dbo.fn_MES_NetMPS
end
go

create function dbo.fn_MES_NetMPS
()
returns @NetMPS table
(	ID int not null IDENTITY(1, 1) primary key
,	ShipToCode varchar(20) null
,	OrderNo int default (-1) not null
,	LineID int not null
,	Part varchar(25) not null
,	RequiredDT datetime not null --default (getdate()) 
,	GrossDemand numeric(30,12) not null
,	Balance numeric(30,12) not null
,	OnHandQty numeric(30,12) default (0) not null
,	WIPQty numeric(30,12) default (0) not null
,	BuildableQty numeric(30,12) null
,	LowLevel int not null
,	Sequence int not null
,	AccumGrossDemand numeric(30,12) null
,	AccumBalance numeric(30,12) null
,	unique
	(	OrderNo
	,	LowLevel
	,	ID
	)
,	unique
	(	Part
	,	Sequence
	,	OrderNo
	,	ID
	)
,	unique
	(	OrderNo
	,	LineID
	,	LowLevel
	,	OnHandQty
	,	ID
	)
,	unique
	(	ShipToCode
	,	Part
	,	ID
	)
)
as
begin
-- <Body>
	insert
		@NetMPS
	(	ShipToCode
	,	OrderNo
	,	LineID
	,	Part
	,	RequiredDT
	,	GrossDemand
	,	Balance
	,	OnHandQty
	,	WIPQty
	,	LowLevel
	,	Sequence)
	select
		ShipToCode = od.destination
	,	fgn.OrderNo
	,	fgn.LineID
	,	fgn.Part
	,	fgn.RequiredDT
	,	fgn.GrossDemand
	,	fgn.Balance
	,	fgn.OnHandQty
	,	fgn.WIPQty
	,	fgn.LowLevel
	,	fgn.Sequence
	from
		dbo.fn_GetNetout() fgn
		left join dbo.order_detail od
			on od.order_no = fgn.OrderNo
			and od.id = fgn.LineID
			and od.part_number = fgn.Part
	order by
		od.destination
	,	fgn.Part
	,	fgn.RequiredDT
	
	update
		nm
	set	BuildableQty = 
		(	select
				min(nm2.OnHandQty / (xr.XQty * xr.XScrap))
			from
				FT.XRt xr
				join @NetMPS nm2
					on nm2.OrderNo = nm.OrderNo
					and nm2.LineID = nm.LineID
					and nm2.Sequence = nm.Sequence + xr.Sequence
				left join FT.XRt xrC
					on xrC.TopPart = xr.ChildPart
					and xrC.Sequence > 0
			where
				xr.TopPart = nm.Part
				and xrC.TopPart is null
		)
	from
		@NetMPS nm
	
	update
		nm
	set
		AccumGrossDemand = (select sum(nm2.GrossDemand) from @NetMPS nm2 where coalesce(nm.ShipToCode, '') = coalesce(nm2.ShipToCode, '') and nm.Part = nm2.Part and nm.ID >= nm2.ID)
	,	AccumBalance = (select sum(nm2.Balance) from @NetMPS nm2 where coalesce(nm.ShipToCode, '') = coalesce(nm2.ShipToCode, '') and nm.Part = nm2.Part and nm.ID >= nm2.ID)
	from
		@NetMPS nm
	-- </Body>

--	<Return>
	return
end
go

select
	fmnm.ID
,   fmnm.ShipToCode
,   fmnm.OrderNo
,   fmnm.LineID
,   fmnm.Part
,   fmnm.RequiredDT
,   fmnm.GrossDemand
,   fmnm.Balance
,   fmnm.OnHandQty
,   fmnm.WIPQty
,   fmnm.BuildableQty
,   fmnm.LowLevel
,   fmnm.Sequence
,   fmnm.AccumGrossDemand
,   fmnm.AccumBalance
from
	dbo.fn_MES_NetMPS() fmnm


if	objectproperty(object_id('dbo.MES_CurrentSchedules'), 'IsView') = 1 begin
	drop view dbo.MES_CurrentSchedules
end
go

create view dbo.MES_CurrentSchedules
as
select
	WODID = max(wodActive.RowID)
,	WorkOrderNumber = max(wohActive.WorkOrderNumber)
,   WorkOrderStatus = max(wohActive.Status)
,   WorkOrderType = max(wohActive.Type)
,   MachineCode = max(wohActive.MachineCode)
,   WorkOrderDetailLine = max(wodActive.Line)
,   WorkOrderDetailStatus = max(wodActive.Status)
,   mjl.PartCode
,   WorkOrderDetailSequence = max(wodActive.Sequence)
,   DueDT = max(wodActive.DueDT)
,   QtyRequired = sum(mjl.QtyRequired)
,   QtyLabelled = sum(mjl.QtyLabelled)
,   QtyCompleted = sum(mjl.QtyCompleted)
,   QtyDefect = sum(mjl.QtyDefect)
,	StandardPack = max(mjl.StandardPack)
,	NewBoxesRequired = sum(mjl.NewBoxesRequired)
,	BoxesLabelled = sum(mjl.BoxesLabelled)
,	BoxesCompleted = sum(mjl.BoxesCompleted)
,   StartDT = max(wodActive.StartDT)
,   EndDT = max(wodActive.EndDT)
,   ShipperID = max(wodActive.ShipperID)
,   mjl.BillToCode
from
	dbo.MES_JobList mjl
	join dbo.WorkOrderHeaders wohActive
		join dbo.WorkOrderDetails wodActive
			on wodActive.WorkOrderNumber = wohActive.WorkOrderNumber
		on wodActive.PartCode = mjl.PartCode
		and wodActive.CustomerCode = mjl.BillToCode
		and wodActive.RowID = coalesce
		(	(	select
		 			max(wod.RowID)
		 		from
					dbo.WorkOrderHeaders woh
						join dbo.WorkOrderDetails wod
							on wod.WorkOrderNumber = woh.WorkOrderNumber
				where
					wod.RowID = wodActive.RowID
					and	woh.Status in
					(	select
	 						sd.StatusCode
	 					from
	 						FT.StatusDefn sd
	 					where
	 						sd.StatusTable = 'dbo.WorkOrderHeaders'
	 						and sd.StatusName = 'Running'
					 )
					 and wod.Status in
					 (	select
	  						sd.StatusCode
	  					from
	  						FT.StatusDefn sd
	  					where
	  						sd.StatusTable = 'dbo.WorkOrderDetails'
	 						and sd.StatusName = 'Running'
					 )
			)
		,	(	select
		 			max(wod.RowID)
		 		from
					dbo.WorkOrderHeaders woh
						join dbo.WorkOrderDetails wod
							on wod.WorkOrderNumber = woh.WorkOrderNumber
				where
					wod.RowID = wodActive.RowID
					and	woh.Status in
					(	select
							sd.StatusCode
						from
							FT.StatusDefn sd
						where
							sd.StatusTable = 'dbo.WorkOrderHeaders'
							and sd.StatusName = 'New'
					 )
					 and wod.Status in
					 (	select
							sd.StatusCode
						from
							FT.StatusDefn sd
						where
							sd.StatusTable = 'dbo.WorkOrderDetails'
							and sd.StatusName = 'New'
					 )
			)
		)
group by
	mjl.PartCode
,	mjl.BillToCode
go

select
	*
from
	dbo.MES_CurrentSchedules mcs

/*
Create view fx21st.dbo.MES_JobList
*/

--use fx21st
--go

--drop table dbo.MES_JobList
if	objectproperty(object_id('dbo.MES_JobList'), 'IsView') = 1 begin
	drop view dbo.MES_JobList
end
go

create view dbo.MES_JobList
as
select
	WODID = wod.RowID
,	WorkOrderNumber = woh.WorkOrderNumber
,   WorkOrderStatus = woh.Status
,   WorkOrderType = woh.Type
,   MachineCode = woh.MachineCode
,   WorkOrderDetailLine = wod.Line
,   WorkOrderDetailStatus = wod.Status
,   wod.PartCode
,   WorkOrderDetailSequence = wod.Sequence
,   DueDT = wod.DueDT
,   QtyRequired = wod.QtyRequired
,   QtyLabelled = wod.QtyLabelled
,   QtyCompleted = wod.QtyCompleted
,   QtyDefect = wod.QtyDefect
,	StandardPack = pi.standard_pack
,	NewBoxesRequired = case when wod.QtyRequired > wod.QtyLabelled then ceiling((wod.QtyRequired - wod.QtyLabelled) / pi.standard_pack) else 0 end
,	BoxesLabelled = coalesce(boxes.BoxesLabelled, 0)
,	BoxesCompleted = coalesce(boxes.BoxesCompleted, 0)
,   StartDT = wod.StartDT
,   EndDT = wod.EndDT
,   ShipperID = wod.ShipperID
,   BillToCode = wod.CustomerCode
from
	dbo.WorkOrderHeaders woh
		join dbo.WorkOrderDetails wod
			on wod.WorkOrderNumber = woh.WorkOrderNumber
		left join
		(	select
		 		woo.WorkOrderNumber
		 	,	woo.WorkOrderDetailLine
		 	,	BoxesLabelled = count(*)
		 	,	BoxesCompleted = count(woo.CompletionDT)
		 	from
		 		dbo.WorkOrderObjects woo
		 	group by
		 		woo.WorkOrderNumber
		 	,	woo.WorkOrderDetailLine
		 ) boxes
		 on boxes.WorkOrderNumber = wod.WorkOrderNumber
		 and boxes.WorkOrderDetailLine = wod.Line
	join dbo.part_inventory pi
		on wod.PartCode = pi.part
where
	woh.Status in
	(	select
	 		sd.StatusCode
	 	from
	 		FT.StatusDefn sd
	 	where
	 		sd.StatusTable = 'dbo.WorkOrderHeaders'
	 		and sd.StatusName in ('Open', 'Hold', 'New', 'Running')
	 )
	 and wod.Status in
	 (	select
	  		sd.StatusCode
	  	from
	  		FT.StatusDefn sd
	  	where
	  		sd.StatusTable = 'dbo.WorkOrderDetails'
	 		and sd.StatusName in ('Open', 'Hold', 'New', 'Running')
	 )
go

select
	*
from
	dbo.MES_JobList

if	objectproperty(object_id('dbo.MES_PickList'), 'IsView') = 1 begin
	drop view dbo.MES_PickList
end
go

create view dbo.MES_PickList
as
select
	cs.MachineCode
,	cs.WODID
,	cs.PartCode
,	ChildPart = wodbom.ChildPart
,	QtyRequired = (cs.QtyRequired - cs.QtyCompleted) * wodbom.XQty
,	QtyAvailable = alloc.QtyAvailable
,	QtyToPull = (cs.QtyRequired - cs.QtyCompleted) * wodbom.XQty - coalesce(alloc.QtyAvailable, 0)
,	FIFOLocation = dbo.fn_MES_GetFIFOLocation_forPart(wodbom.ChildPart, 'A', null, null, null, 'N')
,	ProductLine = p.product_line
,	Commodity = p.commodity
,	PartName = p.name
from
	(	select
	 		cs.MachineCode
		,	cs.WODID
		,	cs.WorkOrderNumber
		,	cs.WorkOrderDetailLine
		,	cs.PartCode
		,	cs.QtyRequired
		,	cs.QtyCompleted
	 	from
	 		dbo.MES_CurrentSchedules cs
	 	group by
	 		cs.MachineCode
		,	cs.WODID
		,	cs.WorkOrderNumber
		,	cs.WorkOrderDetailLine
		,	cs.PartCode
		,	cs.QtyRequired
		,	cs.QtyCompleted
	) cs
	left join dbo.WorkOrderDetailBillOfMaterials wodbom
	on
		wodbom.WorkOrderNumber = cs.WorkOrderNumber
		and wodbom.WorkOrderDetailLine = cs.WorkOrderDetailLine
	left join dbo.part p on
		p.part = wodbom.ChildPart
	left join
	(	select
	 		Part = o.part
	 	,	Machine = o.location
	 	,	QtyAvailable = sum(o.std_quantity)
	 	from
	 		dbo.object o
	 	where
	 		o.status = 'A'
	 	group by
	 		o.part
	 	,	o.location
	) alloc on
		alloc.Part = wodbom.ChildPart
		and
			alloc.Machine = cs.MachineCode
where
	cs.QtyRequired > cs.QtyCompleted
go

select
	MachineCode
,	WODID
,	PartCode
,	ChildPart
,	QtyRequired
,	QtyAvailable
,	QtyToPull
,	FIFOLocation
,	ProductLine
,	Commodity
,	PartName
from
	dbo.MES_PickList pl
order by
	Commodity

/*
insert
	dbo.group_technology
(	id
,	notes
,	source_type
)
values
(	'EEA Warehouse'
,	'Material warehouse in Florence, AL'
,	null
)

update
	dbo.location
set
	group_no = 'EEA Warehouse'
where
	code like 'ALA%'
*/

/*
Create view fx21st.dbo.Scheduling_NetRequirementsSummary
*/

--use fx21st
--go

--drop table dbo.Scheduling_NetRequirementsDetails
if	objectproperty(object_id('dbo.Scheduling_NetRequirementsDetails'), 'IsView') = 1 begin
	drop view dbo.Scheduling_NetRequirementsDetails
end
go

create view dbo.Scheduling_NetRequirementsDetails
as
select
	PrimaryMachineCode = pm.machine
,	BuildPartCode = fmnm.Part
,	OrderNo = oh.order_no
,	BillToCode = oh.customer
,	ShipToCode = oh.destination
,	fmnm.LowLevel
,	RequiredDT = fmnm.RequiredDT
,	QtyTotalDue = convert(numeric(20,6), fmnm.GrossDemand)
,	QtyAvailable = fmnm.OnHandQty
,	QtyAlreadyProduced = fmnm.WIPQty
,	QtyNetDue = fmnm.Balance
,	QtyBuildable = fmnm.BuildableQty
,	RunningWODID = wodR.RowID
,	QtyRunningBuild =
	case
		when
			(	case
					when wodR.QtyRequired >= wodR.QtyLabelled then wodR.QtyRequired
					else wodR.QtyLabelled
				end - wodR.QtyCompleted
			) > fmnm.AccumBalance
			then
			(	case
					when wodR.QtyRequired >= wodR.QtyLabelled then wodR.QtyRequired
					else wodR.QtyLabelled
				end - wodR.QtyCompleted
			)
		when
			(	case
					when wodR.QtyRequired >= wodR.QtyLabelled then wodR.QtyRequired
					else wodR.QtyLabelled
				end - wodR.QtyCompleted
			) < fmnm.AccumBalance - fmnm.Balance
			then 0
		else
			(	case
					when wodR.QtyRequired >= wodR.QtyLabelled then wodR.QtyRequired
					else wodR.QtyLabelled
				end - wodR.QtyCompleted
			) - (fmnm.AccumBalance - fmnm.Balance)
	end	
,	NextWODID = wodN.RowID
,	QtyNextBuild =
	case
		when
			(	case
					when wodN.QtyRequired >= wodN.QtyLabelled then wodN.QtyRequired
					else wodN.QtyLabelled
				end - wodN.QtyCompleted
			) > fmnm.AccumBalance
			then
			(	case
					when wodN.QtyRequired >= wodN.QtyLabelled then wodN.QtyRequired
					else wodN.QtyLabelled
				end - wodN.QtyCompleted
			)
		when
			(	case
					when wodN.QtyRequired >= wodN.QtyLabelled then wodN.QtyRequired
					else wodN.QtyLabelled
				end - wodN.QtyCompleted
			) < fmnm.AccumBalance - fmnm.Balance
			then 0
		else
			(	case
					when wodN.QtyRequired >= wodN.QtyLabelled then wodN.QtyRequired
					else wodN.QtyLabelled
				end - wodN.QtyCompleted
			) - (fmnm.AccumBalance - fmnm.Balance)
	end
,	BoxLabel = coalesce(oh.box_label, pi.label_format)
,	PalletLabel = oh.pallet_label
,	PackageType = coalesce(oh.package_type, (select max(code) from dbo.part_packaging where part = fmnm.Part))
,	TopPartCode = vs.Part
from
	dbo.fn_MES_NetMPS() fmnm
	join dbo.vwSOD vs
		on vs.LineID = fmnm.LineID
		and vs.OrderNo = fmnm.OrderNo
	left join dbo.order_header oh
		on oh.order_no = fmnm.OrderNo
		and oh.blanket_part = fmnm.Part
	join dbo.part_inventory pi
		on pi.part = fmnm.Part
	join dbo.part_machine pm
		on pm.part = fmnm.Part
		and pm.sequence = 1
	left join dbo.WorkOrderHeaders wohR
		join dbo.WorkOrderDetails wodR
			on wohR.WorkOrderNumber = wodR.WorkOrderNumber
		on wohR.Status = dbo.udf_StatusValue('dbo.WorkOrderHeaders', 'Running')
		and coalesce(wodR.SalesOrderNumber, -1) = coalesce(fmnm.OrderNo, -1)
		and coalesce(wodR.CustomerCode, '~~~~') = coalesce(oh.customer, '~~~~')
		and coalesce(wodR.DestinationCode, '~~~~') = coalesce(oh.destination, '~~~~')
		and coalesce(wodR.TopPartCode, vs.Part) = vs.Part
		and wodR.PartCode = fmnm.Part
	left join dbo.WorkOrderHeaders wohN
		join dbo.WorkOrderDetails wodN
			on wohN.WorkOrderNumber = wodN.WorkOrderNumber
		on wohN.Status = dbo.udf_StatusValue('dbo.WorkOrderHeaders', 'New')
		and coalesce(wodN.SalesOrderNumber, -1) = coalesce(fmnm.OrderNo, -1)
		and coalesce(wodN.CustomerCode, '~~~~') = coalesce(oh.customer, '~~~~')
		and coalesce(wodN.DestinationCode, '~~~~') = coalesce(oh.destination, '~~~~')
		and coalesce(wodN.TopPartCode, vs.Part) = vs.Part
		and wodN.PartCode = fmnm.Part
go

select
	*
from
	dbo.Scheduling_NetRequirementsDetails snrd
go


/*
Create view fx21st.dbo.Scheduling_NetRequirementsSummary
*/

--use fx21st
--go

--drop table dbo.Scheduling_NetRequirementsSummary
if	objectproperty(object_id('dbo.Scheduling_NetRequirementsSummary'), 'IsView') = 1 begin
	drop view dbo.Scheduling_NetRequirementsSummary
end
go

create view dbo.Scheduling_NetRequirementsSummary
as
select
	snrd.PrimaryMachineCode
,	snrd.BuildPartCode
,	snrd.OrderNo
,	snrd.BillToCode
,	snrd.ShipToCode
,	snrd.LowLevel
,	DueDT = min(case when snrd.QtyNetDue > 0 then snrd.RequiredDT end)
,	DaysOnHand = datediff(day, getdate(), min(case when snrd.QtyNetDue > 0 then snrd.RequiredDT end))
,	QtyTotalDue = sum(snrd.QtyTotalDue)
,	QtyAvailable = sum(snrd.QtyAvailable)
,	QtyAlreadyProduced = sum(snrd.QtyAlreadyProduced)
,	QtyNetDue = sum(snrd.QtyNetDue)
,	QtyBuildable = sum(snrd.QtyBuildable)
,	RunningWODID = min(snrd.RunningWODID)
,	QtyRunningBuild = sum(snrd.QtyRunningBuild)
,	NextWODID = min(snrd.NextWODID)
,	QtyNextBuild = sum(snrd.QtyNextBuild)
,	BoxLabel = max(snrd.BoxLabel)
,	PalletLabel = max(snrd.PalletLabel)
,	PackageType = max(snrd.PackageType)
,	snrd.TopPartCode
from
	dbo.Scheduling_NetRequirementsDetails snrd
group by
	snrd.PrimaryMachineCode
,	snrd.BuildPartCode
,	snrd.OrderNo
,	snrd.BillToCode
,	snrd.ShipToCode
,	snrd.LowLevel
,	snrd.TopPartCode
go


select
	*
from
	dbo.Scheduling_NetRequirementsSummary
go

select
	snrd.PrimaryMachineCode
,   snrd.BuildPartCode
,   snrd.OrderNo
,   snrd.BillToCode
,	DueDT = min(case when snrd.QtyNetDue > 0 then snrd.RequiredDT end)
,	DaysOnHand = datediff(day, getdate(), min(case when snrd.QtyNetDue > 0 then snrd.RequiredDT end))
,   QtyTotalDue = sum(snrd.QtyTotalDue)
,   QtyAvailable = sum(snrd.QtyAvailable)
,   QtyAlreadyProduced = sum(snrd.QtyAlreadyProduced)
,   QtyNetDue = sum(snrd.QtyNetDue)
,   QtyBuildable = sum(snrd.QtyBuildable)
,   RunningWODID = min(snrd.RunningWODID)
,   QtyRunningBuild = sum(snrd.QtyRunningBuild)
,   NextWODID = min(snrd.NextWODID)
,   QtyNextBuild = sum(snrd.QtyNextBuild)
,   BoxLabel = min(snrd.BoxLabel)
,   PalletLabel = min(snrd.PalletLabel)
,   PackageType = min(snrd.PackageType)
from
	dbo.Scheduling_NetRequirementsDetails snrd
where
	snrd.QtyNetDue > 0
group by
	snrd.PrimaryMachineCode
,   snrd.BuildPartCode
,   snrd.OrderNo
,   snrd.BillToCode
,   snrd.RunningWODID
,   snrd.NextWODID
go


/*
Create table fx21st.dbo.vwGetDate
*/

--use fx21st
--go

--drop table dbo.vwGetDate
if	objectproperty(object_id('dbo.vwGetDate'), 'IsView') = 1 begin
	drop view dbo.vwGetDate
end
go

create view dbo.vwGetDate
as
select
	CurrentDatetime = getdate()
go


/*
Create table fx21st.dbo.vwSOD
*/

--use fx21st
--go

--drop table dbo.vwSOD
if	objectproperty(object_id('dbo.vwSOD'), 'IsView') = 1 begin
	drop view dbo.vwSOD
end
go

create view dbo.vwSOD
as
select
    OrderNO = order_no
,	LineID = id
,	ShipDT = due_date
,	Part = part_number
,	StdQty = std_qty
from
    dbo.order_detail od
where
    std_qty > 0
go

