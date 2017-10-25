alter view dbo.PartPackaging_Setup
as
with GlobalDefaults
(	DefaultAlternatePackEnabled
,	DefaultAlternatePackWarn
,	DefaultEmptyOrNullEnabled
,	DefaultEmptyOrNullWarn
)
as
(	select
		DefaultAlternatePackEnabled = 
			case when
					(	select
							g.Value
						from
							Fx.Globals g
						where
							g.Name = 'Shipping_PartPackaging.AllowAllAlternates'
					) = 1
					or
					(	select
							g.Value
						from
							Fx.Globals g
						where
							g.Name = 'Shipping_PartPackaging.AllowButWarnAllAlternates'
					) = 1 then 1
				else 0
			end
		,	DefaultEmptyOrNullEnabled =
			case when
					(	select
							g.Value
						from
							Fx.Globals g
						where
							g.Name = 'Shipping_PartPackaging.AllowButWarnAllAlternates'
					) = 1 then 1
				else 0
			end
		,	DefaultEmptyOrNullWarn = 
			case when
					(	select
							g.Value
						from
							Fx.Globals g
						where
							g.Name = 'Shipping_PartPackaging.AllowEmptyOrNull'
					) = 1
					or
					(	select
							g.Value
						from
							Fx.Globals g
						where
							g.Name = 'Shipping_PartPackaging.AllowButWarnEmptyOrNull'
					) = 1 then 1
				else 0
			end
		,	DefaultAlternatePackWarn =
			case when
					(	select
							g.Value
						from
							Fx.Globals g
						where
							g.Name = 'Shipping_PartPackaging.AllowButWarnEmptyOrNull'
					) = 1 then 1
				else 0
			end
)
/*	Customer Part Packaging*/
select
	Type = 1
,	ID = null
,	PartCode = null
,	PackagingCode = null
,	Code = 'Customer Part Packaging'
,	Description = ''
,	PackDisabled = null
,	PackEnabled = null
,	PackDefault = null
,	PackWarn = null
,	DefaultPackDisabled = null
,	DefaultPackEnabled = null
,	DefaultPackDefault = null
,	DefaultPackWarn = null
union all
select
	Type = 1
,	ID = pc.customer
,	PartCode = pc.part
,	PackagingCode = pp.code
,	Code = 'Customer Part Packaging:  ' + pc.customer + '-' + pc.part + ',' + pp.code
,	Description = 'Customer Part Packaging:  ' + pc.customer + '-' + pc.part + ',' + pp.code
,	PackDisabled = coalesce(ppbt.PackDisabled, 0)
,	PackEnabled = coalesce(ppbt.PackEnabled, gd.DefaultAlternatePackEnabled)
,	PackDefault = coalesce(ppbt.PackDefault, 0)
,	PackWarn = coalesce(ppbt.PackWarn, gd.DefaultAlternatePackWarn)
,	DefaultPackDisabled = null
,	DefaultAlternatePackEnabled = null
,	DefaultPackDefault = null
,	DefaultAlternatePackWarn = null
from
	dbo.part_packaging pp
	join dbo.part_customer pc
		on pc.part = pp.part
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = pc.customer
		and ppbt.PartCode = pc.part
		and ppbt.PackagingCode = pp.code
	cross join GlobalDefaults gd
union all
select
	Type = 1
,	ID = pc.customer
,	PartCode = pc.part
,	PackagingCode = 'N/A'
,	Code = 'Customer Part Packaging:  ' + pc.customer + '-' + pc.part + ',' + 'N/A'
,	Description = 'Customer Part Packaging:  ' + pc.customer + '-' + pc.part + ',' + 'N/A'
,	PackDisabled = coalesce(ppbt.PackDisabled, 0)
,	PackEnabled = coalesce(ppbt.PackEnabled, gd.DefaultEmptyOrNullEnabled)
,	PackDefault = coalesce(ppbt.PackDefault, 0)
,	PackWarn = coalesce(ppbt.PackWarn, gd.DefaultEmptyOrNullWarn)
,	DefaultPackDisabled = null
,	DefaultAlternatePackEnabled = null
,	DefaultPackDefault = null
,	DefaultAlternatePackWarn = null
from
	dbo.part_customer pc
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = pc.customer
		and ppbt.PartCode = pc.part
		and ppbt.PackagingCode = 'N/A'
	cross join GlobalDefaults gd

