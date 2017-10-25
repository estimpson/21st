SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[ftsp_CreateDropShipPOs]
as

begin
Declare		@PoNumber int,
		@Vendor varchar(15),
		@Terms varchar(20),
		@FOB varchar(20),
		@ShipVia varchar(20),
		@Destination varchar(15),
		@Description varchar(50),
		@FreightType varchar(20),
		@Part varchar(25),
		@Price numeric(20,6),
		@StdUnit varchar(2)

Declare PartList cursor for
Select	PartImport.Part
from	PartImport
join	Part on Partimport.part = part.part
where	partimport.part not in (Select isNull(Blanket_part,'') from po_header)

OPEN PartList

FETCH NEXT FROM PartList
INTO @Part

While	@@FETCH_STATUS = 0
BEGIN

Select	@PONumber = purchase_order
From	parameters

Select	@Vendor = 'PARAMOUNT',
	@Destination = 'IRWIN-GRAN'

Select	@terms = terms,
	@FOB = FOB,
	@ShipVia = ship_via,
	@FreightType = frieght_type
From	vendor
where	code = @Vendor
	
Select	@Description = name,
	@price = price,
	@StdUnit = standard_unit
From	part 
join	part_standard on part.part = part_standard.part
join	part_inventory on part.part = part_inventory.part
where	part.part = @part


Insert	po_header 
	(	po_number,
		vendor_code,
		po_date,
		terms,
		fob,
		ship_via,
		ship_to_destination,
		status,
		type,
		description,
		plant,
		freight_type,
		blanket_part,
		price,
		std_unit,
		ship_type,
		release_no,
		release_control)

Select		@PoNumber,
		@Vendor,
		getdate(),
		@Terms,
		@FOB,
		@ShipVia,
		@Destination,
		'A',
		'B',
		@Description,
		'PLANT 1',
		@FreightType,
		@Part,
		@Price,
		@StdUnit,
		'DropShip',
		1,
		'A'

update	parameters set purchase_order = @PONumber + 1

FETCH NEXT FROM PartList
INTO @Part

END
CLOSE PartList
DEALLOCATE PartList

end



			
		
GO
