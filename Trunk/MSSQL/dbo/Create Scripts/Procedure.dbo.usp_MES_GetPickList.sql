
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
	@WODID int = null
,	@PartCode varchar(25) = null
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
if (@WODID is not null) begin
	select
--		WODID
		Mach = convert(varchar(4), MachineCode)
--	,	PartCode
	,	ChildPart
	,	QtyRq = convert(numeric(10,2), QtyRequired)
	,	QtyRequiredStandardPack
	,	QtyPk = isnull(QtyAvailable, 0)
	,	QtyNeed = convert(numeric(10,2), QtyToPull)
--	,	FIFOLocation
--	,	ProductLine
--	,	Commodity
--	,	PartName
	from
		dbo.MES_PickList pl
	where
		WODID = @WODID
	order by
		QtyAvailable/nullif(QtyRequired, 0)
end
else if (@PartCode is not null) begin
	select
--		WODID
		Mach = convert(varchar(4), MachineCode)
--	,	PartCode
	,	ChildPart
	,	QtyRq = convert(numeric(10,2), QtyRequired)
	,	QtyRequiredStandardPack
	,	QtyPk = isnull(QtyAvailable, 0)
	,	QtyNeed = convert(numeric(10,2), QtyToPull)
--	,	FIFOLocation
--	,	ProductLine
--	,	Commodity
--	,	PartName
	from
		dbo.MES_PickList pl
	where
		PartCode = @PartCode
	order by
		QtyAvailable/nullif(QtyRequired, 0)
end
else begin
	select
--		WODID
		Mach = convert(varchar(4), MachineCode)
--	,	PartCode
	,	ChildPart
	,	QtyRq = convert(numeric(10,2), QtyRequired)
	,	QtyRequiredStandardPack
	,	QtyPk = isnull(QtyAvailable, 0)
	,	QtyNeed = convert(numeric(10,2), QtyToPull)
--	,	FIFOLocation
--	,	ProductLine
--	,	Commodity
--	,	PartName
	from
		dbo.MES_PickList pl
	order by
		QtyAvailable/nullif(QtyRequired, 0)
end
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