/*	Destination Part Packaging*/
union all
select
	Type = 2
,	ID = null
,	PartCode = null
,	PackagingCode = null
,	Code = 'Destination Part Packaging'
,	Description = ''
,	PackDisabled = null
,	PackEnabled = null
,	PackDefault = null
,	PackWarn = null
,	DefaultPackDisabled = null
,	DefaultPackEnabled = null
,	DefaultPackDefault = null
,	DefaultPackWarn = null
union all
select
	Type = 2
,	ID = d.destination
,	PartCode = pc.part
,	PackagingCode = pp.code
,	Code = 'Destination Part Packaging:  ' + pc.customer + ':' + d.destination + '-' + pc.part + ',' + pp.code
,	Description = 'Destination Part Packaging:  ' + pc.customer + ':' + d.destination + '-' + pc.part + ',' + pp.code
,	PackDisabled = coalesce(ppbt.PackDisabled, ppst.PackDisabled, 0)
,	PackEnabled = coalesce(ppbt.PackEnabled, ppst.PackEnabled, gd.DefaultAlternatePackEnabled)
,	PackDefault = coalesce(ppbt.PackDefault, ppst.PackDefault, 0)
,	PackWarn = coalesce(ppbt.PackWarn, ppst.PackWarn, gd.DefaultAlternatePackWarn)
,	DefaultPackDisabled = ppbt.PackDisabled
,	DefaultPackEnabled = ppbt.PackEnabled
,	DefaultPackDefault = ppbt.PackDefault
,	DefaultPackWarn = ppbt.PackWarn
from
	dbo.part_packaging pp
	join dbo.part_customer pc
		on pc.part = pp.part
	join dbo.destination d
		on d.customer = pc.customer
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = pc.customer
		and ppbt.PartCode = pc.part
		and ppbt.PackagingCode = pp.code
	left join dbo.PartPackaging_ShipTo ppst
		on ppst.ShipToCode = d.destination
		and ppst.PartCode = pc.part
		and ppst.PackagingCode = pp.code
	cross join GlobalDefaults gd
union all
select
	Type = 2
,	ID = pc.customer
,	PartCode = pc.part
,	PackagingCode = 'N/A'
,	Code = 'Destination Part Packaging:  ' + pc.customer + ':' + d.destination + '-' + pc.part + ',' + 'N/A'
,	Description = 'Destination Part Packaging:  ' + pc.customer + ':' + d.destination + '-' + pc.part + ',' + 'N/A'
,	PackDisabled = coalesce(ppbt.PackDisabled, ppst.PackDisabled, 0)
,	PackEnabled = coalesce(ppbt.PackEnabled, ppst.PackEnabled, gd.DefaultEmptyOrNullEnabled)
,	PackDefault = coalesce(ppbt.PackDefault, ppst.PackDefault, 0)
,	PackWarn = coalesce(ppbt.PackWarn, ppst.PackWarn, gd.DefaultEmptyOrNullWarn)
,	DefaultPackDisabled = null
,	DefaultAlternatePackEnabled = null
,	DefaultPackDefault = null
,	DefaultAlternatePackWarn = null
from
	dbo.part_customer pc
	join dbo.destination d
		on d.customer = pc.customer
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = pc.customer
		and ppbt.PartCode = pc.part
		and ppbt.PackagingCode = 'N/A'
	left join dbo.PartPackaging_ShipTo ppst
		on ppst.ShipToCode = d.destination
		and ppst.PartCode = pc.part
		and ppst.PackagingCode = 'N/A'
	cross join GlobalDefaults gd

