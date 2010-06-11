USE [FIS_Empower_21st]
GO

/****** Object:  StoredProcedure [dbo].[FT_Report_CountReceiptsPerMonth]    Script Date: 06/11/2010 14:26:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FT_Report_CountReceiptsPerMonth]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FT_Report_CountReceiptsPerMonth]
GO

USE [FIS_Empower_21st]
GO

/****** Object:  StoredProcedure [dbo].[FT_Report_CountReceiptsPerMonth]    Script Date: 06/11/2010 14:26:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE	PROCEDURE [dbo].[FT_Report_CountReceiptsPerMonth] (@StartDate datetime, @EndDate datetime)

AS
BEGIN

-- dbo.FT_Report_CountReceiptsPerMonth '2010-05-01', '2010-05-31'

SELECT	MAX(1) AS Receipts,
		From_loc AS Vendor,
		Vendor.name AS VendorName,
		( CASE	WHEN ISNULL(NULLIF(shipper	, ''), '-1') = '-1' THEN  CONVERT(varchar(25), dbo.udf_Truncdate('d', date_stamp), 112) ELSE shipper END) AS PackSlip,
		convert(varchar(5),dbo.udf_datepart('YYYY', date_stamp)) + ' / '+ convert(varchar(5), dbo.udf_Truncdate('m', date_stamp)) AS MonthofReceipt 
From	audit_trail
JOIN	vendor ON audit_trail.from_loc = vendor.code
WHERE	date_stamp> = dbo.udf_Truncdate('d', @StartDate) AND 
		date_stamp< DATEADD(dd, 1, dbo.udf_Truncdate('d', @EndDate)) AND
		TYPE = 'R'
GROUP BY
		From_loc,
		vendor.name,
		( CASE	WHEN ISNULL(NULLIF(shipper	, ''), '-1') = '-1' THEN  CONVERT(varchar(25), dbo.udf_Truncdate('d', date_stamp), 112) ELSE shipper END),
		convert(varchar(5),dbo.udf_datepart('YYYY', date_stamp)) + ' / '+ convert(varchar(5), dbo.udf_Truncdate('m', date_stamp))
END 
		
GO


