SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_MonitorInvoice]
(	@InvoiceNumber varchar(25))
as
select	shipper.id,
	destination.company,
	destination.destination,
	destination.name,
	destination.address_1,
	destination.address_2,
	destination.address_3,
	destination.address_4,
	destination.address_5,
	destination.address_6,
	customer.customer,
	customer.name,
	customer.address_1,
	customer.address_2,
	customer.address_3,
	customer.address_4,
	customer.address_5,
	customer.address_6,
	customer.custom1,
	customer.custom2,
	customer.custom3,
	customer.default_currency_unit,
	edi_setups.supplier_code,
	shipper.aetc_number,
	destination_shipping.fob,
	destination_shipping.note_for_bol,
	destination_shipping.note_for_shipper,
	shipper.freight_type,
	carrier.name,
	shipper_detail.note,
	order_header.customer_po,
	shipper_detail.qty_original,
	shipper_detail.qty_packed,
	shipper_detail.date_shipped,
	shipper.gross_weight,
	part.part,
	ISNULL(part.name, 'Part has been deleted'),
	part.cross_ref,
	shipper.staged_objs,
	shipper.staged_pallets,
	shipper.gross_weight,
	shipper_detail.price,
	destination_shipping.note_for_bol,
	shipper_detail.customer_part,
	shipper_detail.net_weight,
	shipper.terms,
	shipper.invoice_number,
	shipper.notes,
	shipper.pro_number,
	shipper.truck_number,
	parameters.company_name,
	parameters.address_1,
	parameters.address_2,
	parameters.address_3,
	parameters.phone_number,
	order_header.salesman,
	order_header.plant,
	shipper.trans_mode,
	shipper.date_shipped,
	shipper_detail.release_no,
	part_inventory.standard_pack,
	part_inventory.standard_unit,
	shipper_detail.customer_part,
	shipper_detail.part_original,
	shipper.freight,
	shipper_detail.part_name,
	shipper_detail.customer_po,
	isnull(shipper.type, 'x') as shipper_type,
	part_customer.customer_part,
	shipper.date_stamp,
	shipper_detail.release_no,
	shipper.invoice_printed
from	shipper
	join shipper_detail on shipper.id = shipper_detail.shipper
	left join carrier on shipper.ship_via = carrier.scac
	join destination on shipper.destination = destination.destination
	left join customer on destination.customer = customer.customer
	left join destination_shipping on destination.destination = destination_shipping.destination
	left join edi_setups on destination.destination = edi_setups.destination
	left join order_header on shipper_detail.order_no = order_header.order_no
	LEFT join part on shipper_detail.part_original = part.part
	LEFT join part_inventory on shipper_detail.part_original = part_inventory.part
	left join part_customer on shipper_detail.part = part_customer.part and
				customer.customer = part_customer.customer
	cross join parameters
where	shipper.invoice_number = convert(integer, @InvoiceNumber)

GO
