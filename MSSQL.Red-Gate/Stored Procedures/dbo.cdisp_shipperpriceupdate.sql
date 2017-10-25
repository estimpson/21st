SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[cdisp_shipperpriceupdate]
@Part varchar(25),
@Customer varchar(20),
@Price numeric(20,6),
@Action smallint
as
if	@Action = 0 begin
	update	shipper_detail
	set	alternate_price = @Price
	from	shipper_detail
		join shipper on shipper_detail.shipper = shipper.id
	where	shipper_detail.part_original = @Part and
		shipper.customer = @Customer and
		shipper.status in ('O', 'S') and
		Coalesce(shipper.type, 'N') in ('N', 'Q')
end
if	@Action = 1 begin
	update	shipper_detail
	set	alternate_price = @Price
	from	shipper_detail
		join shipper on shipper_detail.shipper = shipper.id
	where	shipper_detail.part_original = @Part and
		shipper.customer = @Customer and
		shipper.status in ('C', 'Z') and
		Coalesce(shipper.type, 'N') in ('M', 'N', 'Q') and
		shipper.invoice_number > 0 and
		Coalesce(shipper.invoice_printed, 'N') = 'N'
end

GO
