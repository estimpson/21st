SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [custom].[usp_InventoryValuation_CycleCountUpdateStandardCost]

AS
set nocount on
set ansi_warnings off

--- <Body>
UPDATE	
	part_standard
SET
	cost = [custom].[fn_Inventory_GetLastCost](part_standard.part),
	cost_cum = [custom].[fn_Inventory_GetLastCost](part_standard.part),
	material = [custom].[fn_Inventory_GetLastCost](part_standard.part),
	material_cum = [custom].[fn_Inventory_GetLastCost](part_standard.part),
	price =  [custom].[fn_Inventory_GetLastCost](part_standard.part)
FROM
	part_standard 
JOIN
	part ON part.part = part_standard.part
WHERE
	part.class =  'P' AND
	ISNULL(part.user_defined_2,'N') != 'Y'

UPDATE	
	part_standard
SET
	price =  [custom].[fn_Inventory_GetLastCost](part_standard.part)
FROM
	part_standard 
JOIN
	part ON part.part = part_standard.part
WHERE
	part.class =  'F' AND
	ISNULL(part.user_defined_2,'N') != 'Y'
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
