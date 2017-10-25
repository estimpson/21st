SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

	                                   
CREATE VIEW [EDI_XML_PLEX_ASN].[ASNLinePackQtyDetails]
AS
SELECT
	ShipperID = s.id
,	CustomerPart = sd.customer_part
,	PackageType = COALESCE(NULLIF(at.package_type,''),'CTN90')
,	PackQty = at.std_quantity
,	PackCount = COUNT(*)
FROM
	dbo.shipper s
	JOIN dbo.shipper_detail sd
		ON sd.shipper = s.id
	JOIN dbo.audit_trail at
		ON at.type ='S'
		AND at.shipper = CONVERT(VARCHAR, sd.shipper)
		AND at.part = sd.part
WHERE
	COALESCE(s.type, 'N') IN ('N', 'M')
GROUP BY
	s.id
,	sd.customer_part
,	at.std_quantity
,	COALESCE(NULLIF(at.package_type,''),'CTN90')


GO
