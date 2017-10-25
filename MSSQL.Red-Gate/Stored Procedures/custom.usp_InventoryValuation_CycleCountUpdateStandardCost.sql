SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [custom].[usp_InventoryValuation_CycleCountUpdateStandardCost]

as
set nocount on
set ansi_warnings off

--- <Body>
update	
	part_standard
Set
	cost = [custom].[fn_Inventory_GetLastCost](part_standard.part),
	cost_cum = [custom].[fn_Inventory_GetLastCost](part_standard.part),
	material = [custom].[fn_Inventory_GetLastCost](part_standard.part),
	material_cum = [custom].[fn_Inventory_GetLastCost](part_standard.part)
from
	part_standard 
join
	part on part.part = part_standard.part
where
	part.type = 'R'
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



begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = [custom].[usp_InventoryValuation_CycleCountUpdateStandardCost]


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