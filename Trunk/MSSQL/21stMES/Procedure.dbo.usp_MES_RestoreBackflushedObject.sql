
/*
Create Procedure.Fx.dbo.usp_MES_RestoreBackflushedObject.sql
*/

--use Fx
--go

if	objectproperty(object_id('dbo.usp_MES_RestoreBackflushedObject'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_MES_RestoreBackflushedObject
end
go

create procedure dbo.usp_MES_RestoreBackflushedObject
	@User varchar(5)
,	@Serial int
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
/*	Get the backflushes since the last non-backflush transaction. */
declare
	@Backflushes table
(	BackflushNumber varchar(50)
,	QtyIssue numeric(20,6)
,	WorkOrderNumber varchar(50)
,	WorkOrderDetailLine float
,	RowID int
)

insert
	@Backflushes

select
	bd.BackflushNumber
,	bd.QtyIssue
,	bh.WorkOrderNumber
,	bh.WorkOrderDetailLine
,	bd.RowID
from
	dbo.BackflushHeaders bh
	join dbo.BackflushDetails bd
		on bh.BackflushNumber = bd.BackflushNumber
where
	bd.SerialConsumed = @Serial
	and bd.RowCreateDT >
		(	select
				max(atBF.date_stamp)
			from
				dbo.audit_trail atBF
			where
				atBF.serial = @Serial
				and atBF.date_stamp not in
					(	select
							bh2.TranDT
						from
							dbo.BackflushHeaders bh2
							join dbo.BackflushDetails bd2
								on bh2.BackflushNumber = bd2.BackflushNumber
						where
							bd2.SerialConsumed = @Serial
					)
		)

/*	Validate backflush found. */
if	not exists
	(	select
			*
		from
			@Backflushes
	) begin
	
		set	@Result = 999999
		RAISERROR ('Error encountered in %s.  Object @d is not valid for recovery from backflush', 16, 1, @ProcName, @Serial)
		rollback tran @ProcName
		return
end

/*	Recover object. */
declare
	@restoreQty numeric(20,6)

select
	@restoreQty =
		(	select
				sum(b.QtyIssue)
			from
				@Backflushes b
		)

--- <Insert rows="1">
set	@TableName = 'dbo.object'

insert
	dbo.object
(	serial
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
	serial = @Serial
,   part = at.part
,   location = at.from_loc
,   last_date = @TranDT
,   unit_measure = at.unit
,   operator = @User
,   status = at.status
,   destination = at.destination
,   station = null
,   origin = at.origin
,   cost = at.cost
,   weight = dbo.fn_Inventory_GetPartNetWeight(at.part, @restoreQty)
,   parent_serial = null
,   note = 'Object recovered from backflush to ship.'
,   quantity = dbo.udf_GetQtyFromStdQty(at.part, @restoreQty, at.unit)
,   last_time = @TranDT
,   date_due = at.due_date
,   customer = at.customer
,   sequence = at.sequence
,   shipper = null
,   lot = at.lot
,   type = at.object_type
,   po_number = at.po_number
,   name = at.part_name
,   plant = at.plant
,   start_date = at.start_date
,   std_quantity = @restoreQty
,   package_type = at.package_type
,   field1 = at.field1
,   field2 = at.field2
,   custom1 = at.custom1
,   custom2 = at.custom2
,   custom3 = at.custom3
,   custom4 = at.custom4
,   custom5 = at.custom5
,   show_on_shipper = 'N'
,   tare_weight = at.tare_weight
,   suffix = at.suffix
,   std_cost = at.std_cost
,   user_defined_status = at.user_defined_status
,   workorder = at.workorder
,   engineering_level = at.engineering_level
,   kanban_number = at.kanban_number
,   dimension_qty_string = at.dimension_qty_string
,   dim_qty_string_other = at.dim_qty_string_other
,   varying_dimension_code = at.varying_dimension_code
,   posted = at.posted
from
	dbo.audit_trail at
where
	at.serial = @Serial
	and at.ID = (select min(LastTransID) from dbo.InventoryControl_CycleCount_GetSerialInfo(@Serial))

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

/*	Find available material to compensate. */
declare	@MaterialAvailable table
(	Serial int
,	AllocationDT datetime
,	QtyAvailable numeric(20,6)
,	QtyPrior numeric(20,6)
,	RowID int not null IDENTITY(1, 1) primary key
,	unique
	(	Serial
	)
)

insert
	@MaterialAvailable
(	Serial
,	AllocationDT
,	QtyAvailable)
select
	Serial = oAvailable.Serial
,	AllocationDT = coalesce
	(	(	select
				max(atTransfer.date_stamp)
			from
				dbo.audit_trail atTransfer
			where
				atTransfer.Serial = oAvailable.Serial
				and atTransfer.type = 'T'
		)
	,	(	select
				max(atBreak.date_stamp)
			from
				dbo.audit_trail atBreak
			where
				atBreak.Serial = oAvailable.Serial
				and atBreak.type = 'B'
		)
	,	(	select
				min(atOrig.date_stamp)
			from
				dbo.audit_trail atOrig
			where
				atOrig.Serial = oAvailable.Serial
		)
	)
,	QtyAvailable = coalesce(oAvailable.QtyAvailable, 0)
from
	(	select
			Serial = o.serial
		,	Part = o.part
		,	LocationCode = o.location
		,	QtyAvailable = o.std_quantity
		from
			dbo.object o
		where
			o.status = 'A'
			and o.part =
				(	select
						at.part
					from
						dbo.audit_trail at
					where
						at.serial = @Serial
						and at.ID = (select min(LastTransID) from dbo.InventoryControl_CycleCount_GetSerialInfo(@Serial))
				)
			and o.std_quantity > 0
	) oAvailable
		join dbo.MES_SetupBackflushingPrinciples msbp
			on msbp.Type = 3
			and msbp.ID = oAvailable.Part
			and msbp.BackflushingPrinciple = 5 --(select dbo.udf_TypeValue('dbo.MES_SetupBackflushingPrinciples', 'BackflushingPrinciple', 'Plant'))
where
	oAvailable.Serial != @Serial
	and exists
		(	select
				*
			from
				dbo.location lPlant
					join dbo.location lPlantMachines -- All the machines within the inventory's plant.
						on coalesce(lPlantMachines.plant, 'N/A') = coalesce(lPlant.plant, 'N/A')
				join dbo.WorkOrderDetails wod
					join dbo.WorkOrderHeaders woh
						on woh.WorkOrderNumber = wod.WorkOrderNumber
					on exists
						(	select
								*
							from
								@Backflushes b
							where
								b.WorkOrderNumber = wod.WorkOrderNumber
								and b.WorkOrderDetailLine = wod.Line
						)
					and woh.MachineCode = coalesce(lPlantMachines.code, oAvailable.LocationCode)
				join dbo.machine m
					on m.machine_no = coalesce(lPlantMachines.code, oAvailable.LocationCode)
					and m.machine_no = woh.MachineCode
			where
				lPlant.code = oAvailable.LocationCode
		)
order by
	AllocationDT

update
	ma
set
	QtyPrior = coalesce
		(	(	select
					sum(ma2.QtyAvailable)
				from
					@MaterialAvailable ma2
				where
					ma2.RowID < ma.RowID
			)
		,	0
		)
from
	@MaterialAvailable ma

/*	Reduce compensatory inventory. */
--- <Update rows="*">
set	@TableName = 'dbo.object'

update
	o
set
	quantity =
		case
			when ma.QtyAvailable + ma.QtyPrior < @restoreQty then 0
			else dbo.udf_GetQtyFromStdQty(o.part, ma.QtyAvailable + ma.QtyPrior - @restoreQty, o.unit_measure)
		end
,	std_quantity =
		case
			when ma.QtyAvailable + ma.QtyPrior < @restoreQty then 0
			else ma.QtyAvailable + ma.QtyPrior - @restoreQty
		end
,	weight = 
		case
			when ma.QtyAvailable + ma.QtyPrior < @restoreQty then 0
			else dbo.fn_Inventory_GetPartNetWeight(o.part, ma.QtyAvailable + ma.QtyPrior - @restoreQty)
		end
from
	dbo.object o
		join @MaterialAvailable ma
			on ma.Serial = o.serial
where
	ma.QtyPrior < @restoreQty

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

---	<CloseTran AutoCommit=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
---	</CloseTran AutoCommit=Yes>

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
	@ProcReturn = dbo.usp_MES_RestoreBackflushedObject
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

