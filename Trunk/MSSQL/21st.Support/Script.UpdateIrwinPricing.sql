begin transaction
go
return

select
	*
--into
--	tempdb.dbo.PricesWithNoParts
from
	tempdb.dbo.Prices_2022 p2
where
	not exists
		(	select
				*
			from
				dbo.part p
			where
				p.part = p2.PartCode
		)

select
	*
--into
--	tempdb.dbo.PricesWithNoPartCustomer
from
	tempdb.dbo.Prices_2022 p2
where
	exists
		(	select
				*
			from
				dbo.part p
			where
				p.part = p2.PartCode
		)
	and not exists
		(	select
				*
			from
				dbo.part_customer pc
			where
				pc.part = p2.PartCode
		)

select
	pc.part
,	pc.customer
,	pc.customer_part
,	pc.customer_standard_pack
,	pc.taxable
,	pc.customer_unit
,	pc.type
,	pc.upc_code
,	pc.blanket_price
,	new_blanket_price = round(p2.Price, 2)
--into
--	tempdb.dbo.UpdatedPartCustomer
from
	dbo.part_customer pc
	join tempdb.dbo.Prices_2022 p2
		on p2.PartCode = pc.part
where
	pc.customer = 'IRWIN-GRAN'

select
	pcpm.part
,	pcpm.customer
,	pcpm.code
,	pcpm.price
,	pcpm.qty_break
,	pcpm.discount
,	pcpm.category
,	pcpm.alternate_price
,	new_price = round(p2.Price, 2)
,	new_alternate_price = round(p2.Price, 2)
--into
--	tempdb.dbo.UpdatedPartCustomerPriceMatrix
from
	dbo.part_customer_price_matrix pcpm
	join tempdb.dbo.Prices_2022 p2
		on p2.PartCode = pcpm.part
where
	pcpm.customer = 'IRWIN-GRAN'

select
	oh.order_no
,	oh.customer
,	oh.destination
,	oh.blanket_part
,	oh.price
,	oh.alternate_price
,	new_price = round(p2.Price, 2)
,	new_alternate_price = round(p2.Price, 2)
--into
--	tempdb.dbo.UpdatedBlanketOrders
from
	dbo.order_header oh
		join tempdb.dbo.Prices_2022 p2
		on p2.PartCode = oh.blanket_part
where
	oh.customer = 'IRWIN-GRAN'

select
	od.order_no
,	od.destination
,	od.part_number
,	od.price
,	od.alternate_price
,	new_price = round(p2.Price, 2)
,	new_alternate_price = round(p2.Price, 2)
--into
--	tempdb.dbo.UpdatedOrderDetails
from
	dbo.order_detail od
		join tempdb.dbo.Prices_2022 p2
		on p2.PartCode = od.part_number
	join dbo.order_header oh
		on oh.order_no = od.order_no
where
	oh.customer = 'IRWIN-GRAN'

select
	sd.shipper
,	s.destination
,	s.date_shipped
,	sd.part_original
,	sd.price
,	sd.alternate_price
,	new_price = round(p2.Price, 2)
,	new_alternate_price = round(p2.Price, 2)
--into
--	tempdb.dbo.UpdatedShippers
from
	dbo.shipper_detail sd
		join tempdb.dbo.Prices_2022 p2
		on p2.PartCode = sd.part_original
	join dbo.shipper s
		on sd.shipper = s.id
where
	s.customer = 'IRWIN-GRAN'
	and coalesce(s.date_shipped, getdate()) > '2022-01-01'
	and coalesce(s.posted, 'N') != 'Y'
	and s.type is null
go
return

update
	pc
set blanket_price = round(p2.Price, 2)
from
	dbo.part_customer pc
	join tempdb.dbo.Prices_2022 p2
		on p2.PartCode = pc.part
where
	pc.customer = 'IRWIN-GRAN'

/* dbo.part_customer_price_matrix is a view from dbo.part_customer */
--update
--	pcpm
--set price = round(p2.Price, 2)
--,	alternate_price = round(p2.Price, 2)
--from
--	dbo.part_customer_price_matrix pcpm
--	join tempdb.dbo.Prices_2022 p2
--		on p2.PartCode = pcpm.part
--where
--	pcpm.customer = 'IRWIN-GRAN'

update
	oh
set price = round(p2.Price, 2)
,	alternate_price = round(p2.Price, 2)
--into
--	tempdb.dbo.UpdatedBlanketOrders
from
	dbo.order_header oh
		join tempdb.dbo.Prices_2022 p2
		on p2.PartCode = oh.blanket_part
where
	oh.customer = 'IRWIN-GRAN'

update
	od
set price = round(p2.Price, 2)
,	alternate_price = round(p2.Price, 2)
--into
--	tempdb.dbo.UpdatedOrderDetails
from
	dbo.order_detail od
		join tempdb.dbo.Prices_2022 p2
		on p2.PartCode = od.part_number
	join dbo.order_header oh
		on oh.order_no = od.order_no
where
	oh.customer = 'IRWIN-GRAN'

update
	sd
set price = round(p2.Price, 2)
,	alternate_price = round(p2.Price, 2)
--into
--	tempdb.dbo.UpdatedShippers
from
	dbo.shipper_detail sd
		join tempdb.dbo.Prices_2022 p2
		on p2.PartCode = sd.part_original
	join dbo.shipper s
		on sd.shipper = s.id
where
	s.customer = 'IRWIN-GRAN'
	and coalesce(s.date_shipped, getdate()) > '2022-01-01'
	and coalesce(s.posted, 'N') != 'Y'
	and s.type is null
go

/* Prototype new parts */
return

insert
	dbo.part
(	part
,	name
,	cross_ref
,	class
,	type
,	quality_alert
,	description_short
,	serial_type
,	product_line
,	gl_account_code
)
select
	pNew.part
,	pNew.name
,	pNew.cross_ref
,	pNew.class
,	pNew.type
,	pNew.quality_alert
,	pNew.description_short
,	pNew.serial_type
,	pNew.product_line
,	pNew.gl_account_code
--into
--	tempdb.dbo.PricesWithNoParts
from
	tempdb.dbo.Prices_2022 p2
	cross apply
		(	select top(1)
				part = p2.PartCode
			,	pProto.name
			,	pProto.cross_ref
			,	pProto.class
			,	pProto.type
			,	pProto.quality_alert
			,	description_short = 'Irwin Price Update 2022'
			,	pProto.serial_type
			,	pProto.product_line
			,	pProto.gl_account_code
			from
				dbo.part pProto
			where
				pProto.part like left(p2.PartCode, len(p2.PartCode) - 3) + '%'
			order by
				pProto.part
		) pNew
where
	not exists
		(	select
				*
			from
				dbo.part p
			where
				p.part = p2.PartCode
		)



go

--commit
rollback
go
