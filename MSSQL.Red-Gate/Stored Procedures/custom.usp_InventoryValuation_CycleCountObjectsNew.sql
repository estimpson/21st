SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [custom].[usp_InventoryValuation_CycleCountObjectsNew]
	@Class VARCHAR(10) = NULL,
	@Type VARCHAR(10) = NULL,
	@CycleCountNumber VARCHAR(25)

AS
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

--- <Body>

SELECT
	DISTINCT 
	ps.part,
	piv.standard_unit AS FxStdUnit,
	apLastPricepaid.item AS APPart,
	arLastPricepaid.item AS ARpart,
	apLastPricepaid.price AS EmpowerAPInvoiceCost,
	apLastPricepaid.unit_of_measure AS EmpowerAPUnit,
	arLastPricepaid.item_price AS EmpowerARInvoiceCost,
	arLastPricepaid.pricing_uom AS EmpowerARUnit,
	ps.cost_cum FxCost,
	COALESCE(pcd.class_name, 'Class Not Defined') AS PartClass,
	COALESCE(ptd.type_name, 'Type Not Defined') AS PartType,
	COALESCE(pwi.cost,0) AS ImportedWIPCost
	
	INTO #CostData	
	FROM 
dbo.part_standard ps
JOIN
	part p ON p.part = ps.part
JOIN
	part_inventory piv ON piv.part = p.part
LEFT JOIN
	dbo.part_class_definition pcd ON pcd.class = p.class
LEFT JOIN
	dbo.part_type_definition ptd ON ptd.type = p.type
LEFT JOIN
	( SELECT * FROM custom.fn_lastWIPCost ()) pwi ON pwi.Part = p.part

LEFT JOIN
(SELECT ap.item, ap.price, ap.unit_of_measure, pinv.standard_unit
 FROM 
ap_items ap
 JOIN

(SELECT item, MAX(changed_date) lastDate
FROM dbo.ap_items
WHERE item IS NOT NULL
	GROUP BY item ) lastInvoicePrice ON lastInvoicePrice.item = ap.item AND lastInvoicePrice.lastDate = ap.changed_date 
JOIN
	part_inventory pinv ON pinv.part = ap.item	
) apLastPricepaid ON APLastPricepaid.item = ps.part
LEFT JOIN
	(SELECT AR.item, ar.item_price, AR.pricing_uom, pinv.standard_unit
 FROM 
  AR_ITEMS aR
 JOIN

(SELECT item, MAX(changed_date) lastDate
FROM dbo.AR_items
WHERE item IS NOT NULL
	GROUP BY item ) lastInvoicePrice ON lastInvoicePrice.item = AR.item AND lastInvoicePrice.lastDate = AR.changed_date 
JOIN
	part_inventory pinv ON pinv.part = AR.item	
) arLastPricepaid ON arLastPricepaid.item = ps.part



	ORDER BY 1 ASC

SELECT
	CCO.Serial,
	CCO.part,
	p.name,
	ps.PartClass,
	ps.PartType,
	p.commodity,
	COALESCE(CCO.CorrectedLocation, CCO.OriginalLocation) AS Location,
	COALESCE(CCO.CorrectedQuantity, CCO.OriginalQuantity) AS Quantity,
	CCO.Unit,
	ps.EmpowerAPInvoiceCost AS APCost,
	ps.EmpowerARInvoiceCost AS ARCost,
	ps.FxCost AS FxCost,
	ps.ImportedWIPCost AS ImportedWIPCost,
	CASE	WHEN ps.PartType = 'WIP' 
			THEN ps.ImportedWIPCost*.65
			WHEN ps.PartClass = 'Manufactured' 
			THEN COALESCE(ps.EmpowerARInvoiceCost, ps.EmpowerAPInvoiceCost, ps.FxCost, 0)*.65 
			ELSE COALESCE(ps.EmpowerAPInvoiceCost, ps.EmpowerARInvoiceCost, ps.FxCost, 0) END AS CalculatedCost,
	COALESCE(CCO.CorrectedQuantity, CCO.OriginalQuantity)*
	CASE 	WHEN ps.PartType = 'WIP' 
			THEN ps.ImportedWIPCost*.65
			WHEN ps.PartClass = 'Manufactured' 
			THEN COALESCE(ps.EmpowerARInvoiceCost, ps.EmpowerAPInvoiceCost, ps.FxCost, 0)*.65 
			ELSE COALESCE(ps.EmpowerAPInvoiceCost, ps.EmpowerARInvoiceCost, ps.FxCost, 0)  END AS ExtendedCost
	
FROM
	dbo.InventoryControl_CycleCountObjects CCO
JOIN
	dbo.part p ON p.part = CCO.part
LEFT JOIN
	#CostData ps ON ps.part = p.part
WHERE
	CCO.CycleCountNumber  =  @CycleCountNumber
AND
	ps.PartClass != 'Non-Inventory'
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

Set @Param3 = 'CC_000001205'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = [custom].[usp_InventoryValuation_CycleCountObjects]
	@CycleCountNumber = @Param3


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
