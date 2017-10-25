SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [custom].[ftsp_salesHistory] (@FromDate datetime, @ThroughDate datetime )
as

Begin

--Execute custom.ftsp_salesHistory '2012-05-01', '2012-05-23'

SELECT [ShipperID]
      ,[InvoiceNumber]
      ,[DateShipped]
      ,[ShippedDateQtr]
      ,[ShippedDateMonth]
      ,[ShipperStatus]
      ,[ShipperType]
      ,[Part]
      ,[PartName]
      ,[CustomerPart]
      ,[CustomerPurchaseOrder]
      ,[StandardUnit]
      ,[QuantityShipped]
      ,[Price]
      ,[ExtendedSales]
      ,[UnitStandardCost]
      ,[ExtendedStandardCost]
      ,[SalesPerson]
      ,[CommissionType]
      ,[CommissionRate]
      ,[CustomerCode]
      ,[CustomerName]
      ,[CustomerAddress1]
      ,[CustomerAddress2]
      ,[CustomerAddress3]
      ,[CustomerAddress4]
      ,[CustomerAddress5]
      ,[CustomerAddress6]
      ,[DestinationCode]
      ,[DestinationName]
      ,[DestinationAddress1]
      ,[DestinationAddress2]
      ,[DestinationAddress3]
      ,[DestinationAddress4]
      ,[DestinationAddress5]
      ,[DestinationAddress6]
  FROM [FIS_Empower_21st].[custom].[vw_sales_history]

Where DateShipped >= @FromDate and
	DateShipped <= dateadd(dd,1, ft.fn_TruncDate('dd', @ThroughDate))
End
GO
