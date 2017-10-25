SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[usp_Purchasing_ChangeVendorCode]
	@OldVendorCode varchar(50)
,	@NewVendorCode varchar(50)
,	@TranDT datetime out
,	@Result integer out
as
set nocount on
set ansi_warnings off
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

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid) -- e.g. dbo.usp_Test
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


/* Verify old vendor code exists and new vendor code is valid */


if	not exists ( Select 1 from  vendor where code = @OldVendorCode )
	begin
	set	@Result = 999999
	Select @OldVendorCode + ' does not exist in Fx'
	rollback tran @ProcName
	return
end

if DATALENGTH (@newVendorCode) > 10
	begin
	set	@Result = 999999
	Select 'To many characters for ' + @NewVendorCode 
	rollback tran @ProcName
	return
end

/*	Update purchase order header with the new vendor. (u1) */

If not exists
( select 1 
	from 
		dbo.vendor 
	where
		code = @NewVendorCode
)

Begin

-- <Update rows="1">
set	@TableName = 'dbo.destination'

update
	d
set 
	vendor = @NewVendorCode
from
	dbo.destination d
where
	d.vendor = @OldVendorCode

update
	d
set 
	destination = @NewVendorCode
from
	dbo.destination d
where
	d.destination = @OldVendorCode and
not exists 
	( Select 1 
		from 
		destination 
		where 
		destination = @NewVendorCode
	)

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s. Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end

end
--- </Update>

-- <Update rows="1">
set	@TableName = 'dbo.vendor'

Declare @Notes varchar(50)

select
	@Notes = 'Modified ' + @OldVendorCode + ' to ' + @NewVendorCode + ' ' +  convert(varchar(15), getdate(), 112)
	

update
	v
set 
	code = @NewVendorCode
	,address_6 = @Notes
from
	dbo.vendor v
where
	v.code = @OldVendorCode

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s. Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end

--- </Update>

/*	Update purchase order header with the new vendor. (u2) */
declare
	@Terms varchar(20)
,	@FOB varchar(20)
,	@ShipVia varchar(15)
,	@FreightType varchar(20)

--- <Update rows="1">
set	@TableName = 'dbo.po_header'

select
	@Terms = terms
,	@FOB = fob
,	@ShipVia = ship_via
,	@FreightType = frieght_type
from		
	dbo.vendor
where
	code = @NewVendorCode

update
	ph
set 
	vendor_code = @NewVendorCode
,	terms = @Terms
,	fob = @FOB
,	ship_via = @ShipVia
,	freight_type = @FreightType
from
	dbo.po_header ph
where
	ph.vendor_code = @OldVendorCode

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s. Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end

--- </Update>

/*	Update purchase order details with the new vendor. (u*) */
--- <Update rows="*">
set	@TableName = 'dbo.po_detail'

update
	pd
set
	vendor_code = @NewVendorCode
from
	dbo.po_detail pd
where
	vendor_code = @OldVendorCode

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s. Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end

-- <Update rows="1">

/*	Update part vendor with the new vendor. (u*) */
--- <Update rows="*">
set	@TableName = 'dbo.part_vendor'

Insert 
	part_vendor
Select
			[part]
           , @NewVendorCode
           ,[vendor_part]
           ,[vendor_standard_pack]
           ,[accum_received]
           ,[accum_shipped]
           ,[outside_process]
           ,[qty_over_received]
           ,[receiving_um]
           ,[part_name]
           ,[lead_time]
           ,[min_on_order]
           ,[beginning_inventory_date]
           ,[note]

from 
	part_vendor pv
where
	pv.vendor = @OldVendorCode and
not exists 
	( Select 1 
		from 
			part_vendor pv2 
		where 
			pv2.vendor = @NewVendorCode and
			pv2.part = pv.part
	)

Insert
	part_vendor_price_matrix
Select 
			[part]
           ,@NewVendorCode
           ,[price]
           ,[break_qty]
           ,[code]
           ,[alternate_price]
from
	dbo.part_vendor_price_matrix pvpm
where
	vendor = @OldVendorCode
and not exists	
	( select 1 
		from
		part_vendor_price_matrix pvpm2 
		where 
			pvpm2.vendor = @NewVendorCode and
			pvpm2.part = pvpm.part )



Delete 
	part_vendor_price_matrix
Where 
	vendor = @OldVendorCode


Delete 
	part_vendor
where
	vendor = @OldVendorCode



select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s. Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end

-- <Update rows="1">




set	@TableName = 'dbo.ReceiverHeaders'

update
	rh
set 
	ShipFrom = @NewVendorCode
from
	dbo.ReceiverHeaders rh
where
	rh.ShipFrom = @OldVendorCode and
	rh.Status <= 4 

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s. Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end

--- </Update>

--- </Update>
--- </Body>

---	<Return>
Select @OldVendorCode + ' changed to   ' + @NewVendorCode
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
	@ProcReturn = dbo.usp_Purchasing_ChangePOVendor
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
