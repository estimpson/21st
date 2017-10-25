SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [EDI_XML_PLEX_ASN].[ASNObjects]
AS
SELECT
	ShipperID = s.id
,	CustomerPart = sd.customer_part
,	CustomerSerial = 'C' + CONVERT(VARCHAR(12), at.serial)
,	PackageType = COALESCE(NULLIF(at.package_type,''),'CTN90')
,	PackQty = at.std_quantity 
FROM
	dbo.shipper s
	JOIN dbo.shipper_detail sd
		ON sd.shipper = s.id
	JOIN dbo.audit_trail at
		ON at.type = 'S'
		AND at.shipper = CONVERT(VARCHAR(50), s.id)
		AND at.part = sd.part
WHERE
	COALESCE(s.type, 'N') IN ('N', 'M')



GO
