SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [EDI_XML_PLEX_ASN].[udf_Root]
(	@ShipperID INT
,	@Purpose CHAR(2)
,	@partialComplete INT
)
RETURNS XML
AS
BEGIN
	

--- <Body>
	declare
		@xmlOutput xml

	declare
		@ItemLoops int
	,	@TotalQuantity int

	select
		@ItemLoops = max(al.RowNumber)
	,	@TotalQuantity = sum(al.QtyPacked)
	from
		EDI_XML_PLEX_ASN.ASNLines al
	where
		al.ShipperID = @ShipperID

	SET
		@xmlOutput =
			(	SELECT
					(	SELECT
							EDI_XML.TRN_INFO('004010', '856', ah.TradingPartner, ah.IConnectID, ah.ShipperID, @PartialComplete)
						,	EDI_XML_V4010.SEG_BSN(@Purpose, ah.ShipperID, ah.ASNDate, ah.ASNTime)
						,	EDI_XML_V4010.SEG_DTM('011', ah.ShipDateTime, ah.TimeZoneCode)
						,	(	SELECT
				 					EDI_XML.LOOP_INFO('HL')
								,	EDI_XML_V4010.SEG_HL(1, NULL, 'S', 1)
								,	EDI_XML_V4010.SEG_MEA('WT', 'G', ah.GrossWeight, 'LB')
								,	EDI_XML_V4010.SEG_MEA('WT', 'N', ah.NetWeight, 'LB')
								,	EDI_XML_V4010.SEG_TD1(ah.PackageType, ah.BOLQuantity)
								,	EDI_XML_V4010.SEG_TD5('B', '2', ah.Carrier, ah.TransMode, NULL, NULL)
								,	EDI_XML_V4010.SEG_TD3('TL', ah.EquipInitial, ah.TruckNumber)
								,	EDI_XML_V4010.SEG_REF('PK', ah.PackingListNumber)
								,	EDI_XML_V4010.SEG_REF('BM', ah.BOLNumber)
								,	EDI_XML_V4010.SEG_REF('CN', ah.PackingListNumber)
								,   EDI_XML_PLEX_ASN.SEG_FOB(ah.FOB)
								,	(	SELECT
						 					EDI_XML.LOOP_INFO('N1')
										,	EDI_XML_PLEX_ASN.SEG_N1('ST', 92, ah.ShipToID, ah.ShipToName)
						 				FOR XML RAW ('LOOP-N1'), TYPE
						 			)
								,	(	SELECT
						 					EDI_XML.LOOP_INFO('N1')
										,	EDI_XML_PLEX_ASN.SEG_N1('SU', 92, ah.SupplierCode, ah.SupplierName)
						 				FOR XML RAW ('LOOP-N1'), TYPE
						 			)
				 				FOR XML RAW ('LOOP-HL'), TYPE
				 			)
						,	(	SELECT
				 					EDI_XML.LOOP_INFO('HL')
								,	EDI_XML_V4010.SEG_HL(1+al.RowNumber, 2, 'I', NULL)
								,	EDI_XML_PLEX_ASN.SEG_LIN(NULL, 'BP', al.CustomerPart, 'PO', al.CustomerPO, 'EC', al.CustomerECL)
								,	EDI_XML_V4010.SEG_SN1(NULL, al.QtyPacked, 'EA', al.AccumShipped)
								,	EDI_XML_V4010.SEG_PRF(al.CustomerPO)
									--CLD Loop
								,	(	SELECT
											EDI_XML.LOOP_INFO('CLD')
										,	EDI_XML_V4010.SEG_CLD(alpqd.PackCount, alpqd.PackQty, ah.PackageType)
										,	EDI_XML_PLEX_ASN.udf_OrderSerials(ah.ShipperID, al.CustomerPart, alpqd.PackageType, alpqd.PackQty)
										FROM
											EDI_XML_PLEX_ASN.ASNLinePackQtyDetails alpqd
										WHERE
											alpqd.ShipperID = al.ShipperID
											AND alpqd.CustomerPart = al.CustomerPart
										FOR XML RAW ('LOOP-CLD'), TYPE
									)	
								FROM
									EDI_XML_PLEX_ASN.ASNLines al
								WHERE
									al.ShipperID = @ShipperID
								ORDER BY
									al.RowNumber
				 				FOR XML RAW ('LOOP-HL'), TYPE
							)
						,	EDI_XML_V4010.SEG_CTT(1 + @ItemLoops, NULL)
						FROM
							EDI_XML_PLEX_ASN.ASNHeaders ah
						WHERE
							ah.ShipperID = @ShipperID
						FOR XML RAW ('TRN-856'), TYPE
					)
				FOR XML RAW ('TRN'), TYPE
			)

			if not exists ( select 1 from EDI_XML_PLEX_ASN.ASNLines where shipperID = @ShipperID )
			Begin
				Select @xmlOutput = ''
			End
--- </Body>

---	<Return>
	RETURN
		@xmlOutput
END



GO
