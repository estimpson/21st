declare
	@serial int; set @serial = 1911122
declare
	@user varchar(5); set @user = 'EES'

declare
	@TranDT datetime; set @TranDT = getdate()

declare
	@Backflushes table
(	BackflushNumber varchar(50)
,	QtyIssue numeric(20,6)
,	WorkOrderNumber varchar(50)
,	WorkOrderDetailLine float
,	BFD_RowID int
,	Line float
,	NextLine float
,	QtyPrior numeric(20,6)
,	RowID int not null IDENTITY(1, 1) primary key
)

insert
	@Backflushes
(	BackflushNumber
,	QtyIssue
,	WorkOrderNumber
,	WorkOrderDetailLine
,	BFD_RowID
,	Line
,	NextLine
)
select
	bd.BackflushNumber
,	bd.QtyIssue - bd.QtyOverage
,	bh.WorkOrderNumber
,	bh.WorkOrderDetailLine
,	bd.RowID
,	bd.Line
,	coalesce(bdNext.Line, bd.Line + 1)
from
	dbo.BackflushHeaders bh
	join dbo.BackflushDetails bd
		left join dbo.BackflushDetails bdNext
			on bdNext.BackflushNumber = bd.BackflushNumber
			and bdNext.Line =
				(	select
						min(bd2.Line)
					from
						dbo.BackflushDetails bd2
					where
						bd2.BackflushNumber = bd.BackflushNumber
						and bd2.Line > bd.Line
				)
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
order by
	bh.TranDT
,	bd.Line

update
	b
set
	QtyPrior = coalesce
		(	(	select
					sum(b2.QtyIssue)
				from
					@Backflushes b2
				where
					b2.RowID < b.RowID
			)
		,	0
		)
from
	@Backflushes b

select
	*
from
	@backflushes

declare
	@restoreQty numeric(20,6)

select
	@restoreQty =
		(	select
				sum(b.QtyIssue)
			from
				@Backflushes b
		)

select
	dbo.udf_GetQtyFromStdQty(at.part, @restoreQty, at.unit)
from
	dbo.audit_trail at
where
	at.serial = @Serial
	and at.ID = (select min(LastTransID) from dbo.InventoryControl_CycleCount_GetSerialInfo(@Serial))

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
			and o.shipper is null
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

declare
	@newBackflush table
(	BFD_RowID int
,	B_RowID int
,	MA_RowID int
,	BackflushNumber varchar(50)
,	Line float
,	NextLine float
,	LineSegment int
,	NewLine float
,	Serial int
,	NewIssue decimal(20,6)
)

insert
	@newBackflush
(	BFD_RowID
,	B_RowID
,	MA_RowID
,	BackflushNumber
,	Line
,	NextLine
,	LineSegment
,	Serial
,	NewIssue
)
select
	b.BFD_RowID
,	b.RowID
,	ma.RowID
,	b.BackflushNumber
,	b.Line
,	b.NextLine
,	LineSegment = row_number() over (partition by b.RowID order by ma.RowID) - 1
,	ma.Serial
,	NewIssue =
		case
			when b.QtyPrior >= ma.QtyPrior then
				case
					when b.QtyPrior + b.QtyIssue < ma.QtyPrior + ma.QtyAvailable then b.QtyIssue
					else ma.QtyPrior + ma.QtyAvailable - b.QtyPrior
				end
			else
				case
					when b.QtyPrior + b.QtyIssue > ma.QtyPrior + ma.QtyAvailable then ma.QtyAvailable
					else b.QtyPrior + b.QtyIssue - ma.QtyPrior
				end
		end
from
	@Backflushes b
	join @MaterialAvailable ma
		on not
		(	b.QtyPrior + b.QtyIssue <= ma.QtyPrior
			or b.QtyPrior >= ma.QtyPrior + ma.QtyAvailable
		)      
order by
	b.RowID
,	ma.RowID

update
	nb
set
	NewLine = nb.Line + (nb.NextLine - nb.Line) * nb.LineSegment /
		(	select
				count(*)
			from
				@newBackflush nb2
			where
				nb2.B_RowID = nb.B_RowID
		)
from
	@newBackflush nb

select
	bd.*
,	Serial = nb.Serial
,	QtyIssue = nb.NewIssue
,	RowModifiedDT = @TranDT
from
	@newBackflush nb
	join dbo.BackflushDetails bd
		on bd.RowID = nb.BFD_RowID
		and bd.Line = nb.NewLine

