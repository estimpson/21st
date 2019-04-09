SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [FT].[Custom_Pricing_UpdateIrwinPricing]
AS

BEGIN

--ASB FT, LLC 02/14/2019 : Created to update pricing in Fx from imported IRWIN Pricing 

---------------------------------------------------------------------------------------------------------------------------------------------------
/*

1a. Insert part where not exists and at least one base part exists that can used as "template"
1b Insert part customer rows that do not exist
2. Update existing part customer rows
3. Update blanket order price and order detail price
4. Update shipper detail for unprinted invoices and shippers on the dock

*/
-------------------------------------------------------------------------------------------------------------------------------------------------

--1. Insert Part

INSERT INTO [dbo].[part]
           ([part]
           ,[name]
           ,[cross_ref]
           ,[class]
           ,[type]  
           ,[quality_alert]
           ,[serial_type]
           ,[product_line]
           ,[gl_account_code]
		   ,description_short
           )

SELECT tip.part,
				TIP.PART,
				EP.cross_ref,
				EP.class,
				ep.type,
				EP.quality_alert ,
				EP.serial_type,
				ep.product_line,
				EP.gl_account_code,
				'IrwinPriceUpdate'

from 
	Temp_IRWIN_Pricing tip
		outer apply ( 
						SELECT TOP 1 
							P.*							 
						FROM PART p
						JOIN part_inventory piv on Piv.part = p.part and len(p.part)>3
						JOIN part_inventory pline on pline.part = p.part
						JOIN part_standard ps on ps.part = ps.part
						Where SUBSTRING(p.part, 1,(len(p.part)-3)) = SUBSTRING(tip.part, 1,(len(tip.part)-3))

					) as EP


where EffectiveDate < GETDATE() AND noT exists ( sELECT 1 FROM PART WHERE PART.PART = tip.PART)
and EP.part is not NULL


INSERT INTO [dbo].[part_inventory]
           ([part]
           ,[standard_pack]
           ,[unit_weight]
           ,[standard_unit]
           ,[primary_location]
           ,[label_format]
           ,[material_issue_type]
         )
     

	 SELECT tip.part,
				EP.standard_pack,
				EP.unit_weight,
				EP.standard_unit,
				ep.primary_location,
				EP.label_format ,
				EP.material_issue_type

from 
	Temp_IRWIN_Pricing tip
		outer apply ( 
						SELECT TOP 1 
							Piv.*							 
						FROM PART p
						JOIN part_inventory piv on Piv.part = p.part and len(p.part)>3
						JOIN part_inventory pline on pline.part = p.part
						JOIN part_standard ps on ps.part = ps.part
						Where SUBSTRING(p.part, 1,(len(p.part)-3)) = SUBSTRING(tip.part, 1,(len(tip.part)-3))

					) as EP
where EffectiveDate < GETDATE() AND noT exists ( sELECT 1 FROM PART_inventory WHERE dbo.part_inventory.PART = tip.PART)
and EP.part is not NULL

INSERT INTO [dbo].[part_online]
           ([part]
           ,[on_hand]
		   )

SELECT tip.part,
				0

from 
	Temp_IRWIN_Pricing tip
		outer apply ( 
						SELECT TOP 1 
							Piv.*							 
						FROM PART p
						JOIN part_inventory piv on Piv.part = p.part and len(p.part)>3
						JOIN part_inventory pline on pline.part = p.part
						JOIN part_standard ps on ps.part = ps.part
						Where SUBSTRING(p.part, 1,(len(p.part)-3)) = SUBSTRING(tip.part, 1,(len(tip.part)-3))

					) as EP
where EffectiveDate < GETDATE() AND noT exists ( sELECT 1 FROM PART_online WHERE PART_online.PART = tip.PART)
and EP.part is not NULL

INSERT INTO [dbo].[part_standard]
     
           ([part]
           
		   )

SELECT tip.part

from 
	Temp_IRWIN_Pricing tip
		outer apply ( 
						SELECT TOP 1 
							Piv.*							 
						FROM PART p
						JOIN part_inventory piv on Piv.part = p.part and len(p.part)>3
						JOIN part_inventory pline on pline.part = p.part
						JOIN part_standard ps on ps.part = ps.part
						Where SUBSTRING(p.part, 1,(len(p.part)-3)) = SUBSTRING(tip.part, 1,(len(tip.part)-3))

					) as EP
where EffectiveDate < GETDATE() AND noT exists ( sELECT 1 FROM PART_standard WHERE PART_standard.PART = tip.PART)
and EP.part is not NULL


