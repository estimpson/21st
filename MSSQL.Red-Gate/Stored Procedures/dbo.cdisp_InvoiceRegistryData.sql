SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[cdisp_InvoiceRegistryData](@al_shipper integer)
as
declare @total_invamount numeric(20,6),
@total_fgsamount numeric(20,6),
@total_tolamount numeric(20,6),
@total_misamount numeric(20,6),
@total_frtamount numeric(20,6)
select @total_fgsamount=isnull(sum(round(alternative_qty*alternate_price,2)),0)
  from shipper_detail
  where shipper=@al_shipper
  and upper(part_original) not like '%TOOLING%' and upper(part_original) not like '%MISCELLANEOUS%'
select @total_tolamount=isnull(sum(round(alternative_qty*alternate_price,2)),0)
  from shipper_detail
  where shipper=@al_shipper
  and upper(part_original) like '%TOOLING%'
select @total_misamount=isnull(sum(round(alternative_qty*alternate_price,2)),0)
  from shipper_detail
  where shipper=@al_shipper
  and upper(part_original) like '%MISCELLANEOUS%'
select @total_frtamount=isnull(freight,0)
  from shipper
  where id=@al_shipper
select @total_invamount=isnull(sum(round(alternative_qty*alternate_price,2)),0)+@total_frtamount
  from shipper_detail
  where shipper=@al_shipper
select finished=@total_fgsamount,
  tooling=@total_tolamount,
  freight=@total_frtamount,
  miscellaneous=@total_misamount,
  invoiceamt=@total_invamount
GO