select
	bd.BackflushNumber
,	Line = nb.NewLine
,	bd.Status
,	bd.Type
,	bd.ChildPartSequence
,	bd.ChildPartBOMLevel
,	bd.BillOfMaterialID
,	bd.PartConsumed
,	bd.SerialConsumed
,	bd.QtyAvailable
,	bd.QtyRequired
,	QtyIssue = nb.NewIssue
,	bd.QtyOverage
,	bd.Notes
from
	@newBackflush nb
	join dbo.BackflushDetails bd
		on bd.RowID = nb.BFD_RowID
		and bd.Line = nb.Line
where
	nb.LineSegment > 0

select
	at.serial
,	at.date_stamp
,	at.type
,	at.part
,	quantity = dbo.udf_GetQtyFromStdQty(at.part, -b.QtyIssue, at.unit)
,	remarks = 'Undo MI'
,	at.price
,	at.salesman
,	at.customer
,	at.vendor
,	at.po_number
,	at.operator
,	at.from_loc
,	at.to_loc
,	at.on_hand
,	at.lot
,	at.weight
,	at.status
,	at.shipper
,	at.flag
,	at.activity
,	at.unit
,	at.workorder
,	std_quantity = -b.QtyIssue
,	at.cost
,	at.control_number
,	at.custom1
,	at.custom2
,	at.custom3
,	at.custom4
,	at.custom5
,	at.plant
,	at.invoice_number
,	notes = 'Object recovered from backflush to ship.'
,	at.gl_account
,	at.package_type
,	at.suffix
,	at.due_date
,	at.group_no
,	at.sales_order
,	at.release_no
,	at.dropship_shipper
,	at.std_cost
,	at.user_defined_status
,	at.engineering_level
,	posted = 'N'
,	at.parent_serial
,	at.origin
,	at.destination
,	at.sequence
,	at.object_type
,	at.part_name
,	at.start_date
,	at.field1
,	at.field2
,	at.show_on_shipper
,	at.tare_weight
,	at.kanban_number
,	at.dimension_qty_string
,	at.dim_qty_string_other
,	at.varying_dimension_code
from
	@Backflushes b
	join dbo.BackflushHeaders bh
		on bh.BackflushNumber = b.BackflushNumber
	join dbo.audit_trail at
		on at.serial = @Serial
		and at.type = 'M'
		and at.date_stamp = bh.TranDT

declare
	@materialIssueATType char(1)
,	@materialIssueATRemarks varchar(10)

set	@materialIssueATType = 'M'
set @materialIssueATRemarks = 'Mat Issue'

select
	serial = o.serial
,   date_stamp = bh.TranDT
,   type = @materialIssueATType
,   part = o.part
,   quantity = dbo.udf_GetQtyFromStdQty(o.part, nb.NewIssue, o.unit_measure)
,   remarks = @materialIssueATRemarks
,   price = 0
,   salesman = ''
,   customer = o.customer
,   vendor = ''
,   po_number = o.po_number
,   operator = @User
,   from_loc = o.location
,   to_loc = bh.MachineCode
,   on_hand = dbo.udf_GetPartQtyOnHand(o.part) - nb.NewIssue
,   lot = o.lot
,   weight = dbo.fn_Inventory_GetPartNetWeight(o.part, nb.NewIssue)
,   status = o.status
,   shipper = o.shipper
,   flag = ''
,   activity = ''
,   unit = o.unit_measure
,   workorder = o.workorder
,   std_quantity = nb.NewIssue
,   cost = o.cost
,   control_number = ''
,   custom1 = o.custom1
,   custom2 = o.custom2
,   custom3 = o.custom3
,   custom4 = o.custom4
,   custom5 = o.custom5
,   plant = o.plant
,   invoice_number = ''
,   notes = 'Serial changed from ' + convert(varchar, @Serial) + ' to ' + convert(varchar, nb.Serial) + ' to ship.'
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
	@newBackflush nb
	join dbo.BackflushHeaders bh
		on bh.BackflushNumber = nb.BackflushNumber
	join dbo.object o
		on o.serial = nb.Serial

select
	nb.Serial
,	sum(nb.NewIssue)
from
	@newBackflush nb
group by
	nb.Serial

select
	sum(nb.NewIssue)
from
	@newBackflush nb

select
	o.serial
,	o.std_quantity
,	ma.QtyPrior
,	quantity =
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
