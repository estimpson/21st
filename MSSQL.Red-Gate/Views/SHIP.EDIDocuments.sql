SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [SHIP].[EDIDocuments]
as

 WITH ExcludeShippers (ShipperID, cpCount, cp2Count)
      AS
      (
            SELECT s.id, coalesce((select count(distinct customer_part) from shipper_detail  sd where sd.shipper = s.id and (sd.customer_part  like '%52S-%' or  sd.customer_part  like '%45S-%' )),0)  ,(select count(distinct customer_part) from shipper_detail  sd where sd.shipper = s.id )
            FROM shipper s
			Join
				edi_setups es on es.destination = s.destination and es.asn_overlay_group = 'PLX'
			where s.date_shipped >getdate()-180
      )
select
	ShipperNumber = 'L' + convert(varchar(49), s.id)
,	ShipDT = s.date_shipped
,	LegacyShipperID = s.id
,	ShipperType = coalesce(s.type, 'N')
,	DocumentType = 1 --Should come from a more generic XML_DataRootFunction table.
,	OverlayGroup = esASN.asn_overlay_group
,	LegacyGenerator = case when esASN.auto_create_asn = 'Y' then 1 else 0 end
,	xsnadrf.FunctionName
,	xsnaeh.ExceptionHandler
,	cegl.FileStreamID
,	cegl.RowID
,	cegl.FileGenerationDT
,	cegl.FileSendDT
,	cegl.FileAcknowledgementDT
,	FileStatus = cegl.Status
from
	dbo.shipper s
	join dbo.edi_setups esASN
		on esASN.destination = s.destination
		and
		(	esASN.asn_overlay_group > ''
			or coalesce(esASN.auto_create_asn, 'N') != 'N'
		)
	left join EDI.XMLShipNotice_ASNDataRootFunction xsnadrf
		on xsnadrf.ASNOverlayGroup = esASN.asn_overlay_group
	outer apply
		(	select top 1
				xsnaeh.ExceptionHandler
			from
				EDI.XMLShipNotice_ASNExceptionHandler xsnaeh
			where
				xsnaeh.ASNOverlayGroup = esASN.asn_overlay_group
				and coalesce(xsnaeh.BillTo, s.customer) = s.customer
				and coalesce(xsnaeh.ShipTo, s.destination) = s.destination
			order by
				case when xsnaeh.ShipTo = s.destination then 0 else 1 end
			,	case when xsnaeh.BillTo = s.customer then 0 else 1 end
		) xsnaeh
	outer apply
		(	select top 1
				cegl.FileStreamID
			,	cegl.Status
			,	cegl.FileGenerationDT
			,	cegl.FileSendDT
			,	cegl.FileAcknowledgementDT
			,	cegl.RowID
			from
				dbo.CustomerEDI_GenerationLog cegl
			where
				cegl.ShipperID = s.id
				and cegl.Type = 1 --Should be DocumentType
			order by
				cegl.FileGenerationDT desc
		) cegl
where
	s.status in ('C', 'Z')
	and coalesce(s.type, 'N') = 'N'
	and s.id in  (Select ShipperID from ExcludeShippers where cpCount != cp2Count)  
	and case when esASN.auto_create_asn = 'N' then 1 else 0 end = 1 -- Want to capture only edi destinations
	and	Nullif(asn_overlay_group,'') is not NULL --ignore destinations that do not have ASN Overlay group defined





GO