/*	Order Header Part Packaging*/
union all
select
	Type = 3
,	ID = null
,	PartCode = null
,	PackagingCode = null
,	Code = 'Order Header Part Packaging'
,	Description = ''
,	PackDisabled = null
,	PackEnabled = null
,	PackDefault = null
,	PackWarn = null
,	DefaultPackDisabled = null
,	DefaultPackEnabled = null
,	DefaultPackDefault = null
,	DefaultPackWarn = null
union all
select
	Type = 3
,	ID = convert(varchar, oh.order_no)
,	PartCode = pp.part
,	PackagingCode = pp.code
,	Code = 'Order Header Part Packaging:  ' + convert(varchar, oh.order_no) + '(' + oh.customer + ':' + oh.destination + ')-' + pp.part + ',' + pp.code
,	Description = 'Order Header Part Packaging:  ' + convert(varchar, oh.order_no) + '(' + oh.customer + ':' + oh.destination + ')-' + pp.part + ',' + pp.code
,	PackDisabled = coalesce(ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled, 0)
,	PackEnabled = coalesce(ppoh.PackEnabled, ppbt.PackEnabled, ppst.PackEnabled, gd.DefaultAlternatePackEnabled)
,	PackDefault = coalesce(ppoh.PackDefault, ppbt.PackDefault, ppst.PackDefault, 0)
,	PackWarn = coalesce(ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn, gd.DefaultAlternatePackWarn)
,	DefaultPackDisabled = coalesce(ppbt.PackDisabled, ppst.PackDisabled)
,	DefaultPackEnabled = coalesce(ppbt.PackEnabled, ppst.PackEnabled)
,	DefaultPackDefault = coalesce(ppbt.PackDefault, ppst.PackDefault)
,	DefaultPackWarn = coalesce(ppbt.PackWarn, ppst.PackWarn)
from
	dbo.part_packaging pp
	join dbo.order_header oh
		on oh.blanket_part = pp.part
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = oh.customer
		and ppbt.PartCode = oh.blanket_part
		and ppbt.PackagingCode = pp.code
	left join dbo.PartPackaging_ShipTo ppst
		on ppst.ShipToCode = oh.destination
		and ppst.PartCode = oh.blanket_part
		and ppst.PackagingCode = pp.code
	left join dbo.PartPackaging_OrderHeader ppoh
		on ppoh.OrderNo = oh.order_no
		and ppoh.PartCode = pp.part
		and ppoh.PackagingCode = pp.code
	cross join GlobalDefaults gd
union all
select
	Type = 3
,	ID = convert(varchar, oh.order_no)
,	PartCode = oh.blanket_part
,	PackagingCode = 'N/A'
,	Code = 'Order Header Part Packaging:  ' + convert(varchar, oh.order_no) + '(' + oh.customer + ':' + oh.destination + ')-' + oh.blanket_part + ',' + 'N/A'
,	Description = 'Order Header Part Packaging:  ' + convert(varchar, oh.order_no) + '(' + oh.customer + ':' + oh.destination + ')-' + oh.blanket_part + ',' + 'N/A'
,	PackDisabled = coalesce(ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled, 0)
,	PackEnabled = coalesce(ppoh.PackEnabled, ppbt.PackEnabled, ppst.PackEnabled, gd.DefaultEmptyOrNullEnabled)
,	PackDefault = coalesce(ppoh.PackDefault, ppbt.PackDefault, ppst.PackDefault, 0)
,	PackWarn = coalesce(ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn, gd.DefaultEmptyOrNullWarn)
,	DefaultPackDisabled = coalesce(ppbt.PackDisabled, ppst.PackDisabled)
,	DefaultPackEnabled = coalesce(ppbt.PackEnabled, ppst.PackEnabled)
,	DefaultPackDefault = coalesce(ppbt.PackDefault, ppst.PackDefault)
,	DefaultPackWarn = coalesce(ppbt.PackWarn, ppst.PackWarn)
from
	dbo.order_header oh
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = oh.customer
		and ppbt.PartCode = oh.blanket_part
		and ppbt.PackagingCode = 'N/A'
	left join dbo.PartPackaging_ShipTo ppst
		on ppst.ShipToCode = oh.destination
		and ppst.PartCode = oh.blanket_part
		and ppst.PackagingCode = 'N/A'
	left join dbo.PartPackaging_OrderHeader ppoh
		on ppoh.OrderNo = oh.order_no
		and ppoh.PartCode = oh.blanket_part
		and ppoh.PackagingCode = 'N/A'
	cross join GlobalDefaults gd

