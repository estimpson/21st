SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [custom].[usp_InventoryListByLocation]
	@InventoryDate datetime = null
,	@ClassType varchar(2) = null
as
set nocount on
set ansi_warnings off

--- <Body>
select
	object.ObjectSerial,
	part.name,
	object.LocationCode,
	object.LastOperatorCode,
	object.StdQty,
	part.part,
	location.plant,
	part.cross_ref,
	object.ShortStatus
from
	(	select
			*
		from
			dbo.udf_GetInventory_FromDT (@InventoryDate)
	) object
	right outer join part on object.PartCode = part.part
	left outer join location on object.LocationCode = location.code
where
	object.LocationCode != 'PRE-OBJECT'
	and part.class = left(@ClassType, 1)
	and part.type = right(@ClassType, 1)
--- </Body>

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
	@ProcReturn = custom.usp_InventoryListByLocation
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
