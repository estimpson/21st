
/*
Create Procedure.Fx.custom.usp_InventoryControl_CycleCount_GetRecentRawConsumptionNotice.sql
*/

--use Fx
--go

if	objectproperty(object_id('custom.usp_InventoryControl_CycleCount_GetRecentRawConsumptionNotice'), 'IsProcedure') = 1 begin
	drop procedure custom.usp_InventoryControl_CycleCount_GetRecentRawConsumptionNotice
end
go

create procedure custom.usp_InventoryControl_CycleCount_GetRecentRawConsumptionNotice
	@TranDT datetime = null out
,	@Result integer = null out
,	@Email bit = 1
as
set nocount on
set ansi_warnings on
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
if	object_id('tempdb.dbo.##Temp')is not null begin
	drop table ##Temp
end

select
	[Commodity] = icccrrcn.Commodity
,	[Part] = icccrrcn.RawPart
,	[First_Consumption_DT] = icccrrcn.ConsumptionDT
,	[Last_Cycle_Count_DT] = icccrrcn.LastCycleCountDT
,	[Current_Inventory] = convert(int, icccrrcn.CurrentInventory)
,	[Total_Consumption] = convert(int, icccrrcn.TotalConsumption)
into
	##Temp
from
	custom.InventoryControl_CycleCount_RecentRawConsumptionNotice icccrrcn
order by
	1, 4

if	@Email = 1 begin
	declare
		@html nvarchar(max)
	
	if	not exists
		(	select
				*
			from
				##Temp
		) begin
		select
			@html = '<br/>No recent changes to raw material.'
	end
	else begin
		select
			@tableName = N'##Temp'

		execute
			FT.usp_TableToHTML
			@tableName = @tableName
		,	@html = @html out
		,	@orderBy = ''
	end
	
	declare
		@EmailBody nvarchar(max)
	,	@EmailHeader nvarchar(max)
	
	select
		@EmailHeader = 'Cycle Count - Recent Raw Consumption Notice'
	
	select
		@EmailBody =
			N'<H1>' + @EmailHeader + ' - ' + left(convert(varchar, getdate(), 120), 10) + N'</H1>' +
			@html
	
	exec msdb.dbo.sp_send_dbmail
		@profile_name = 'DBMail'
	,	@recipients = 'estimpson@fore-thought.com; aboulanger@fore-thought.com; bolinger@21stcpc.com'
	, 	@subject = @EmailHeader
	,	@body = @EmailBody
	,	@body_format = 'HTML'
end
else begin
	select
		*
	from
		##Temp t

	select
		'Cycle Count - Recent Raw Consumption Notice - ' + left(convert(varchar, getdate(), 120), 10)
end
--- </Body>

if	@TranCount = 0 begin
	commit tran @ProcName
end

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
	@Email bit

set	@Email = 1

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = custom.usp_InventoryControl_CycleCount_GetRecentRawConsumptionNotice
	@TranDT = @TranDT out
,	@Result = @ProcResult out
,	@Email = @Email

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

