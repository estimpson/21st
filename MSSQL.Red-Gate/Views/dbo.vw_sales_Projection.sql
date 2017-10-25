SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_sales_Projection]
AS
SELECT	order_header.order_no AS OrderID,
		order_detail.due_date AS CustomerRequestedShipDate,
		CONVERT(char(4), DATEPART(yyyy,order_detail.due_date))+'/'+CONVERT(char(1), DATEPART(qq,order_detail.due_date)) AS RequestedShipDateQtr,
		CONVERT(char(4), DATEPART(yyyy,order_detail.due_date)) +'/'+ CONVERT(char(2), DATEPART(mm,order_detail.due_date)) AS RequestedShipDateMonth,
		order_detail.promise_date AS PromisedShipDate,
		(CASE ISNULL(NULLIF(order_detail.type,''),'P') WHEN 'P' then 'Planning' WHEN 'F' THEN 'Firm' When 'O' THEN 'Forecast' ELSE 'NotClassified' END) AS OrderType,
		order_detail.part_number AS Part,
		part.name AS PartName,
		order_detail.customer_part AS CustomerPart,
		order_header.customer_po AS CustomerPurchaseOrder,
		part_inventory.standard_unit AS StandardUnit,
		order_detail.std_qty AS OrderQty,
		ISNULL(order_detail.alternate_price,0) AS OrderPrice,
		order_detail.std_qty*ISNULL(order_detail.alternate_price,0) AS ExtendedSalesProjection,
		ISNULL(part_standard.cost_cum,0) AS UnitStandardCost,
		order_detail.std_qty*ISNULL(part_standard.cost_cum,0) AS ExtendedStdCostProjection,
		order_header.salesman AS SalesPerson,
		salesrep.commission_type AS CommissionType,
		salesrep.commission_rate AS CommissionRate,
		customer.customer AS CustomerCode,
		customer.name AS CustomerName,
		customer.address_1 AS CustomerAddress1,
		customer.address_2 AS CustomerAddress2,
		customer.address_3 AS CustomerAddress3,
		customer.address_4 AS CustomerAddress4,
		customer.address_5 AS CustomerAddress5,
		customer.address_6 AS CustomerAddress6,
		destination.destination AS DestinationCode,
		destination.name AS DestinationName,
		destination.address_1 AS DestinationAddress1,
		Destination.address_2 AS DestinationAddress2,
		Destination.address_3 AS DestinationAddress3,
		Destination.address_4 AS DestinationAddress4,
		Destination.address_5 AS DestinationAddress5,
		Destination.address_6 AS DestinationAddress6
		
FROM	dbo.order_header
JOIN	dbo.order_detail ON dbo.order_header.order_no = dbo.order_detail.order_no	
LEFT JOIN	dbo.salesrep ON dbo.order_header.salesman = dbo.salesrep.salesrep	
JOIN	dbo.customer ON dbo.order_header.customer = dbo.customer.customer
JOIN	dbo.destination ON dbo.order_header.destination = dbo.destination.destination
JOIN	dbo.part ON dbo.order_detail.part_number = dbo.part.part
JOIN	dbo.part_standard ON dbo.part.part = dbo.part_standard.part
JOIN	dbo.part_inventory ON dbo.part.part = dbo.part_inventory.part
GO
