SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--SELECT * FROM  [custom].[Label_FinishedGoodsData] where PartNumber = 'WA121905'
--SELECT  * FROM  [custom].[Label_FinishedGoodsData] where serial >=2764150
--select * from dbo.report_library rl
--select * from dbo.BartenderLabels bl
	
CREATE VIEW [custom].[Label_FinishedGoodsData]
AS
SELECT
	*
,	LabelDataCheckSum = BINARY_CHECKSUM(*)
FROM
	(	SELECT
		--	Fields on every label
			Serial = o.serial
		,	Quantity = CONVERT (INT, o.quantity)
		,	CompanyName = param.company_name
		,	CompanyAddress1 = param.address_1
		,	CompanyAddress2 = param.address_2
		,	CompanyAddress3 = param.address_3
		,	CompanyPhoneNumber = param.phone_number
		--	Fields on some labels (all need case statements)...
		,	CustomerPart = COALESCE(sd.customer_part, oh.customer_part, ohLast.customer_part, pcLast.customer_part, o.part)
		,	CustomerPO =  COALESCE(sd.customer_po, oh.customer_po, ohLast.customer_po)
		,	EngineeringLevel = COALESCE(oh.engineering_level, ohLast.engineering_level, ecn.engineering_level,'' )
		,	customerName = c.name
		,	DestinationName = d.name
		,	DestinationAddress1 = d.address_1
		,	DestinationAddress2 = d.address_2
		,	DestinationAddress3 = d.address_3
		,	SupplierCode = COALESCE(es.supplier_code, '')
		,	VendorName = COALESCE(atReceipt.vendorname, '')
		,	PartNumber = o.part
		,	PartName = p.name
		,	PartType =  CASE WHEN p.type = 'R' THEN 'RAW'  WHEN p.type = 'W' THEN 'WIP' WHEN p.type = 'F' THEN 'FIN' ELSE 'UNKOWN' END
		,	UnitOfMeasure =  o.unit_measure
		,	Location = o.location
		,	Lot =  COALESCE(NULLIF(o.lot,''), '')
		,	Operator =   o.operator
		,	MfgDate =  CONVERT(VARCHAR(10), COALESCE(atFirst.RowCreateDT, o.last_date) , 101)
		,	MfgTime = CONVERT(VARCHAR(5), COALESCE(atFirst.RowCreateDT, o.last_date), 108)

		/*	Removed because we don't validate label data and therefore don't need to restrict label data. */
		--,	CustomerPart = CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'IRWIN CUSTBTW', 'INFILTRATORB', 'INFILTRATORBTW1', 'INFILTRATORBTW2', 'InfiltraBoth', 'InfiltraWhite') THEN COALESCE(sd.customer_part, oh.customer_part, ohLast.customer_part, pcLast.customer_part, o.part) END
		--,	CustomerPO =  CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'IRWIN CUSTBTW', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite') THEN COALESCE(sd.customer_po, oh.customer_po, ohLast.customer_po) END 
		--,	EngineeringLevel = CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'IRWIN CUSTBTW', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite') THEN COALESCE(oh.engineering_level, ohLast.engineering_level, ecn.engineering_level,'' ) END
		--,	customerName = CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite') THEN c.name END
		--,	DestinationName = CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite') THEN d.name END
		--,	DestinationAddress1 = CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite') THEN d.address_1 END
		--,	DestinationAddress2 = CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite')THEN d.address_2 END
		--,	DestinationAddress3 = CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite') THEN d.address_3 END
		--,	SupplierCode = CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite') THEN COALESCE(es.supplier_code, '') END
		--,	VendorName = CASE WHEN rl.name IN ('RAWWIPFINBTW',  'SMART_LABEL') THEN COALESCE(atReceipt.vendorname, '') END
		--,	PartNumber =  CASE WHEN rl.name IN ('RAWWIPFINBTW',  'SMART_LABEL') THEN o.part END
		--,	PartName = CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'IRWIN CUSTBTW', 'RAWWIPFINBTW', 'INFILTRATORB', 'INFILTRATORBTW1', 'INFILTRATORBTW2', 'InfiltraBoth', 'InfiltraWhite') THEN p.name END
		--,	PartType =  CASE WHEN rl.name IN ('RAWWIPFINBTW',  'SMART_LABEL') THEN (CASE WHEN p.type = 'R' THEN 'RAW'  WHEN p.type = 'W' THEN 'WIP' WHEN p.type = 'F' THEN 'FIN' ELSE 'UNKOWN' END) END
		--,	UnitOfMeasure =  CASE WHEN rl.name IN ('RAWWIPFINBTW',  'SMART_LABEL') THEN o.unit_measure END  -- TODO: Check GM
		--,	Location = CASE WHEN rl.name IN ('RAWWIPFINBTW',  'SMART_LABEL') THEN o.location END
		--,	Lot =  CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'IRWIN CUSTBTW', 'INFILTRATORB', 'INFILTRATORBTW1', 'INFILTRATORBTW2','RAWWIPFINBTW', 'InfiltraBoth', 'InfiltraWhite') THEN COALESCE(NULLIF(o.lot,''), '') END
		--,	Operator =   CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'IRWIN CUSTBTW', 'RAWWIPFINBTW', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite')  THEN o.operator END
		--,	MfgDate =  CASE WHEN rl.name IN ('ALLSTEELBTW', 'CUSTBTW', 'SMART_LABEL', 'IRWIN CUSTBTW', 'RAWWIPFINBTW', 'INFILTRATORB', 'INFILTRATORBTW1', 'InfiltraBoth', 'InfiltraWhite')  THEN CONVERT(VARCHAR(10), COALESCE(atFirst.RowCreateDT, o.last_date) , 101)  END
		--,	MfgTime = CASE WHEN rl.name IN ('RAWWIPFINBTW', 'SMART_LABEL') THEN CONVERT(VARCHAR(5), COALESCE(atFirst.RowCreateDT, o.last_date), 108) END

		--	Make sure we printed the correct label format.
		,	BoxLabelFormat = COALESCE(odFirst.box_label, oh.box_label,  rl.name)
		-- Get number of Copies to print (can be passed to BT label)
		,	Copies = COALESCE(rl.copies, 1)
		,	TemplateToPrintRAW = CASE WHEN COALESCE(atLast.ReceiptIndicator ,0 ) = 1 OR P.Type = 'R' THEN 1 ELSE 0 END 
		,	TemplateToPrintWIPFIN = CASE WHEN COALESCE(atLast.ReceiptIndicator ,0 ) = 0 AND  P.Type != 'R' THEN 1 ELSE 0 END
		--,	LicensePlate = CASE WHEN rl.name IN ('GM_Part','AMAXLE2') THEN 'UN' + es.supplier_code + CONVERT(VARCHAR, o.serial) END
		--,	SerialCooper = CASE WHEN rl.name IN ('Cooper Part') THEN RIGHT(('000000000' + CONVERT(VARCHAR, o.serial)), 9) END
		--	FIAT Brazil specific
		--,	SerialFiat = CASE WHEN rl.name IN ('Fiat_Part') THEN RIGHT(CONVERT(VARCHAR, o.serial), 5) END
		--,	QuantityFiat = CASE WHEN rl.name IN ('Fiat_Part') THEN RIGHT(('00000' + CONVERT(VARCHAR, CONVERT(INT, o.quantity))), 5) END
		--,	MfgDateFiat = CASE WHEN rl.name IN ('Fiat_Part') THEN CONVERT(VARCHAR(10), COALESCE(atFirst.RowCreateDT, o.last_date), 103) END
		--,	GrossNetWeightKg = CASE WHEN rl.name IN ('Fiat_Part') THEN CONCAT(CONVERT(VARCHAR, CONVERT(NUMERIC(10,0),((o.weight + o.tare_weight) / 2.2))), ' / ', CONVERT(VARCHAR, CONVERT(NUMERIC(10,0), (o.weight / 2.2)))) END
		--,	JulianDate = CASE WHEN rl.name IN ('Fiat_Part') THEN CONCAT(RIGHT('000' + CONVERT(VARCHAR, DATEPART(dy, GETDATE())), 3), RIGHT(CONVERT(VARCHAR, DATEPART(yy, GETDATE())), 2)) END
		--,	MfgDateMM = case when rl.name in ('Ford_Part Container') then convert(varchar(6), o.coalesce(atFirst.RowCreateDT, o.last_date), 12) end
		--,	MfgDateMMM = CASE WHEN rl.name IN ('AMAXLE2','Ford_Part Container') THEN UPPER(REPLACE(CONVERT(VARCHAR, COALESCE(atFirst.RowCreateDT, o.last_date), 106), ' ', '')) END
		--,	MfgDateMMMWithoutYear = CASE WHEN rl.name IN ('GM_Part') THEN UPPER(REPLACE(CONVERT(VARCHAR(6), COALESCE(atFirst.RowCreateDT, o.last_date), 106), ' ', '')) END
		--,	MfgDateMMMYearOnly = CASE WHEN rl.name IN ('GM_Part') THEN YEAR(COALESCE(atFirst.RowCreateDT, o.last_date)) END
		--,	MfgDateMMMDashes = CASE WHEN rl.name IN ('APT_BOX') THEN UPPER(REPLACE(CONVERT(VARCHAR, COALESCE(atFirst.RowCreateDT, o.last_date), 106), ' ', '-')) END
		--,	DyOfYear = CASE WHEN rl.name IN ('TSMStorage') THEN DATEPART(dy, COALESCE(atFirst.RowCreateDT, o.last_date)) END
		--,	WeekOfYear = CASE WHEN rl.name IN ('TSMStorage') THEN DATEPART(ww, COALESCE(atFirst.RowCreateDT, o.last_date)) END
		--,	YearLastChar = CASE WHEN rl.name IN ('TSMStorage') THEN RIGHT(YEAR(COALESCE(atFirst.RowCreateDT, o.last_date)), 1) END
		--,	GrossWeight = CASE WHEN rl.name IN (/*'AMAXLE2',*/'Borg Part Label','Ford_Part Container') THEN CONVERT(NUMERIC(10,2), ROUND((o.weight + o.tare_weight),2)) END
		--,	GrossWeightKilograms = CASE WHEN rl.name IN ('GM_Part') THEN CONVERT(NUMERIC(10,0),((o.weight + o.tare_weight) / 2.2)) END
		--,	NetWeight = CASE WHEN rl.name IN ('Borg Part Label','NPG Part','MPTMuncie_Box') THEN CONVERT(NUMERIC(10,2), ROUND(o.weight,2)) END
		--,	TareWeight = case when rl.name in ('AMAXLE2') then o.tare_weight end
		--,	StagedObjects = CASE WHEN rl.name IN ('Borg Part Label') THEN s.staged_objs END
		--,	Origin = o.origin
		--,	PackageType = CASE WHEN rl.name IN ('GM_Part','Ford_Part Container') THEN o.package_type END
		--,	PartShortDescription = CASE WHEN rl.name IN ('Borg Part Label','CLBL','DCX_Part','GM_Part','TSMStorage','wip_noqty_bt') THEN p.name END
		--,	customer = oh.customer
		--,	DockCode =  CASE WHEN rl.name IN ('AMAXLE2','Borg Part Label','DCX_Part','Ford_Part Container','GM_Part','MITSUBISHI_RAN','NPG Part','MPTMuncie_Box','Fiat_Part') THEN oh.dock_code END
		--,	ZoneCode = CASE WHEN rl.name IN ('AMAXLE2','DCX_Part','Ford_Part Container','MPTMuncie_Box','Fiat_Part') THEN oh.zone_code END
		--,	LineFeedCode = CASE WHEN rl.name IN ('Ford_Part Container','MITSUBISHI_RAN') THEN oh.line_feed_code END
		--,	Line11 = CASE WHEN rl.name IN ('GM_Part') THEN oh.line11 END -- Material Handling Code
		--,	Line12 =CASE WHEN rl.name IN ('GM_Part') THEN oh.line12 END --Plant/Dock on GM Label
		--,	Line13 = oh.line13
		--,	Line14 = CASE WHEN rl.name IN ('GM_Part') THEN oh.line14 END
		--,	Line15 = CASE WHEN rl.name IN ('GM_Part') THEN oh.line15 END
		--,	Line16 = oh.line16
		--,	Line17 = CASE WHEN rl.name IN ('GM_Part') THEN oh.line17 END
		--,	Shipper = CASE WHEN rl.name IN ('Borg Part Label') THEN sd.shipper END
		--,	Destination = CASE WHEN rl.name IN ('XXX') THEN d.destination END
		--,	DestinationAddress4 = case when rl.name in ('AMAXLE2') then d.address_4 end 
		--,	ObjectKANBAN = CASE WHEN rl.name IN ('AMAXLE2') THEN COALESCE(o.kanban_number, '') END
		--,	ObjectCUSTBTWom5 = CASE WHEN rl.name IN ('AMAXLE2') THEN COALESCE(o.CUSTBTWom5, '') END
		--,	MitsuRAN = CASE WHEN rl.name IN ('MITSUBISHI_RAN') THEN COALESCE(o.CUSTBTWom1, '') END
		--,	ShipToID = CASE WHEN rl.name IN ('MITSUBISHI_RAN') THEN es.parent_destination END
		--,	RecArea = CASE WHEN rl.name IN ('MITSUBISHI_RAN') THEN s.shipping_dock END
		FROM
			dbo.object o
			OUTER APPLY 
				(	SELECT TOP 1
						*
					FROM
						dbo.order_header ohLast
					WHERE
						ohLast.blanket_part= o.part
						ORDER BY ohlast.order_no DESC
							 ) ohLast
			OUTER APPLY
				(	SELECT TOP 1
						pc.customer_part
					FROM
						dbo.part_customer pc
					WHERE
						pc.part = o.part
					ORDER BY
						pc.customer_part
				) pcLast
			LEFT JOIN dbo.shipper s
				JOIN dbo.shipper_detail sd
					ON sd.shipper = s.id
				ON s.id = COALESCE(o.shipper, CASE WHEN o.origin NOT LIKE '%[^0-9]%' AND LEN(o.origin) < 10 THEN CONVERT (INT, o.origin) END)
				AND sd.part_original = o.part
			LEFT JOIN dbo.order_header oh ON
				oh.order_no = COALESCE(sd.order_no, CASE WHEN o.origin NOT LIKE '%[^0-9]%' AND LEN(o.origin) < 10 THEN CONVERT(INT, o.origin) END)
				AND oh.blanket_part = o.part
			LEFT JOIN dbo.destination d ON
				d.destination = COALESCE(s.destination, oh.destination, ohLast.destination, o.destination)
			LEFT JOIN dbo.customer c ON
				c.customer = COALESCE(s.customer, oh.customer, ohlast.destination, o.customer)
			LEFT JOIN dbo.edi_setups es ON
				es.destination = COALESCE(s.destination, oh.destination, ohlast.destination, o.destination)
			JOIN dbo.part p ON
				p.part = o.part --AND p.type IN ('R','W', 'F')
			JOIN dbo.part_inventory [pi] ON
				[pi].part = p.part
			
			OUTER APPLY 
				(	SELECT TOP 1
						atFirst.serial
					,	atFirst.date_stamp  RowCreateDT
					FROM
						dbo.audit_trail atFirst
					WHERE
						atFirst.serial = o.serial AND
                        atFirst.type IN ('J', 'R', 'A')
						ORDER BY atFirst.date_stamp ASC
							 ) atFirst
				OUTER APPLY 
				(	SELECT TOP 1
						vendor.name VendorName
					FROM
						dbo.audit_trail atReceiptVendor
					JOIN
						dbo.vendor vendor ON vendor.code = atReceiptVendor.vendor
					WHERE
						atReceiptVendor.serial = o.serial AND
                        atReceiptVendor.type = 'R'
						ORDER BY atReceiptVendor.date_stamp DESC
							 )  atRECEIPT
				OUTER APPLY 
				(	SELECT TOP 1
						CASE WHEN atLast.type = 'R' THEN 1 ELSE 0 END AS ReceiptIndicator
					FROM
						dbo.audit_trail atlast
					WHERE
						atlast.serial = o.serial 
						ORDER BY atlast.date_stamp DESC
							 ) atLast

					OUTER APPLY
						(SELECT  TOP  1
							engineering_level , 
							part AS ecn_part 
							FROM 
								dbo.effective_change_notice ecl 
							 WHERE 
								ecl.part = o.part 
								ORDER BY ecl.effective_date DESC ) ecn
					OUTER APPLY
				(	SELECT TOP 1
						*
					FROM
						dbo.order_detail od
					WHERE
						od.part_number = o.part 
					ORDER BY
						od.due_date ASC
				) odFirst
			JOIN dbo.report_library rl ON
				rl.name = COALESCE( oh.box_label, odFirst.box_label, ohLast.box_label, pi.label_format)
			CROSS JOIN dbo.parameters param
	) rawLabelData







GO
