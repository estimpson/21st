SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[msp_CreateDropShipShipper]
(	@Operator varchar (5),
	@PONumber integer,
	@ShipperDT datetime,
	@ShipperID integer = 0 output,
	@Result integer = null output )
as
---------------------------------------------------------------------------------------
--	Description:
--	This procedure creates a drop ship shppper for the specified PO and shipper
--	date. The shipper id created is returned.
--
--	Parameters:
--	Operator	The operator creating the invoice.
--	PONumber	The PO Number being invoiced.
--	ShipperDT	The date the shipper is expected to ship.
--	ShipperID	The new shipper id created.
--	Result		The result of running the procedure.  Same as return
--			value.
--
--	Returns:
--	    0	success
--	  -10	Invalid operator.
--	  -20	Invalid PO number.
--	 -999	Unknown error.
--
--	History:
--	11 JUN 2002, Eric Stimpson	Original.
--
--	Process:
--	I.	Validate parameters.
--		A.	Check that operator is valid.
--		B.	Check that PO Number is valid.
--	II.	Create new PO.
--		A.	Obtain new Invoice Number and Shipper ID.
--		B.	Create Invoice header record.
--	III.	Return success.
---------------------------------------------------------------------------------------
begin transaction

--	I.	Validate parameters.
--		A.	Check that operator is valid.
if not exists
(	select	1
	from	employee
	where	operator_code = @Operator )
begin
	select	@Result = -10
	rollback
	return	@Result
end

--		B.	Check that PO Number is valid.
if not exists
(	select	1
	from	po_detail
		join po_header on po_detail.po_number = po_header.po_number and
			po_header.status = 'A'
	where	po_detail.po_number = @PONumber and
		po_detail.balance > 0 and
		po_detail.ship_type = 'D' )
begin
	select	@Result = -20
	rollback
	return	@Result
end

--	II.	Create new PO.
--		A.	Obtain new Shipper ID.
update	parameters
set	shipper = shipper + 1

select	@ShipperID = shipper - 1
from	parameters

while exists
(	select	id
	from	shipper
	where	id = @ShipperID )
	select	@ShipperID = @ShipperID + 1

update	parameters
set	shipper = @ShipperID + 1

--		B.	Create shipper header record.
insert	shipper
(	id,
	destination,
	date_stamp,
	ship_via,
	status,
	freight_type,
	customer,
	plant,
	type,
	freight,
	trans_mode,
	invoice_printed,
	terms,
	tax_rate,
	dropship_reconciled )
select	@ShipperID,
	po_header.ship_to_destination,
	@ShipperDT,
	destination_shipping.scac_code,
	'C',
	destination_shipping.freight_type,
	destination.customer,
	po_header.plant,
	'D',
	0,
	destination_shipping.trans_mode,
	'N',
	customer.terms,
	IsNull ( destination.salestax_rate, 0 ),
	'N'
from	po_header
	join destination on po_header.ship_to_destination = destination.destination
	join destination_shipping on po_header.ship_to_destination = destination_shipping.destination
	join customer on destination.customer = customer.customer
where	po_number = @PONumber

if @@error != 0 or @@rowcount != 1
begin
	select	@Result = -999
	rollback
	return	@Result
end

--	III.	Return success.
select	@Result = 0
return	@Result

GO