/*	Order Detail Part Packaging*/
union all
select
	Type = 4
,	ID = null
,	PartCode = null
,	PackagingCode = null
,	Code = 'Order Detail Part Packaging'
,	Description = ''
,	PackDisabled = null
,	PackEnabled = null
,	PackDefault = null
,	PackWarn = null
,	DefaultPackDisabled = null
,	DefaultPackEnabled = null
,	DefaultPackDefault = null
,	DefaultPackWarn = null
union all
select
	Type = 4
,	ID = convert(varchar, od.order_no) + ':' + convert(varchar, od.id)
,	PartCode = pp.part
,	PackagingCode = pp.code
,	Code = 'Order Detail Part Packaging:  ' + convert(varchar, od.id) + '(' + convert(varchar, oh.order_no) + ':' + oh.customer + ':' + oh.destination + ')-' + pp.part + ',' + pp.code
,	Description = 'Order Detail Part Packaging:  ' + convert(varchar, od.id) + '(' + convert(varchar, oh.order_no) + ':' + oh.customer + ':' + oh.destination + ')-' + pp.part + ',' + pp.code
,	PackDisabled = coalesce(ppod.PackDisabled, ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled, 0)
,	PackEnabled = coalesce(ppod.PackEnabled, ppoh.PackEnabled, ppbt.PackEnabled, ppst.PackEnabled, gd.DefaultEmptyOrNullEnabled)
,	PackDefault = coalesce(ppod.PackDefault, ppoh.PackDefault, ppbt.PackDefault, ppst.PackDefault, 0)
,	PackWarn = coalesce(ppod.PackWarn, ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn, gd.DefaultEmptyOrNullWarn)
,	DefaultPackDisabled = coalesce(ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled)
,	DefaultPackEnabled = coalesce(ppoh.PackEnabled, ppbt.PackEnabled, ppst.PackEnabled)
,	DefaultPackDefault = coalesce(ppoh.PackDefault, ppbt.PackDefault, ppst.PackDefault)
,	DefaultPackWarn = coalesce(ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn)
from
	dbo.part_packaging pp
	join dbo.order_detail od
		join dbo.order_header oh
			on oh.order_no = od.order_no
		on od.part_number = pp.part
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = oh.customer
		and ppbt.PartCode = od.part_number
		and ppbt.PackagingCode = pp.code
	left join dbo.PartPackaging_ShipTo ppst
		on ppst.ShipToCode = oh.destination
		and ppst.PartCode = od.part_number
		and ppst.PackagingCode = pp.code
	left join dbo.PartPackaging_OrderHeader ppoh
		on ppoh.OrderNo = oh.order_no
		and ppoh.PartCode = oh.blanket_part
		and ppoh.PackagingCode = pp.code
	left join dbo.PartPackaging_OrderDetail ppod
		on ppod.ReleaseID = od.id
		and ppod.PartCode = pp.part
		and ppod.PackagingCode = pp.code
	cross join GlobalDefaults gd
union all
select
	Type = 4
