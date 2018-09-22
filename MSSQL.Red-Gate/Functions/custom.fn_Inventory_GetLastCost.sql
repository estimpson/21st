SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [custom].[fn_Inventory_GetLastCost]
(	@Part VARCHAR(25)
)
RETURNS NUMERIC(20,6)
AS
BEGIN
--- <Body>
/*	Return the net weight of a quantity of a part. */
	DECLARE
		@LastCost NUMERIC(20,6)
	
	SET @LastCost = COALESCE(

	(SELECT LastInvoice.price FROM 
		dbo.part_inventory p
		JOIN dbo.part pt ON pt.part = p.part AND pt.type = 'R'
		OUTER APPLY ( SELECT TOP 1 ap.price 
		FROM 
		ap_items ap
		JOIN
		ap_headers ah ON ah.vendor = ap.vendor AND
		ah.inv_cm_flag = ap.inv_cm_flag AND
		ah.invoice_cm = ap.invoice_cm
		WHERE ap.item = p.part AND p.part = @Part
		ORDER BY ah.gl_date DESC ) 		LastInvoice
		WHERE p.part =  @part ),
	
	(SELECT	TOP 1 cost
			FROM
				dbo.audit_trail at
				JOIN part p ON p.part = at.part AND p.type = 'R'
			WHERE
				at.part = @Part
			AND	 at.type = 'R'
			AND	date_stamp = (SELECT 
									MAX(date_stamp) 
								FROM
									audit_trail at2
								WHERE
									at2.part = @part 
								AND	at2.type ='R')),

		(SELECT TOP 1 LastShippedPrice.alternate_price
		FROM dbo.part p
		OUTER APPLY 
			( Select top 1 * from shipper_detail where shipper_detail.part_original = p.part and date_shipped is not NULL order by date_shipped desc) as LastShippedPrice
		WHERE p.type = 'F'
		AND		p.part= @Part	)	
								
								
								
								
								
								
								
								
								
								,0)
	
--- </Body>

---	<Return>
	RETURN
		@LastCost
END


		



GO