--end 1

--2 Insert part customer

INSERT INTO [dbo].[part_customer]
           ([part]
           ,[customer]
           ,[customer_part]
           ,[customer_standard_pack]
           ,[customer_unit]
           ,[type]
           ,[blanket_price])

SELECT Tp.part,
			'IRWIN-GRAN',
			tp.Part,
			piv.standard_pack,
			'EA',
			'B',
			ROUND(tp.Price,3)
FROM
	dbo.Temp_IRWIN_Pricing TP
JOIN
	dbo.part_inventory piv ON piv.part= tp.part
CROSS APPLY ( SELECT TOP 1 * FROM dbo.Temp_IRWIN_Pricing tp2 WHERE tp2.Part =tp.part AND tp2.EffectiveDate<= GETDATE() AND tp.EffectiveDate = tp2.EffectiveDate ORDER BY tp2.EffectiveDate DESC) lastprice
WHERE NOT EXISTS ( SELECT 1 FROM dbo.part_customer pc WHERE pc.customer = 'IRWIN-GRAN' AND pc.part = tp.part)


--update part customer 
UPDATE pc
SET pc.blanket_price =  ROUND(lastprice.Price,3)
FROM
	part_customer pc
CROSS APPLY ( SELECT TOP 1 * FROM dbo.Temp_IRWIN_Pricing tp2 WHERE tp2.Part =pc.part AND tp2.EffectiveDate<= GETDATE() ORDER BY tp2.EffectiveDate DESC ) lastprice
WHERE pc.customer = 'IRWIN-GRAN'



--update order_header
UPDATE oh
SET		oh.price = ROUND(lastprice.Price,3)
		,	oh.alternate_price = ROUND(lastprice.price,3)
FROM
	order_header oh
CROSS APPLY ( SELECT TOP 1 * FROM dbo.Temp_IRWIN_Pricing tp2 WHERE tp2.Part =oh.blanket_part AND tp2.EffectiveDate<= GETDATE() ORDER BY tp2.EffectiveDate DESC ) lastprice
WHERE oh.customer = 'IRWIN-GRAN' AND ROUND(lastprice.price,3) != oh.alternate_price


--update order_detail

UPDATE od
SET od.price = ROUND(lastprice.Price,3),	
	od.alternate_price = ROUND(lastprice.Price,3)

FROM	
	order_detail od
CROSS APPLY ( SELECT TOP 1 * FROM dbo.Temp_IRWIN_Pricing tp2 WHERE tp2.Part =od.part_number AND tp2.EffectiveDate<= GETDATE() ORDER BY tp2.EffectiveDate DESC ) lastprice
WHERE EXISTS ( SELECT 1 FROM order_header WHERE order_header.order_no = od.order_no AND order_header.customer = 'IRWIN-GRAN')

--Update shipper_detail FOR SHIPPERS ON DOCK

UPDATE sd
SET sd.price = ROUND(lastprice.Price,3),	
	sd.alternate_price = ROUND(lastprice.Price,3)

FROM	
	dbo.shipper_detail sd
CROSS APPLY ( SELECT TOP 1 * FROM dbo.Temp_IRWIN_Pricing tp2 WHERE tp2.Part =sd.part_original AND tp2.EffectiveDate<= GETDATE() ORDER BY tp2.EffectiveDate DESC ) lastprice
WHERE EXISTS ( SELECT 1 FROM shipper WHERE shipper.id = sd.shipper AND shipper.customer = 'IRWIN-GRAN' AND shipper.date_shipped IS NULL AND shipper.TYPE IS NULL AND SHIPPER.STATUS IN ('O', 'S'))


--Update shipper_detail FOR Invocies not printed

UPDATE sd
SET sd.price = ROUND(lastprice.Price,3),	
	sd.alternate_price = ROUND(lastprice.Price,3)

FROM	
	dbo.shipper_detail sd
CROSS APPLY ( SELECT TOP 1 * FROM dbo.Temp_IRWIN_Pricing tp2 WHERE tp2.Part =sd.part_original AND tp2.EffectiveDate<= GETDATE() ORDER BY tp2.EffectiveDate DESC ) lastprice
WHERE EXISTS ( SELECT 1 FROM shipper WHERE shipper.id = sd.shipper AND shipper.customer = 'IRWIN-GRAN' AND shipper.date_shipped >= lastprice.EffectiveDate AND shipper.TYPE IS NULL AND SHIPPER.STATUS IN ('C', 'Z') AND invoice_printed ='N')
	


END
GO