,	ID = convert(varchar, od.order_no) + ':' + convert(varchar, od.id)
,	PartCode = od.part_number
,	PackagingCode = 'N/A'
,	Code = 'Order Detail Part Packaging:  ' + convert(varchar, od.id) + '(' + convert(varchar, oh.order_no) + ':' + oh.customer + ':' + oh.destination + ')-' + od.part_number + ',' + 'N/A'
,	Description = 'Order Detail Part Packaging:  ' + convert(varchar, od.id) + '(' + convert(varchar, oh.order_no) + ':' + oh.customer + ':' + oh.destination + ')-' + od.part_number + ',' + 'N/A'
,	PackDisabled = coalesce(ppod.PackDisabled, ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled, 0)
,	PackEnabled = coalesce(ppod.PackEnabled, ppoh.PackEnabled, ppbt.PackEnabled, ppst.PackEnabled, gd.DefaultAlternatePackEnabled)
,	PackDefault = coalesce(ppod.PackDefault, ppoh.PackDefault, ppbt.PackDefault, ppst.PackDefault, 0)
,	PackWarn = coalesce(ppod.PackWarn, ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn, gd.DefaultAlternatePackWarn)
,	DefaultPackDisabled = coalesce(ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled)
,	DefaultPackEnabled = coalesce(ppoh.PackEnabled, ppbt.PackEnabled, ppst.PackEnabled)
,	DefaultPackDefault = coalesce(ppoh.PackDefault, ppbt.PackDefault, ppst.PackDefault)
,	DefaultPackWarn = coalesce(ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn)
from
	dbo.order_detail od
		join dbo.order_header oh
			on oh.order_no = od.order_no
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = oh.customer
		and ppbt.PartCode = od.part_number
		and ppbt.PackagingCode = 'N/A'
	left join dbo.PartPackaging_ShipTo ppst
		on ppst.ShipToCode = oh.destination
		and ppst.PartCode = od.part_number
		and ppst.PackagingCode = 'N/A'
	left join dbo.PartPackaging_OrderHeader ppoh
		on ppoh.OrderNo = oh.order_no
		and ppoh.PartCode = od.part_number
		and ppoh.PackagingCode = 'N/A'
	left join dbo.PartPackaging_OrderDetail ppod
		on ppod.ReleaseID = od.id
		and ppod.PartCode = od.part_number
		and ppod.PackagingCode = 'N/A'
	cross join GlobalDefaults gd
/*	Shipper Detail Part Packaging*/
union all
select
	Type = 5
,	ID = null
,	PartCode = null
,	PackagingCode = null
,	Code = 'Shipper Detail Part Packaging'
,	Description = ''
,	PackDisabled = null
,	PackEnabled = null
,	PackDefault = null
,	PackWarn = null
,	DefaultPackDisabled = null
,	DefaultPackEnabled = null
,	DefaultPackDefault = null
,	DefaultPackWarn = null
union all
select
	Type = 5
