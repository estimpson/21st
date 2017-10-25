SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view
  [dbo].[cdivw_orders_list](order_no,
  part,
  boxlabel,
  customerpo,
  customerpart,
  destination,
  duedate)
  as select distinct od.order_no,od.part_number,od.box_label,oh.customer_po,od.customer_part,oh.destination,
    od.due_date
    from order_detail as od join
    order_header as oh on oh.order_no=od.order_no and isnull(oh.status,'o')<>'c'
    where oh.order_type='N'
  union select oh.order_no,oh.blanket_part,oh.box_label,oh.customer_po,oh.customer_part,oh.destination,
    oh.order_date
    from order_header as oh
    where oh.order_type='B' 
GO
