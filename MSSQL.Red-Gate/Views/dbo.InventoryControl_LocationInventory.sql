SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[InventoryControl_LocationInventory]
as
select
	Location = l.code
,	LocationName = l.name
,	locInv.TotalInv
,	locInv.TotalWIP
,	locInv.TotalVOP
,	locInv.Unit
,	PackagingInventroyList = pckInv.InventoryList
,	PartInventoryList = locInv.InventoryList
from
	dbo.location l
	left join
		(	select
		 		pckInv.Location
			,	InventoryList = Fx.ToList(
					pckInv.Part + ': '
					+ case
						when pckInv.Boxes > 1 then convert(varchar, pckInv.Boxes) + ' objs. of '
						else ''
					end
					+ case
						when pckInv.Quantity = ceiling(pckInv.Quantity) then convert(varchar, convert(int, pckInv.Quantity))
						else convert(varchar, pckInv.Quantity)
					end + ' '
					+ pckInv.Unit + ' '
					+ coalesce('in ' + pckInv.PackageType + ' ', '')
					+ '- (' + pckInv.Status + ') ' + pckInv.UserDefinedStatus
					)
		 	from
			(	select
					ico.Location
				,	ico.Part
				,	ico.Quantity
				,	ico.Unit
				,	ico.PackageType
				,	ico.Status
				,	ico.UserDefinedStatus
				,	Boxes = count(*)
				from
					dbo.InventoryControl_Objects ico
				group by
					ico.Location
				,	ico.Part
				,	ico.Quantity
				,	ico.Unit
				,	ico.PackageType
				,	ico.Status
				,	ico.UserDefinedStatus
			) pckInv
			group by
				pckInv.Location
		) pckInv
	on pckInv.Location = l.code
	left join
		(	select
		 		locInv.Location
			,	InventoryList = Fx.ToList(
					locInv.Part + ': '
					+ case
						when locInv.Quantity = ceiling(locInv.Quantity) then convert(varchar, convert(int, locInv.Quantity))
						else convert(varchar, locInv.Quantity)
					end + ' '
					+ locInv.StdUnit + ' '
					+ '- (' + locInv.Status + ') ' + locInv.UserDefinedStatus
					)
			,	TotalInv = sum(case when lWIP.code is null and vOP.code is null then locInv.Quantity else 0 end)
			,	TotalWIP = sum(case when lWIP.code is not null and vOP.code is null then locInv.Quantity else 0 end)
			,	TotalVOP = sum(case when vOP.code is not null then locInv.Quantity else 0 end)
			,	Unit = max(locInv.StdUnit)
		 	from
			(	select
					ico.Part
				,	Quantity = sum(ico.StdQuantity)
				,	ico.StdUnit
				,	ico.Location
				,	ico.Status
				,	ico.UserDefinedStatus
				from
					dbo.InventoryControl_Objects ico
				group by
					ico.Part
				,	ico.StdUnit
				,	ico.Location
				,	ico.Status
				,	ico.UserDefinedStatus
			) locInv
			left join dbo.part_machine pm
				left join dbo.vendor vOP
					on vOP.code = pm.machine
				on pm.part = locInv.Part
				and pm.sequence = 1
			left join dbo.location lWIP
				on lWIP.code = locInv.Location
				and lWIP.type = 'MC'
				and lWIP.code != coalesce(pm.machine, '')
				and lWIP.code not in ('NCM', 'FG')
			group by
				locInv.Location
		) locInv
	on locInv.Location = l.code
GO
