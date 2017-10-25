SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_ASN_Alert]

AS 

BEGIN

--Get Shipments From Prior Week
DECLARE @Shipments TABLE 
	(
	ShipperID VARCHAR(25),
	DateShipped DATETIME,
	Operator VARCHAR(50),
	Destination VARCHAR(25),
	TradingPartnerCode VARCHAR(25), PRIMARY KEY (ShipperID)
	)

DECLARE	@Date1 DATETIME,
		@Date2 DATETIME

SELECT	@Date1 = DATEADD(HOUR,-4, GETDATE())
SELECT	@Date2 = DATEADD(MINUTE,-30, GETDATE())

INSERT	@Shipments
	SELECT
		s.id,
		s.date_shipped,
		MAX(e.name),
		s.destination,
		es.trading_partner_code
	FROM 
		shipper s
	JOIN
		edi_setups es ON s.destination = es.destination
	JOIN
		shipper_detail sd ON s.id = sd.shipper
	LEFT JOIN
		employee e ON sd.operator = e.operator_code
	WHERE
		status in ('C', 'Z' ) AND 
		COALESCE(auto_create_asn,'N') = 'Y'AND
		s.date_shipped >= @Date1 AND  s.date_shipped <= @Date2 
		AND s.type is NULL
		
	GROUP BY
		s.id,
		s.date_shipped,
		s.destination,
		es.trading_partner_code
		



Select * From @shipments


	
DECLARE @Exceptions TABLE 
	(
	ShipperID INT,
	Destination VARCHAR(25),
	DateShipped DATETIME,
	Operator VARCHAR(25),
	TradingPartnerCode VARCHAR(25), 
	Notes VARCHAR(MAX), PRIMARY KEY (ShipperID)
	)

INSERT
	@Exceptions


SELECT
		CASE WHEN es.trading_partner_code LIKE '%Mazda%' THEN RIGHT((REPLICATE('0', 6) +CONVERT(VARCHAR(20), s.id)),6) ELSE CONVERT(VARCHAR(15),s.id) END,
		s.destination,
		s.date_shipped,
		MAX(e.name),		
		es.trading_partner_code,
		CASE WHEN sedi.FileStatus = 0 THEN 'ASN Sent but not Acknowledged by iConnect' WHEN sedi.FileStatus = -1 THEN 'Ship Notice Rejected by IConnect' WHEN sedi.FileStatus = -2 THEN 'Ship Notice Rejected by Customer' ELSE 'ASN Not Sent to iConnect' END
	FROM 
		dbo.Shipping_EDIDocuments sedi
	JOIN
		shipper s ON s.id = sedi.LegacyShipperID
	JOIN
		edi_setups es ON s.destination = es.destination
	JOIN
		shipper_detail sd ON s.id = sd.shipper
	LEFT JOIN
		employee e ON sd.operator = e.operator_code
	WHERE
		status IN ( 'Z', 'C') AND 
		s.date_shipped >= @Date1 AND  s.date_shipped <= @Date2  AND
		nullif(sedi.OverlayGroup,'') IS NOT NULL AND
        (ISNULL(sedi.FileStatus,0) < 0 or (ISNULL(sedi.FileStatus,0) = 0 and datediff(minute, s.date_shipped, getdate())>30)) AND
		legacyGenerator = 0
	GROUP BY
		s.id,
		s.date_shipped,
		s.destination,
		es.trading_partner_code,
		CASE WHEN sedi.FileStatus = 0 THEN 'ASN Sent but not Acknowledged by iConnect' WHEN sedi.FileStatus = -1 THEN 'Ship Notice Rejected by IConnect' WHEN sedi.FileStatus = -2 THEN 'Ship Notice Rejected by Customer' ELSE 'ASN Not Sent to iConnect' END


ORDER BY 5,1


Select * From @Exceptions

IF EXISTS (SELECT 1 FROM @Exceptions)

BEGIN

DECLARE @tableHTML  NVARCHAR(MAX) ;

SET @tableHTML =
    N'<H1>ASN Issue Alert</H1>' +
    N'<table border="1">' +
    N'<tr><th>TradingPartner</th>' +
    N'<th>Destination</th><th>ShipperID</th><th>DateShipped</th>' +
    N'<th>Notes</th></tr>' +
    CAST ( ( SELECT td = eo.TradingPartnerCode, '',
                    td = eo.Destination, '',
                    td = eo.ShipperID, '',
					td = eo.DateShipped, '',
                    td = eo.Notes
              FROM @Exceptions  eo
              ORDER BY 1,2,3  
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' +
	N'Note : For iConnect ASN issues, please log into iExchange WEB and correct the ASN from the draft folder if it exists'+
	N'if it does not exist, creat the ASN and send to the Trading Partner. If you need assistance, please contact iConnect to assist.';
    
EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBMail', -- sysname
    @recipients = 'tBursley@21stcpc.com', -- varchar(max)
    @copy_recipients = 'aboulanger@fore-thought.com', -- varchar(max)
    --@blind_copy_recipients = 'aboulanger@fore-thought.com;estimpson@fore-thought.com', -- varchar(max)
    @subject = N'ASN Issue Alert', -- nvarchar(255)
    @body = @TableHTML, -- nvarchar(max)
    @body_format = 'HTML', -- varchar(20)
    @importance = 'High' -- varchar(6)
    
 END
 
 END























GO
