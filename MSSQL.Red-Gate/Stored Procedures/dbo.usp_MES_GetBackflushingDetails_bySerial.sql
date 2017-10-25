SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_MES_GetBackflushingDetails_bySerial]
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
GO
