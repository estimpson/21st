SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE procedure [custom].[usp_InventoryValuation_CycleCountUpdateStandardCost]
as
set nocount on
set ansi_warnings off

--- <Body>
update
	ps
set
	ps.cost = coalesce(lastInv.Price, lastRec.Cost, lastShip.Price, 0)
,	ps.cost_cum = coalesce(lastInv.Price, lastRec.Cost, lastShip.Price, 0)
,	ps.material = coalesce(lastInv.Price, lastRec.Cost, lastShip.Price, 0)
,	ps.material_cum = coalesce(lastInv.Price, lastRec.Cost, lastShip.Price, 0)
,	ps.price = coalesce(lastInv.Price, lastRec.Cost, lastShip.Price, 0)
from
	dbo.part_standard ps
	join dbo.part pPurch
		on pPurch.part = ps.part
		and pPurch.class = 'P'
		and coalesce(pPurch.user_defined_2, 'N') != 'Y'
	outer apply
	(	select
			lastInv.Price
		from
			dbo.part pRaw
			cross apply
				(	select top 1
						Price = ai.price
					from
						dbo.ap_items ai
							join dbo.ap_headers ah
								on ah.inv_cm_flag = ai.inv_cm_flag
								and ah.invoice_cm = ai.invoice_cm
					where
						ai.item = pRaw.part
					order by
						ah.gl_date desc
				) lastInv
		where
			pRaw.part = ps.part
			and pRaw.type = 'R'
	) lastInv
	outer apply
	(	select
			lastRec.Cost
		from
			dbo.part pRaw
			cross apply
				(	select top 1
						Cost = at.cost
					from
						dbo.audit_trail at
					where
						at.part = pRaw.part
						and at.type = 'R'
					order by
						at.date_stamp desc
				) lastRec
		where
			pRaw.part = ps.part
			and pRaw.type = 'R'
	) lastRec
	outer apply
	(	select
			lastShip.Price
		from
			dbo.part pFin
			cross apply
				(	select top 1
						Price = sd.alternate_price
					from
						dbo.shipper_detail sd
					where
						sd.part_original = pFin.part
						and sd.date_shipped is not null
					order by
						sd.date_shipped desc
				) lastShip
		where
			pFin.part = ps.part
			and pFin.type = 'F'
	) lastShip

/*	The old statement had restricted update to parts with a class of 'F' which doesn't exist
	and thus did nothing.  The modified statement below would appear to be the intended
	behavior, but to be safe has been disabled by comment until it has been verified. */
--update
--	ps
--set
--	ps.price = coalesce(lastInv.Price, lastRec.Cost, lastShip.Price, 0)
--from
--	dbo.part_standard ps
--	join dbo.part pPurch
--		on pPurch.part = ps.part
--		and pPurch.class = 'M'
--		and coalesce(pPurch.user_defined_2, 'N') != 'Y'
--	outer apply
--	(	select
--			lastInv.Price
--		from
--			dbo.part pRaw
--			cross apply
--				(	select top 1
--						Price = ai.price
--					from
--						dbo.ap_items ai
--							join dbo.ap_headers ah
--								on ah.inv_cm_flag = ai.inv_cm_flag
--								and ah.invoice_cm = ai.invoice_cm
--					where
--						ai.item = pRaw.part
--					order by
--						ah.gl_date desc
--				) lastInv
--		where
--			pRaw.part = ps.part
--			and pRaw.type = 'R'
--	) lastInv
--	outer apply
--	(	select
--			lastRec.Cost
--		from
--			dbo.part pRaw
--			cross apply
--				(	select top 1
--						Cost = at.cost
--					from
--						dbo.audit_trail at
--					where
--						at.part = pRaw.part
--						and at.type = 'R'
--					order by
--						at.date_stamp desc
--				) lastRec
--		where
--			pRaw.part = ps.part
--			and pRaw.type = 'R'
--	) lastRec
--	outer apply
--	(	select
--			lastShip.Price
--		from
--			dbo.part pFin
--			cross apply
--				(	select top 1
--						Price = sd.alternate_price
--					from
--						dbo.shipper_detail sd
--					where
--						sd.part_original = pFin.part
--						and sd.date_shipped is not null
--					order by
--						sd.date_shipped desc
--				) lastShip
--		where
--			pFin.part = ps.part
--			and pFin.type = 'F'
--	) lastShip

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
	@ProcReturn = custom.usp_InventoryValuation_CycleCountUpdateStandardCost

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
