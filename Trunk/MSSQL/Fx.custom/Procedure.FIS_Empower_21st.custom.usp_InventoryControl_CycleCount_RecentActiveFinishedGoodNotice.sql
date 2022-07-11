
/*
Create Procedure.FIS_Empower_21st.custom.usp_InventoryControl_CycleCount_RecentActiveFinishedGoodNotice.sql
*/

use FIS_Empower_21st
go

if	objectproperty(object_id('custom.usp_InventoryControl_CycleCount_RecentActiveFinishedGoodNotice'), 'IsProcedure') = 1 begin
	drop procedure custom.usp_InventoryControl_CycleCount_RecentActiveFinishedGoodNotice
end
go

create procedure custom.usp_InventoryControl_CycleCount_RecentActiveFinishedGoodNotice
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
	@Production table
(	PartCode varchar(25)
,	CompletedDT datetime
,	CompletedQty numeric(20,6)
)

insert
	@Production
(	PartCode
,	CompletedDT
,	CompletedQty
)
select
	at.part
,	min(at.date_stamp)
,	sum(at.std_quantity)
from
	dbo.audit_trail at
where
	at.date_stamp > getdate() - @DaysHistory
	and exists
		(	select
				*
			from
				dbo.part p
			where
				p.part = at.part
				and p.type in ('F', 'W')
		)
group by
	at.part

declare
	@Shipments table
(	PartCode varchar(25)
,	ShipDT datetime
,	ShipQty numeric(20,6)
)

insert
	@Shipments
(	PartCode
,	ShipDT
,	ShipQty
)
select
	sd.part_original
,	min(sd.date_shipped)
,	sum(sd.qty_packed)
from
	dbo.shipper_detail sd
	join dbo.shipper s
		on s.id = sd.shipper
where
	sd.date_shipped > getdate() - @DaysHistory
	and s.type is null
	and exists
		(	select
				*
			from
				dbo.part p
			where
				p.part = sd.part_original
				and p.type = 'F'
		)
group by
	sd.part_original

declare
	@ActiveFinishedGoods table
(	PartCode varchar(25)
,	CompletionDT datetime
,	CompletionQty numeric(20,6)
,	ShipDT datetime
,	ShipQty numeric(20,6)
)

insert
	@ActiveFinishedGoods
(	PartCode
,	CompletionDT
,	CompletionQty
,	ShipDT
,	ShipQty
)
select
	coalesce(p.PartCode, s.PartCode)
,	p.CompletedDT
,	p.CompletedQty
,	s.ShipDT
,	s.ShipQty
from
	@Production p
	full join @Shipments s
		on s.PartCode = p.PartCode

select
	afg.PartCode
,	afg.CompletionDT
,	afg.CompletionQty
,	afg.ShipDT
,	afg.ShipQty
,	plcc.LastCountDT
,	Inventory.OnHand
from
	@ActiveFinishedGoods afg
	left join @PartLastCycleCount plcc
		on plcc.PartCode = afg.PartCode
	left join
	(	select
			PartCode = o.part
		,	OnHand = sum(o.std_quantity)
		from
			dbo.object o
		group by
			o.part
	) Inventory
		on Inventory.PartCode = afg.PartCode
order by
	afg.PartCode
go

execute custom.usp_InventoryControl_CycleCount_RecentActiveFinishedGoodNotice
	@DaysHistory = 33
