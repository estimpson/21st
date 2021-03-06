
/*
Create Procedure.Fx.dbo.usp_Purchasing_ChangePOVendor.sql
*/

--use Fx
--go

if	objectproperty(object_id('dbo.usp_Purchasing_ChangePOVendor'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_Purchasing_ChangePOVendor
end
go

create procedure dbo.usp_Purchasing_ChangePOVendor
	@PONumber int
,	@NewVendorCode varchar(10)
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
/*	Update purchase order header with the new vendor. (u1) */
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
	ph.po_number = @PONumber

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s. Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error updating %s in procedure %s. Rows Updated: %d. Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
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
	po_number = @PONumber

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s. Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
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
	@PONumber int
,	@NewVendorCode varchar(10)

set	@PONumber = 21792
set @NewVendorCode = 'KENDALL'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_Purchasing_ChangePOVendor
	@PONumber = @PONumber
,	@NewVendorCode = @NewVendorCode
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult

select
	*
from
	dbo.po_header ph
where
	ph.po_number = @PONumber

select
	*
from
	dbo.po_detail pd
where
	pd.po_number = @PONumber

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

