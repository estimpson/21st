SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [custom].[InventoryControl_CycleCount_RecentWIPConsumptionNotice]
as
select
	Commodity = pRaw.commodity
,	RawPart = bdRecentRaw.PartConsumed
,	ConsumptionDT = min(bdRecentRaw.RowCreateDT)
,	LastCycleCountDT =
		(	select
				max(iccch.CountEndDT)
			from
				dbo.InventoryControl_CycleCountHeaders iccch
			where
				iccch.Description = 'All inventory of part ''' + bdRecentRaw.PartConsumed + '''.'
		)
,	CurrentInventory = coalesce(max(Inventory.OnHand), 0)
,	TotalConsumption = sum(bdRecentRaw.QtyIssue)
,	ConsumptionPercentage = sum(bdRecentRaw.QtyIssue) / (sum(bdRecentRaw.QtyIssue) + coalesce(max(Inventory.OnHand), 0))
,	ConsumedByPart = custom.udf_GetConsumedByForPartInDateRange(bdRecentRaw.PartConsumed, min(bdRecentRaw.RowCreateDT), max(bdRecentRaw.RowCreateDT))
,	ConsumedAtMachine = custom.udf_GetConsumedWhereForPartInDateRange(bdRecentRaw.PartConsumed, min(bdRecentRaw.RowCreateDT), max(bdRecentRaw.RowCreateDT))
from
	dbo.BackflushDetails bdRecentRaw
		join dbo.part pRaw
			on pRaw.type = 'W'
			and pRaw.part = bdRecentRaw.PartConsumed
	left join
		(	select
				PartCode = o.part
			,	OnHand = sum(o.std_quantity)
			from
				dbo.object o
			group by
				o.part
		) Inventory
		on Inventory.PartCode = bdRecentRaw.PartConsumed
		
where
	bdRecentRaw.RowCreateDT > coalesce
	(	(	select
				max(iccch.CountEndDT)
			from
				dbo.InventoryControl_CycleCountHeaders iccch
			where
				iccch.CountEndDT > getdate() - 10
				and iccch.Description = 'All inventory of part ''' + bdRecentRaw.PartConsumed + '''.'
		)
	,	getdate() - 28
	)
group by
	bdRecentRaw.PartConsumed
,	pRaw.commodity

GO
