SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [EDI_XML_PLEX_ASN].[ASNHeaders]
AS
 WITH ExcludeShippers (ShipperID, cpCount, cp2Count)
      AS
      (
            SELECT s.id 
			,coalesce((select count(distinct customer_part) 
						from shipper_detail  sd 
						join part p on p.part = sd.part_original
						join user_definable_data ud on ud.code = p.user_defined_1 and ud.module = 'PM' and ud.description like '%No%ASN%'
						where sd.shipper = s.id ),0)  
			,(select count(distinct customer_part) from shipper_detail  sd where sd.shipper = s.id )
            FROM shipper s
			Join
				edi_setups es on es.destination = s.destination and es.asn_overlay_group = 'PLX'
			where s.date_shipped >getdate()-180
      )

SELECT 
	ShipperID = s.id
,	IConnectID = es.IConnectID
,	ShipDateTime = s.date_shipped
,	ASNDate = CONVERT(DATE, s.date_shipped)
,	ASNTime = CONVERT(TIME, s.date_shipped)
,	TimeZoneCode =  [dbo].[udfGetDSTIndication] (s.date_shipped)
,	TradingPartner	= es.trading_partner_code
,	ShipToCode = es.parent_destination
,	ShipToID = COALESCE(NULLIF(es.EDIShipToID,''),NULLIF(es.parent_destination,''),es.destination)
,	ShipToName = d.name
,	SupplierCode = es.supplier_code
,	SupplierName = '21st Century Plastics'
,	EquipInitial = COALESCE( bol.equipment_initial, s.ship_via )
,	BOLQuantity = s.staged_objs
,	GrossWeight = CONVERT(INT, ROUND(COALESCE(s.gross_weight,0), 0))+1
,	NetWeight = CONVERT(INT, ROUND(COALESCE(s.net_weight,0), 0))+1
,	Carrier = s.ship_via
,	TransMode = s.trans_mode
,	TruckNumber = LEFT(UPPER(COALESCE(NULLIF(s.truck_number,''), 'TRUCKNO')),10)
,	BOLNumber = COALESCE(s.bill_of_lading_number, id)
,	PackingListNumber = s.id
,	PackageType = 'CTN90'
,	FOB = CASE WHEN freight_type =  'Collect' THEN 'CC' WHEN freight_type IN  ('Consignee Billing', 'Third Party Billing') THEN 'TP' WHEN freight_type  IN ('Prepaid-Billed', 'PREPAY AND ADD') THEN 'PA' WHEN freight_type = 'Prepaid' THEN 'PP' ELSE 'CC' END

FROM
		Shipper s
	JOIN
		dbo.edi_setups es ON s.destination = es.destination
	JOIN
		dbo.destination d ON es.destination = d.destination
	LEFT JOIN
		dbo.bill_of_lading bol ON s.bill_of_lading_number = bol_number
WHERE
	s.id in  (Select ShipperID from ExcludeShippers where cpCount != cp2Count) and
	es.asn_overlay_group = 'PLX'







GO
