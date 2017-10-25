SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[msp_CreateDropShipPO]
(	@Vendor varchar (25),
	@ShipTo varchar (25),
	@PONumber integer = 0 output,
	@Result integer = null output )
as
/*
declare	@Vendor varchar(25),
	@ShipTo varchar(25),
	@PONumber integer

set	@Vendor = 'A&K FINISH'
set	@ShipTo = 'ADRIAN STL'

begin transaction CreateDropShipPO

declare	@ProcReturn integer,
	@ProcResult integer,
	@Error integer

execute	@ProcReturn = dbo.msp_CreateDropShipPO
	@Vendor = @Vendor,
	@ShipTo = @ShipTo,
	@PONumber = @PONumber out,
	@Result = @ProcResult out

select	@ProcReturn, @ProcResult, @PONumber, @ProcResult

rollback


---------------------------------------------------------------------------------------
--	Description:
--	This procedure creates a drop ship PO from the specified vendor to the
--	specified ship to.  The PO Number created is returned.
--
--	Parameters:
--	Vendor		The supplier of the material.
--	ShipTo		Address to deliver materials to.
--	PONumber	The new PO Number created.
--	Result		The result of running the procedure.  Same as return
--			value.
--
--	Returns:
--	    0	success
--	  -10	Invalid vendor.
--	  -20	Invalid ship to.
--	 -999	Unknown error.
--
--	History:
--	30 MAY 2002, Eric Stimpson	Original.
--	04 JUL 2002, Eric Stimpson	Added freight type from destination shipping.
--
--	Process:
--	I.	Validate parameters.
--		A.	Check that vendor is valid.
--		B.	Check that delivery address is valid.
--	II.	Create new PO.
--		A.	Obtain new PO Number.
--		B.	Create PO header record.
--	III.	Return success.
---------------------------------------------------------------------------------------
*/
set nocount on
set	@Result = 999999

--- <Error Handling>
declare	@CallProcName sysname,
	@TableName sysname,
	@ProcName sysname,
	@ProcReturn integer,
	@ProcResult integer,
	@Error integer,
	@RowCount integer

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. dbo.usp_Test
--- </Error Handling>

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=No>
declare	@TranCount smallint

set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
save tran @ProcName
--- </Tran>

--	I.	Validate parameters.
--		A.	Check that vendor is valid.
if not exists
(	select	1
	from	vendor
	where	code = @Vendor )
begin
	select	@Result = -10
	rollback tran @ProcName
	return	@Result
end

--		B.	Check that delivery address is valid.
if not exists
(	select	1
	from	destination
	where	destination = @ShipTo and
		customer in
		(	select	customer
			from	customer ) )
begin
	select	@Result = -20
	rollback tran @ProcName
	return	@Result
end

--	II.	Create new PO.
--		A.	Obtain new PO Number.
update	parameters
set	purchase_order = purchase_order + 1

select	@PONumber = purchase_order - 1
from	parameters

while exists
(	select	po_number
	from	po_header
	where	po_number = @PONumber ) or
exists
(	select	po_number
	from	po_detail_history
	where	po_number = @PONumber )
	select	@PONumber = @PONumber + 1

update	parameters
set	purchase_order = @PONumber + 1

--		B.	Create PO header record.
insert	po_header
(	po_number,
	vendor_code,
	po_date,
	terms,
	ship_to_destination,
	status,
	freight_type,
	ship_type )
select	@PONumber,
	@Vendor,
	GetDate ( ),
	vendor.terms,
	@ShipTO,
	'A',
	(	select	min ( freight_type )
		from	destination_shipping
			join destination on destination_shipping.destination = destination.destination
		where	destination.vendor = @Vendor ),
	'DropShip'
from	vendor
where	code = @Vendor

if @@error != 0 or @@rowcount != 1
begin
	select	@Result = -999
	rollback tran @ProcName
	return	@Result
end

--<CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit transaction @ProcName
end
--</CloseTran Required=Yes AutoCreate=Yes>

--	III.	Return success.
select	@Result = 0
return	@Result

GO