,	ID = convert(varchar, sd.shipper) + ':' + convert(varchar, sd.part)
,	PartCode = sd.part_original
,	PackagingCode = pp.code
,	Code = 'Shipper Detail Part Packaging{' + convert(varchar, sd.shipper) + ',' + sd.part + ',' + ',' + pp.part + ',' + pp.code + '}'
,	Description = 'Shipper Detail Part Packaging{ShipperID:' + convert(varchar, sd.shipper) + ', ShipperPart:' + sd.part + ', OrderNo:' + convert(varchar, sd.order_no) + ', BillTo:' + sOpen.customer + ', ShipTo:' + sOpen.destination + ', PartCode:' + pp.part + ', PackagingCode:' + pp.code + '}'
,	PackDisabled = coalesce(ppsd.PackDisabled, ppod.PackDisabled, ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled, 0)
,	PackEnabled = coalesce(ppsd.PackEnabled, ppod.PackEnabled, ppoh.PackEnabled, case when coalesce(ohBlanket.package_type, oh.package_type) = pp.code then 1 end, ppbt.PackEnabled, ppst.PackEnabled, gd.DefaultAlternatePackEnabled)
,	PackDefault = coalesce(ppsd.PackDefault, ppod.PackDefault, ppoh.PackDefault, case when coalesce(ohBlanket.package_type, oh.package_type) = pp.code then 1 end, ppbt.PackDefault, ppst.PackDefault, 0)
,	PackWarn = coalesce(ppsd.PackWarn, ppod.PackWarn, ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn, gd.DefaultAlternatePackWarn)
,	PackDisabled = coalesce(ppod.PackDisabled, ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled)
,	PackEnabled = coalesce(ppod.PackEnabled, ppoh.PackEnabled, case when coalesce(ohBlanket.package_type, oh.package_type) = pp.code then 1 end, ppbt.PackEnabled, ppst.PackEnabled)
,	PackDefault = coalesce(ppod.PackDefault, ppoh.PackDefault, case when coalesce(ohBlanket.package_type, oh.package_type) = pp.code then 1 end, ppbt.PackDefault, ppst.PackDefault)
,	PackWarn = coalesce(ppod.PackWarn, ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn)
from
	--Shipper is anchor
	dbo.shipper_detail sd
		join dbo.shipper sOpen
			on sOpen.id = sd.shipper
			and sOpen.status in ('O', 'S')
	--Part packaging relationships for shipper's parts
	join dbo.part_packaging pp
		on pp.part = sd.part_original
	--Part customer relationships for shipper's parts
	left join dbo.part_customer pc
		on pc.part = sd.part_original
	--First release for each of shipper's lines
	left join dbo.order_detail od
		join dbo.order_header oh
			on oh.order_no = od.order_no
		on od.part_number = sd.part_original
		and oh.destination = sOpen.destination
		and od.id =
		(	select
				min(id)
			from
				dbo.order_detail
			where
				order_no = oh.order_no
		)
	--Blanket order for each of shipper's lines
	left join dbo.order_header ohBlanket
		on ohBlanket.blanket_part = sd.part_original
		and ohBlanket.destination = sOpen.destination
	--	Bill to part packaging.
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = sOPen.customer
		and ppbt.PartCode = sd.part_original
		and ppbt.PackagingCode = pp.code
	--	Ship to part packaging
	left join dbo.PartPackaging_ShipTo ppst
		on ppst.ShipToCode = sOpen.destination
		and ppst.PartCode = sd.part_original
		and ppst.PackagingCode = pp.code
	--	Order header part packaging
	left join dbo.PartPackaging_OrderHeader ppoh
		on ppoh.OrderNo = coalesce(ohBlanket.order_no, oh.order_no)
		and ppoh.PartCode = sd.part_original
		and ppoh.PackagingCode = pp.code
	--	Order detail part packaging
	left join dbo.PartPackaging_OrderDetail ppod
		on ppod.ReleaseID = od.id
		and ppod.PartCode = sd.part_original
		and ppod.PackagingCode = pp.code
	--	Shipper detail part packaging
	left join dbo.PartPackaging_ShipperDetail ppsd
		on ppsd.ShipperID = sd.shipper
		and ppsd.PartCode = pp.part
		and ppsd.PackagingCode = pp.code
	cross join GlobalDefaults gd
union all
select
	Type = 5
