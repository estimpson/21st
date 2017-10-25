SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_InventoryControl_QualityBoxesOnPallet]
	@User varchar(10)
,	@PalletSerial int
,	@NewUserDefinedStatus varchar(30)
,	@DeleteScrapped bit = 0
,	@DefectReason varchar(25) = null
,	@Notes varchar(max)
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
/*	Record the original status of the boxes for audit trail. */
declare
	@originalQuantityStatusBoxes table
(	BoxSerial int
,	Quantity numeric(20,6)
,	OriginalStatus varchar(30)
)  

insert
	@originalQuantityStatusBoxes
select
	BoxSerial = o.serial
,	Quantity = o.std_quantity
,	OriginalStatus = coalesce(uds.display_name, udsAlt.display_name)
from
	dbo.object o
	left join dbo.user_defined_status uds
		on uds.display_name = o.user_defined_status
	left join dbo.user_defined_status udsAlt
		on udsAlt.type = coalesce(o.status,'A')
		and udsAlt.base = 'Y'
where
	parent_serial = @PalletSerial

/*	If all boxes are already at the designaged status, do nothing. */
if	not exists
		(	select
				*
			from
				@originalQuantityStatusBoxes os
			where
				os.OriginalStatus != @NewUserDefinedStatus
		) begin
	set	@Result = 100
	rollback tran @ProcName
	return
end

/*	Set object status and adjust scrapped or rejected object. */
--- <Update rows="1+">
set	@TableName = 'dbo.object'

update
	o
set
	quantity =
		case
			when uds.type = 'S' then 0
			else o.quantity
		end
,	std_quantity =
		case
			when uds.type = 'S' then 0
			else o.std_quantity
		end
,	status = uds.type
,	user_defined_status = uds.display_name
from
	dbo.object o
	join dbo.user_defined_status uds
		on uds.display_name = @NewUserDefinedStatus
where
	o.parent_serial = @PalletSerial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount < 1 begin
	set	@Result = 999999
	RAISERROR ('Error updating %s in procedure %s.  Rows Updated: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Update>

/*	Create quality audit trail. (ial1) */
declare
	@QualityATType char(1)
,	@QualityATRemarks char(1)

set	@QualityATType = 'Q'
set @QualityATRemarks = 'Quality'

--- <Insert rows="1+">
set	@TableName = 'dbo.audit_trail'

insert
	dbo.audit_trail
(	serial
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
,   type = @QualityATType
,   part = o.part
,   quantity = o.quantity
,   remarks = @QualityATRemarks
,   price = 0
,   salesman = ''
,   customer = o.customer
,   vendor = ''
,   po_number = o.po_number
,   operator = @User
,   from_loc = udsOrig.type
,   to_loc = udsNew.type
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
,   notes = convert(varchar(254), @Notes)
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
	join @originalQuantityStatusBoxes oqsb
		join dbo.user_defined_status udsOrig
			on udsOrig.display_name = oqsb.OriginalStatus
		on oqsb.BoxSerial = o.serial
	join dbo.user_defined_status udsNew
		on udsNew.display_name = @NewUserDefinedStatus
where
	o.parent_serial = @PalletSerial

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount < 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1 or more.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end
--- </Insert>

/*	If the "delete scrapped" flag is set and passed, delete fully scrapped object. */
if	@DeleteScrapped = 1 begin
	if	exists
			(	select
					*
				from
					dbo.parameters p
				where
					p.delete_scrapped_objects = 'Y'
			)
		and	(	select
		   			udsNew.type
		   		from
		   			dbo.user_defined_status udsNew
				where
					udsNew.display_name = @NewUserDefinedStatus
		   	) = 'S'
		and exists
			(	select
					*
				from
					dbo.object o
				where
					o.parent_serial = @PalletSerial
					and o.std_quantity = 0
			) begin
        
		--- <Call>	
		set	@CallProcName = 'dbo.usp_InventoryControl_DeleteBoxesFromPallet'
		execute
			@ProcReturn = dbo.usp_InventoryControl_DeleteBoxesFromPallet
				@User = @User
			,	@PalletSerial = @PalletSerial
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
	end
end
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
	@ProcReturn = dbo.usp_InventoryControl_QualityBoxesOnPallet
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
GO
