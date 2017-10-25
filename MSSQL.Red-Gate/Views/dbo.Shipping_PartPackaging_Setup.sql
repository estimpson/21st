SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[Shipping_PartPackaging_Setup]
as
select
	pps.Type
,   pps.ID
,   ShipperID = sd.shipper
,	ShipperPart = sd.part
,	pps.PartCode
,	PartName = p.name
,   pps.PackagingCode
,	PackageName = pm.name
,   pps.Code
,   pps.Description
,	OrderNo = sd.order_no
,	ShipTo = s.destination
,	ShipToName = d.name
,	BillTo = s.customer
,	BillToName = c.name
,   pps.PackDisabled
,   pps.PackEnabled
,   pps.PackDefault
,   pps.PackWarn
,   pps.DefaultPackDisabled
,   pps.DefaultPackEnabled
,   pps.DefaultPackDefault
,   pps.DefaultPackWarn
from
	dbo.PartPackaging_Setup pps
	join dbo.shipper s
		join dbo.shipper_detail sd
			on sd.shipper = s.id
		on pps.id = convert(varchar, sd.shipper) + ':' + sd.part
		and s.status in ('O', 'S')
		and s.type is null
	join dbo.part p
		on p.part = pps.PartCode
	join dbo.package_materials pm
		on pm.code = pps.PackagingCode
	join dbo.destination d
		on d.destination = s.destination
	join dbo.customer c
		on c.customer = s.customer
where
	pps.Type = 5
GO
