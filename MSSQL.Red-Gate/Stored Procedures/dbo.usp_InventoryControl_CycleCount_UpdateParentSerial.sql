SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_InventoryControl_CycleCount_UpdateParentSerial]
	@User varchar(10)
,	@CycleCountNumber varchar(50)
,	@Serial int
,	@ParentSerial numeric(10, 0) = null
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

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. <schema_name, sysname, dbo>.usp_Test
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
if ((	select
			isnull(parent_serial, 0)
		from
			dbo.object
		where
			serial = @Serial ) != isnull(@ParentSerial, 0)) begin		
	
	--- <Update>	
	set @TableName = 'dbo.object'
	update
		o
	set
		o.parent_serial = @ParentSerial
	from 
		dbo.object o
	where
		o.serial = @Serial

	select
		@Error = @@Error,
		@RowCount = @@Rowcount

	if	@Error != 0 begin
		set	@Result = 900507
		RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if  @RowCount != 1 begin
		set @Result = 900508
		RAISERROR ('Expected one row updated in table %s in procedure %s.  Rows updated: %d', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Update>


	--- <Update>	
	set @TableName = 'dbo.InventoryControl_CycleCountObjects'
	update
		cco
	set
		cco.ParentSerial = @ParentSerial
	from 
		dbo.InventoryControl_CycleCountObjects cco
	where
		cco.Serial = @Serial
		and cco.CycleCountNumber = @CycleCountNumber
		and cco.RowCommittedDT is null

	select
		@Error = @@Error,
		@RowCount = @@Rowcount

	if	@Error != 0 begin
		set	@Result = 900507
		RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if  @RowCount != 1 begin
		set @Result = 900508
		RAISERROR ('Expected one row updated in table %s in procedure %s.  Rows updated: %d', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Update>
	

	--- <Create audit_trail record (pallet transfer)>
	declare 
		@Remarks varchar(10)
	,	@Notes varchar(100)

	if (@ParentSerial != null) begin
		set @Remarks = 'TranToPal'
		set	@Notes = 'Cycle Count operation. Transferred to pallet.'
	end
	else begin
		set @Remarks = 'TranFrmPal'
		set	@Notes = 'Cycle Count operation. Transferred from pallet.'
	end


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
	,   type = 'T'
	,   part = o.part
	,   quantity = o.quantity
	,   remarks = @Remarks
	,   price = 0
	,   salesman = ''
	,   customer = ''
	,   vendor = ''
	,   po_number = ''
	,   operator = @User
	,   from_loc = o.location
	,   to_loc = o.location
	,   on_hand = dbo.udf_GetPartQtyOnHand(o.part)
	,   lot = o.Lot
	,   weight = o.weight
	,   status = o.status
	,   shipper = o.origin
	,   flag = ''
	,   activity = ''
	,   unit = o.unit_measure
	,   workorder = @CycleCountNumber
	,   std_quantity = o.std_quantity
	,   cost = o.Cost
	,   control_number = ''
	,   custom1 = o.custom1
	,   custom2 = o.custom2
	,   custom3 = o.custom3
	,   custom4 = o.custom4
	,   custom5 = o.custom5
	,   plant = o.plant
	,   invoice_number = ''
	,   notes = @Notes
	,   gl_account = ''
	,   package_type = o.package_type
	,   suffix = null
	,   due_date = null
	,   group_no = ''
	,   sales_order = ''
	,   release_no = ''
	,   dropship_shipper = 0
	,   std_cost = o.std_cost
	,   user_defined_status = o.user_defined_status
	,   engineering_level = ''
	,   posted = null
	,   parent_serial = o.parent_serial
	,   origin = o.origin
	,   destination = ''
	,   sequence = null
	,   object_type = null
	,   part_name = (select name from part where part = o.part)
	,   start_date = null
	,   field1 = o.field1
	,   field2 = o.field2
	,   show_on_shipper = o.show_on_shipper
	,   tare_weight = null
	,   kanban_number = null
	,   dimension_qty_string = null
	,   dim_qty_string_other = null
	,   varying_dimension_Code = null
	from
		dbo.object o
	where
		o.serial = @Serial

	select
		@Error = @@Error,
		@RowCount = @@Rowcount

	if	@Error != 0 begin
		set	@Result = 100020
		RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount != 1 begin
		set	@Result = 100021
		RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Create audit_trail record (pallet transfer)>
end
--- </Body>


--- <Tran AutoClose=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
--- </Tran>


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
	@ProcReturn = <schema_name, sysname, dbo>.<proc_name, sysname, usp_[NewProcedure]>
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