,	ID = convert(varchar, sd.shipper) + ':' + convert(varchar, sd.part)
,	PartCode = sd.part_original
,	PackagingCode = 'N/A'
,	Code = 'Shipper Detail Part Packaging{' + convert(varchar, sd.shipper) + ',' + sd.part + ',' + ',' + sd.part_original + ',' + 'N/A' + '}'
,	Description = 'Shipper Detail Part Packaging{ShipperID:' + convert(varchar, sd.shipper) + ', ShipperPart:' + sd.part + ', OrderNo:' + convert(varchar, sd.order_no) + ', BillTo:' + sOpen.customer + ', ShipTo:' + sOpen.destination + ', PartCode:' + sd.part_original + ', PackagingCode:' + 'N/A' + '}'
,	PackDisabled = coalesce(ppsd.PackDisabled, ppod.PackDisabled, ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled, 0)
,	PackEnabled = coalesce(ppsd.PackEnabled, ppod.PackEnabled, ppoh.PackEnabled, case when coalesce(ohBlanket.package_type, oh.package_type) = sd.part_original then 1 end, ppbt.PackEnabled, ppst.PackEnabled, gd.DefaultEmptyOrNullEnabled)
,	PackDefault = coalesce(ppsd.PackDefault, ppod.PackDefault, ppoh.PackDefault, case when coalesce(ohBlanket.package_type, oh.package_type) = sd.part_original then 1 end, ppbt.PackDefault, ppst.PackDefault, 0)
,	PackWarn = coalesce(ppsd.PackWarn, ppod.PackWarn, ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn, gd.DefaultEmptyOrNullWarn)
,	PackDisabled = coalesce(ppod.PackDisabled, ppoh.PackDisabled, ppbt.PackDisabled, ppst.PackDisabled)
,	PackEnabled = coalesce(ppod.PackEnabled, ppoh.PackEnabled, case when coalesce(ohBlanket.package_type, oh.package_type) = sd.part_original then 1 end, ppbt.PackEnabled, ppst.PackEnabled)
,	PackDefault = coalesce(ppod.PackDefault, ppoh.PackDefault, case when coalesce(ohBlanket.package_type, oh.package_type) = sd.part_original then 1 end, ppbt.PackDefault, ppst.PackDefault)
,	PackWarn = coalesce(ppod.PackWarn, ppoh.PackWarn, ppbt.PackWarn, ppst.PackWarn)
from
	--Shipper is anchor
	dbo.shipper_detail sd
		join dbo.shipper sOpen
			on sOpen.id = sd.shipper
			and sOpen.status in ('O', 'S')
	--Part customer relationships for shipper's parts
	left join dbo.part_customer pc
		on pc.part = sd.part_original
	--First release for each of shipper's lines
	left join dbo.order_detail od
		join dbo.order_header oh
			on oh.order_no = od.order_no
		on od.part_number = sd.part_original
		and oh.destination = sOpen.destination
		and od.id =
		(	select
				min(id)
			from
				dbo.order_detail
			where
				order_no = oh.order_no
		)
	--Blanket order for each of shipper's lines
	left join dbo.order_header ohBlanket
		on ohBlanket.blanket_part = sd.part_original
		and ohBlanket.destination = sOpen.destination
	--	Bill to part packaging.
	left join dbo.PartPackaging_BillTo ppbt
		on ppbt.BillToCode = sOPen.customer
		and ppbt.PartCode = sd.part_original
		and ppbt.PackagingCode = 'N/A'
	--	Ship to part packaging
	left join dbo.PartPackaging_ShipTo ppst
		on ppst.ShipToCode = sOpen.destination
		and ppst.PartCode = sd.part_original
		and ppst.PackagingCode = 'N/A'
	--	Order header part packaging
	left join dbo.PartPackaging_OrderHeader ppoh
		on ppoh.OrderNo = coalesce(ohBlanket.order_no, oh.order_no)
		and ppoh.PartCode = sd.part_original
		and ppoh.PackagingCode = 'N/A'
	--	Order detail part packaging
	left join dbo.PartPackaging_OrderDetail ppod
		on ppod.ReleaseID = od.id
		and ppod.PartCode = sd.part_original
		and ppod.PackagingCode = 'N/A'
	--	Shipper detail part packaging
	left join dbo.PartPackaging_ShipperDetail ppsd
		on ppsd.ShipperID = sd.shipper
		and ppsd.PartCode = sd.part_original
		and ppsd.PackagingCode = 'N/A'
	cross join GlobalDefaults gd