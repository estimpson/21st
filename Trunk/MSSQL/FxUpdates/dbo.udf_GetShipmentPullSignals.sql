SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[udf_GetShipmentPullSignals]
(	@ShipTo varchar(10),
	@ShipFrom varchar(10),
	@ShipmentType char(1))
returns @OrderQuantities table
(	OrderNo numeric(8,0),
	PartNumber varchar(25),
	CustomerPart varchar(30),
	Suffix integer,
	DueDT datetime,
	HorizonType integer,
	Sequence integer,
	OrderQty numeric(20,6),
	ScheduledQty numeric(20,6),
	TransitInvQty numeric(20,6))
as
begin
	insert	@OrderQuantities
	select	order_detail.order_no,
		order_detail.part_number,
		order_detail.customer_part,
		order_detail.suffix,
		order_detail.due_date,
		type =(case order_detail.type when 'F' then 0 when 'P' then 1 when 'O' then 2 end),
		order_detail.sequence,
		order_detail.quantity,
		CommittedQty =
		(	case	when Coalesce(Previous.Accum, 0) + Coalesce(quantity, 0) < Coalesce(Scheduled.Qty, 0)
					then Coalesce(quantity, 0)
				when Coalesce(Previous.Accum, 0) < Coalesce(Scheduled.Qty, 0)
					then Coalesce(Scheduled.Qty, 0) - Coalesce(Previous.Accum, 0)
				else 0
				end),
		0
	from	order_detail
		join order_header on order_header.order_no = order_detail.order_no
		join
		(	select	od.id, Accum = Coalesce(sum(od2.quantity), 0)
			from	order_detail od
				left outer join order_detail od2 on od.order_no = od2.order_no and
					od.part_number = od2.part_number and
					coalesce(od.suffix, od2.suffix, -1) = Coalesce(od2.suffix, -1) and
					(	od.due_date > od2.due_date or
						od.due_date = od2.due_date and
						od.id < od2.id)
			group by od.id) as Previous on order_detail.id = Previous.id
		left outer join
		(	select		type = Coalesce('N', shipper.type),
					order_no, 
					part_original, 
					suffix, 
					Qty = sum(qty_required)
			from	shipper_detail
				join shipper on shipper_detail.shipper = shipper.id
			where	shipper.status in('O', 'S') 
			group by shipper.type, order_no, part_original, suffix) as Scheduled 
				on order_detail.order_no = Scheduled.order_no and
				part_number = Scheduled.part_original and
				Coalesce(order_detail.suffix, -1) = Coalesce(Scheduled.suffix, -1) and
				Scheduled.type = @ShipmentType
	where	Coalesce(order_header.plant, '') = Coalesce(NullIf(@ShipFrom, ''), Coalesce(order_header.plant, '')) and
		order_detail.destination = Coalesce(@ShipTo,order_detail.destination)

	return
end
GO
