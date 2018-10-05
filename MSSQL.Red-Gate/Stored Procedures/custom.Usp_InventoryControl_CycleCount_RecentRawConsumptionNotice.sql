SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [custom].[Usp_InventoryControl_CycleCount_RecentRawConsumptionNotice]
	@DaysHistory int
as

declare
	@PartLastCycleCount table
(	PartCode varchar(25) primary key
,	LastCountDT datetime null
)

insert
	@PartLastCycleCount
(	PartCode
,	LastCountDT
)
select
	PartCode = reverse
		(	substring
			(	reverse
				(	substring
					(	iccch.Description
					,	24
					,	27
					)
				)
			,	3
			,	25
			)
		)
,	LastCountDT = max(iccch.CountEndDT)
from
	dbo.InventoryControl_CycleCountHeaders iccch
where
	iccch.CountEndDT > getdate() - @DaysHistory
	and left(iccch.Description, 22) = 'All inventory of part '
group by
	iccch.Description

declare
	@MaterialConsumption table
(	PartConsumed varchar(25)
,	PartProduced varchar(25)
,	MachineCode varchar(10)
,	ConsumptionDT datetime
,	ConsumedQty numeric(20,6)
)
insert
	@MaterialConsumption
(	PartConsumed
,	PartProduced
,	MachineCode
,	ConsumptionDT
,	ConsumedQty
)
select
	bdRecentRaw.PartConsumed
,	bh.PartProduced
,	bh.MachineCode
,	ConsumptionDT = min(bdRecentRaw.RowCreateDT)
,	ConsumedQty = sum(bdRecentRaw.QtyIssue)
from
	dbo.BackflushDetails bdRecentRaw
	left join @PartLastCycleCount plcc
		on plcc.PartCode = bdRecentRaw.PartConsumed
	join dbo.BackflushHeaders bh
		on bh.BackflushNumber = bdRecentRaw.BackflushNumber
where
	bdRecentRaw.RowCreateDT > coalesce(plcc.LastCountDT, getdate() - @DaysHistory)
group by
	bdRecentRaw.PartConsumed
,	bh.PartProduced
,	bh.MachineCode

select
	Commodity = pRaw.commodity
,	RawPart = mc.PartConsumed
,	ConsumptionDT = min(mc.ConsumptionDT)
,	LastCycleCountDT = max(plcc.LastCountDT)
,	CurrentInventory = coalesce(max(Inventory.OnHand), 0)
,	TotalConsumption = sum(mc.ConsumedQty)
,	ConsumptionPercentage = sum(mc.ConsumedQty)
		/ (sum(mc.ConsumedQty) + coalesce(max(Inventory.OnHand), 0))
,	ConsumedByPart = replace(Fx.ToList(distinct mc.PartProduced), ', ', ',')
,	ConsumedAtMachine = replace(Fx.ToList(distinct mc.MachineCode), ', ', ',')
from
	@MaterialConsumption mc
	join dbo.part pRaw
		on pRaw.type = 'R'
			and pRaw.part = mc.PartConsumed
	left join @PartLastCycleCount plcc
		on plcc.PartCode = mc.PartConsumed
	left join
	(	select
			PartCode = o.part
		,	OnHand = sum(o.std_quantity)
		from
			dbo.object o
		group by
			o.part
	) Inventory
		on Inventory.PartCode = mc.PartConsumed
group by
	mc.PartConsumed
,	pRaw.commodity
GO
