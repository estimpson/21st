SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [custom].[usp_InventoryValuation_CycleCountObjects]
	@Class VARCHAR(1) = NULL,
	@Type VARCHAR(1) = NULL,
	@CycleCountNumber VARCHAR(25)

AS
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

--- <Body>
SELECT
	CCO.Serial,
	CCO.part,
	p.name,
	p.commodity,
	COALESCE(CCO.CorrectedLocation, CCO.OriginalLocation) AS Location,
	COALESCE(CCO.CorrectedQuantity, CCO.OriginalQuantity) AS Quantity,
	CCO.Unit,
	COALESCE(ps.cost_cum, 0) AS Cost,
	COALESCE(CCO.CorrectedQuantity, CCO.OriginalQuantity)*COALESCE(ps.cost_cum, 0) AS ExtendedCost
	
FROM
	dbo.InventoryControl_CycleCountObjects CCO
JOIN
	dbo.part p ON p.part = CCO.part AND p.class = COALESCE(@Class,'P')
JOIN
	dbo.part_standard ps ON ps.part = p.part
WHERE
	CCO.CycleCountNumber  =  @CycleCountNumber 
AND
	CCO.status  NOT IN ( -1)
AND
	CCO.RowID IN ( SELECT MAX(rowID) FROM dbo.InventoryControl_CycleCountObjects CCO2 WHERE CCO2.CycleCountNumber = @CycleCountNumber AND CCO2.Status NOT IN ( -1 ) GROUP BY CCO2.Serial )
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
	@Param1 varchar (1),
	@Param2 varchar(1),
	@Param3 varchar(15)

set	@Param1 = 'P'
Set @param2 = 'R'
Set @Param3 = 'CC_000000087'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = [custom].[usp_InventoryValuation_CycleCountObjects]
	@Class = @Param1
,	@Type = @Param2
,	@CycleCountNumber = @Param3


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
